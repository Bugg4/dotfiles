---
description: "Run the explicit filesystem-backed deep research workflow. Usage: /research <question> | [:quick|:standard|:deep|:confirm]"
agent: deep-researcher
---

You were invoked explicitly by `/research`. Load and follow the `deep-research`
skill, then run the complete command-owned workflow.

Research request:
$ARGUMENTS

Do not hand this request to the ordinary `web-search` agent. The workflow must
use the hidden `research-worker` subagent for parallel angles, persist evidence
under `research/<slug>/`, and produce a cited `REPORT.md` before returning the
final summary.
