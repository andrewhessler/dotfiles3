#!/usr/bin/env node

import { tmpdir } from "node:os";
import { join } from "node:path";
import { writeFileSync, unlinkSync, existsSync } from "node:fs";
import { execSync } from "node:child_process";
import { connect } from "./cdp.js";

const DEBUG = process.env.DEBUG === "1";
const log = DEBUG ? (...args) => console.error("[debug]", ...args) : () => {};

// Global timeout
const globalTimeout = setTimeout(() => {
  console.error("✗ Global timeout exceeded (15s)");
  process.exit(1);
}, 15000);

try {
  log("connecting...");
  const cdp = await connect(5000);

  log("getting pages...");
  const pages = await cdp.getPages();
  const page = pages.at(-1);

  if (!page) {
    console.error("✗ No active tab found");
    process.exit(1);
  }

  log("attaching to page...");
  const sessionId = await cdp.attachToPage(page.targetId);

  log("taking screenshot...");
  const data = await cdp.screenshot(sessionId);

  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const tempPng = join(tmpdir(), `screenshot-${timestamp}-temp.png`);
  const filename = `screenshot-${timestamp}.jpg`;
  const filepath = join(tmpdir(), filename);

  // Write raw PNG first
  writeFileSync(tempPng, data);

  // Compress: resize to 1280px width and convert to JPEG with 70% quality
  log("compressing...");
  try {
    execSync(`sips --resampleWidth 1280 "${tempPng}" --out "${filepath}" -s format jpeg -s formatOptions 70`, { stdio: 'pipe' });
  } catch (e) {
    // If sips fails (non-macOS), just use the PNG
    log("sips not available, using uncompressed PNG");
    writeFileSync(filepath.replace('.jpg', '.png'), data);
    console.log(filepath.replace('.jpg', '.png'));
    cdp.close();
    process.exit(0);
  }

  // Clean up temp PNG
  if (existsSync(tempPng)) {
    unlinkSync(tempPng);
  }

  console.log(filepath);

  log("closing...");
  cdp.close();
  log("done");
} catch (e) {
  console.error("✗", e.message);
  process.exit(1);
} finally {
  clearTimeout(globalTimeout);
  setTimeout(() => process.exit(0), 100);
}
