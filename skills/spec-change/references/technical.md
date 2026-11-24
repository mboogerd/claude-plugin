# TECHNICAL: criteria and templates

Shared by `spec-change`, `spec-check` and `spec-adopt`. Source: `factory/research/spec-system/`,
report 10 sections 3.3, 3.6, 5 and 7. Words as in `language.md`.

The how is the build team's (the deputy skill: "why and what are yours; how is the foreman's"). A
maintaining agent writes into a TECHNICAL only a Not designed yet entry, a rename, a `Realises:`
line, or a decision the human or the build team stated; it must not invent a design, because the
team that builds the slice owns it and will test it.

## Project TECHNICAL

Purpose: how the product is built where parts meet. Readers: the foreman, the implementers, the
validator checking fit.

- It must hold the constraints (stack, platforms); the parts, one row each with name, reason to
  exist in one line, and what it depends on; the dependency rules; the flows between parts; the
  security model (assets, attackers, boundaries, what is not protected); the decisions in force,
  each with its reason and its cost to undo; and a `## Not designed yet` list.
- It should hold a context view in text and the rule for where journey tests live.
- It may hold shared formats that no single subsystem owns, and links to reference material.
- It must not hold a subsystem's signatures or inner modules (they live in that subsystem's
  TECHNICAL, and two copies drift), build status, the history of a decision, or behaviour that
  FUNCTIONAL lacks: an effect a person or caller can notice goes into FUNCTIONAL first (C3,
  `links.md`).

## Subsystem TECHNICAL

Purpose: the one place for this part's signatures, formats, algorithms, errors, security properties
and test plan. Reader: its implementer.

- It must hold the public interface (signatures, only here); the formats it owns, byte-exact where
  others interoperate; behaviour per requirement group (algorithm, limits, errors); the security
  properties it holds; what it provides to and needs from other parts; a test plan by requirement;
  its decisions with reasons; and `## Not designed yet`.
- It should give each dependency its reason.
- It may outline inner modules when that explains a security boundary.
- It must not hold build status, "notes (built)", answered-question narratives with test names and
  versions as evidence, or per-step diaries: they are records, and they grow a contract without
  bound. An answered question becomes a rule in the right section, and its story goes to a record.

## Rules for every TECHNICAL

- Each `##` section carries `Realises: <ids>` or `Realises: –` with what motivates it (`links.md`).
- TECHNICAL adds parts, mechanisms, formats, technologies, internal numbers, reasons and attack
  analysis. It must not add observable behaviour.
- Every requirement has a how in some TECHNICAL, or an entry under Not designed yet with the step
  that needs it (`spec-lint` M4).
- A decision row reads: rule in force | reason | cost to undo. No dates, no slice ids: when and who
  are records.

## Template

(P) project only, (S) subsystem only; unmarked: both.

```
# <name>: technical specification
<one paragraph>    How this realises FUNCTIONAL; which ids it cites.
## Constraints     Realises: –  (P) stack, platforms, mandated choices. (S) facts others rely on.
## Parts           (P) | Part | Reason to exist | Depends on |  then the dependency rules.
## Flows           (P) What passes between parts. Realises: ...
## Interface       (S) Public signatures, only here. Realises: ...
## Formats         Byte-level formats this level owns. Realises: ...
## Behaviour       (S) Per requirement group: algorithm, limits, errors. Realises: ...
## Security        (P) Assets, attackers, boundaries, not protected. (S) Properties held.
## Provides / Needs (S) To and from other subsystems.
## Test plan       (S) | Requirement | Test kind | Where |
## Decisions       | Rule in force | Reason | Cost to undo |
## Not designed yet  - F-<AREA>-<n>: not designed yet; <the step or slice kind that needs it>.
## Open            (may) - O-1 <question>. Options: ... Owner: ...
```
