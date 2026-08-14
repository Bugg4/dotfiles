---
name: deep-research
description: "Use ONLY when invoked by the /research command. Run a filesystem-backed, multi-source investigation with iterative search, source validation, gap analysis, and a cited report. Do not activate for ordinary research questions, quick lookups, or direct web searches."
compatibility: opencode
metadata:
  entrypoint: "/research"
  workflow: "plan-search-reflect-synthesize"
---

# Deep Research Workflow

This is a command-owned workflow. It is not a general-purpose research persona
and must not be activated from a normal user message, an ordinary agent, or the
built-in `web-search` agent. The only supported entry point is `/research`.

The goal is a current, evidence-backed report, not a longer answer produced
from memory. Use the built-in `websearch` tool for discovery and `webfetch` to
read the sources that support important claims.

## Run Contract

- Work only under `research/<slug>/` relative to the current working directory.
- Never modify project files, configuration, or an existing report outside that
  research directory.
- If the directory already contains a matching `brief.md`, resume it rather
  than starting a second run or overwriting findings.
- Treat the current date as relevant evidence for requests containing "latest",
  "today", "current", or version-specific language.
- Search snippets are leads, not evidence. A source may enter the report only
  after its page has been opened with `webfetch` or otherwise directly read.
- Never invent a citation, quotation, publication date, benchmark, or source.
- Separate sourced facts, interpretations, and unresolved hypotheses.

## Invocation Options

The `/research` command accepts a question and optional pipe-delimited controls:

```text
/research <question>
/research <question> | :quick
/research <question> | :deep
/research <question> | :confirm
/research <question> | <stop criteria>
```

The default is `standard`. `:confirm` stops after the brief and proposed plan
so the user can revise it before searches begin. Without `:confirm`, show the
plan in the progress update and continue automatically.

| Mode | Workers | Target | Follow-up rounds |
| --- | ---: | ---: | ---: |
| `quick` | 2-3 | 8+ useful sources | 0-1 |
| `standard` | 3-5 | 15+ useful sources | 1 |
| `deep` | 5-8 | 25+ useful sources | 2 |

These are budgets, not promises. Stop early when the evidence converges; do
not pad a report with weak or duplicate sources.

## Phase 0: Triage

Decide whether the request needs this workflow. A narrow fact that one
authoritative source can answer should use the quick path: one or two searches,
one or two source reads, and a short cited answer inside the research folder.
For everything else, continue with the selected mode. An explicit `/research`
invocation always gets evidence and citations, even when the quick path is
appropriate.

Ask at most one round of clarifying questions, and only when audience, scope,
time range, geography, or decision criteria would materially change the
research. Otherwise record reasonable assumptions in `brief.md` and proceed.

## Phase 1: Brief and Plan

Create `research/<slug>/` and these files before searching:

```text
brief.md             # research contract and plan
sources-index.md     # canonical source registry
findings/            # one file per research angle or follow-up
REPORT.md            # final report, written only by the orchestrator
```

`brief.md` must contain:

- the original question and refined question;
- audience, purpose, scope, exclusions, assumptions, and date;
- selected depth mode and explicit stop criteria;
- three to eight independent research angles;
- source strategy and expected evidence types;
- a checklist mapping each angle to the question it must answer.

Choose angles from the following lenses as appropriate:

- core definitions, mechanisms, and current state;
- recent changes, releases, or timeline;
- quantitative data, benchmarks, or cost;
- competing explanations, criticism, and failure cases;
- primary or official documentation and original announcements;
- practitioner experience, issues, and implementation evidence;
- alternatives, key actors, and comparative trade-offs.

Prefer angles that can be researched independently. Keep dependencies in the
brief so the reflection phase can schedule them sequentially when necessary.

## Phase 2: Parallel Research

Dispatch one hidden `research-worker` subagent per independent angle in a
single parallel task message. Every worker receives:

- `ENTRYPOINT=/research`;
- the absolute or relative research directory;
- exactly one assigned angle;
- the relevant success criteria from `brief.md`;
- its search and fetch budget;
- an instruction to write its findings file before returning.

Workers must vary query wording and source families. They should use at least
one primary/official query and, for important or contested claims, one query
aimed at criticism, limitations, or contradictory evidence. They should read
the strongest one to three result pages rather than citing search snippets.

Workers write only their assigned file, for example
`findings/angle-01-official-evidence.md`. Each finding entry must include:

```markdown
## Claim
The precise fact or conclusion supported by the source.

**Evidence:** A short quote or faithful paraphrase.
**Source:** URL
**Title:** Page title
**Published:** YYYY-MM-DD or n.d.
**Accessed:** YYYY-MM-DD
**Tier:** Primary | Established | Low
**Confidence:** High | Medium | Low
**Limitations:** What the source does not establish.
```

Workers must record rejected or dead-end paths when useful: paywalls,
irrelevant results, stale versions, duplicate reporting, or claims that could
not be independently verified. They return only a short summary after the
file is written. Raw page content must not be returned to the orchestrator.

The orchestrator must not let parallel workers write `REPORT.md` or mutate the
shared source registry concurrently.

## Phase 3: Evidence Registry and Reflection

After workers finish, read the findings files and build or update
`sources-index.md` in one place. Give every actually read source a stable ID:

```markdown
| ID | Title | URL | Published | Accessed | Tier | Used for |
| --- | --- | --- | --- | --- | --- | --- |
| S1 | ... | https://... | 2026-01-02 | 2026-08-11 | Primary | ... |
```

Then compare the evidence against every item in `brief.md`:

- Which questions have no evidence?
- Which important claims rely on only one weak source?
- Which sources are duplicates or merely repeating one another?
- Where do authoritative sources conflict?
- Is one geography, vendor, ideology, or source type overrepresented?
- What new question emerged from the evidence?

If a material gap remains and the mode has follow-up budget, dispatch targeted
delta queries to workers in parallel. Delta queries must name the missing
claim, the reason it matters, and the evidence needed. Do not repeat a failed
query without changing the approach. If the budget is exhausted, record the
gap in `brief.md` and later in the report's uncertainty section.

Use these convergence signals together:

- the required questions have credible evidence;
- the last two searches add little or duplicate known material;
- major claims have independent corroboration or an explicit uncertainty flag;
- the mode's worker, fetch, and follow-up budgets are exhausted.

## Phase 4: Single-Point Synthesis

Only the orchestrator writes `REPORT.md`. Use this structure unless the user
requested another format:

```markdown
# <Research question>

> Scope, date, assumptions, depth mode, and source count.

## Executive Summary
...

## Findings
### <Question or theme>
...

## Analysis and Implications
...

## Conflicts and Uncertainty
...

## Open Questions
...

## Sources
[S1] Title. URL. Published/accessed dates. Tier.
```

Citation rules:

- Put `[S#]` immediately after the claim it supports.
- Use only IDs from `sources-index.md`; URLs must come from findings files.
- Cite every non-obvious factual claim, number, date, version, and comparison.
- Require two independent credible sources for a consequential claim when
  possible; mark it `Low confidence` when only one weak source exists.
- Prefer primary sources, formal documentation, papers, datasets, filings, and
  original statements over derivative summaries.
- Present unresolved conflicts with dates and reasons for the weighting; never
  silently choose a convenient source.
- Label synthesis with language such as "This suggests" rather than presenting
  an inference as a sourced fact.

Write prose first. Use tables only when they make a comparison clearer. Do not
inflate the report to hit a word count or source target.

## Phase 5: Critique and Delivery

For `deep` mode, perform one explicit skeptical pass before delivery. Check for
unsupported claims, citation drift, stale sources, missing counter-evidence,
false consensus, overconfident recommendations, and conclusions not answering
the original question. Fix `REPORT.md` and update the source registry in place.

Finally, report in chat:

- the answer in a few sentences;
- the number and tier mix of sources actually read;
- the confidence and unresolved limitations;
- the path to `REPORT.md`;
- useful follow-up research questions.

On interruption or compaction, resume by reading `brief.md`,
`sources-index.md`, and the existing `findings/` files. Never restart by
discarding prior evidence.
