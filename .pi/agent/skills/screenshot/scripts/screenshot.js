#!/usr/bin/env node

/**
 * Screenshot tool - capture URLs or displays
 * 
 * Usage:
 *   ./screenshot.js --url <url> [output-path]
 *   ./screenshot.js --display <1|2> [output-path]
 * 
 * Output is compressed JPEG to reduce file size for AI model consumption.
 */

import puppeteer from 'puppeteer';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';
import { unlinkSync, existsSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const DEFAULT_OUTPUT = resolve(__dirname, '..', 'screenshot.jpg');

function printUsage() {
  console.error('Usage:');
  console.error('  screenshot.js --url <url> [output-path]');
  console.error('  screenshot.js --display <1|2> [output-path]');
  console.error('');
  console.error('Examples:');
  console.error('  screenshot.js --url http://localhost:3000');
  console.error('  screenshot.js --display 1 ~/Desktop/screen.jpg');
  process.exit(1);
}

function parseArgs() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) printUsage();
  
  const mode = args[0];
  
  if (mode === '--url') {
    if (!args[1]) {
      console.error('Error: URL required');
      printUsage();
    }
    return {
      mode: 'url',
      url: args[1],
      output: args[2] || DEFAULT_OUTPUT
    };
  }
  
  if (mode === '--display') {
    const display = parseInt(args[1], 10);
    if (isNaN(display) || display < 1) {
      console.error('Error: Display must be a positive number (1 = main, 2 = secondary)');
      printUsage();
    }
    return {
      mode: 'display',
      display,
      output: args[2] || DEFAULT_OUTPUT
    };
  }
  
  console.error(`Error: Unknown mode "${mode}"`);
  printUsage();
}

async function screenshotUrl(url, outputPath) {
  console.log(`Capturing screenshot of: ${url}`);
  
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    const page = await browser.newPage();
    
    // Set viewport - standard quality for smaller file size
    await page.setViewport({
      width: 1280,
      height: 800,
      deviceScaleFactor: 1
    });
    
    // Navigate to the URL
    await page.goto(url, {
      waitUntil: 'networkidle2',
      timeout: 30000
    });
    
    // Wait for animations to settle
    await new Promise(r => setTimeout(r, 1000));
    
    // Take screenshot with compression
    const resolvedPath = resolve(outputPath);
    const isJpeg = resolvedPath.endsWith('.jpg') || resolvedPath.endsWith('.jpeg');
    
    await page.screenshot({
      path: resolvedPath,
      fullPage: false,
      type: isJpeg ? 'jpeg' : 'png',
      quality: isJpeg ? 70 : undefined
    });
    
    console.log(`Screenshot saved to: ${resolvedPath}`);
    
  } finally {
    await browser.close();
  }
}

function screenshotDisplay(display, outputPath) {
  console.log(`Capturing screenshot of display ${display}...`);
  
  const resolvedPath = resolve(outputPath);
  const tempPath = `/tmp/pi_screenshot_${process.pid}.png`;
  
  try {
    // Capture the specified display
    execSync(`screencapture -x -D ${display} "${tempPath}"`, { stdio: 'pipe' });
    
    if (!existsSync(tempPath)) {
      console.error('Screenshot capture failed.');
      process.exit(1);
    }
    
    // Compress and resize using sips
    const isJpeg = resolvedPath.endsWith('.jpg') || resolvedPath.endsWith('.jpeg');
    
    if (isJpeg) {
      execSync(`sips --resampleWidth 1280 "${tempPath}" --out "${resolvedPath}" -s format jpeg -s formatOptions 70`, { stdio: 'pipe' });
    } else {
      execSync(`sips --resampleWidth 1280 "${tempPath}" --out "${resolvedPath}"`, { stdio: 'pipe' });
    }
    
    // Get file size for output
    const stat = execSync(`du -h "${resolvedPath}"`).toString().split('\t')[0].trim();
    console.log(`Screenshot saved to: ${resolvedPath} (${stat})`);
    
  } finally {
    // Clean up temp file
    if (existsSync(tempPath)) {
      unlinkSync(tempPath);
    }
  }
}

async function main() {
  const config = parseArgs();
  
  if (config.mode === 'url') {
    await screenshotUrl(config.url, config.output);
  } else if (config.mode === 'display') {
    screenshotDisplay(config.display, config.output);
  }
}

main().catch(err => {
  console.error('Screenshot failed:', err.message);
  process.exit(1);
});
