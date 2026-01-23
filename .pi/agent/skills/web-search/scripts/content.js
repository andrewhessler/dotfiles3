#!/usr/bin/env node

/**
 * Extract readable content from a URL
 * 
 * Usage:
 *   ./content.js "https://example.com/article"
 * 
 * Uses a simple approach with fetch + HTML parsing.
 * For better results on complex pages, consider adding @mozilla/readability.
 */

import fetch from 'node-fetch';

const MAX_CONTENT_LENGTH = 8000;
const TIMEOUT_MS = 10000;

function printUsage() {
  console.error('Usage: content.js <url>');
  console.error('');
  console.error('Extracts readable text content from a URL.');
  process.exit(1);
}

function stripHtml(html) {
  // Remove script and style elements entirely
  html = html.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ' ');
  html = html.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, ' ');
  html = html.replace(/<noscript\b[^<]*(?:(?!<\/noscript>)<[^<]*)*<\/noscript>/gi, ' ');
  
  // Remove HTML comments
  html = html.replace(/<!--[\s\S]*?-->/g, ' ');
  
  // Remove all HTML tags
  html = html.replace(/<[^>]+>/g, ' ');
  
  // Decode common HTML entities
  html = html.replace(/&nbsp;/g, ' ');
  html = html.replace(/&amp;/g, '&');
  html = html.replace(/&lt;/g, '<');
  html = html.replace(/&gt;/g, '>');
  html = html.replace(/&quot;/g, '"');
  html = html.replace(/&#39;/g, "'");
  html = html.replace(/&mdash;/g, '—');
  html = html.replace(/&ndash;/g, '–');
  html = html.replace(/&hellip;/g, '...');
  
  // Normalize whitespace
  html = html.replace(/\s+/g, ' ');
  
  // Split into lines and filter out very short ones (likely nav items, etc.)
  const lines = html.split(/[.!?]\s+/)
    .map(line => line.trim())
    .filter(line => line.length > 40); // Only keep substantial sentences
  
  return lines.join('. ').trim();
}

function extractMainContent(html) {
  // Try to find main content areas
  const mainPatterns = [
    /<main[^>]*>([\s\S]*?)<\/main>/i,
    /<article[^>]*>([\s\S]*?)<\/article>/i,
    /<div[^>]*class="[^"]*content[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
    /<div[^>]*class="[^"]*post[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
    /<div[^>]*class="[^"]*article[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
  ];
  
  for (const pattern of mainPatterns) {
    const match = html.match(pattern);
    if (match && match[1]) {
      const content = stripHtml(match[1]);
      if (content.length > 200) {
        return content;
      }
    }
  }
  
  // Fall back to body content
  const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i);
  if (bodyMatch) {
    return stripHtml(bodyMatch[1]);
  }
  
  return stripHtml(html);
}

function extractTitle(html) {
  const titleMatch = html.match(/<title[^>]*>([^<]*)<\/title>/i);
  return titleMatch ? titleMatch[1].trim() : null;
}

async function fetchContent(url) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);
  
  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
      }
    });
    
    clearTimeout(timeout);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('text/html') && !contentType.includes('application/xhtml')) {
      throw new Error(`Not an HTML page (${contentType})`);
    }
    
    return response.text();
  } catch (err) {
    clearTimeout(timeout);
    if (err.name === 'AbortError') {
      throw new Error('Request timed out');
    }
    throw err;
  }
}

async function main() {
  const url = process.argv[2];
  
  if (!url) {
    printUsage();
  }
  
  // Validate URL
  try {
    new URL(url);
  } catch {
    console.error(`Error: Invalid URL "${url}"`);
    process.exit(1);
  }
  
  const html = await fetchContent(url);
  const title = extractTitle(html);
  let content = extractMainContent(html);
  
  // Truncate if too long
  if (content.length > MAX_CONTENT_LENGTH) {
    content = content.substring(0, MAX_CONTENT_LENGTH) + '... [truncated]';
  }
  
  if (title) {
    console.log(`# ${title}\n`);
  }
  console.log(`Source: ${url}\n`);
  console.log(content);
}

main().catch(err => {
  console.error(`Error: ${err.message}`);
  process.exit(1);
});
