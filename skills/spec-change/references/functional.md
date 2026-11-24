# FUNCTIONAL: criteria and templates

Shared by `spec-change`, `spec-check` and `spec-adopt`. Source: `factory/research/spec-system/`,
report 10 sections 3.2, 3.5, 5 and 7. Words as in `language.md`.

## Project FUNCTIONAL

Purpose: what the product does, observable from outside, free of technology. Readers: the deputy
cutting slices, the user-sim agent, the validator checking acceptance.

- It must hold a terms table (every domain noun its requirements use, defined once); requirements
  with stable ids `F-<AREA>-<n>`, grouped in areas, each area heading citing the goals it serves
  (`links.md`); and journeys, one per success criterion of the vision, each naming the requirements
  it exercises. Lower documents cite these ids and terms, so without them coverage cannot be checked.
- It should hold the actors and their permissions, quality requirements a person observes
  (refusals name their cause, works offline), and what is explicitly later.
- It may hold limits and numbers a person sees, and a named outside service the person chooses.
- It must not hold subsystem or part names, file formats, protocols, libraries, algorithms,
  signatures, test paths, step or slice ids, or references into a TECHNICAL: each fails the
  rebuild test. A requirement must not say how the product checks itself ("verifies with Ed25519").

## A requirement

One trigger, one response, checkable, in present tense or with must (`language.md`, two
registers); never "shall", never "should" inside a requirement.

| Shape | Form |
|---|---|
| always | `<product> <response>.` |
| event | `When <trigger>, <product> <response>.` |
| state | `While <state>, <product> <response>.` |
| unwanted | `If <unwanted condition>, <product> <response>.` |
| option | `Where <feature is present>, <product> <response>.` |

Write it as `- **F-SYNC-3** When a phone joins the household, pantry sends it the whole list.`

- A requirement that joins three behaviours with "and" is three requirements.
- A requirement that only restates a goal adds nothing: refine it until it has a trigger and a
  checkable response.
- Each requirement traces to a goal: a reader of the vision could have predicted that it exists
  (C1, `links.md`). When no vision sentence motivates it, the vision needs the motivation, proposed
  to the human, or the requirement goes.
- FUNCTIONAL adds actors, terms, triggers, responses, visible limits and journeys. It must not add a
  goal, a kind of person, or anything a non-goal forbids.

## Subsystem FUNCTIONAL

Purpose: the observable behaviour of one part, from the side of its users and callers (other
subsystems are callers). Reader: that part's implementer and validator.

- It must hold the terms new to this subsystem only (a project term is cited, never redefined);
  requirements with prefixed ids `<sub>:F-<AREA>-<n>`, each area serving a project goal or
  requirement; and scenarios, each naming the requirements it tests.
- It should state its offer to other subsystems as behaviour ("when a caller asks what is held, net
  answers ..."), not as signatures.
- It must not restate what the project FUNCTIONAL says (it cites the id, because two copies drift),
  hold behaviour outside its charter, or name types, crates, protocols, paths or steps.

Checks: every requirement traces up; every responsibility of the charter has at least one
requirement; none falls under a never line of the charter.

## Template

(P) project only, (S) subsystem only; unmarked: both.

```
# <name>: functional specification
<one paragraph>    What this covers; free of technology; how ids are cited.
## Terms           | Term | Meaning |   (S: only terms new to this subsystem)
## Requirements
### <n.m> <Area> (serves V1, V3)
- **F-<AREA>-1** When <trigger>, <product> <response>.
## Quality         Observable qualities: refusals, offline, limits a person sees.
## Journeys        (P) One per success criterion: the steps and the requirements they exercise.
## Scenarios       (S) | Scenario | Requirements |
## Later           Requirements sketched only to keep the way open.
## Open            (may) - O-1 <question>. Options: ... Owner: ...
```
