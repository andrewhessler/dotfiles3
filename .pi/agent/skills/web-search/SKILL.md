---
name: web-search
description: Search the web using Brave Search API. Use when you need to find current information, documentation, facts, news, or any web content. Can also extract full page content from URLs.
---

# Web Search

Search the web and extract content using the Brave Search API.

## Setup (First Time Only)

1. Set your Brave Search API key:
```bash
export BRAVE_API_KEY="your-api-key-here"
```

Or add to your shell profile (~/.zshrc or ~/.bashrc):
```bash
echo 'export BRAVE_API_KEY="your-api-key-here"' >> ~/.zshrc
```

2. Install dependencies:
```bash
cd ~/.pi/agent/skills/web-search && npm install
```

## Usage

### Search the Web

```bash
cd ~/.pi/agent/skills/web-search && ./scripts/search.js "your search query"
```

Options:
- `--count <n>` - Number of results (default: 5, max: 20)
- `--content` - Also fetch content from top results

Examples:
```bash
./scripts/search.js "typescript generics tutorial"
./scripts/search.js "latest node.js release" --count 3
./scripts/search.js "react hooks best practices" --content
```

### Extract Page Content

Fetch and extract readable text from a URL:

```bash
cd ~/.pi/agent/skills/web-search && ./scripts/content.js "https://example.com/article"
```

## Output Format

Search results include:
- Title
- URL
- Description snippet

With `--content` flag, also includes extracted page text (truncated to ~4000 chars per page).

## Troubleshooting

- **401 Unauthorized**: Check your BRAVE_API_KEY is set correctly
- **429 Too Many Requests**: You've hit the rate limit (2,000/month on free tier)
- **Content extraction fails**: Some sites block automated access; try a different source
