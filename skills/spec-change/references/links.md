# Links between the documents, and what consistent means

Shared by `spec-change`, `spec-check` and `spec-adopt`; `scripts/spec-lint.sh` checks the
mechanical part. Source: `factory/research/spec-system/`, report 20 and PROPOSAL section 3. Words
as in `language.md`.

## Where the documents are

`factory/config.toml` names them, and `spec-lint` reads only this:

```toml
[spec]
levels = ["spec/VISION.md", "spec/FUNCTIONAL.md", "spec/TECHNICAL.md"]
subsystems = ["net", "log"]
```

- `levels`: the project's three documents, highest first (why, what, how). The table replaces the
  older top-level `spec = [...]` key: TOML forbids a key and a table of one name, so a config must
  not have both.
- `subsystems`: each folder holds `VISION.md`, `FUNCTIONAL.md` and `TECHNICAL.md`. Leave the key out
  for a flat project, which has only the project documents.
- Records beside them: `LOG.md` next to the project `VISION` and in each subsystem folder;
  `ACCEPTED.md` next to the project `VISION`.

## Ids

| Item | Id | Defined in |
|---|---|---|
| goal | `V1`, `V2`, ... | a VISION |
| boundary or non-goal | `VB1`, ... | a VISION |
| requirement | `F-<AREA>-<n>`, `<AREA>` in capitals (`F-SYNC-3`) | a FUNCTIONAL |
| open point | `O-<n>`, numbered per document | that document's `## Open` |

- An id is defined where it starts a list item, a paragraph or a heading: `- **F-SYNC-3** When ...`
  or `### F-SYNC-3 ...`. Anywhere else it is a citation. `spec-lint` reads ids this way.
- A subsystem's ids carry its folder name as a prefix, in its own documents too: `net:F-SYNC-3`,
  `net:VB2`. A bare id is always the project's, so a reader never has to guess the scope. An
  existing id of the older form `NET-F-1` stays as it is: ids are never renamed (below).
- Write ids bare, never in backticks: text in backticks is never read as an id, so `V8` can name an
  engine without being a goal.
- A V-shaped or F-shaped name that is not an item must not be written bare in a spec (a probe
  "V27"): `spec-lint` reads it as a citation of a goal that does not exist.
- Ids are never reused and never renumbered: tests, commits, records and other projects cite them.
  A removed item's id is retired with a line in `LOG.md` (below), and `spec-lint` M1 fails if it
  comes back.

Per-sentence ids are not used: their upkeep is what kills traceability in practice. Links inferred
by an LLM alone are not used either: they reach about F1 0.8, and each miss is a silent gap.

## The link lines

- Each FUNCTIONAL area heading cites the goals it serves: `### 2.3 Install (serves V5, V6)`. A
  requirement whose parent differs from its area's cites it inline: `(V3)`. A subsystem area may
  also serve a project requirement: `(serves F-SHARE-2, net:V1)`.
- Each `##` section of a TECHNICAL holds at least one line `Realises: <ids>`; an area may be cited
  whole as `F-RUN-*`. A section that realises no requirement says `Realises: –` and names what
  motivates it (a constraint, a goal, another section). A `###` subsection may carry its own line.
- Each TECHNICAL has a `## Not designed yet` section. An entry names the requirement and the step
  that needs it: `- F-SYNC-4: not designed yet; the slice that builds it designs it.` It holds no
  design. The slice that designs it removes the entry in the same change.
- A subsystem VISION has a `## Goals served` table; each row names a project goal id.
- Code cites TECHNICAL sections in its `//!` line (`(TECHNICAL 4.3)`), not requirement ids. A test
  that proves a requirement should name its id in its name or doc comment: it is the one link from
  code that makes "a requirement with no test" findable.

## Terms

- Each document level has one terms table, a Markdown table whose first header cell is `Term`.
- A term is defined in exactly one table: the highest level that uses it. A lower document uses it
  unchanged and may add a narrower term that cites it.
- A rejected synonym is a row whose meaning starts with "use": `| basket | use list |`. `spec-lint`
  M7 then flags "basket" wherever a contract uses it.

## Records

`LOG.md` is append-only, newest entry first, and it is a record: an agent must not cite it as a
rule, and reads it only to answer "why is this here". One entry per change set:

```
## 2026-11-23: <one line: what changed>

The human: "<their words, verbatim>"

- F-SYNC-7 added (must, said)
- F-SYNC-2 replaced by F-SYNC-7
- retired: F-SYNC-2 (superseded by F-SYNC-7)
- proposed for VISION: "<sentence>" (answer: yes, 2026-11-24)
- deferred: F-SYNC-7 in TECHNICAL, Not designed yet
```

A line that starts with `retired:` retires every id on it. `ACCEPTED.md` holds the tensions the
human accepted (`spec-check`, "Accepted tensions").

## Consistent, defined

A lower document L is consistent with the one above it, H (vision to functional, functional to
technical, project to subsystem), when all four hold:

1. Grounded: every item of L has a parent in H that it cites, by its own id line or its section's.
2. Covered: every item of H in L's scope has a child in L, or an entry in L's Not designed yet or
   Later list.
3. Refining: L narrows H. It never permits what H forbids, forbids what H requires, widens H, or
   uses a weaker obligation than H.
4. Same words: each term L uses that H defines means in L what H says.

## New concepts

A new concept is a new actor, object or state, capability, outside party, named limit, or (in
TECHNICAL only) interface, format on disk or on the wire, or boundary that no terms table at its
level or above defines. A synonym, a part of an existing concept, an adjective on one, or a means
that only realises a parent (a library, an algorithm) is not a new concept.

- C1. A new FUNCTIONAL concept must have a VISION parent that motivates it: a reader of the vision
  can then predict that it exists. The parent need not name it. Without one, the change carries a
  proposed vision sentence for the human, or the concept is dropped; an agent never adds it.
- C2. A new FUNCTIONAL concept must have a TECHNICAL section that realises it or a Not designed yet
  entry: the how is the build team's, so the maintaining agent never invents the design.
- C3. A new TECHNICAL interface, format or boundary must have a FUNCTIONAL parent, because a person
  or another part can observe it. A means nobody outside sees needs only its section's citation.
- C4. A new concept in a subsystem must fall under that subsystem's responsibilities and outside
  its never list. Otherwise it is a placement question (`placement.md`).

## What spec-lint checks

`scripts/spec-lint.sh`, copied to `.claude/factory/spec-lint.sh` in each project. Without
`[spec] levels` every finding is a warning; with it, an error fails the gate.

| | Check |
|---|---|
| M1 | ids well formed, with the subsystem prefix in a subsystem; defined once; no retired id defined again |
| M2 | every cited id resolves; an area wildcard matches a requirement |
| M3 | every FUNCTIONAL area with requirements has a `serves`; every TECHNICAL `##` section has `Realises:` (Not designed yet, Open and Later are exempt) |
| M4 | every requirement is realised (`Realises:`) or under Not designed yet, unless it sits under Later |
| M5 | every goal is served by an area, or cited under a FUNCTIONAL Later |
| M6 | every subsystem has its three files and a Goals served that names a project goal |
| M7 | each term defined once; no rejected synonym in use |
| M8 | no word outside the vocabulary, no capitals for weight, no TODO or TBD outside Open or Not designed yet |
| M9 | relative links resolve; `TECHNICAL n.m` citations in documents and code name an existing section; the config's levels exist |
| M10 | with a base commit: bold phrases added since then that no terms table defines, as notes for `spec-check` J1 |

It does not judge meaning: whether a parent motivates its child, a contradiction, a weakened level,
drift. Those are `spec-check`'s judgment checks. A section citation broken over two lines is read
without its subsystem name.
