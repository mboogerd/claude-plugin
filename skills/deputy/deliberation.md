# Deliberation, records and the human's brief

The reference for rungs 2 and 3 of the decision ladder (`SKILL.md`, section 5). Rules use only
must, must not, should, should not, may, need not, can and unless; capitals and bold add nothing.
Why each step is there: `<collection>/factory/research/spec-system/40-decision-ladder.md` (a record,
not the rule).

## 1. Roles

- The steward is the agent that met the issue: you, or a foreman inside its slice. You frame the
  issue, run the steps, write the record, and copy the counterpart's text verbatim. You are a party,
  not a judge.
- The counterpart is Codex, in a fresh context, given the same documents.
- There must be no judge model: a judge prefers its own model's text and shares the others' errors,
  so the stopping rule (section 4) decides instead.
- Do not assign fixed proponent and critic roles: a side made to argue an option it does not hold
  produces theatre, and a fixed critic concedes under pressure. Each side argues for one option and
  against another, in different steps.

## 2. Steps

1. Frame (you). The issue as one question; each clause quoted in full with its path and section;
   Door, Fit and Kind (`SKILL.md`, section 5); the drivers, each traced to a clause. Name no option
   yet: a framing with options steers the counterpart's blind position.
2. Blind positions (both, independently). Each side lists the options it sees (at least two, and one
   that changes no document if one exists), its choice, and for each option the arguments for and
   against, each tied to a clause or a piece of evidence. Codex also answers "is the question framed
   fairly?". You must write your own position into the record before you read Codex's: a position
   written after reading the other is not independent.
3. Merge (you). One tree (section 3): the union of options and arguments, each tagged with who raised
   it, each argument marked diagnostic when it tells options apart.
4. Cross-examination, round 1 (both). Each side gets the merged tree and must write the strongest case
   for an option it did not choose, then its strongest objection to its own choice, then its choice
   again. A changed choice must name the argument that changed it; a change without one is recorded
   as conformity and does not count.
5. Round 2 only when the choices still differ and round 1 brought in a new argument. There must be no
   round 3: a third round adds cost and deference, not arguments.

Limits: at most 3 Codex calls per issue (blind, round 1, round 2), each asked to answer in about 800
words. A slice with two deliberations behind it should be re-sketched instead of deliberating a
third time: that many open questions mean the sketch is unclear.

Team deadlock (the same finding three rounds running) should be deliberated on the PR: the two teams
are already two vendors. Send each side a brief that asks for its blind position on the finding
(step 2), post both verbatim, then a brief that asks for step 4; you merge and check section 4.

## 3. The tree

```
Q  <the question>
   clauses: <path §n "quoted text"> ...
   drivers: <what matters, each traced to a clause>
O1 <option>  changes: <documents> door: <none|C|H> undo: <how and cost>
   + <argument> [<who>, <clause or evidence>, diagnostic: yes|no]
   - <argument> [<who>, ...]  status: open | rebutted by <ref> | accepted cost
O2 ...
Positions: blind: claude O1, codex O2; r1: claude O1, codex O1 (moved by O2-a3); r2: -
```

The chosen option must carry at least one con: a record without one is incomplete.

## 4. A rational conclusion

A deliberation has a rational conclusion when all six hold:
1. Both sides choose the same option at the end of the last round run.
2. Every change of choice names the argument that caused it.
3. Every diagnostic argument against the chosen option is rebutted (with a reference) or an accepted
   cost for both sides; an open diagnostic con blocks.
4. The chosen option keeps every VISION clause as written and touches no Door H class.
5. A factual premise that decides the issue is backed by the repository, a test or a primary source,
   not by both models believing it.
6. Each option was steelmanned by a side that did not choose it.

Anything else goes to the human (rung 3), with the tree as the brief's source. On a Door C issue, a
blind disagreement that ends in agreement only because one side moved without new evidence also goes
to the human: the two vendors' models make correlated errors, so their agreement alone is weak
evidence. Blind agreement, and a dissenter's steelman that added no diagnostic con, count as stronger.

## 5. Guards

- Give both sides the clauses verbatim, never your paraphrase: a paraphrase carries your reading.
- The prompt to Codex must not say which option you prefer or that you are the deputy: an authority
  cue makes the counterpart defer.
- Do not settle a fact by agreement: send it to a probe task or a test, since a premise both models
  share is untested.

## 6. Running Codex

Run Codex locally, read-only, with stdin closed: deliberation reads documents and writes text, needs
an answer in seconds, and needs the exact files at the exact commit, which a cloud task starting from
`origin/main` does not have. The human accepted this exception to "nothing runs on the Mac" for
deliberation only (2026-11-23). Write the prompt to a file in a fresh temporary folder, then:

```
d=$(mktemp -d); # prompt in "$d/prompt.md"
codex exec -C "$P" -s read-only -o "$d/answer.md" "$(cat "$d/prompt.md")" </dev/null
```

- `-s read-only` must stay: the call must not write to any checkout or build anything; a team's work
  runs in a cloud (`README`, "Nothing runs on the Mac").
- `</dev/null` must stay: with stdin open, `codex exec` waits on it or appends it to the prompt.
- Each call is a fresh context: put everything that step needs (frame, clauses, the merged tree) in
  its prompt.
- Copy `answer.md` into the record verbatim, then delete the folder.

When the local call fails (not signed in, the CLI missing, an error twice), use a Codex Cloud task in
ask mode, no code change, through the browser pane (`SKILL.md`, 4c), with the same limits; it starts
from `origin/main`, so push the text under discussion first or quote it in full. When Codex is down
on both, a fresh Claude subagent with no context may stand in, and the record must say so (`codex:
absent`). A Door C conclusion reached that way must go to the human (rung 3): same-model agreement is
not independent.

## 7. The record

Rung 1 is one line under `Deputy decisions` in `PLAN.md`. Rungs 2 and 3 each get a file
`factory/decisions/D<nnn>-<slug>.md` (the next free number), which you commit to `main` by path, as
`PLAN.md`, and one line under `Deputy decisions` or `Waiting on the human` that links it. It holds:

```yaml
---
id: D017
date: 2026-11-23
rung: 3             # where it ended
trigger: cross-axis # door-C | cross-axis | doc-conflict | judgement | team-deadlock | H-class
door: [H]           # classes touched
docs: [spec/TECHNICAL.md#5, net/VISION.md#boundaries]
blind_agree: false
rounds: 1
codex: local        # local | cloud | absent
outcome: escalated  # concluded | escalated
human: pending      # pending | accepted | vetoed | answered-<option>
---
```

then the frame, both blind positions verbatim, the tree, the six conditions of section 4 each with
yes or no, the outcome, the spec edits it caused, and later the human's answer or veto. The fact
itself must go into the document that owns it (the `spec-change` skill); the record keeps only why.
A record is a record: a later agent may cite it for why and must not cite it as the rule.

Patterns, at each handover (`SKILL.md`, section 8): read the front matter of the records since the
last handover. A `trigger` and `docs` pair seen three times, or a human veto of a rung 2 conclusion,
must become a proposal to the human for a spec rule or a ladder change: a repeated question means a
missing rule. More than about two rung 3 questions a week in one project should be reported with
their triggers: either the specs lack a rule or the ladder is too timid.

## 8. The human's brief

```
<The question, as one sentence a newcomer understands.>
Recommendation: <option> (<one clause why>). If you do nothing: <what happens, by when>.

Context. <3 to 6 sentences: the project, the part involved, what is being built, why the question
came up now. Explain each name once; no ids, slice numbers or file paths here.>

The conflict. <The two rules or needs that pull apart, in plain words, and what each protects.>

Options.
A. <name>. <what it means in practice>. Strongest case: <its best argument, as its advocate would
   put it>. Against: <the strongest objection>. Undo: <what reversing takes, and when it gets harder>.
B. ...

What the agents found. <whether Claude and Codex agreed blind, where they differed, what neither
could settle, and the rule that sends it to you>

Sources: <record path, clauses with paths>.
```

The brief must be readable with no other document open, must give each option its strongest case and
its cost to undo, must say what happens if the human does not answer, and must not put an internal id
in the prose: the human reads it between other work. It should stay under 400 words. A brief without
a recommendation must not be sent.

## 9. Example (constructed for illustration, not an open question)

> Should the networking part of watane be allowed to keep a short-lived copy of search results?
> Recommendation: A, allow it narrowly (fastest searches, smallest change). If you do nothing: the
> current build answers each search by asking again over the network; nothing breaks, searches on a
> laptop stay about as slow as today.
>
> Context. watane lets people share and install mods without a central server. A person's machines
> sync with each other directly. A "light" machine (a laptop) does not keep everything; it asks one of
> the person's "full" machines (an always-on computer) when it searches. Two parts are involved: the
> networking part, which only moves data between machines, and the distribution part, which stores
> and verifies everything a person follows. The project's technical plan says a light machine should
> answer a repeated search from a local copy kept for a day.
>
> The conflict. The networking part's own vision says it must never store channels: storage belongs to
> the distribution part, so that one part alone decides what is kept and verified (this protects the
> project goal "safe by default"). The project's technical plan, which ranks above the part's documents
> but below visions, wants the copy for speed. One of them has to give.
>
> Options.
> A. Amend the networking part's vision: it may keep a copy of search answers for at most a day, only
> of data already verified, never as a source for installs. Strongest case: search results are
> answers to the networking part's own questions, not channels; keeping them where they arrive is
> simple and fast, and the limits keep the boundary's purpose intact. Against: a boundary with an
> exception invites the next exception. Undo: delete the copy and the clause; easy until other parts
> rely on it.
> B. Keep the vision; the distribution part keeps the copy, and the networking part asks it first.
> Strongest case: no vision changes; one part keeps owning all storage, as designed. Against: every
> search now crosses between two parts and changes the interface between them; more code for the
> same result. Undo: moderate, an interface change between two parts.
> C. Drop the copy from the technical plan. Strongest case: no change to any rule; searches already
> work. Against: repeated searches on a laptop stay slow, which the plan meant to fix. Undo: trivial.
>
> What the agents found. Claude chose B and Codex chose A independently. After one exchange both chose
> A: Claude moved on the argument that search answers are not channels. Both agree C costs speed for
> nothing. It reaches you because A changes a vision, which only you may do.
>
> Sources: `factory/decisions/D017-search-copy.md`; `net/VISION.md` "Boundaries"; `spec/TECHNICAL.md`
> (the search-copy clause).
