/**
 * Answer Questions Extension
 *
 * Two modes:
 * 1. Tool mode: LLM calls the qna tool with questions, user answers one by one
 * 2. Command mode: User runs /qna to extract questions from last assistant message
 *    using a cheaper model, then uses the same one-by-one UI
 */

import { complete, type Model, type Api, type UserMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { BorderedLoader } from "@mariozechner/pi-coding-agent";
import { Editor, type EditorTheme, Key, matchesKey, Text, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import type { Tui, Theme } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";

const EXTRACTION_SYSTEM_PROMPT = `You are a question extractor. Given text from a conversation, extract any questions that need answering.

Output format:
- Output ONLY the questions, one per line
- Do not include numbering, prefixes like "Q:", or any other formatting
- If no questions are found, output exactly: NO_QUESTIONS_FOUND
- When there is important context needed to answer a question, include it in parentheses after the question

Example input:
"I have a few questions: What database do you prefer? We support MySQL and PostgreSQL. Also, should we use TypeScript?"

Example output:
What database do you prefer? (We support MySQL and PostgreSQL)
Should we use TypeScript?

Keep questions in the order they appeared. Be concise.`;

// Cheaper models for extraction by provider
const CHEAP_MODELS: Record<string, string> = {
  anthropic: "claude-haiku-4-5",
  "github-copilot": "claude-haiku-4.5",
  openai: "gpt-4o-mini",
};

/**
 * Select a cost-efficient model for extraction.
 */
async function selectExtractionModel(
  currentModel: Model<Api>,
  modelRegistry: {
    find: (provider: string, modelId: string) => Model<Api> | undefined;
    getApiKey: (model: Model<Api>) => Promise<string | undefined>;
  }
): Promise<Model<Api>> {
  const cheapModelId = CHEAP_MODELS[currentModel.provider];
  if (!cheapModelId) {
    return currentModel;
  }

  // Don't switch if already using a cheap model
  const currentId = currentModel.id.toLowerCase();
  if (currentId.includes("haiku") || currentId.includes("mini") || currentId.includes("flash")) {
    return currentModel;
  }

  const cheapModel = modelRegistry.find(currentModel.provider, cheapModelId);
  if (!cheapModel) {
    return currentModel;
  }

  const apiKey = await modelRegistry.getApiKey(cheapModel);
  if (!apiKey) {
    return currentModel;
  }

  return cheapModel;
}

// Simple word-wrap implementation
function wrapText(text: string, maxWidth: number): string[] {
  const words = text.split(/\s+/);
  const lines: string[] = [];
  let currentLine = "";

  for (const word of words) {
    const testLine = currentLine ? `${currentLine} ${word}` : word;
    if (visibleWidth(testLine) <= maxWidth) {
      currentLine = testLine;
    } else {
      if (currentLine) lines.push(currentLine);
      currentLine = word;
    }
  }
  if (currentLine) lines.push(currentLine);
  return lines.length > 0 ? lines : [""];
}

interface QuestionAnswer {
  question: string;
  answer: string;
}

interface CollectAnswersResult {
  questions: string[];
  answers: QuestionAnswer[];
  cancelled: boolean;
  cancelledAtIndex: number;
}

/**
 * Show interactive UI to collect answers to questions one by one.
 */
async function collectAnswersUI(
  questions: string[],
  ui: ExtensionContext["ui"]
): Promise<CollectAnswersResult> {
  return ui.custom<CollectAnswersResult>((tui: Tui, theme: Theme, _kb, done) => {
    let currentIndex = 0;
    const answers: QuestionAnswer[] = [];
    let cachedLines: string[] | undefined;

    const editorTheme: EditorTheme = {
      borderColor: (s) => theme.fg("accent", s),
      selectList: {
        selectedPrefix: (t) => theme.fg("accent", t),
        selectedText: (t) => theme.fg("accent", t),
        description: (t) => theme.fg("muted", t),
        scrollInfo: (t) => theme.fg("dim", t),
        noMatch: (t) => theme.fg("warning", t),
      },
    };
    const editor = new Editor(tui, editorTheme);

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    editor.onSubmit = (value) => {
      const trimmed = value.trim() || "(no answer)";
      answers.push({
        question: questions[currentIndex],
        answer: trimmed,
      });

      currentIndex++;
      editor.setText("");

      if (currentIndex >= questions.length) {
        done({ questions, answers, cancelled: false, cancelledAtIndex: -1 });
      } else {
        refresh();
      }
    };

    function handleInput(data: string) {
      if (matchesKey(data, Key.escape)) {
        done({ questions, answers, cancelled: true, cancelledAtIndex: currentIndex });
        return;
      }
      editor.handleInput(data);
      refresh();
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;

      const lines: string[] = [];
      const add = (s: string) => lines.push(truncateToWidth(s, width));

      add(theme.fg("accent", "─".repeat(width)));
      add(theme.fg("muted", ` Question ${currentIndex + 1} of ${questions.length}`));
      lines.push("");

      if (answers.length > 0) {
        add(theme.fg("dim", " Previous answers:"));
        for (const qa of answers) {
          add(theme.fg("dim", `   • ${truncateToWidth(qa.answer, width - 10)}`));
        }
        lines.push("");
      }

      const questionText = questions[currentIndex];
      const wrappedQuestion = wrapText(questionText, width - 2);
      for (const line of wrappedQuestion) {
        add(theme.fg("text", theme.bold(` ${line}`)));
      }
      lines.push("");

      add(theme.fg("muted", " Your answer:"));
      for (const line of editor.render(width - 2)) {
        add(` ${line}`);
      }

      lines.push("");
      add(theme.fg("dim", " Enter to submit answer • Esc to cancel all"));
      add(theme.fg("accent", "─".repeat(width)));

      cachedLines = lines;
      return lines;
    }

    return {
      render,
      invalidate: () => {
        cachedLines = undefined;
      },
      handleInput,
    };
  });
}

/**
 * Format the Q&A result for display/return to LLM.
 */
function formatResult(result: CollectAnswersResult): { text: string; cancelled: boolean } {
  if (result.cancelled) {
    const lines: string[] = ["User cancelled. Questions were:"];
    for (let i = 0; i < result.questions.length; i++) {
      const answered = result.answers.find((a) => a.question === result.questions[i]);
      lines.push(`Q${i + 1}: ${result.questions[i]}`);
      lines.push(`A${i + 1}: ${answered ? answered.answer : "(not answered)"}`);
    }
    return { text: lines.join("\n"), cancelled: true };
  }

  const formatted = result.answers
    .map((qa, i) => `Q${i + 1}: ${qa.question}\nA${i + 1}: ${qa.answer}`)
    .join("\n\n");
  return { text: formatted, cancelled: false };
}

const AnswerQuestionsParams = Type.Object({
  questions: Type.Array(Type.String(), {
    description: "List of questions to ask the user, one at a time",
  }),
});

export default function qna(pi: ExtensionAPI) {
  // Tool: LLM calls this with questions
  pi.registerTool({
    name: "qna",
    label: "Q&A",
    description:
      "Ask the user a series of questions one at a time. Each question is answered individually before moving to the next. Use this when you have multiple clarifying questions and want to collect all answers before proceeding.",
    parameters: AnswerQuestionsParams,

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [{ type: "text", text: "Error: UI not available (running in non-interactive mode)" }],
          details: { questions: [], answers: [], cancelled: true, cancelledAtIndex: -1 },
        };
      }

      if (params.questions.length === 0) {
        return {
          content: [{ type: "text", text: "Error: No questions provided" }],
          details: { questions: [], answers: [], cancelled: true, cancelledAtIndex: -1 },
        };
      }

      const result = await collectAnswersUI(params.questions, ctx.ui);
      const formatted = formatResult(result);

      return {
        content: [{ type: "text", text: formatted.text }],
        details: result,
      };
    },

    renderCall(args, theme) {
      const qs = (args.questions as string[]) || [];
      let text = theme.fg("toolTitle", theme.bold("qna "));
      text += theme.fg("muted", `${qs.length} question${qs.length !== 1 ? "s" : ""}`);
      return new Text(text, 0, 0);
    },

    renderResult(result, _options, theme) {
      const details = result.details as CollectAnswersResult | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "", 0, 0);
      }

      if (details.cancelled) {
        return new Text(theme.fg("warning", "Cancelled"), 0, 0);
      }

      const lines = details.answers.map(
        (qa) => `${theme.fg("success", "✓ ")}${theme.fg("muted", truncateToWidth(qa.question, 40))} → ${qa.answer}`
      );
      return new Text(lines.join("\n"), 0, 0);
    },
  });

  // Command handler for extracting questions from last assistant message
  const extractQuestionsHandler = async (ctx: ExtensionContext) => {
    if (!ctx.hasUI) {
      ctx.ui.notify("qna requires interactive mode", "error");
      return;
    }

    if (!ctx.model) {
      ctx.ui.notify("No model selected", "error");
      return;
    }

    // Find the last assistant message on the current branch
    const branch = ctx.sessionManager.getBranch();
    let lastAssistantText: string | undefined;

    for (let i = branch.length - 1; i >= 0; i--) {
      const entry = branch[i];
      if (entry.type === "message") {
        const msg = entry.message;
        if ("role" in msg && msg.role === "assistant") {
          if (msg.stopReason !== "stop") {
            ctx.ui.notify(`Last assistant message incomplete (${msg.stopReason})`, "error");
            return;
          }
          const textParts = msg.content
            .filter((c): c is { type: "text"; text: string } => c.type === "text")
            .map((c) => c.text);
          if (textParts.length > 0) {
            lastAssistantText = textParts.join("\n");
            break;
          }
        }
      }
    }

    if (!lastAssistantText) {
      ctx.ui.notify("No assistant messages found", "error");
      return;
    }

    // Select the best model for extraction (prefer cheaper models)
    const extractionModel = await selectExtractionModel(ctx.model, ctx.modelRegistry);

    // Run extraction with loader UI
    const extractedText = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
      const loader = new BorderedLoader(tui, theme, `Extracting questions using ${extractionModel.id}...`);
      loader.onAbort = () => done(null);

      const doExtract = async () => {
        const apiKey = await ctx.modelRegistry.getApiKey(extractionModel);
        const userMessage: UserMessage = {
          role: "user",
          content: [{ type: "text", text: lastAssistantText! }],
          timestamp: Date.now(),
        };

        const response = await complete(
          extractionModel,
          { systemPrompt: EXTRACTION_SYSTEM_PROMPT, messages: [userMessage] },
          { apiKey, signal: loader.signal }
        );

        if (response.stopReason === "aborted") {
          return null;
        }

        return response.content
          .filter((c): c is { type: "text"; text: string } => c.type === "text")
          .map((c) => c.text)
          .join("\n");
      };

      doExtract()
        .then(done)
        .catch(() => done(null));

      return loader;
    });

    if (extractedText === null) {
      ctx.ui.notify("Cancelled", "info");
      return;
    }

    // Check if no questions were found
    if (extractedText.trim() === "NO_QUESTIONS_FOUND") {
      ctx.ui.notify("No questions found in the last message", "info");
      return;
    }

    // Parse questions (one per line, filter empty lines)
    const questions = extractedText
      .split("\n")
      .map((line) => line.trim())
      .filter((line) => line.length > 0);

    if (questions.length === 0) {
      ctx.ui.notify("No questions found in the last message", "info");
      return;
    }

    // Use the same interactive UI to collect answers
    const result = await collectAnswersUI(questions, ctx.ui);
    const formatted = formatResult(result);

    if (result.cancelled) {
      ctx.ui.notify("Cancelled", "info");
      return;
    }

    // Send the answers directly to the conversation
    pi.sendUserMessage(formatted.text);
  };

  pi.registerCommand("qna", {
    description: "Extract questions from last assistant message and answer them",
    handler: (_args, ctx) => extractQuestionsHandler(ctx),
  });

  pi.registerShortcut("ctrl+q", {
    description: "Extract questions and answer them",
    handler: extractQuestionsHandler,
  });
}
