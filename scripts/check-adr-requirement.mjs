#!/usr/bin/env node
// Fails if a diff touches a protected path (.ai/policies.yaml's
// protected_paths) without adding/changing anything under
// knowledge/decisions/ — a lightweight backstop for POLICY.md's ADR
// requirement. This catches the mechanical signal (protected path touched,
// no ADR in the same diff); it can't judge whether the ADR that WAS added
// actually covers the change — that's still a human/reviewer call.
//
// Usage: node scripts/check-adr-requirement.mjs <base-sha> <head-sha>

import { readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execSync } from "node:child_process";
import { parseYamlLite } from "./lib/yaml-lite.mjs";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");

const [baseSha, headSha] = process.argv.slice(2);
if (!baseSha || !headSha) {
  console.error("Usage: node scripts/check-adr-requirement.mjs <base-sha> <head-sha>");
  process.exit(2);
}

function globToRegExp(glob) {
  const escaped = glob
    .split("**")
    .map((part) => part.split("*").map((p) => p.replace(/[.+^${}()|[\]\\]/g, "\\$&")).join("[^/]*"))
    .join(".*");
  return new RegExp(`^${escaped}$`);
}

const policiesPath = join(ROOT, ".ai", "policies.yaml");
let protectedPaths = [];
try {
  const parsed = parseYamlLite(readFileSync(policiesPath, "utf8"));
  protectedPaths = parsed.protected_paths ?? [];
} catch {
  console.log("No .ai/policies.yaml protected_paths defined — skipping ADR-requirement check.");
  process.exit(0);
}

const changedFiles = execSync(`git -C "${ROOT}" diff --name-only ${baseSha} ${headSha}`)
  .toString()
  .trim()
  .split("\n")
  .filter(Boolean);

const patterns = protectedPaths.map(globToRegExp);
const touchedProtected = changedFiles.filter((f) => patterns.some((re) => re.test(f)));

if (touchedProtected.length === 0) {
  console.log("No protected paths touched — ADR not required by this check.");
  process.exit(0);
}

const touchedAdr = changedFiles.some(
  (f) => f.startsWith("knowledge/decisions/") && !f.endsWith("0000-template.md")
);

if (touchedAdr) {
  console.log(`Protected paths touched (${touchedProtected.join(", ")}) — ADR present in diff. OK.`);
  process.exit(0);
}

console.error(
  `Protected path(s) touched without an ADR in the same diff:\n` +
    touchedProtected.map((f) => `  - ${f}`).join("\n") +
    `\n\nAdd an ADR under knowledge/decisions/ (see POLICY.md#adr-requirement), ` +
    `or if this PR genuinely doesn't need one, note "ADR not required: <reason>" in the PR description ` +
    `and have a human override this check.`
);
process.exit(1);
