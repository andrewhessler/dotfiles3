#!/usr/bin/env node

/**
 * Web Search using Brave Search API
 * 
 * Usage:
 *   ./search.js "query" [--count N] [--content]
 * 
 * Environment:
 *   BRAVE_API_KEY - Your Brave Search API key
 */

import fetch from 'node-fetch';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const BRAVE_API_URL = 'https://api.search.brave.com/res/v1/web/search';

function printUsage() {
  console.error('Usage: search.js "query" [--count N] [--content]');
  console.error('');
  console.error('Options:');
  console.error('  --count N    Number of results (default: 5, max: 20)');
  console.error('  --content    Also fetch content from top results');
  console.error('');
  console.error('Environment:');
  console.error('  BRAVE_API_KEY - Your Brave Search API key');
  process.exit(1);
}

function parseArgs() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) printUsage();
  
  let query = null;
  let count = 5;
  let fetchContent = false;
  
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--count') {
      count = parseInt(args[++i], 10);
      if (isNaN(count) || count < 1) count = 5;
      if (count > 20) count = 20;
    } else if (args[i] === '--content') {
      fetchContent = true;
    } else if (!query) {
      query = args[i];
    }
  }
  
  if (!query) {
    console.error('Error: Search query required');
    printUsage();
  }
  
  return { query, count, fetchContent };
}

async function search(query, count) {
  const apiKey = process.env.BRAVE_API_KEY;
  
  if (!apiKey) {
    console.error('Error: BRAVE_API_KEY environment variable not set');
    console.error('');
    console.error('Get your API key at: https://brave.com/search/api/');
    console.error('Then set it: export BRAVE_API_KEY="your-key-here"');
    process.exit(1);
  }
  
  const params = new URLSearchParams({
    q: query,
    count: count.toString(),
    text_decorations: 'false',
    search_lang: 'en'
  });
  
  const response = await fetch(`${BRAVE_API_URL}?${params}`, {
    headers: {
      'Accept': 'application/json',
      'X-Subscription-Token': apiKey
    }
  });
  
  if (!response.ok) {
    const error = await response.text();
    if (response.status === 401) {
      console.error('Error: Invalid API key (401 Unauthorized)');
    } else if (response.status === 429) {
      console.error('Error: Rate limit exceeded (429 Too Many Requests)');
    } else {
      console.error(`Error: API request failed (${response.status})`);
      console.error(error);
    }
    process.exit(1);
  }
  
  return response.json();
}

async function fetchPageContent(url) {
  try {
    const contentScript = resolve(__dirname, 'content.js');
    const output = execSync(`node "${contentScript}" "${url}"`, {
      encoding: 'utf-8',
      timeout: 15000,
      stdio: ['pipe', 'pipe', 'pipe']
    });
    return output.trim();
  } catch (err) {
    return `[Failed to fetch content: ${err.message}]`;
  }
}

async function main() {
  const { query, count, fetchContent } = parseArgs();
  
  console.log(`Searching for: "${query}"\n`);
  
  const data = await search(query, count);
  
  if (!data.web?.results || data.web.results.length === 0) {
    console.log('No results found.');
    return;
  }
  
  const results = data.web.results;
  
  console.log(`Found ${results.length} results:\n`);
  console.log('='.repeat(80));
  
  for (let i = 0; i < results.length; i++) {
    const result = results[i];
    console.log(`\n[${i + 1}] ${result.title}`);
    console.log(`    ${result.url}`);
    if (result.description) {
      console.log(`    ${result.description}`);
    }
    
    if (fetchContent && i < 3) { // Only fetch content for top 3
      console.log('\n    --- Page Content ---');
      const content = await fetchPageContent(result.url);
      // Indent the content
      const indentedContent = content.split('\n').map(line => `    ${line}`).join('\n');
      console.log(indentedContent);
      console.log('    --- End Content ---');
    }
    
    console.log('');
  }
  
  console.log('='.repeat(80));
}

main().catch(err => {
  console.error('Search failed:', err.message);
  process.exit(1);
});
