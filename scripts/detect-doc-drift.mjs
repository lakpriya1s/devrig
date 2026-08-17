#!/usr/bin/env node
// Surfaces likely-stale knowledge — this is a WARNING tool, not a gate: it
// always exits 0. Wire it into CI as a non-blocking step, or run it by hand
// before a knowledge review. Checks:
//   - systems.yaml entries with no matching devrig.toml repo (renamed/removed)
//   - devrig.toml repos with no systems.yaml entry (undocumented system)
//   - dangling `related:`/`superseded_by` frontmatter ids (doc renamed/removed)
//   - docs past their `review_interval` since `last_reviewed`
//
// What this can't check from a template repo alone (needs real cloned repos
// with real code): stale command definitions vs. actual package.json
// scripts, and "removed API still documented" — flagged below as manual
// follow-ups, not attempted.

import { readdirSync, statSync, readFileSync, existsSync } from "node:fs";
import { join, relative, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { parseYamlLite } from "./lib/yaml-lite.mjs";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const KNOWLEDGE_DIR = join(ROOT, "knowledge");
const SKIP_FILES = new Set(["README.md", "index.md", "0000-template.md"]);

function walk(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) out.push(...walk(full));
    else if (entry.endsWith(".md") && !SKIP_FILES.has(entry)) out.push(full);
  }
  return out;
}

function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;
  const fm = {};
  for (const line of match[1].split("\n")) {
    const kv = line.match(/^([A-Za-z_]+):\s*(.*)$/);
    if (!kv) continue;
    const [, key, rawValue] = kv;
    let value = rawValue.trim();
    if (value.startsWith("[") && value.endsWith("]")) {
      value = value
        .slice(1, -1)
        .split(",")
        .map((s) => s.trim().replace(/^["']|["']$/g, ""))
        .filter(Boolean);
    } else {
      value = value.replace(/^["']|["']$/g, "");
    }
    fm[key] = value;
  }
  return fm;
}

function parseToml(text) {
  // Just enough to read [project].repos = [...] from devrig.toml.
  const match = text.match(/repos\s*=\s*\[([^\]]*)\]/);
  if (!match) return [];
  return match[1]
    .split(",")
    .map((s) => s.trim().replace(/^["']|["']$/g, ""))
    .filter(Boolean);
}

function addDays(dateStr, amount, unit) {
  const d = new Date(dateStr);
  if (isNaN(d)) return null;
  const days = unit === "y" ? amount * 365 : unit === "m" ? amount * 30 : amount;
  d.setDate(d.getDate() + days);
  return d;
}

const warnings = [];

// --- systems.yaml vs devrig.toml ---
const tomlPath = join(ROOT, "devrig.toml");
const systemsPath = join(ROOT, ".ai", "systems.yaml");
if (existsSync(tomlPath) && existsSync(systemsPath)) {
  const repos = parseToml(readFileSync(tomlPath, "utf8"));
  const systems = parseYamlLite(readFileSync(systemsPath, "utf8")).systems ?? {};
  const systemRepos = new Set(Object.values(systems).map((s) => s.repo));

  for (const repo of repos) {
    if (!systemRepos.has(repo)) {
      warnings.push(`devrig.toml repo "${repo}" has no matching entry in .ai/systems.yaml`);
    }
  }
  for (const [name, sys] of Object.entries(systems)) {
    if (sys.repo && repos.length > 0 && !repos.includes(sys.repo)) {
      warnings.push(`.ai/systems.yaml system "${name}" points at repo "${sys.repo}", which isn't in devrig.toml's repos list (renamed or removed?)`);
    }
  }
}

// --- dangling related/superseded_by ids ---
const files = walk(KNOWLEDGE_DIR);
const docsById = new Map();
const docs = [];
for (const file of files) {
  const fm = parseFrontmatter(readFileSync(file, "utf8"));
  if (!fm) continue;
  docs.push({ file, fm });
  if (fm.id) docsById.set(fm.id, file);
}

for (const { file, fm } of docs) {
  const relPath = relative(ROOT, file);
  const relatedIds = Array.isArray(fm.related) ? fm.related : fm.related ? [fm.related] : [];
  for (const id of relatedIds) {
    if (id && !docsById.has(id)) {
      warnings.push(`${relPath}: related id "${id}" doesn't match any doc's frontmatter id`);
    }
  }
  if (fm.superseded_by && fm.superseded_by !== "null" && !docsById.has(fm.superseded_by)) {
    warnings.push(`${relPath}: superseded_by "${fm.superseded_by}" doesn't match any doc's frontmatter id`);
  }
}

// --- freshness: last_reviewed + review_interval vs today ---
const today = new Date();
for (const { file, fm } of docs) {
  if (!fm.review_interval || !fm.last_reviewed) continue;
  const match = fm.review_interval.match(/^(\d+)([dmy])$/);
  if (!match) continue;
  const dueDate = addDays(fm.last_reviewed, Number(match[1]), match[2]);
  if (dueDate && dueDate < today) {
    const daysOverdue = Math.round((today - dueDate) / (1000 * 60 * 60 * 24));
    warnings.push(`${relative(ROOT, file)}: stale — last reviewed ${fm.last_reviewed}, review_interval ${fm.review_interval}, ${daysOverdue} day(s) overdue`);
  }
}

// --- what this script can't check without real repos ---
const manualFollowUps = [
  "Command drift: whether .ai/commands.yaml's commands still match each repo's actual package.json scripts (needs cloned repos).",
  "Removed-API-still-documented: whether documented endpoints/events still exist in code (needs semantic code reading — see /check-knowledge-consistency).",
];

console.log(`Doc drift check — ${warnings.length} warning(s):\n`);
for (const w of warnings) console.log(`  ⚠ ${w}`);
if (warnings.length === 0) console.log("  (none)");

console.log(`\nNot checked here (needs cloned repos / semantic reading — use /check-knowledge-consistency):`);
for (const f of manualFollowUps) console.log(`  - ${f}`);

process.exit(0); // warning tool — never fails the build
