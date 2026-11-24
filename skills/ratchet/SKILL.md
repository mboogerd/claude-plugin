---
name: ratchet
description: Improve an existing document by looping a critic, a planner that turns findings into independent changes, and judges that accept or reject each change on its own. Use when the user says "ratchet", or asks to tighten, sharpen, harden, or refine a whole document file — a skill, prompt, spec, README already roughly the right shape, needing its defects removed. Not cheap: many passes. Not for single sentences or paragraphs, not for source code, not for deciding what a text should be.
allowed-tools: Agent, Read, Write, Bash
---

# Ratchet

Improve a text against its own intent, one vetted change at a time. The champion only moves forward: changes are judged individually and only accepted ones fold in.

Every role is a fresh `Agent` call — `general-purpose` — given exactly its listed inputs, pasted in full, never a path: filenames name the incumbent. Critic and planner run `sonnet`, every judge `opus`: a missed finding costs a round, a wrong verdict is unrecoverable.

## Setup

**Target.** One file. Given a directory or multi-file document, ratchet the file carrying the intent (a skill directory's `SKILL.md`) and say which. Write pasted text to a working-directory file and target that. Under ~15 lines, decline: the loop costs more than it can return.

**Criterion.** What "better" means here — the user's words if given, else derived from the text. Every role receives it verbatim. Before round 1, put it to the user with the cost — up to four rounds, each a critic and planner pass over the text, a judgment per proposed change that also re-reads the full champion, and a final judgment over both champion and challenger in full — and wait for a go-ahead.

**Run directory.** `<target's directory>/.ratchet/<target-basename>-<timestamp>/`. Copy the target there unchanged as `r0.md`; create `ledger.md` and `state.md`. Nothing writes the target until the run ends.

**State.** `champion` = `r0.md`, `strikes` = 0, kept in `state.md`. No role receives it.

## Each round n

1. **Critic** — gets: the champion text, the criterion, `ledger.md`. Attacks the text against the criterion; structural proposals count — "wrong shape" is a legitimate finding. Leaves alone what the ledger marks accepted; may re-raise anything rejected or churned, with a different fix. Weighs its own hit rate there: most findings rejected means aim higher, not wider, and an honest empty result is worth more than a manufactured one.

2. **Planner** — gets: the champion text, the criterion, the findings, `ledger.md`. Turns the findings into a small set of **independent changes**, each a delta against the champion — an exact excerpt of its current text paired with the replacement text, so the orchestrator can fold it in by substitution alone — that stands alone and touches no text another delta touches. A single change may resolve several findings — cutting a sentence settles every finding inside it — and collapsing them that way is the point.

3. **Judges** — one per change, each getting: the criterion, the champion text, and that one change. Judges never receive the findings. Answers whether the change is a material improvement to the text against the criterion. Default no.

Fold the accepted changes into the champion to make the challenger. Below two accepted changes there is nothing to sit badly together: promote it unjudged. Otherwise a last judge gets the criterion and the two texts pasted as A and B, champion first on odd rounds, and answers which it would ship and whether the difference is material — it is never told which letter is which, and only the orchestrator can resolve its answer. Its one question is whether the changes sit badly together; each was already judged on its own merits, and that is settled. Promote the challenger unless the judge materially prefers the champion: write it to `r<n>.md`, set `champion` = `r<n>.md` in `state.md`, and `strikes` = 0. Otherwise `strikes` += 1, the champion stands, and the round's changes are churned.

Record each finding in `ledger.md` as `r<n> | <finding in a clause> | accepted` / `| rejected` / `| churned` — churned meaning its change was accepted but the fold was not. Nothing else goes in it, least of all a judge's reasoning: fed forward, a critic writes to the rubric instead of the text.

## Stopping

Stop at `strikes` = 2, after round 4, or when a round produces no accepted change.

Copy the champion over the target — the target is left untouched if no round earned it. Report the criterion, which rounds advanced the champion, and the run directory to keep or delete; `r0.md` there is the original.
