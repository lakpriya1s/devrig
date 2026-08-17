---
id: system-map
title: System Map (generated)
type: architecture
status: accepted
authority: generated
systems: []
owners: []
authorship: generated
human_reviewed: false
created: 2026-08-16
last_reviewed: 2026-08-16
tags: [generated]
---

# System Map

> Generated from `.ai/systems.yaml` by `scripts/generate-architecture-views.mjs`.
> Do not edit by hand — edit the source file and regenerate. `authority: generated`:
> treat this as a lead to verify, not a citation (see `knowledge/README.md`).

## Dependency graph

```mermaid
flowchart LR
    api --> web
```

## Systems

| System | Repo | Purpose | Stack | Depends on |
|---|---|---|---|---|
| api | example-api | Backend API | nestjs, postgresql | — |
| web | example-web | Web frontend | nextjs, tailwind | api |
