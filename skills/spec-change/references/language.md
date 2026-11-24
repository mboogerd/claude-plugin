# The language of rules and statements

Shared by `spec-change`, `spec-check` and `spec-adopt`. Source: `factory/research/spec-system/`,
report 30 (the evidence) and PROPOSAL section 2 (the choice).

## The key

Paste this at the top of a skill, an `AGENTS.md` or a spec, with the owner and the record filled in.

```
## How to read the rules here

Rules use these words and no others. Capitals and bold add nothing.

- must / a bare imperative / "always" (with its scope): do it. Deviate only with the approval of
  <owner: the human>. If you cannot comply, stop that path, take the option that keeps the others
  open, and escalate.
- must not / never / do not: never do it, on the same terms.
- should / by default / prefer: the default. Deviate when this case has a reason the rule did not
  foresee, and write the reason in <where>. Effort, cost or taste is no reason. Unsure: deliberate,
  then ask.
- should not / avoid: the same, inverted.
- may: your choice; no record. need not: not required.
- can: possible or able, never permission.
- unless / except: the complete list of exceptions.

Statements are decided unless marked. "(assumed)" means acted on but unconfirmed: check it before
anything costly to undo depends on it, and report evidence against it. "(open: O-n)" means
undecided: build only what keeps the options open.

When two rules clash: the higher document wins, then must over should, then the more specific
rule. If they still clash, satisfy the stricter one, record the clash, and report it.
```

In a spec, add: "Statements of what the product does are decided requirements; 'may' and 'can'
about a person or a mod describe what the product allows or enables."

## Words outside the vocabulary

These must not appear in a rule or a requirement, because each one either hides the level or
lets the reader pick it: "shall", "ought to", "is expected to", "try to", "if possible", "where
possible", "as appropriate", "where appropriate", "ideally", "make sure", "it is important that",
"critical" as emphasis (a defined label such as a severity is fine), "might", "perhaps", "may not" (write "must not" or "need not"). Text in backticks, code
blocks and `>` quotes are exempt. `spec-lint` M8 finds the most common of them; the rest are the
reviewer's.

## Two registers

- In a skill, a bare imperative ("Commit by path") is a must; "never" and "do not" are must not.
  An indicative sentence ("you do not build") reads as a description, so write a rule as an
  imperative or with "must".
- In a spec, a present-tense statement of what the product does ("When a phone joins, pantry
  sends it the whole list") is a decided requirement. "may" about a person is a permission the
  product grants; "can" is a capability. The implementer's own freedom is written with should or
  may about the design ("the store should be append-only").

## Certainty, a second axis

| Level | Marking | What may depend on it |
|---|---|---|
| decided | unmarked | anything |
| assumed | `(assumed)` or `(assumed: <how it is checked>)` at the end of the sentence | work may build on it; work costly to undo checks it first |
| open | an entry `- O-<n> <question>. Options: <a>; <b>. Owner: <who>.` under the document's `## Open`; inline `(open: O-<n>)` | only what keeps the options open |

An obligation is only as certain as the fact under it: a must on an assumed fact holds until the
assumption fails, and then the agent stops relying on it and escalates. An open point carries no
obligation word. A section where most sentences need `(assumed)` is not ready: move it to `## Open`
as a whole. A vision may state a bet: "we bet that ... (assumed: <evidence that would show
otherwise>)".

## How to write a rule

Shape: `[When <scope>,] <actor> <word> <action>[, unless <closed list>]: <reason as a fact>.`

- One actor, one action. The condition first, the exceptions in the same sentence, the reason last.
- Each must and should carries its reason, written as a fact ("cloud teams start from
  `origin/main`"), not as a goal the reader could meet another way ("to keep things in sync"). For a
  must the reason explains and never licenses deviation; for a should it is what the reader weighs.
  When the human gave no reason, ask for it or write `(reason: not given)`.
- A must that guards something says what to do once it is broken ("stop the slice and tell the
  human at once").

| Anti-pattern | Fix |
|---|---|
| capitals, bold, "critical", "you must always" | delete the emphasis, add the reason |
| an unbounded always or never | give its scope or its exceptions |
| no scope ("keep it lean") | name who, when and what |
| "only" folding two rules ("ask only to ...") | write the must and the must not apart |
| an escape clause ("if possible", "as needed") | a should, or the known condition written out |
| a hedged number ("at least about 1,500") | a floor (must) or a target (should) |
| the exception in another section | "unless" in the same sentence, or a pointer to it |

## Setting levels from conversation

The maintaining agent maps the human's words by what they mean to allow, never by the word alone:
the human's own "should be compatible with either" meant must.

- Record each statement at the level the human's words clearly carry. When two levels fit, record
  the weaker one, mark it `(assumed)`, and ask at the end of the turn, batched with other questions.
- Never strengthen a level (may to should, should to must, assumed or open to decided) without the
  human's own words in this conversation that carry the stronger one. Summarising and moving text
  are where this happens unnoticed: compare the level before and after each moved sentence.
- You may weaken certainty on evidence: add an `## Open` entry that cites the evidence and keep the
  rule in force until it is decided. Never weaken an obligation unless the human says so or a
  higher document forces it; then report the change in one line.
- Ask before you change any must or must not, any security check, or any vision statement, whatever
  the human's phrasing: each of these is the human's to set.
- When the human's words clash with a higher document, record nothing yet: ask, quoting both.

| The human said | Recorded as |
|---|---|
| "always", "never", "it really has to", "certainly want" | must / must not |
| "should be compatible with either", where the context restates it as a requirement | must; ask if the context does not settle it |
| "usually", "by default", "prefer" | should |
| "could", "is fine", "should generally be fine if ..." | may, with the "if" written as its scope |
| "not necessarily", "that is not to say it must" | need not / may |
| "e.g. two", "something like" | the rule decided, the number `(assumed)` |
| "I think maybe", "what if" | not a rule: open, or assumed when work needs a default |
| "I have no good criteria for ..." | open: an `O-n` entry |
| "what's really important is ..." | not an obligation: a goal or a priority, for the vision |
| "this is my proposition, review it critically" | assumed, the whole of it |

## Reviewer checklist

Apply it to every rule written or moved.

1. Only the vocabulary? No "shall", "try to", "if possible", "ideally", capitals or bold for weight?
2. Is the level the one its source carries (the human's words, or the higher document)? Was
   anything strengthened compared with the previous version or the conversation?
3. Is the scope explicit (who, when)? Is every always and never bounded?
4. Are the exceptions closed and next to the rule?
5. Does every must and should carry a reason stated as a fact, narrow enough not to be a loophole?
6. Does a guarding must say what to do on breach?
7. One actor, one action? No double negative, no "only" hiding two rules?
8. Could a reviewer tell from a transcript whether it was followed?
9. Does it clash with another rule at the same level, and is the resolution written?
10. Is its certainty right: decided unmarked, assumed marked, open under `## Open` with no
    obligation word?
11. For a should: does it say where a deviation's reason goes, or does the key cover it?
