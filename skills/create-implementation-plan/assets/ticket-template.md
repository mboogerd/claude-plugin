# [TICKET-ID] — [outcome as a change to the system, not an activity]

**Status:** not-started | in-progress | in-review | merged | blocked
**Model:** [tier] · **Escalate to:** [tier]
**Wave:** [n] · **Branches:** `ticket/<id>` — or `accept/<id>` + `impl/<id>` → `integrate/<id>`

## Your role

[Only for twin-checkout tickets. One of:]
- **Acceptance** — implement the acceptance criteria below as tests. Do not read
  or modify implementation code. The tests must fail today.
- **Implementation** — implement the solution direction. Do not write acceptance
  tests. You will be judged against the acceptance criteria below.

## Context

What the system does here today, and why this work exists. Written for an agent
with no prior session and no access to the planning conversation — it knows the
codebase only through what you cite.

## Problem

Concretely, with evidence: `path/to/file.kt:120`.

## Solution direction

The decided design. State what is settled and what is left to the implementer's
judgment.

## Files expected to touch

- `path/to/file.kt` — [what changes]

Touching files outside this list: note it in the completion report rather than
expanding silently. Parallel work is scheduled on this claim.

## Read first

- `doc/spec/....md` §N — [why it matters]
- `path/to/exemplar.kt:40-90` — [pattern to mirror]

Do not modify: [files owned by other tickets]

## Acceptance criteria

- [ ] [checkable statement]
- [ ] [checkable statement]
- [ ] No unrelated files in the diff

## Verify

```bash
[exact command]
```

## Report on completion

- Checks run and their results
- Files actually touched, and any not in the claim above
- Anything specified here you could not do, and why
