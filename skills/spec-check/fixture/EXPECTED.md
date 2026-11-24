# What spec-check should find in this fixture

A tiny adopted flat project with seeded defects (skills/spec-check/SKILL.md, section 9). It passes
spec-lint, so every defect here is one only the judgment checks can find. Run a full check with
this folder as the project root, then count: seeded defects found (recall) and sound pairs flagged
(false positives).

## Seeded defects

| # | Check | Ids | Expected verdict | Severity | The defect |
|---|---|---|---|---|---|
| D1 | J3 | F-SHARE-3 / VB1 | conflict | critical | restores from a backup service, which the non-goal forbids |
| D2 | J2 | F-ADD-2 / V3 | unmotivated | medium | price history in shops serves no goal; quick add does not motivate it |
| D3 | J4 | F-ADD-3 / F-ADD-4 | conflict | medium | adds a duplicate that a sibling forbids |
| D4 | J3 | F-QUAL-1 / V1 | weaker | high | "should show within a minute" weakens the goal's "sees ... within a minute" |
| D5 | J3 | TECHNICAL 2 / F-QUAL-1 | conflict | high | sending every five minutes breaks "within a minute" |
| D6 | J6 | "phone" in TECHNICAL 2 / Terms | drift | medium | the relay is called a phone, which the terms define as a household member's device |

## Sound pairs (must come back ok)

| Check | Ids | Why it is sound |
|---|---|---|
| J2, J3 | F-SHARE-1 / V1 | sending each change to every phone serves one list |
| J2, J3 | F-SHARE-2 / V1 | a joining phone gets the same list |
| J2, J3 | F-ADD-1 / V3 | typing and confirming is a quick add |
| J3 | TECHNICAL 4 / VB1 | a relay that keeps nothing holds no list |
| J1 | "local database" | a means, not a new concept |
| J2 | F-SHARE-4 / V2 | a leaver's phones are no longer the household's, so "stays on the household's own phones" motivates it |

## spec-lint self-test

In a scratch copy, each of these must turn the PASS into an error: "basket" in any requirement (M7,
a rejected synonym); a second `- **F-ADD-1**` (M1); "F-ADD-9" cited in a journey (M2); deleting the
`Realises:` line of section 3 (M3, M4); "shall" in a requirement (M8); "(TECHNICAL 7)" in a
requirement (M9); a `LOG.md` beside the vision with the line `- retired: F-ADD-5` (M1).

## Accepted

`spec/ACCEPTED.md` A1 (F-ADD-5 against VB2) must be skipped while its quotes hold. Change "the ten
items" in F-ADD-5 in a scratch copy: A1 must then show as stale and the pair be judged again.
