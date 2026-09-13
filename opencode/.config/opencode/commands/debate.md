---
description: "Run a stateful debate between the main agent and a configured debater* subagent. Usage: /debate <topic or proposal>"
---

You were invoked explicitly by `/debate`. Load and follow the `debate` skill,
then run its complete main-versus-subagent workflow.

Debate request:
$ARGUMENTS

Use only a configured subagent whose name begins with `debater`, preserve its
task session across rounds, and do not fall back to another subagent type. If
the request is empty, ask the user what should be debated.
