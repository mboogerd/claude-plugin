# Model routing

## Facts come from the live source

Read the `claude-api` skill for current model ids, context windows, pricing, and
capabilities. Do not use ids pinned in this file or recalled from memory — a plan
naming a retired model fails at spawn time.

This file is stable heuristics only.

## The ladder

Cheapest to most capable: **Haiku → Sonnet → Opus → Fable**. Higher tiers buy
reasoning depth and reliability under ambiguity, not rescue from a badly
specified ticket. Confirm the current lineup via `claude-api`; Fable is the tier
reserved for deep analysis and planning rather than bulk implementation.

## Route by task shape

The question is how much is already decided, not how important the feature is.

| Signal | Route |
|---|---|
| Mechanical transform, pattern exists in-repo, exemplar file citable | Haiku |
| Few files, design fully specified, obvious verification | Haiku → escalate Sonnet |
| Multi-file within one subsystem, judgment on fitting existing style | Sonnet |
| Cross-module, or intent must be inferred from specs | Sonnet → escalate Opus |
| Novel design inside the ticket, subtle invariants, concurrency, protocol/wire | Opus |
| Analysis, decomposition, replanning a wave, adjudicating contradictory findings | Opus or Fable |

Route a tier higher than the size suggests when the ticket requires reading far
more than it changes, or when correctness depends on something not visible in
the files it touches.

Acceptance-test tickets in the twin-checkout flow usually route one tier below
their implementation counterpart — the criteria are already written, the work is
expressing them in the repo's test idiom.

## Write for the tier

**Haiku** — do the searching in advance. Exact paths and line anchors, an in-repo
exemplar to mirror, exact commands, short explicit sequence. Enumerate targets
rather than asking it to find them. Keep it short.

**Sonnet** — state outcome, constraints, and boundaries; name entry points rather
than every file; include the intent so it can resolve cases the ticket missed.
Default tier for implementation.

**Opus** — state the problem, the invariants that must survive, and the decided
design. Be explicit about what is not open for redesign; leave the rest to it.

**Fable** — analysis and planning checkpoints. Hand it the merged state, the
findings, and the decision to make. Ask for a decomposition or judgment, not a
diff.

## Escalation

Every ticket names one escalation tier. Escalate when the assigned model fails
verification twice, stalls without converging, or reports the ticket is
underspecified.

The third case is feedback on the ticket — fix the ticket, not only the tier.

Failing at the escalation tier means the ticket is wrong. Re-split or hand back.

## Evaluator routing

Evaluate at or above the implementer's tier, always in a fresh session — an
author reviewing its own work already believes it is done.

| Implementer | Evaluator |
|---|---|
| Haiku | Sonnet |
| Sonnet | Sonnet for mechanical tickets; Opus where invariants or cross-module effects are at stake |
| Opus | Opus |

Raise the evaluator tier regardless of implementer when the merge is hard to
undo, the ticket touched a security or data-integrity path, or the wave gate is
about to run against `main`.
