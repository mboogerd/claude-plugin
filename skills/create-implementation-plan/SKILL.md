---
name: create-implementation-plan
description: Turn a decided design into an agent-executable orchestration plan plus a folder of self-contained tickets — sized per ticket, routed to the smallest capable model, scheduled into parallel or sequential waves by predicted file overlap, each ticket executed by a Docker-sandboxed headless claude worker in its own clone, with evaluator and replanning checkpoints. Use whenever the user asks to "make an implementation plan", "plan this for agents", "split this into tickets", "orchestrate this work", or has just settled on a design and needs it executed by Claude Code agents — even if they don't say the words "orchestration" or "tickets".
---

# Create implementation plan

Produce two artifacts:

1. **Tickets** — one file per unit of work, in the repo's ticket folder.
2. **An orchestration plan** — a runbook a Sonnet 5 orchestrator executes, referencing tickets by id and never restating their content.

The design must be decided first. If the "what" is still open, settle it before planning — an audit or design skill if one is installed, or ask.

## 1. Ground

- Read the design, then the code it touches. Verify every file, module, and test you name exists.
- Locate the ticket folder: follow the repo's convention (`doc/tickets/`, `backlog/`, a tracker named in CONTRIBUTING.md / AGENTS.md / CLAUDE.md). If there is none, propose one and get agreement before writing files.
- Check whether the repo keeps acceptance tests separate from implementation — own module, source set, directory, or gate. If it does, use the twin-checkout flow in step 5.
- Inventory what the design brings with it: test suites that assert on the work (run them in every ticket's verification and the wave gate), rule files with embedded policies (honor the policy as written), ledgers that declare how they are maintained (schedule their updates as checkpoints), priority orderings (let them order the waves), stated abandon- or replan-triggers (wire them into the replan checkpoints). Artifacts declare their own semantics; the plan's job is to wire them in, not re-derive them.

## 2. Cut tickets by read-surface

Size by how much an agent must read and hold to be correct, not by diff size or cleverness. Right-sized: a fresh agent with no prior session and no access to this conversation can read the ticket, do the work, and prove it.

The evaluator judges the work against the ticket and nothing else. Give every ticket:

- **Context** — what the system does here today, why this work exists
- **Problem** — concretely, with evidence cited as `path:line`
- **Solution direction** — the decided design, and explicitly where the implementer has latitude
- **File claim** — files it expects to create or modify
- **References** — exact paths and sections to read first; adjacent files not to touch
- **Acceptance criteria** — checkable statements
- **Verification** — exact commands
- **Model and escalation tier** — step 3
- **Status** — for resumption

Use `assets/ticket-template.md`.

## 3. Route models

Read `references/model-routing.md` before assigning tiers. Pull model facts (ids, context windows, capabilities) from the `claude-api` skill, not from memory or from this skill.

Per ticket, assign a model, an escalation tier, and write the ticket in the register that model needs — a Haiku ticket and an Opus ticket are different documents for the same work.

## 4. Schedule waves

- Every ticket runs in its own isolated checkout — a local `git clone` of the repo on branch `ticket/<id>`. A clone, not a worktree: a worktree's `.git` file points at the main repo by absolute host path, so a bind-mounted worktree is not a git repository inside a container (verified empirically). Local clones hardlink objects, so they cost little; the orchestrator merges by fetching the branch back from the clone path.
- Two tickets run in parallel only when their file claims are disjoint **and** neither consumes the other's output. Overlapping claims are a dependency even when the logic is independent.
- State what each wave branches from (usually `main` after the previous wave merged).
- Unpredicted collisions: the orchestrator serializes at runtime. The evaluator records drift between claimed and actually-touched files as a sizing signal.
- **Shared-read fork groups.** When two or more same-wave, same-model tickets cite a heavily overlapping read-first surface — the shared files dominate each ticket's read list and run to thousands of lines, not hundreds — name a fork group in the plan. One read-only reader session loads the shared files verbatim from a pristine clone at the wave's base commit; the orchestrator then forks it once per ticket into that ticket's clone. The fork inherits the file contents in context, which is the one thing a ticket cannot carry — a ticket distills, a fork remembers the bytes. Validity rests on three conditions the plan states next to the group: every clone in the group is at the same commit as the reader's; the reader writes nothing; forks are cut before anything merges. Do not group to share small read sets, mixed tiers, or tickets whose work is itself exploratory — a diagnosis ticket needs its own reading. Tickets stay self-contained regardless, so if fork mechanics are unavailable the group degrades to plain fresh sessions (log the downgrade) — there is no intermediate digest artifact; anything a digest would say belongs in the tickets.

## 5. Twin checkouts for acceptance tests

When the repo separates acceptance tests from implementation, split each ticket across two clones running in parallel from the same ticket text:

- **`accept/<id>`** — writes the acceptance tests from the ticket's acceptance criteria. Does not read or modify implementation code.
- **`impl/<id>`** — writes the implementation. Does not write acceptance tests.

Route the two independently; the acceptance side is often a tier lower.

They converge at the ticket's verification checkpoint. The evaluator first confirms the new tests fail against the pre-change baseline — a test that already passes proves nothing — then merges both into an integration clone, runs the acceptance gate, and iterates until green, adjudicating each failure as either a wrong test or a wrong implementation, fixing small errors on either side and sending large ones back to the responsible branch. Merge only the converged result.

Ticket and plan both name the two branches and the integration branch.

## 6. Place checkpoints

**Verification.** Fresh evaluator session at or above the implementer's tier. Judges against the ticket, and **repairs by default**: a rejection forfeits both the implementation spend and the evaluation spend, so the evaluator fixes everything it can within the ticket's stated scope — missed criteria, wrong edges, broken tests — not just superficial slips. Before sending anything back it writes a repair-versus-redo estimate into its report; rejection is justified only when the approach is wrong at the design level or repair would rewrite the majority of the diff. Merges on pass.

- Merge target is `main`; merge each ticket as soon as it passes. Use a collection branch only when a wave is incoherent in pieces, and say why.
- Run the repo-wide gate per wave before its merges land. Tickets run only their own narrow verification.

**Replan.** Ticket concretely as far as your confidence extends, then place a replan checkpoint rather than inventing the next wave. Specify the trigger, what the replanner must inspect (merged work, findings, open questions), and a high-reasoning tier. It re-enters this skill, appends tickets to the plan, and the orchestrator continues.

## 7. Write the orchestration plan

Per ticket the plan carries only: id, one-line nature, model, wave, session strategy, branches, evaluator model. Everything else lives in the ticket. Spend the words on process:

**Sandboxing.** Claude Code has no built-in Docker sandbox for subagents — a plan that says "runs in Docker" without the launch command gets silently downgraded to in-process Agent-tool workers. The plan must therefore carry the full, tested dispatch mechanics: the worker image Dockerfile, the clone-and-dispatch recipe, the watchdog, the acceptance probe, and the failure taxonomy. The template's Sandbox section contains all of these, verified empirically; copy it and fill the blanks rather than paraphrasing — the details are load-bearing:

- the image must run as a **non-root user** (`--dangerously-skip-permissions` refuses to run as root) with `git safe.directory` configured;
- auth is a forwarded `-e CLAUDE_CODE_OAUTH_TOKEN` — the long-lived subscription token a human mints once with `claude setup-token`. Never forward `ANTHROPIC_API_KEY`: it outranks the OAuth token in auth precedence and silently reroutes workers to metered API billing. If the token is unset, the plan stops and asks the human; and mounting `~/.claude` carries no auth on macOS hosts (keychain);
- workers get a **local clone** mounted at the canonical `/work`, never a worktree (see step 4), with git identity pre-set by the orchestrator;
- **exit code 0 is not success** — some claude failures (e.g. an unavailable model) print an error and exit 0, so completion is judged by the acceptance probe (clean tree + commits ahead of base), never by the exit code alone;
- containers run **without `--rm`** so a failed or killed worker can be post-mortemed from its logs and exit code, and are removed only after harvest.

Mount every clone at the **same canonical path** so paths in transcripts and reports stay portable across workers. The first worker of the run doubles as a smoke test — if the container cannot run the repo's build, fix the image before dispatching the rest of the wave. Falling back to host execution without containers is allowed only as an explicit, logged decision recorded in the plan's status — never a silent downgrade. Inside the container agents act without asking for confirmation; the container is disposable, and the branch is the unit of review.

**Session strategy**, per ticket:

- *Fork the previous session* — same files, same mental model, context still true.
- *Fork from wave reader* — the ticket belongs to a shared-read fork group (step 4): it starts from the group reader's session with the shared files already in context, in its own clone.
- *Fresh session* — different subsystem, or the prior session is long, noisy, or failed.
- *Fresh plus handoff* — keeps the conclusions, drops the dead ends. Default when unsure.

Forking across checkouts is safe only because every container mounts its clone at the same canonical `/work` and the clones are content-identical at the wave base commit — the fork's remembered paths and file contents stay literally true. The fork's first message states the new branch (`you are now on ticket/<id>`); nothing else needs re-orienting. Outside that regime, a forked session is anchored to its old checkout and needs an explicit re-orientation step.

**Failure policy.** Verification fails → the evaluator repairs in place within the ticket's scope and re-checks; it may only reject with a written repair-versus-redo estimate concluding redo is cheaper. Design-level wrongness, or repair failing twice → re-run at the escalation tier in a fresh session, handing it the evaluator's diagnosis rather than the failed diff. Fails there → stop, re-split the ticket or hand it back. No third retry.

**Orchestrator escalation.** For process problems rather than ticket problems — an untangleable merge, tickets that contradict each other, a wave that no longer matches the repo — spawn a higher-tier session to decide, take its answer, continue. Name the tier and what to hand it.

**Resumability.** Ticket status is authoritative in the ticket file and mirrored in the plan.

Use `assets/orchestration-plan-template.md`.

## 8. Fan out ticket writing, then reconcile

Write the plan skeleton first — ids, waves, routing, checkpoints. Then spawn one subagent per ticket, each with the complete design context and its ticket's slot in the plan.

Read all tickets together before handing over. Look for claims that overlap after all, solution directions that contradict at a seam, and work that fell between two tickets.

## 9. Hand over

- Commit the plan and tickets to `main` before the run starts. Worktrees branch from `main` and sandboxes mount the ticket folder — uncommitted tickets do not exist for any agent.
- Tell the user the kickoff: a fresh Sonnet 5 session, pointed at the plan path, with permission to create clones and run Docker.
- Report what wave 1 will run in parallel, where the first checkpoint is, and which waves are intent-only pending a replan.

Handing over completes the plan, not necessarily the user's request. If they also asked to execute it, start the run in the same turn rather than stopping at the artifacts.

## Leave out

- Rollback prose — disposable clones and branches make it "delete the branch". Only merged work needs a recovery story.
- Fields whose value never varies.

## Reference files

- `references/model-routing.md` — task shape to tier, per-tier ticket authoring, escalation, evaluator routing
- `assets/ticket-template.md`
- `assets/orchestration-plan-template.md`
