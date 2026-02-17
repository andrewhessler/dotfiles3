---
name: latest-screenshot
description: Pull the most recent screenshot from the Desktop. Use when the user says things like "pull the latest screenshot", "grab my last screenshot", "look at my recent screenshot", etc.
---

# Latest Screenshot

Finds and displays the most recent macOS screenshot from the Desktop.

## Usage

1. Find the most recent screenshot:
```bash
ls -t ~/Desktop/Screenshot*.png 2>/dev/null | head -1
```

2. Use the `read` tool to display it:
```
read <path from step 1>
```

If no screenshots are found, let the user know their Desktop has no screenshot files.
