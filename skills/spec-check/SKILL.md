---
name: spec-check
description: Checks a project's VISION, FUNCTIONAL and TECHNICAL documents (flat or with subsystems) for consistency, and writes only a findings report. Runs spec-lint, then small pairwise judgment checks J1 to J7, keeps only findings whose quotes a script finds in the files, has the other vendor confirm the severe ones, and skips tensions the human accepted. Use when the human says "/spec-check", when spec-change checks a change before showing it, when the deputy is about to sketch a slice, or after a project gains subsystems.
---

# /spec-check [diff <base> | full]

You find where the spec documents disagree with each other. You report; you do not fix: a checker
that edits what it checks hides its own mistakes, so fixes go through `spec-change` or a build team.

## How to read the rules here

Rules use these words and no others. Capitals and bold add nothing.

- must / a bare imperative / "always" (with its scope): do it. Deviate only with the human's
  approval. If you cannot comply, stop that path, take the option that keeps the others open, and
  escalate.
- must not / never / do not: never do it, on the same terms.
- should / by default / prefer: the default. Deviate when this case has a reason the rule did not
  foresee, and write the reason in your report. Effort, cost or taste is no reason. Unsure:
  deliberate, then ask.
- should not / avoid: the same, inverted.
- may: your choice; no record. need not: not required. can: possible, never permission.
- unless / except: the complete list of exceptions.

Statements are decided unless marked: "(assumed)" is acted on but unconfirmed, "(open: O-n)" is
undecided. When two rules clash, the higher document wins, then must over should, then the more
specific rule; if they still clash, satisfy the stricter one, record the clash and report it.

## References

`../spec-change/references/` holds the criteria: `links.md` (what consistent means, the ids, what
`spec-lint` checks), `language.md` (the vocabulary, for J3), `placement.md` (the charter test, for
J5), and `vision.md`, `functional.md`, `technical.md`. Read `links.md` before the first run in a
session.

## 0. Scope of a run

- diff (the default): the items changed since a base. `spec-change` passes `HEAD` (its uncommitted
  change set). The deputy passes the commit of its previous run, which it notes in `PLAN.md` as
  `spec-check <sha>` after each run.
- full: every item. Run it when the human asks, after `spec-adopt`, and when a slice reports a spec
  conflict.

You write nothing to the project except `ACCEPTED.md`, and that only on the human's word (step 7).

## 1. Run spec-lint

`"$P"/.claude/factory/spec-lint.sh --diff <base>` (or this plugin's `../../scripts/spec-lint.sh --diff <base>
"$P"`, relative to this skill's folder; in full mode leave out `--diff`). Its errors open the report as they are. Do
not judge a pair whose ids do not resolve (M2): the judgment would rest on a broken link. Its M10
notes are the candidates for J1.

## 2. Build the pairs

| Check | Question | The judge sees | Verdicts |
|---|---|---|---|
| J1 | Is the candidate term a new concept, a synonym of a defined term, a part of one, or a means? | its sentence and the 5 nearest terms rows | new, synonym, part, means, unclear |
| J2 | Does the cited parent motivate the child? | the child item and one parent item | ok, unmotivated, unclear |
| J3 | Does the child contradict, widen or weaken its parent? | the same pair | ok, conflict, weaker, unclear |
| J4 | Does the item conflict with a sibling at its level? | the item and one sibling | ok, conflict, unclear |
| J5 | Does a subsystem item fall inside its charter? | the item and the charter's responsibilities and never lines | ok, outside, forbidden, unclear |
| J6 | Is the term used in the meaning its table gives? | the definition and up to 5 uses | ok, drift, unclear |
| J7 | Does the item agree with one parent and clash with a parent on another axis? | the item and both parents | ok, conflict, unclear |

Where the pairs come from:
- diff mode: for each item the diff adds or changes, J2 and J3 with each parent it cites; J4 with
  each sibling whose title could conflict (judge from titles, as in `spec-change` step 3); J5 when it
  is a subsystem item; J6 for each term the diff defines or redefines; J1 for each M10 note; J7 when
  the item has parents on two axes (a subsystem item under both its own vision and the project
  TECHNICAL). A J1 verdict of new runs C1: J2 with the item's vision parent, and unmotivated when it
  cites none.
- full mode: every requirement with the goals its area serves (J2, J3), every `Realises:` section
  with the requirements it names (J3), every subsystem requirement with its charter (J5), every term
  that more than one level uses (J6). Judge at most 60 pairs, because each pair costs a subagent;
  take guard items first, because their findings are the severe ones: non-goals and never lines,
  the security sections (the config's `boundaries`), musts. List what you left unjudged.

## 3. Judge each pair in a fresh context

Give each pair to its own subagent (the Agent tool) with this prompt and nothing else: no other
document, no other pair, no earlier verdict. A long or mixed context loses detail in its middle,
and a judge that saw other findings anchors on them.

```
You judge one pair of statements from a product specification. You see only these two; judge only
what they say, and assume nothing about the rest of the specification.

Check <J>: <the question from the table>.
In these documents "must" and a present-tense statement are obligations, "should" is a default,
"may" is a free choice, "(assumed)" is unconfirmed.

Item A (<id>, <file>):
<the item's text, verbatim>

Item B (<id>, <file>):
<the item's text, verbatim>

Answer "ok" and nothing else when <the ok case of this check>. Otherwise answer with one block,
the quotes copied character for character from the items above, each the shortest span that shows
the problem, on one line:

## 1 <J> <verdict>
ids: <A id> / <B id>
file: <A file>
quote: <span of A>
file: <B file>
quote: <span of B>
reason: <one line, stated as a fact>

Verdicts: <the verdict list>. Answer unclear when the two items do not settle it.
```

## 4. Keep only findings with real quotes

Write the blocks to one file in your scratch folder and run `"$P"/.claude/factory/spec-quotes.sh
<file> "$P"` (this plugin's `../../scripts/spec-quotes.sh` where the project has no copy). It prints the blocks whose quotes are in their files and names each dropped one on
stderr. Use only what it prints: a quote the files do not hold means the judge made it up.

## 5. Set the severity

The checker sets it, not the judge, because only the checker knows which items guard something.

| Severity | Findings |
|---|---|
| critical | J3, J5 or J7 against a non-goal, a never line or a security boundary |
| high | any other J3 conflict or weaker, J5 outside or forbidden, J7 conflict |
| medium | J2 unmotivated, J4 conflict, J6 drift, J1 new with no vision parent |
| low | J1 synonym, any unclear |

## 6. Confirm critical and high with the other vendor

Each critical or high finding needs a second judge from the other vendor before it counts: two
vendors' models make different mistakes, and a judge tends to prefer its own model's reading. Give
the second judge the same prompt with items A and B swapped, then run step 4 on its answer.

- From a Claude session: `codex exec -s read-only --ephemeral -C "$P" -o <answer file> - < <prompt
  file>`. Local and read-only, so it reads the exact commit and changes nothing.
- From a Codex session: `claude -p --allowedTools "Read Grep Glob" < <prompt file> > <answer file>`.
- Both keep it: it counts at its severity. The second answers ok or unclear: it moves to unsure.
- No second judge can run (no CLI, a cloud without one): it moves to unsure, marked unconfirmed,
  and the report says why.

Run at most 10 second judgments per run, worst first, because each is a call on the other vendor's
subscription; the rest are unconfirmed. Unsure findings
never count as critical or high.

## 7. Skip accepted tensions

`ACCEPTED.md`, beside the project VISION, holds the findings the human accepted, in the block
format of step 3 with a header `## A<n> <J> <ids>` and two more lines, `accepted: <date>, the human:
"<their words>"` and `reason: <why it stands>`.

- Run `spec-quotes.sh` on it. A finding is skipped when an entry that still holds names the same
  check and ids: the human decided it, and repeating it buries new findings. An entry that no longer
  holds (a quote changed) is stale: its pair is judged again, and the report names the entry.
- Add an entry only when the human, in this conversation, accepts a named finding. Commit it by
  path with their words in the message, by the rules of `spec-change` step 7. This is the one file
  you may write.

## 8. Report

```
spec-check <mode> <base>: <k> findings (<c> critical, <h> high), <u> unsure; <p> pairs judged,
<d> dropped by the quote check, <a> skipped as accepted, <n> not judged
spec-lint: <its summary line>, then its errors

<severity> <J> <ids>: <reason>
  <file>: "<quote>"
  <file>: "<quote>"
  next: <fix the lower document | the human decides | the decision ladder>
...
unsure: <at most 5, the same shape>
not judged: <what, and why>
```

- At most 30 findings, worst first: a long list goes unread, and the worst ones are the ones that
  matter.
- A critical finding is fixed in the lower document or taken to the human. It must not be resolved
  by reading the vision another way, because the vision is the human's.
- A J7 finding goes to the decision ladder (the deputy skill), never to a quick fix: both sides cite
  a rule, so choosing between them is a decision.
- `spec-change` fixes what its change introduced; the deputy turns a critical finding into a spec
  fix before any new slice.

## 9. Calibration

`fixture/` beside this file is a tiny adopted project with seeded defects, listed with the expected
verdicts in `fixture/EXPECTED.md`. When the prompt, the verdicts or the severities in this file
change, run a full check with `fixture/` as the project root and compare with `EXPECTED.md`: report
how many seeded defects it found and how many sound pairs it flagged. A change that finds fewer
seeded defects must not be kept without the human's approval: the fixture is the only measure of the
checker.
