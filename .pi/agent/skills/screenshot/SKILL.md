---
name: screenshot
description: Take screenshots of URLs or displays. Use --url for web pages or --display for capturing a specific monitor (1 = main, 2 = secondary).
---

# Screenshot

Capture screenshots of web pages or displays for visual inspection and debugging.

## Usage

```bash
cd ~/.pi/agent/skills/screenshot && ./scripts/screenshot.js <mode> [output-path]
```

### Screenshot a URL (Puppeteer)

Best for: Capturing any URL with consistent viewport and timing.

```bash
./scripts/screenshot.js --url http://localhost:3000
./scripts/screenshot.js --url https://example.com ~/Desktop/example.jpg
```

### Screenshot a Display (macOS)

Best for: Capturing the current state of a monitor.

```bash
./scripts/screenshot.js --display 1              # Main display
./scripts/screenshot.js --display 2 ./screen.jpg # Secondary display
```

Display numbers match macOS conventions: 1 = main display, 2 = secondary, etc.

## Setup (First Time Only)

```bash
cd ~/.pi/agent/skills/screenshot && npm install
```

## Output

Screenshots are saved as compressed JPEG files (~100-300KB). Default location: `~/.pi/agent/skills/screenshot/screenshot.jpg`

After capturing, use the `read` tool to view the image:
```bash
read ~/.pi/agent/skills/screenshot/screenshot.jpg
```

## Troubleshooting

- **Puppeteer not installed**: Run `npm install` in the skill directory
- **Permission denied (macOS)**: Grant Terminal/IDE screen recording permission in System Preferences > Privacy > Screen Recording
