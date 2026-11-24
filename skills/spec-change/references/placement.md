# Where a fact lives

Shared by `spec-change`, `spec-adopt` and the deputy. Source: `factory/research/spec-system/`,
report 10 sections 2 and 4.3, PROPOSAL sections 1.1 and 1.3. Words as in `language.md`.

## One home per fact

A fact lives in the document whose change would make it false. Apply these tests in order before
you write any statement, and stop at the first that decides:

1. Record test. It says when, by whom, in which slice or PR, or that something is built, answered
   or done: a record (`PLAN.md`, `LOG.md`, a decision file, a `NOTES.md`), never a contract. A
   contract may cite a record only in a trailing "Origin:" note.
2. Code test. A change inside one part could alter it without any other part, user or caller
   noticing (a private module, a helper, a pinned patch version): code and its `//!` line.
3. Rebuild test. It would be false if the product were rebuilt on other technology (language,
   protocol, library, vendor): TECHNICAL.
4. Redesign test. It would be false if the behaviour were redesigned to reach the same goals
   another way (other commands, screens, flows): FUNCTIONAL. Otherwise: VISION.
5. Observer test, when 3 leaves doubt. A user, a maker or a calling program can observe it without
   the source, and it names no technology: FUNCTIONAL. A visible number (a code valid for ten
   minutes) is FUNCTIONAL; the reason for the number is TECHNICAL.
6. Scope test. It concerns more than one subsystem, or a person using the whole product: the
   project document. Only the inside or the offer of one subsystem: that subsystem's. A flat
   project has only project documents.

A vendor or product the person must use (Claude, GitHub) may be named in FUNCTIONAL when replacing
it would change what the person experiences. VISION names the need instead ("the participant's own
agent subscription"), because the vision outlives any vendor.

A fact that fails all of 1 to 5 for every document is not a statement: it is a question, an example
or thinking aloud, and it goes nowhere.

## Placement of work: the charter test

A subsystem's VISION is a charter (`vision.md`). To place a piece of work W, split it into
statements by the tests above, then for each statement:

1. For each charter, mark owns when W falls under one of its responsibilities or touches one of its
   secrets, and forbids when W falls under one of its never lines.
2. Exactly one owns and none forbids: it belongs there.
3. One owns and another forbids: the never line names its owner; follow it. When it names a third
   subsystem, the charters disagree: that is a charter defect (6).
4. Several own: the charters overlap. Do not place it; fix the charters through the decision ladder.
5. None owns: when W shares a reason to change with one charter's secret, widen that charter (a
   vision change, so a proposal to the human); otherwise W is a new secret, and you propose a new
   subsystem with a draft charter and its row in the project TECHNICAL. When every charter and the
   project non-goals forbid W, it is out of scope: say so.
6. A change that moves a responsibility from one charter to another must go up the decision ladder
   and must not be decided alone: two parts' owners and every caller depend on where it sits.

A flat project runs the same test with one charter, its project VISION: W is in scope, out of
scope, or needs a vision change.

The set of charters is sound when no responsibility is in two charters, every never line resolves
to an owner or a non-goal, and every project FUNCTIONAL area is owned by some charter.
