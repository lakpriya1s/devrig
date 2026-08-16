#!/usr/bin/env node
// Validates knowledge/ against the frontmatter schema in knowledge/README.md:
// required fields present, enum values valid, canonical docs are
// human-reviewed, ADR ids/filenames match and are unique, internal links
// resolve, and index.md is up to date with the generated output.
// Run: node scripts/validate-knowledge.mjs — used by
// .github/workflows/knowledge-check.yml.

import { readdirSync, statSync, readFileSync, existsSync } from "node:fs";
import { join, relative, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import { execSync } from "node:child_process";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const KNOWLEDGE_DIR = join(ROOT, "knowledge");
const SKIP_FILES = new Set(["README.md", "index.md", "0000-template.md"]);

const VALID_TYPES = ["architecture", "design", "decision", "runbook", "product", "release"];
const VALID_STATUS = ["draft", "proposed", "accepted", "deprecated", "superseded", "archived"];
const VALID_AUTHORITY = ["canonical", "supporting", "generated", "historical"];
const VALID_AUTHORSHIP = ["human", "ai-assisted", "generated"];

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
      if (value === "true") value = true;
      else if (value === "false") value = false;
      else if (value === "null" || value === "") value = null;
    }
    fm[key] = value;
  }
  return fm;
}

const errors = [];
const files = walk(KNOWLEDGE_DIR);
const seenAdrIds = new Map();

for (const file of files) {
  const relPath = relative(ROOT, file);
  const content = readFileSync(file, "utf8");
  const fm = parseFrontmatter(content);

  if (!fm) {
    errors.push(`${relPath}: missing frontmatter`);
    continue;
  }

  for (const field of ["id", "title", "type", "status", "authority", "authorship", "created", "last_reviewed"]) {
    if (fm[field] === undefined || fm[field] === null || fm[field] === "") {
      errors.push(`${relPath}: missing required frontmatter field "${field}"`);
    }
  }
  if (fm.type && !VALID_TYPES.includes(fm.type)) errors.push(`${relPath}: invalid type "${fm.type}"`);
  if (fm.status && !VALID_STATUS.includes(fm.status)) errors.push(`${relPath}: invalid status "${fm.status}"`);
  if (fm.authority && !VALID_AUTHORITY.includes(fm.authority)) errors.push(`${relPath}: invalid authority "${fm.authority}"`);
  if (fm.authorship && !VALID_AUTHORSHIP.includes(fm.authorship)) errors.push(`${relPath}: invalid authorship "${fm.authorship}"`);
  if (fm.authority === "canonical" && fm.human_reviewed !== true) {
    errors.push(`${relPath}: authority: canonical requires human_reviewed: true`);
  }
  if (fm.status === "superseded" && !fm.superseded_by) {
    errors.push(`${relPath}: status: superseded requires a superseded_by id`);
  }

  // Broken internal markdown links: [text](relative/path.md)
  const linkRe = /\[[^\]]*\]\((?!https?:\/\/|#)([^)]+\.md)\)/g;
  let m;
  while ((m = linkRe.exec(content))) {
    const target = join(dirname(file), m[1]);
    if (!existsSync(target)) errors.push(`${relPath}: broken link to "${m[1]}"`);
  }
}

// ADR-specific checks: filename NNNN matches frontmatter id adr-NNNN, and ids are unique.
const decisionsDir = join(KNOWLEDGE_DIR, "decisions");
if (existsSync(decisionsDir)) {
  for (const entry of readdirSync(decisionsDir)) {
    if (entry === "0000-template.md" || !entry.endsWith(".md")) continue;
    const num = entry.match(/^(\d{4})-/)?.[1];
    const content = readFileSync(join(decisionsDir, entry), "utf8");
    const fm = parseFrontmatter(content);
    if (!num) {
      errors.push(`knowledge/decisions/${entry}: filename doesn't start with NNNN-`);
      continue;
    }
    if (fm?.id && fm.id !== `adr-${num}`) {
      errors.push(`knowledge/decisions/${entry}: frontmatter id "${fm.id}" doesn't match filename number (expected "adr-${num}")`);
    }
    if (fm?.id) {
      if (seenAdrIds.has(fm.id)) {
        errors.push(`knowledge/decisions/${entry}: duplicate ADR id "${fm.id}" (also in ${seenAdrIds.get(fm.id)})`);
      }
      seenAdrIds.set(fm.id, entry);
    }
  }
}

// Generated index freshness: rebuild in-memory and diff against the committed file.
try {
  execSync(`node "${join(ROOT, "scripts", "build-knowledge-index.mjs")}"`, { stdio: "pipe" });
  const gitDiff = execSync(`git -C "${ROOT}" status --porcelain -- knowledge/index.md`).toString().trim();
  if (gitDiff) {
    errors.push(`knowledge/index.md is stale — run "node scripts/build-knowledge-index.mjs" and commit the result`);
  }
} catch (e) {
  errors.push(`could not check knowledge/index.md freshness: ${e.message}`);
}

if (errors.length > 0) {
  console.error(`Knowledge validation failed (${errors.length} issue(s)):\n`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(`Knowledge validation passed (${files.length} docs checked).`);
