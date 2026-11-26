---
name: spec-adopt
description: Brings an existing project's VISION, FUNCTIONAL and TECHNICAL documents under the spec system once, as one reviewable PR that changes no meaning - ids, serves and Realises lines, one terms table per level, records moved out of the contracts, LOG.md, and [spec] in factory/config.toml - and lists for the human everything that would change meaning. Also for a flat project that gains subsystems. Use when the human says "/spec-adopt", when spec-lint reports a project as not adopted and the human wants it fixed, or when a decided split adds a subsystem.
---

# /spec-adopt [<project>]

You restructure a project's documents so that `spec-lint` and `spec-check` can check them. You
change their form, never their meaning: whatever would change meaning is listed for the human, not
done.

## How to read the rules here

Rules use these words and no others. Capitals and bold add nothing.

- must / a bare imperative / "always" (with its scope): do it. Deviate only with the human's
  approval. If you cannot comply, stop that path, take the option that keeps the others open, and
  escalate.
- must not / never / do not: never do it, on the same terms.
- should / by default / prefer: the default. Deviate when this case has a reason the rule did not
  foresee, and write the reason in the PR body. Effort, cost or taste is no reason. Unsure:
  deliberate, then ask.
- should not / avoid: the same, inverted.
- may: your choice; no record. need not: not required. can: possible, never permission.
- unless / except: the complete list of exceptions.

Statements are decided unless marked: "(assumed)" is acted on but unconfirmed, "(open: O-n)" is
undecided. When two rules clash, the higher document wins, then must over should, then the more
specific rule; if they still clash, satisfy the stricter one, record the clash and report it.

## References

`../spec-change/references/`: `links.md` (the target form: ids, link lines, terms, `LOG.md`, the
`[spec]` keys), `placement.md` (the record test and the scope test), `language.md` (the vocabulary
and the reviewer checklist), and `vision.md`, `functional.md`, `technical.md` (sections and
templates). Read all of them before you start: adoption touches every kind of document.

## The meaning test

A change keeps meaning when an implementer reading the documents before and after would build and
test the same thing, and a reviewer would accept and reject the same work. Moving a sentence,
adding an id, a link line or a heading, writing "shall" as "must", and lowering capitals keep
meaning. Choosing a level, picking between two readings, adding or dropping a constraint, and any
new or reworded vision sentence change it. When you cannot tell, it changes meaning.

- Do not make a change that fails the meaning test, because the meaning is the human's and this PR
  is reviewed as form only. List it in the PR body under "For the human":
  the place, the text now, the text you propose, and why.
- A vision sentence you draft or reword is always a proposal: the human decided that an agent never
  adds vision text on its own.

## 0. Before you start

1. Run it when the project has no slice in flight that touches its spec documents, or tell the
   deputy which slices will need a rebase: the PR touches every contract (the factory README, "One
   writer on main").
2. Work on a branch `spec-adopt` from `origin/main`, in your own worktree or clone. The result is
   one PR against `main`.
3. Run `spec-lint` on the project as it is (`.claude/factory/spec-lint.sh`, or this plugin's
   `../../scripts/spec-lint.sh <root>`, relative to this skill's folder). Unadopted, it reports everything as warnings: that list,
   by check, is your worklist. Save it for the PR body.

## 1. The config (commit 1, with the LOG files)

- Write `[spec]` in `factory/config.toml`: `levels` from the existing `spec = [...]` list, and for a
  project with subsystems, `subsystems` with each folder that holds the three documents and has a
  row in the project TECHNICAL's parts table. Remove the top-level `spec` line in the same commit:
  TOML forbids a key and a table of one name. Keep each array on one line: the factory's scripts
  read the config line by line.
- A folder that has some of the three documents, or has them but no parts row, is not listed: put
  it under "For the human".
- Create `LOG.md` beside the project VISION and in each subsystem folder, with one entry: the date,
  "adopted by spec-adopt", and the PR.

## 2. Ids (commit 2)

- Give every goal `V<n>`, every non-goal or never line `VB<n>`, and every requirement `F-<AREA>-<n>`
  that lacks one, in the form of `links.md`; in a subsystem, with its prefix (`net:F-SYNC-1`).
- Keep every existing id exactly as it is, the older `NET-F-1` form included: tests, commits and
  other projects cite them, so a renamed id breaks links nobody can see from here.
- A V-shaped or F-shaped name that is not an item (a probe "V27" in a TECHNICAL) is written in
  backticks, which keeps its words and stops it reading as a goal.
- Two items with one id, or one item with two ids: list it; do not choose.

## 3. Link lines (commit 3)

- Each FUNCTIONAL area gets `(serves <ids>)` in its heading. Take the goals from what the area
  already cites (an outcome of the vision's Priorities names goals; a subsystem's Goals served
  table names them). Mark each link you inferred rather than read in the PR's link table, so the
  human checks those first.
- An area no goal motivates is a C1 gap: draft the vision sentence that would motivate it as a
  proposal, and leave the area without a `serves` line. Do not attach it to the nearest goal: a
  forced link hides the gap that the human has to close.
- Each TECHNICAL `##` section gets `Realises: <ids>` for the requirements it designs, by its own
  text. A section that designs none gets `Realises: –` and what motivates it.
- Each requirement no section designs gets an entry under `## Not designed yet` (create the section
  when missing): that states what is already true, and no design is added.
- Each subsystem VISION keeps or gets a `## Goals served` table of project goal ids, from its
  existing text.

## 4. Terms (commit 4)

- Each level keeps one terms table with `Term` as its first header cell.
- A term defined at two levels with the same meaning stays in the highest level that uses it; the
  lower copy goes, and the lower document cites it.
- A term defined twice with different meanings, or two words for one thing, is listed for the
  human: merging them is a choice of meaning. You may suggest a rejected-synonym row (`| basket |
  use list |`).

## 5. Records out of the contracts (commit 5)

Apply the record test (`placement.md`) to every sentence of every contract.

- Move each record whole into the record file the project keeps for that folder (`NOTES.md` when it
  has none): built notes, answered-question narratives, per-step diaries, slice or step ids used as
  status, completion dates, decision history. Leave a one-line "Origin: <file>" note where a reader
  needs the way to it.
- When a record is the only place a rule is stated, the rule stays in the contract: write it in the
  section that owns it at the same level, move the story, and list it as "rule extracted", with both
  texts, because a rewritten rule is where meaning slips.
- A version pin or a private module name (the code test) moves to the code's own comment or
  manifest only when the code already holds it; otherwise list it.

## 6. Vocabulary (commit 6)

- "shall" becomes the present tense or "must", at the same level. Capitals and bold used for weight
  become lowercase and plain.
- "may not", "should" inside a requirement, and the other words outside the vocabulary
  (`language.md`) are listed with the two readings: choosing one is choosing a level.
- Run the reviewer checklist of `language.md` over every sentence you touched in this commit.

## 7. Proposals for the vision (last commit, separate)

Everything here is proposed vision text, in one commit the human can drop whole: the C1 sentences
of step 3; the charter sections a subsystem VISION lacks (Mission, Responsibilities, Secrets, Never
lines with their owners), drafted from its existing sentences; and rewordings that take technology,
section numbers or ids out of a vision. List each in the PR body with the text it replaces.

## 8. Verify

1. Run `spec-lint` again. With `[spec]` written it is adopted, so its findings are errors. Each one
   left is listed in the PR body with why it stays (a proposal waiting, a choice for the human).
2. Run `.claude/factory/check-docs.sh` for the links.
3. Read `git diff origin/main --stat` and the diff of each commit. Every removed line is moved
   (find it elsewhere in the diff), extracted (listed), or proposed (listed): a removed line in none
   of these is a meaning change you made by accident; put it back.
4. Run `spec-check full` once and put its summary in the PR body. Its findings are for the human
   and for later `spec-change` runs; this PR fixes none of them, because fixing them changes
   meaning.

## 9. The PR

Push `spec-adopt` and open the PR. Its body holds, in this order:
1. One paragraph: what changed in form, with counts (ids added, links added, of which inferred,
   records moved, terms merged).
2. For the human: each meaning question, one decision each, with your recommendation.
3. Proposed vision text, each with the text it replaces.
4. Links inferred rather than read.
5. `spec-lint` before (its summary) and after (each error left), and the `spec-check full` summary.
6. How to put `spec-lint` in the gate: append `&& .claude/factory/spec-lint.sh` to the config's
   `gate` line in a follow-up commit once this merges, so every slice from then on keeps the links.

The PR merges only on the human's approval: it touches every contract, and the vision documents are
theirs. Do not merge it yourself, and do not arm auto-merge.

## A flat project that gains subsystems

Run it only after the split itself was decided (the decision ladder: the new subsystem's row in the
project TECHNICAL and its charter are a placement decision, `placement.md`), with that decision
cited in the PR.

- Create the subsystem folder with its three documents from the templates; its charter is a
  proposal (step 7).
- Add it to `[spec] subsystems`. The new subsystem's ids carry its prefix; project ids keep their
  names, so no existing link breaks.
- Move into the subsystem documents only the facts the scope test gives them, by moving the
  sentences whole. A project requirement stays in the project FUNCTIONAL; the subsystem's
  requirements trace up to it.
- Steps 8 and 9 hold as above.
