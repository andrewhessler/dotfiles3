/**
 * Answer Questions Extension
 *
 * When the LLM asks a list of questions, lets you answer each one
 * individually by pressing Enter after each answer. Collects all
 * answers before continuing.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Editor, type EditorTheme, Key, matchesKey, Text, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";

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

const AnswerQuestionsParams = Type.Object({
  questions: Type.Array(Type.String(), {
    description: "List of questions to ask the user, one at a time",
  }),
});

export default function qna(pi: ExtensionAPI) {
  pi.registerTool({
    name: "qna",
    label: "Q&A",
    description:
      "Ask the user a series of questions one at a time. Each question is answered individually before moving to the next. Use this when you have multiple clarifying questions and want to collect all answers before proceeding.",
    parameters: AnswerQuestionsParams,

    async execute(_toolCallId, params, _onUpdate, ctx, _signal) {
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

      const questions = params.questions;

      const result = await ctx.ui.custom<CollectAnswersResult>((tui, theme, _kb, done) => {
        let currentIndex = 0;
        const answers: QuestionAnswer[] = [];
        let cachedLines: string[] | undefined;

        // Editor for typing answers
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

        // Submit current answer and move to next question
        editor.onSubmit = (value) => {
          const trimmed = value.trim() || "(no answer)";
          answers.push({
            question: questions[currentIndex],
            answer: trimmed,
          });

          currentIndex++;
          editor.setText("");

          if (currentIndex >= questions.length) {
            // All questions answered
            done({ questions, answers, cancelled: false, cancelledAtIndex: -1 });
          } else {
            refresh();
          }
        };

        function handleInput(data: string) {
          // Escape cancels the whole thing
          if (matchesKey(data, Key.escape)) {
            done({ questions, answers, cancelled: true, cancelledAtIndex: currentIndex });
            return;
          }

          // Route everything else to editor
          editor.handleInput(data);
          refresh();
        }

        function render(width: number): string[] {
          if (cachedLines) return cachedLines;

          const lines: string[] = [];
          const add = (s: string) => lines.push(truncateToWidth(s, width));

          add(theme.fg("accent", "─".repeat(width)));

          // Progress indicator
          add(
            theme.fg("muted", ` Question ${currentIndex + 1} of ${questions.length}`)
          );
          lines.push("");

          // Show previous answers (collapsed)
          if (answers.length > 0) {
            add(theme.fg("dim", " Previous answers:"));
            for (const qa of answers) {
              add(theme.fg("dim", `   • ${truncateToWidth(qa.answer, width - 10)}`));
            }
            lines.push("");
          }

          // Current question - wrap long text
          const questionText = questions[currentIndex];
          const wrappedQuestion = wrapText(questionText, width - 2);
          for (const line of wrappedQuestion) {
            add(theme.fg("text", theme.bold(` ${line}`)));
          }
          lines.push("");

          // Editor
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

      if (result.cancelled) {
        // Show all questions and any answers collected before cancellation
        const lines: string[] = ["User cancelled. Questions were:"];
        for (let i = 0; i < questions.length; i++) {
          const answered = result.answers.find(a => a.question === questions[i]);
          if (answered) {
            lines.push(`Q${i + 1}: ${questions[i]}`);
            lines.push(`A${i + 1}: ${answered.answer}`);
          } else {
            lines.push(`Q${i + 1}: ${questions[i]}`);
            lines.push(`A${i + 1}: (not answered)`);
          }
        }
        return {
          content: [{ type: "text", text: lines.join("\n") }],
          details: result,
        };
      }

      // Format answers for LLM
      const formatted = result.answers
        .map((qa, i) => `Q${i + 1}: ${qa.question}\nA${i + 1}: ${qa.answer}`)
        .join("\n\n");

      return {
        content: [{ type: "text", text: formatted }],
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
}
