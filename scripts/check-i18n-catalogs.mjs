#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const PLACEHOLDER = /\{([A-Za-z][A-Za-z0-9_]*)\}/g;

function placeholders(message) {
  return [...message.matchAll(PLACEHOLDER)].map((match) => match[1]).sort();
}

function readCatalog(file) {
  const value = JSON.parse(fs.readFileSync(file, "utf8"));
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${file}: catalog must be a JSON object`);
  }
  for (const [key, message] of Object.entries(value)) {
    if (!/^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$/.test(key)) {
      throw new Error(`${file}: invalid semantic message key ${JSON.stringify(key)}`);
    }
    if (typeof message !== "string" || message.length === 0) {
      throw new Error(`${file}: ${key} must be a non-empty string`);
    }
  }
  return value;
}

function validateDirectory(directory) {
  const englishFile = path.join(directory, "en-US.json");
  const chineseFile = path.join(directory, "zh-Hans.json");
  const english = readCatalog(englishFile);
  const chinese = readCatalog(chineseFile);
  const englishKeys = Object.keys(english).sort();
  const chineseKeys = Object.keys(chinese).sort();
  const missing = englishKeys.filter((key) => !(key in chinese));
  const extra = chineseKeys.filter((key) => !(key in english));
  if (missing.length || extra.length) {
    throw new Error(
      `${directory}: catalog key mismatch\n` +
        `  missing in zh-Hans: ${missing.join(", ") || "none"}\n` +
        `  extra in zh-Hans: ${extra.join(", ") || "none"}`,
    );
  }
  for (const key of englishKeys) {
    const sourceArgs = placeholders(english[key]);
    const translatedArgs = placeholders(chinese[key]);
    if (sourceArgs.join("\0") !== translatedArgs.join("\0")) {
      throw new Error(
        `${directory}: placeholder mismatch for ${key}: ` +
          `${sourceArgs.join(", ")} != ${translatedArgs.join(", ")}`,
      );
    }
  }
  const sourceTranslations = new Map();
  for (const key of englishKeys) {
    const source = english[key];
    const existing = sourceTranslations.get(source);
    if (existing && existing.translation !== chinese[key]) {
      throw new Error(
        `${directory}: duplicate English message ${JSON.stringify(source)} has conflicting translations ` +
          `for ${existing.key} and ${key}`,
      );
    }
    sourceTranslations.set(source, { key, translation: chinese[key] });
  }
  return englishKeys.length;
}

const directories = process.argv.slice(2);
if (directories.length === 0) {
  console.error("usage: node check-i18n-catalogs.mjs <locales-dir> [...]");
  process.exit(2);
}

let count = 0;
for (const directory of directories) count += validateDirectory(directory);
console.log(`validated ${directories.length} catalog(s), ${count} messages`);
