#!/usr/bin/env node
// Validates every .ai/*.yaml file against its JSON Schema in .ai/schemas/.
// Run: node scripts/validate-ai-config.mjs
// Exits non-zero (and lists every error) if any file fails — used by
// .github/workflows/validate.yml.

import { readFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { parseYamlLite } from "./lib/yaml-lite.mjs";
import { validate } from "./lib/json-schema-lite.mjs";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const AI_DIR = join(ROOT, ".ai");

const FILES = [
  { data: "systems.yaml", schema: "schemas/systems.schema.json" },
  { data: "commands.yaml", schema: "schemas/commands.schema.json" },
  { data: "policies.yaml", schema: "schemas/policies.schema.json" },
  { data: "risk-levels.yaml", schema: "schemas/risk-levels.schema.json" },
];

let failed = false;

for (const { data, schema } of FILES) {
  const dataPath = join(AI_DIR, data);
  const schemaPath = join(AI_DIR, schema);
  if (!existsSync(dataPath)) {
    console.log(`SKIP ${data} — not present`);
    continue;
  }
  if (!existsSync(schemaPath)) {
    console.error(`FAIL ${data} — no schema at .ai/${schema}`);
    failed = true;
    continue;
  }
  const parsed = parseYamlLite(readFileSync(dataPath, "utf8"));
  const schemaJson = JSON.parse(readFileSync(schemaPath, "utf8"));
  const errors = validate(schemaJson, parsed);
  if (errors.length === 0) {
    console.log(`PASS ${data}`);
  } else {
    console.error(`FAIL ${data}`);
    for (const err of errors) console.error(`  ${err}`);
    failed = true;
  }
}

// ownership.yaml has no schema yet (Phase 2 didn't define one) — parse-check only.
const ownershipPath = join(AI_DIR, "ownership.yaml");
if (existsSync(ownershipPath)) {
  try {
    parseYamlLite(readFileSync(ownershipPath, "utf8"));
    console.log("PASS ownership.yaml (parses; no schema defined yet)");
  } catch (e) {
    console.error(`FAIL ownership.yaml — ${e.message}`);
    failed = true;
  }
}

if (failed) {
  console.error("\n.ai config validation failed.");
  process.exit(1);
}
console.log("\nAll .ai config files valid.");
