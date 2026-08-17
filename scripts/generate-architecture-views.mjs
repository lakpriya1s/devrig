#!/usr/bin/env node
// Generates architecture views from .ai/systems.yaml and .ai/ownership.yaml
// instead of hand-maintaining diagrams that drift from reality. Writes:
//   knowledge/generated/system-map.md      — Mermaid dependency graph + repo table
//   knowledge/generated/ownership-map.md   — area -> systems -> owners table
// Run: node scripts/generate-architecture-views.mjs (after editing .ai/systems.yaml
// or .ai/ownership.yaml). Output is authority: generated — a lead to verify
// against AGENTS.md/POLICY.md, never a citation on its own (see knowledge/README.md).

import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { parseYamlLite } from "./lib/yaml-lite.mjs";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const GENERATED_DIR = join(ROOT, "knowledge", "generated");
mkdirSync(GENERATED_DIR, { recursive: true });

function existingCreatedDate(outputPath) {
  if (!existsSync(outputPath)) return null;
  const match = readFileSync(outputPath, "utf8").match(/^created:\s*(.+)$/m);
  return match ? match[1].trim() : null;
}

function frontmatter(id, title, outputPath) {
  const today = new Date().toISOString().slice(0, 10);
  const created = existingCreatedDate(outputPath) ?? today;
  return `---
id: ${id}
title: ${title}
type: architecture
status: accepted
authority: generated
systems: []
owners: []
authorship: generated
human_reviewed: false
created: ${created}
last_reviewed: ${today}
tags: [generated]
---
`;
}

const systemsPath = join(ROOT, ".ai", "systems.yaml");
if (existsSync(systemsPath)) {
  const systems = parseYamlLite(readFileSync(systemsPath, "utf8")).systems ?? {};
  const names = Object.keys(systems);

  const mermaidEdges = names
    .flatMap((name) => {
      const deps = systems[name].depends_on ?? [];
      return deps.map((dep) => `    ${dep} --> ${name}`);
    })
    .join("\n");

  const table = names
    .map((name) => {
      const s = systems[name];
      return `| ${name} | ${s.repo ?? ""} | ${s.purpose ?? ""} | ${(s.stack ?? []).join(", ")} | ${(s.depends_on ?? []).join(", ") || "—"} |`;
    })
    .join("\n");

  const systemMapPath = join(GENERATED_DIR, "system-map.md");
  const content = `${frontmatter("system-map", "System Map (generated)", systemMapPath)}
# System Map

> Generated from \`.ai/systems.yaml\` by \`scripts/generate-architecture-views.mjs\`.
> Do not edit by hand — edit the source file and regenerate. \`authority: generated\`:
> treat this as a lead to verify, not a citation (see \`knowledge/README.md\`).

## Dependency graph

\`\`\`mermaid
flowchart LR
${mermaidEdges || "    %% no dependencies declared in .ai/systems.yaml"}
\`\`\`

## Systems

| System | Repo | Purpose | Stack | Depends on |
|---|---|---|---|---|
${table}
`;
  writeFileSync(systemMapPath, content);
  console.log("Wrote knowledge/generated/system-map.md");
} else {
  console.log("SKIP system-map.md — .ai/systems.yaml not found");
}

const ownershipPath = join(ROOT, ".ai", "ownership.yaml");
if (existsSync(ownershipPath)) {
  const areas = parseYamlLite(readFileSync(ownershipPath, "utf8")).areas ?? {};
  const rows = Object.entries(areas)
    .map(([area, def]) => `| ${area} | ${(def.systems ?? []).join(", ")} | ${(def.owners ?? []).join(", ")} |`)
    .join("\n");

  const ownershipMapPath = join(GENERATED_DIR, "ownership-map.md");
  const content = `${frontmatter("ownership-map", "Ownership Map (generated)", ownershipMapPath)}
# Ownership Map

> Generated from \`.ai/ownership.yaml\` by \`scripts/generate-architecture-views.mjs\`.
> Do not edit by hand — edit the source file and regenerate.

| Area | Systems | Owners |
|---|---|---|
${rows}
`;
  writeFileSync(ownershipMapPath, content);
  console.log("Wrote knowledge/generated/ownership-map.md");
} else {
  console.log("SKIP ownership-map.md — .ai/ownership.yaml not found");
}
