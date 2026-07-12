# Bug template

Title: `[<Project> <Surface>] <specific observable symptom>`
Labels: `Bug` + surface labels · Status: Backlog · Priority: 1 for crash/data-loss/security, 2 for broken core flows, 3 default, 4 cosmetic

---

## Summary

<1–3 sentences: what is broken, where, and the user impact. Include the exact error text verbatim if there is one.>

## Severity

<Priority word + one clause of justification, e.g. "High — checkout is a revenue-critical flow and is intermittently unreachable.">

## Environment

- App/build: <version, debug/release>
- Device/OS/browser: <if relevant>
- Backend: <prod / staging / local, if relevant>

## Steps to reproduce

1. <step>
2. <step>
3. <step>

## Expected

<What should happen.>

## Actual

<What happens instead, including frequency if intermittent ("~1 in 3 attempts").>

## Evidence

<Screenshot paths/attachments, log excerpts (trimmed to the relevant lines). Omit section if none.>

## Root cause (if known)

<File and explanation, e.g. `SettingsScreen.tsx` mounts a duplicate save handler. Omit section if not yet investigated.>

## Suggested fix (if known)

<Proposed change. Omit section if none.>

## Related

<Tickets this relates to, blocks, or duplicates-adjacent. Omit section if none.>
