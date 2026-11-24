---
name: improve-architecture
description: Audit a codebase against the architecture and engineering principles that actually matter for it, using parallel subagents and an adversarial verification pass, then produce a prioritized high-leverage resolution design plus specifications for architecture guardrail tests. Runs full or incrementally against the delta since the last audit. Use whenever the user asks to "improve the architecture", "audit this codebase", "find architectural problems", "review the design", "what technical debt should we fix", "add architecture tests", or wants an assessment of where a codebase is degrading — even if they don't use the word "architecture".
---

# Improve architecture

Produce a report: what is wrong, what is worth fixing, and one coherent design that fixes the most for the least. Encode the conclusions you are confident in as guardrail tests, and record the ones you declined.

This skill does not implement. It writes no code and no tests; the only files it touches are its own report and decision log. Everything else it produces is a specification for someone else to build. It emits a design package — report, guardrail specifications, decision log — that any planning or execution process can consume; each artifact carries its own consumption semantics.

## 0. Pick the mode

Read the decision log (`doc/architecture-decisions.md` or the path the repo uses — see step 8). If it records an audit marker, default to **incremental**; otherwise **full**.

**Incremental** — analyze only what changed since the marker:

```bash
git diff --name-only <marker-sha>..HEAD
git diff --stat <marker-sha>..HEAD
```

Read changed files in the context of their module, not in isolation. Run the existing guardrail tests to cover the untouched ground cheaply.

Switch to full when there is no marker, when the delta touches more than roughly a third of the repo, or when a new subsystem appeared. Incremental cannot see drift spread thinly across untouched files.

## 1. Orient

Do this yourself — the fan-out agents inherit your summary and should not each rebuild it.

- Read the entry docs (README, CLAUDE.md / AGENTS.md, `doc/`, specs, ADRs) and the module/build graph.
- Find the churn hotspots — these are where architecture debt is actually paid:

```bash
git log --format= --name-only --since='12 months ago' | sort | uniq -c | sort -rn | head -40
```

- Cross churn against size and against where bug-fix commits land.
- Run the existing guardrail suite if there is one. A failing guardrail is a pre-confirmed finding — it skips the refutation pass and goes straight to step 5.

Write down: what the system is for, its stated philosophy, its current state, and the hotspots. This summary goes to every subagent.

## 2. Pick principles

Derive them from this system's failure modes and change patterns, not from a textbook list. Ask what actually breaks here and what is hard to change here.

Drop principles the codebase has explicitly and defensibly opted out of, and say so.

Show the list to the user before fanning out. Correcting the list costs one message; a wrong list costs the whole fan-out.

## 3. Fan out

One Opus 5 subagent per principle, all spawned in a single message. Each gets:

- your orientation summary
- the one principle it owns, and what it means in this system
- scope — the likely offending area when the concern is isolated, whole-repo only when it is not, changed files only in incremental mode
- the severity rubric below
- the finding contract:

```
Offense: [one line]
Location: path/to/file:line (+ other sites)
Evidence: [what in the code shows this]
Who pays: [what work is made harder, slower, or riskier, and how often]
Documented? [does the project's own spec/docs/ADRs already address or sanction this — cite]
Severity: [rubric level + why]
Solutions: [1-3 directions, each with its cost]
```

Tell each agent that "no significant offenses" is a valid and expected result. A finding with no named payer does not get reported.

## Severity rubric

| Level | Test |
|---|---|
| **Critical** | Can produce silently wrong behavior, or blocks planned work outright |
| **High** | Blast radius crosses module boundaries, or every change in a hotspot pays it |
| **Medium** | Real cost, contained to one module or an area rarely touched |
| **Low** | Consistency or readability, no measurable cost to change velocity |

Apply the rubric yourself when merging results — severities assigned by different agents are not comparable until you normalize them.

## 4. Verify before ranking

- **Dedupe** by location and claim. The same defect found under two principles is corroboration, not two problems — merge it and raise severity one level.
- **Refute** every Critical and High finding: spawn an independent agent per finding, instructed to argue it is *not* a real problem and to check whether the project's own docs sanction it. Findings that survive go in the report; findings that don't move to the declined list with the refutation as the reason.
- Drop Low findings unless they come free alongside something you are already fixing.

## 5. Search for leverage

Build the resolution set to maximize value per unit of effort:

- Prefer solutions proposed for more than one offense.
- Prefer solutions that make other problems moot or downgrade their severity.
- Combine into one coherent architectural move rather than N local patches.
- Include a solution only when the problem is confirmed and the fix is sustainable.

For each selected solution state its cost, its risk, and what would make you abandon it.

## 6. Specify guardrails

Write specifications for architecture tests. Do not write the tests — they are implementation work, they belong in the outline like every other change, and a test written here arrives unreviewed and outside the plan.

Enforcing the wrong structure costs more than enforcing nothing, so the bar is high. Specify a rule only when all of these hold:

- it is an invariant the project already states, or the user has agreed to it
- it is mechanically checkable without heuristics
- it is green today, or its violations fit a finite, explicitly shrinking allowlist

Establish that last point with a disposable probe — a grep or a throwaway script in a scratch directory — and record the violation count in the specification. Do not leave the probe behind.

Each specification states:

- the invariant, in one sentence
- the finding it came from
- the mechanism (`references/guardrail-tests.md` has the options per ecosystem)
- current violation count, and the allowlist if there is one
- the amendment-policy header the implementing ticket must embed:

> Adding a rule is always allowed. Changing, relaxing, or deleting a rule requires human approval and a note in the decision log.

A rule with forty exceptions is noise. Leave it out and record it as considered-not-specified.

## 7. Report

1. **Reported offenses** — all surviving findings, with severity and source principle.
2. **Declined** — what you dropped and why (refuted, sanctioned by design, no payer, too low).
3. **Selected offenses** — what you will tackle.
4. **Solution design** — the coherent set, with which offenses each element kills, plus cost and risk. State abandon-conditions as triggers — "abandon or replan if X becomes true" — for any process executing this design to watch.
5. **Guardrails** — rules specified, each with its mechanism, violation count, and the amendment-policy header to embed; plus rules considered and rejected.
6. **Implementation outline** — every change to be made, guardrail tests included, ordered by leverage so an executor working top-down banks the most value first.

## 8. Record

Append to the decision log (`assets/decision-log-template.md`; follow the repo's convention if one exists, otherwise propose `doc/architecture-decisions.md`):

- the audit marker: the commit SHA audited, and the mode
- accepted findings and the solutions chosen
- declined findings with reasons, so the next run does not re-litigate them
- guardrail rules specified, with status `proposed` until an implementing run lands them; rules considered and rejected; and any amendment to an existing rule with its human approval

## 9. Return

Finishing step 8 completes the audit, not necessarily the user's request. If they also asked for a plan, tickets, or implementation, that part is still outstanding — carry on with it in the same turn, using whatever skill fits, and hand it the design package.

## Reference files

- `references/guardrail-tests.md` — architecture test mechanisms per ecosystem, and how to write the amendment header
- `assets/decision-log-template.md` — durable record and audit marker
