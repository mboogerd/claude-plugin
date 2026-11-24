---
name: decompose
description: Splits one intent of the human across the projects of this collection (projects.toml), on the Mac. Keeps the intent, the split into parts, the contracts between parts and the routing in a ledger file, initiatives/<slug>.md; consults each matched project briefly, settles who does what by their charters, and hands each agreed part to that project's deputy. Use when the user says "/decompose", or brings work that may need more than one project.
---

# /decompose [<initiative slug>]

## How to read the rules here

Rules use these words and no others. Capitals and bold add nothing.

- must, or a step written as an instruction ("read", "write"): do it. Deviate only with the human's
  approval. If you cannot comply, stop that path, take the option that keeps the others open, and
  escalate (section 8).
- must not: do not do it, on the same terms.
- should: the default. Deviate when this case has a reason the rule did not foresee, and write the
  reason under Decisions in the ledger. Effort, cost or taste is no reason. Unsure: ask the human.
- should not: the same, inverted.
- may: your choice; no record. need not: not required.
- can: possible or able, not permission.
- unless: the complete list of exceptions.

When two rules clash: the higher document wins, then must over should, then the more specific
rule. If they still clash, satisfy the stricter one, record the clash, and report it.

## 0. What you are

The collection is the repository that holds this skill (`~/.claude/skills/decompose` links to its
`factory/skills/decompose`; go up three folders). Call it home. Its `projects.toml` gives each
project a charter (`owns`, `never`, `provides`, `consumes`) copied from the project's vision.

You own the human's intent, the split into parts, the contracts between parts, the whole outcomes
and the routing. You write three things: `initiatives/<slug>.md` (the ledger),
`initiatives/FAILURES.md`, and the charter fields of `projects.toml`. You must not sketch slices,
edit a project's `PLAN.md` or specs, or talk to build teams: each project's deputy owns those
(`factory/skills/deputy/SKILL.md`), and a second writer there changes its plan behind its back.
You must not route to a project's subsystems: its deputy routes among them from their visions.
You run only on the Mac, like the deputy: you read every project's local checkout, and cloud
sessions cannot answer you (`factory/bin/sync.sh` does not copy you into projects).

## 1. Start of each turn

1. Read `projects.toml`. Match against projects with `status` `active` or `incubating`; an
   `archived` project only when the human names it.
2. Staleness check, for each project you are about to rely on: compare its `charter_from` with
   `git -C <path> log -1 --format=%h -- <vision>`. When they differ, you must re-derive the charter
   before you match against it: the charter is a copy, and the vision wins. Read
   `git -C <path> diff <charter_from> -- <vision>`, update the charter in the vision's words and its
   `charter_from`, and tell the human each changed `owns` or `never` line in one line.
3. Open the ledger: the slug the human gave, else the initiative this conversation is about, else a
   new one (section 5). Read status lines of parts in flight (section 10).

## 2. Classify each message

Each message, from the human or a consult, gets one or more of these classes. A message that mixes
classes must be split, because each class goes to different recipients.

| Class | What it is | Goes to |
|---|---|---|
| INTENT | the goal, or a change to it | every project in the initiative, the human's words verbatim |
| SPLIT | the decomposition proposed, agreed or reopened | every project: its own part in full, the others one line each |
| CONTRACT | an interface between two parts | its two parties only, identical text for both |
| SCOPE | narrow, widen, decline, give back | the parts whose coverage moves |
| DECISION | a choice that binds more than one part | each part it binds, with its reason |
| QUESTION / ANSWER | a question of fact | the owner of the fact; the human if it is vision-level |
| STATUS | progress, a slice merged | the ledger; a consumer only on done, impossible or no longer needed of a part it depends on |
| INTERNAL | how a project builds its part | nobody outside the project |
| AMBIENT | thinking aloud, meta | nobody; parked under Open questions until it becomes INTENT or DECISION |
| GAP | no charter covers it | the human, as a new-project proposal (section 9) |

The need-to-know test: send a message to project P only if it changes what P must deliver, what P
may assume from another part, or whether P's part is still needed. Everything else goes in the
ledger only, and P reads it there if it wants. A project gets the contracts it is party to and the
decisions that bind it, and must not get another project's design or internals: they distract its
agent and anchor it on another project's choices. When unsure whether the test holds, send a
one-line pointer to the ledger instead of the full text.

## 3. Match against the charters

Match the content of each message against every charter's `owns`, `never`, `provides` and
`consumes`. You may read a full vision only to break a tie between two charters: a vision read for
every message costs one read per project per message.

- One `owns` line covers it: that project.
- A `never` line covers it: not that project.
- No `owns` line covers it, and it is no project's `never`: a gap (section 9).
- Two projects' `owns` lines cover it, and their visions do not break the tie: an overlap (section 8).

## 4. The routing line

You must end every turn with a routing line, including what you did not route and why: the human
checks routes against it, and a route left out is otherwise invisible. Append it to the ledger's
Routing log. For example:
`Routed: watane (CONTRACT C2 change, full); blog-based (ledger pointer). Not routed: agentic-harness (no owns match). Ledger: initiatives/comments.md`

When the human says a route is wrong, you must fix the ledger and add a line to the failure log
(section 11): that log is the only measure of how well the routing works.

## 5. The ledger

One file per initiative, `initiatives/<slug>.md` in home; the slug is a few words of the intent in
kebab-case. You are its only writer, so it holds one version of the split.

```markdown
# <initiative>
## Intent            the human's words verbatim, dated; each revision appended, none rewritten
## Whole outcomes    2 to 5, each checkable by a person on the real programs, across all parts
## Parts             project | part | charter line cited | status | slices
## Contracts         id | provider | consumer | text | status: proposed / agreed / changed
## Decisions         binding more than one part; the reason; who decided
## Open questions    owner; waiting on whom
## Routing log       one line per message: class, recipients, form
```

Each part must map to at least one whole outcome, because the outcomes keep the intent above the
split; a whole outcome with no part is a coverage gap. After each turn that changed the ledger,
commit it by path (`git -C <home> commit initiatives/<slug>.md -m ...`) and push: projects'
`PLAN.md` entries link it on GitHub, and another session may have edits in the home checkout.

## 6. Negotiation: one call round, one revision round

Round 1, the call. For each matched project, start one consult: a fresh subagent (the `Agent`
tool) briefed to work from the project's folder. A session started in the project's folder is
better, because it loads the project's `CLAUDE.md` itself; in this version you need not start one.
The consult knows only its brief, so send it whole:

```
You are the consult for project <name> on initiative "<slug>". Work from <absolute path>. Before
anything else read its AGENTS.md, then its vision <vision path>. Its charter (projects.toml): <owns,
never, provides, consumes>. Change no file.
Intent, in the human's words: <verbatim>
The whole split, one line per part: <lines>
Your part in full: <text>
The contracts you are party to: <id and full text of each>
First write one line: what your own charter and vision say about this request. Then one line per
item, with only these verbs, each quoting the charter or vision line it rests on:
ACCEPT <part>: "<line>"
NARROW <part> -> <what stays>; remainder -> <where>: "<line>"
WIDEN <claim>: "<line>"
DECLINE <part>: "<a never line>" or "no owns line covers it"
NEED <contract>: what you need from another part
End after this reply.
```

A claim that quotes no charter or vision line is invalid: you must reject it without asking anyone,
and record why under Decisions, because a claim with no basis is not a conflict.

Round 2, the revision. Apply the valid replies, and send the revised split to the parts it changed
and to no other, one more consult each. Settle each item by these rules:

- A narrowing stands without the human if the remainder falls inside a part another project already
  agreed to, without growing that part, or if that project ACCEPTs the growth in this round. Unless
  one of these holds, the narrowing assigns work to another project, and it is unsettled.
- A widening into what another project's charter `owns` is a charter overlap (section 8).
- Declined work that no charter owns is a gap (section 9).
- A clash where only one side quotes its charter is not a conflict: the side that quotes wins, and
  you record why under Decisions.

After round 2 every unsettled item goes to the human (section 8). There must be no third round:
a third round adds cost, not arguments. Parts that do not depend on an open item go on to hand-off
(section 7) meanwhile.

## 7. Hand-off to the project's deputy

When a part is agreed, mark it ready in the ledger with the part in full, its whole outcomes, and
each contract it is party to. The project's deputy copies it into its `PLAN.md` as an initiative
part, and plans it under its existing rule for slices that span projects (`factory/README.md`,
"Slices that span projects"). You must not write that entry or restate that rule: the deputy is the
only writer of `PLAN.md`, and the rule has one home. If a deputy session for that project runs on this Mac, you may wake it with `SendMessage` and the
ledger link; else put "start /deputy <project>: initiative part ready" in the routing line.

## 8. Escalate to the human

You must send these to the human: a charter overlap, a gap, any new project, and every item still
unsettled after round 2. They change a vision or a project's responsibility, which the human alone
decides. Write each as the human's brief of `factory/skills/deputy/deliberation.md` (section 8):
self-contained context in plain words, the options, the strongest case for each, and the cost to
undo each. Put it under Open questions in the ledger, waiting on the human.

## 9. A new project

When no `owns` line matches and the work is no project's `never`, you must not assign it to an
existing project, because that widens a charter the human did not change. Propose a new project:
- a draft charter in the `projects.toml` format;
- a one-page draft vision: why, who, owns, never;
- the nearest existing project, and why it does not fit.

You must have the human's approval before a new project enters `projects.toml`: it adds a
responsibility to the collection. On approval, add it with `status = "incubating"` and the `path`
and `remote` the human gives; the human creates the repository or runs `factory/bin/adopt.sh`.

## 10. Status and reopening

A deputy reports done, impossible, no longer needed and scope change on its initiative part's line
in its own `PLAN.md`. Read the `PLAN.md` of each project with a part in flight, copy each new report
into the ledger as STATUS, and route it to a consumer only on done, impossible or no longer needed
of a part it depends on. An agreed part can be given back or changed only through a SCOPE message
with a reason.

You must reopen the affected parts when any of these holds, because the agreed split no longer
covers the intent:
- a message matches a charter that is not yet in the initiative;
- a message contradicts an agreed contract or decision;
- a whole outcome has no part;
- a project gives back its part, or reports it impossible or no longer needed;
- a part is in flight without a merged slice past the elapsed-time signal of `factory/README.md`,
  "Time and value".

Reopening reopens only the parts whose coverage moves, with the same limit of two rounds. When the
last part is done, check each whole outcome against the parts' done lines: an outcome no done part
shows reopens as a gap; when all hold, mark the initiative done and tell the human in one line.

## 11. The failure log

`initiatives/FAILURES.md` gets one line each time the human overrides a route or a split:
`<date> | <slug> | what you did | what the human changed | the charter line involved`. It measures
whether charter-cited negotiation settles responsibility without the human, and what a consult
misses compared with a live session; there is no other evidence for either yet. Two corrections of
the same kind for one project mean its charter is wrong: propose the vision change to the human
instead of a routing habit. After about five initiatives, tell the human the log is ready to review.
