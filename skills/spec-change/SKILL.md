---
name: spec-change
description: Turns a decision or preference the human states about why, what or how a project works into one checked change across its VISION, FUNCTIONAL and TECHNICAL documents (flat or with subsystems), with the human's words kept in LOG.md and vision edits only proposed. Use when the human states such a decision or preference in any session, says "/spec", or when the deputy answers a build team's question with a fact the spec lacks.
---

# /spec

You keep a project's contracts current while the human talks. Each change is classified, placed,
checked, shown and logged, so that a literal agent reading the documents later builds what the
human meant, no more and no less.

## How to read the rules here

Rules use these words and no others. Capitals and bold add nothing.

- must / a bare imperative / "always" (with its scope): do it. Deviate only with the human's
  approval. If you cannot comply, stop that path, take the option that keeps the others open, and
  escalate.
- must not / never / do not: never do it, on the same terms.
- should / by default / prefer: the default. Deviate when this case has a reason the rule did not
  foresee, and write the reason in the change's `LOG.md` entry. Effort, cost or taste is no reason. Unsure:
  deliberate, then ask.
- should not / avoid: the same, inverted.
- may: your choice; no record. need not: not required. can: possible, never permission.
- unless / except: the complete list of exceptions.

Statements are decided unless marked: "(assumed)" is acted on but unconfirmed, "(open: O-n)" is
undecided. When two rules clash, the higher document wins, then must over should, then the more
specific rule; if they still clash, satisfy the stricter one, record the clash and report it.

## References

In `references/` beside this file, shared with `spec-check` and `spec-adopt`:
- `placement.md`: which document a fact belongs in, and the charter test for subsystems;
- `language.md`: the vocabulary, certainty, how to set a level from the human's words, the reviewer
  checklist;
- `links.md`: ids, `serves` and `Realises:` lines, terms, `LOG.md`, what consistent means, new
  concepts (C1 to C4), what `spec-lint` checks;
- `vision.md`, `functional.md`, `technical.md`: what each document holds, with templates.

Read `placement.md`, `language.md` and `links.md` before your first change in a session, and the
document file of each document you edit: the rules below assume them.

## 0. Before you start

1. Find the project root `P` (the deputy's section 0, or the repository you are in) and its
   `factory/config.toml`. `[spec] levels` names the three project documents, highest first, and
   `[spec] subsystems` the subsystem folders; without `subsystems` the project is flat. A config
   that has only the older `spec = [...]` list is not adopted yet: work from that list, give each
   item you add an id as `links.md` says, and tell the human once per session that `spec-adopt`
   has not run. Do not adopt in passing: adoption is one reviewable PR of its own.
2. Run `spec-lint` and keep its output as the baseline: `"$P"/.claude/factory/spec-lint.sh` (this
   plugin's `../../scripts/spec-lint.sh "$P"`, relative to this skill's folder, where the project has no copy). Step 5 compares
   against it, so you fix only what your change broke.
3. Note who you work for. With the human: they are at the keyboard (a turn their own message
   started). As the deputy: the human is away, and you record a decision for a build team.

## 1. Classify each part of the message

| Class | Sign | Becomes |
|---|---|---|
| decision | states what is or must be | a statement |
| preference | leans, with a qualifier ("usually", "I'd rather") | a statement at a should or may level |
| question | asks | an answer, no statement |
| example | "say", "for instance", a case to illustrate | nothing, unless the human says it is the rule |
| thinking aloud | "maybe", "what if", "I wonder" | nothing; an `O-n` open point when work needs it |

As the deputy, your own answer to a build team is a decision: skip this step.

Only decisions and preferences become statements. When a part could be two classes, ask, and never
pick the stronger: models rewriting text drop hedges, so a guess upward turns a musing into a rule
nobody decided.

## 2. Extract each statement

For each decision or preference, write down:
- the statement in the project's own words and terms;
- its document, by the tests of `placement.md` in order, and its scope (project or a subsystem,
  by the scope test and the charter test);
- its obligation, by what the words mean to allow (`language.md`, "Setting levels"), and its
  reason, or `(reason: not given)` when the human gave none and you did not ask;
- its certainty: decided, `(assumed)`, or open;
- said or inferred: inferred when the human did not say it but it follows from what they said;
- the human's words, verbatim; as the deputy, the question and your decision instead.

A statement that passes the record test is not a contract: it goes to `PLAN.md` or `LOG.md`.

## 3. Find the impact set

1. By id: the item you change, its parents (the ids its `serves`, `Realises:` or inline citations
   name) and its children (`grep -rn '<id>'` over every document of every level).
2. By term: every use of each term you add, rename or redefine, in every document of every level
   (`grep -rniw '<term>'`).
3. By title: list the item titles of the sibling documents (headings and the first line of each
   id), and pick the ids that could conflict with the statement. Judge from titles only.

Read the union in full. Edit only items in it: an edit outside it changes meaning nobody asked to
change.

## 4. Draft one change set

One coherent change across every file in the impact set.

- Write each statement at the level and certainty from step 2, with its reason, in the shape of its
  document file (an EARS requirement, a charter line, a decision row).
- Give a new item the next unused id of its area; never reuse a retired one (`LOG.md`): tests,
  commits and records still cite the old one.
- Apply C1 to C4 (`links.md`, "New concepts") to each new concept:
  - no vision parent (C1): draft the motivating vision sentence as a proposal. You must not write it
    into the VISION: the human chose that a vision sentence an agent drafts is always theirs to
    approve. Show it as a question in step 6; on a no, drop the concept too.
  - no technical realisation (C2): add an entry under `## Not designed yet` with the step that needs
    it, and no design: the build team that builds it designs it.
  - a new interface, format or boundary without a functional parent (C3): add the functional
    statement it implies, marked inferred.
  - outside its subsystem's charter (C4): do not place it; run the charter test (`placement.md`),
    and bring the result to the human as a question.
- A rename applies everywhere in the impact set, in the same change set: it changes no meaning, and
  a half-done rename leaves two words for one thing.
- A statement the new one contradicts is shown as replaced ("replaces F-SYNC-2"), never silently
  overwritten, and its id is retired in `LOG.md`: the human sees what goes, and a later reader can
  trace why.
- Never strengthen or weaken an obligation, and never widen a scope ("for pages" stays "for
  pages"), beyond the human's words: a literal reader builds exactly what the level says.
- Do not merge two statements into one rule unless the human said both: a merged rule ties each
  case to the other's conditions.
- Ask before you change any must or must not, any security check, or any vision statement, even
  when the human's words seem to carry it (`language.md`): these are the human's to set.
- When the statement clashes with a higher document, write nothing yet: ask, quoting both.
- When it clashes with a document on another axis (a subsystem vision against the project
  technical), do not resolve it here: it goes to the decision ladder (the deputy skill).
- The human's words never go into a contract: a literal agent would read a chatty quote as a rule.
  They go into `LOG.md` and the commit message.

## 5. Check

1. Run `spec-lint` with `--diff HEAD`. Each error that is not in the baseline is yours: fix it
   before you show anything. Its M10 notes are candidate new terms for step 2 of `spec-check`.
2. Run `spec-check` in diff mode on the change set. Fix each finding the change introduced, or show
   it in step 6 with why it stands.
3. Apply the reviewer checklist of `language.md` to each rule you wrote or moved, and compare each
   moved sentence's level before and after.

## 6. Show

With the human at the keyboard, show, in this order:
1. A statement table: id, document, old to new, level, said or inferred, the human's words.
2. The questions, one decision each, with your recommendation and the cost to undo each option:
   proposed vision sentences, any must, security check or vision statement you would change, the
   levels you recorded as `(assumed)` because two fit, and C4 placements.
3. The diff by path (`git -C "$P" diff -- <paths>`): it is the record of what changes.

Commit nothing before the human has seen it and answered the questions: the documents are theirs.

As the deputy, with the human away: commit only statements you may decide alone (the deputy's
decision rules). Add one line per change under `Deputy decisions` in `PLAN.md` so the human can
veto it. A proposed vision sentence, a changed must, a security check, a vision statement or an
open placement is not committed: put it under `Waiting on the human` with the drafted text, and
have the build team build the option that keeps the others open meanwhile.

## 7. Commit and log

1. Add one entry at the top of each `LOG.md` whose level the change set edits (the project's beside
   its VISION, a subsystem's in its folder), in the format of `links.md`: the date, the human's
   words, each statement by id with its level, ids replaced and retired, vision proposals with their
   answers, and deferrals. Create the file when it is missing.
2. Commit by path, never `-a` or `add -A`: another session may have edits in that checkout. The
   message is one line of what changed, then the human's words.
3. Commit on `main` only when no slice in flight touches those files (the factory README, "One
   writer on main"), because a direct commit to a file a slice owns leaves its rebase to someone
   else; otherwise on a branch `spec/<slug>` with a PR. A build team commits on its own
   slice branch. After a commit on `main`, push it: cloud teams start from `origin/main`.

If you find that you committed something the human had not seen, or wrote a level their words do
not carry: tell the human at once, show the commit, and revert it on their word in a new change set
logged like any other.

## 8. Flat and hierarchical projects

- Flat: one set of documents, ids without a prefix, no charter test beyond the project VISION.
- Hierarchical: a statement about one subsystem's inside or offer goes into that subsystem's
  document with its prefix; a statement that concerns more than one subsystem, or a person using the
  whole product, goes into the project's. A subsystem document cites a project fact by id and never
  restates it, because two copies drift.
- A flat project that gains its first subsystem, or a new subsystem, is a `spec-adopt` run, not a
  `spec-change`.
