# VISION: criteria and templates

Shared by `spec-change`, `spec-check` and `spec-adopt`. Source: `factory/research/spec-system/`,
report 10 sections 3.1, 3.4, 4 and 7. Words as in `language.md`.

A vision is the human's document. An agent must not add, remove or reword a vision statement on its
own: it proposes the sentence, and the human answers (`spec-change`, step 5). Moving an existing
sentence under a template heading without changing its words is not a change of meaning.

## Project VISION

Purpose: why the product exists and what it will and will not be; the yardstick for every lower
decision. Readers: the human, the deputy choosing the next slice, any agent judging a conflict.

- It must hold a one-paragraph statement (for whom, what, unlike what); the problem and why now;
  numbered goals `V1..`, each an outcome for a named kind of person; non-goals `VB1..`, each phrased
  so that a requirement could violate it; and success criteria a person can observe. These are what
  the lower documents cite, so without them nothing below can be checked.
- It should hold trade-offs: principles that settle a conflict between goals ("V5 beats V3 when
  they conflict"), each naming the goals it ranks. They are what an agent cites when two goals pull
  apart, so without them each conflict goes to the human.
- It should hold priorities: a ranked list of outcomes, each in words a person could observe and
  naming the goals it serves, with what waits until later and for what. It ranks; it does not
  schedule. Steps, their numbers, dependencies between them, status and what may run in parallel
  belong in the build plan, which breaks each outcome down and cites it by its words.
- It may hold named people or personas.
- It must not hold technology, formats, part names, requirement ids, slice or step ids, status,
  completion dates, file paths or links to lower documents: each fails the redesign test and goes
  stale when the product changes underneath.
- A goal must not be a feature: "search by interface" is functional; "a person finds work that fits
  their need" is a goal.

Checks: every goal passes the redesign test; every goal is served by at least one functional area
(`spec-lint` M5); every non-goal can be violated; every trade-off names two goals; every priority
names its goals and holds no step id, status or link; no sentence says how; under about 1200 words.

Failures to watch for: the vision as roadmap (status, step numbers, "each step before the next"
or links to the plan creep into Priorities); the vision as feature list; goals so broad nothing
violates them; no non-goals.

## Subsystem VISION: a responsibility charter

A subsystem exists because the project TECHNICAL decided the split, so its charter must agree with
its row in the project's parts table and must name the project goals it serves.

| Section | Rule |
|---|---|
| Mission | must: "`<name>` is the one place that `<verb> <object>`", a uniqueness claim |
| Role | should: one or two of information holder, service provider, structurer, coordinator, controller, interfacer; it tells a reader at once whether decisions or data belong here |
| Responsibilities | must: 3 to 9 lines "knows / does / decides `<object>`", each specific enough that work either falls under it or not, each in exactly one charter of the project |
| Secrets | should: what it hides that may change without others noticing, without technology names; the strongest placement signal |
| Never | must: lines "never `<thing>`: `<owner>` does", each naming the owning subsystem or the project non-goal that forbids it; a line without an owner leaves a hole the placement test cannot close. Ids `<sub>:VB<n>` |
| Collaborators | should: relies on and relied on by, by role, not by interface |
| Goals served | must: a table of project goal id to how this part serves it (`spec-lint` M6) |
| Success | must: observable outcomes of this part, checkable through the journeys or its scenarios |

It must not hold technology, libraries, types, traits, file paths, section numbers of any TECHNICAL,
or requirement ids of its own FUNCTIONAL: a charter decides where work goes and outlives each
design.

## Template

(P) project only, (S) subsystem only; unmarked: both.

```
# <name>: vision
<statement>        (P) For whom, what it is, unlike what. (S) "<name> is the one place that ...".
## Why             (P) The problem and why now. (S) Why this part exists: its row in the project TECHNICAL.
## Role            (S) One or two role stereotypes.
## Goals           (P) - **V1 <short name>.** <outcome for a kind of person>
## Goals served    (S) | Project goal | How this part serves it |
## Responsibilities (S) 3 to 9 lines: knows / does / decides <object>.
## Secrets         (S) What it hides that may change.
## Never           (S) - **<sub>:VB1** Never <thing>: <owner> does.
## Non-goals       (P) - **VB1** <what the product will not be>
## Collaborators   (S) Relies on / relied on by, by role.
## Trade-offs      (P, should) - V.. beats V.. when <conflict>. No id: the goals name it.
## Priorities      (P, should) 1. <outcome> (V..). Ranked; no step ids, status or links.
## Success         Observable outcomes of the current horizon.
## Later           (may) What waits, and for what.
## Open            (may) - O-1 <question>. Options: ... Owner: the human.
```
