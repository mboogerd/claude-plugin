# Orchestration plan — [name]

Runbook for a Sonnet 5 orchestrator session. Tickets live in `[ticket folder]`.
Read a ticket only when dispatching it.

## Goal

[Two or three sentences: what the run achieves, what "done" means overall.]

## Sandbox

Every worker is a headless `claude -p` process inside `docker run` — NOT an
in-process Agent-tool subagent. The mechanics below are empirically verified;
deviations from them are known failure modes, not style choices.

**Worker image** (base — add the repo's toolchain on top):

```dockerfile
FROM node:22-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code
# --dangerously-skip-permissions refuses to run as root
USER node
ENV HOME=/home/node
# bind mounts can surface with a foreign uid; git refuses "dubious ownership" otherwise
RUN git config --global --add safe.directory '*'
WORKDIR /work
```

**Dispatch a ticket** — clone (NEVER a bind-mounted worktree: its `.git` file
points at the main repo by absolute host path and is not a git repository
inside the container), pre-set identity, run detached, no `--rm`:

```bash
git clone <repo-path> <clones-dir>/<id> && cd <clones-dir>/<id> \
  && git checkout -b ticket/<id> <wave-base-commit> \
  && git config user.email <id>@run && git config user.name "Worker <id>"
docker run -d --name <id> \
  -v <clones-dir>/<id>:/work -v <ticket-folder-abs>:/tickets:ro -w /work \
  -e CLAUDE_CODE_OAUTH_TOKEN \
  [image] claude -p "Read /tickets/<id>.md and execute it. Commit your work on the current branch. Report per the ticket's Report section." \
  --model [model-id] --dangerously-skip-permissions
```

**Auth** is the forwarded `CLAUDE_CODE_OAUTH_TOKEN` — a long-lived (one-year)
subscription OAuth token minted once by a human running `claude setup-token`
(interactive browser approval; it cannot be minted headlessly). If the var is
unset on the host, STOP and ask the human to mint it — do not substitute
`ANTHROPIC_API_KEY`. Never forward `ANTHROPIC_API_KEY` to workers at all: it
outranks `CLAUDE_CODE_OAUTH_TOKEN` in claude's auth precedence, so its mere
presence silently reroutes every worker from the subscription to metered API
billing. (Mounting `~/.claude` does not log a container in either — on macOS
hosts credentials live in the keychain.) Network: workers always need egress
to the Anthropic API; `--network none` is never valid for a claude worker (it
hangs silently, forever, with empty logs). Auth preflight at run start,
before any wave:
`docker run --rm -e CLAUDE_CODE_OAUTH_TOKEN [image] claude -p "say ok"` —
seconds when healthy, and it fails here rather than as N confusing worker
failures.

**Watchdog** — no GNU `timeout` on macOS; use a deadline loop, budget per
ticket (default 900 s, more for build-heavy work):

```bash
deadline=$((SECONDS+900))
until [ "$(docker inspect <id> --format '{{.State.Status}}')" = "exited" ] \
  || [ $SECONDS -gt $deadline ]; do sleep 5; done
```

**Acceptance probe** — exit code 0 is NOT success (an unavailable model, among
other failures, prints an error and exits 0). A worker is done only when all
three hold; otherwise treat it as failed and post-mortem:

```bash
docker inspect <id> --format 'exit={{.State.ExitCode}}'      # context, not verdict
test -z "$(git -C <clones-dir>/<id> status --porcelain)"      # clean tree
test "$(git -C <clones-dir>/<id> rev-list --count <wave-base-commit>..ticket/<id>)" -ge 1
docker logs <id> 2>&1 | tail -20                              # worker's own report
```

**Harvest and merge** (then, and only then, remove the container):

```bash
git -C <repo-path> fetch <clones-dir>/<id> ticket/<id>:ticket/<id>
git -C <repo-path> merge --no-ff ticket/<id> -m "merge <id>"
docker rm <id> && rm -rf <clones-dir>/<id>
```

**Failure taxonomy** (observed signatures → response):

| Signature | Meaning | Response |
|---|---|---|
| exit 1, log `Not logged in` | `CLAUDE_CODE_OAUTH_TOKEN` unset in the container, or the token expired | fix the `-e` forwarding; if expired, a human re-mints via `claude setup-token`; re-dispatch |
| exit 1, log about root/sudo | image runs as root | fix image `USER`, rebuild |
| running past deadline, `docker logs` EMPTY, `docker exec <id> ps aux` shows claude at ~0% CPU | no route to the API (network config) — claude retries forever | `docker kill` (exit becomes 137), fix egress, re-dispatch |
| running past deadline, logs show activity | slow work, not a hang | read logs; extend deadline once or kill and re-split the ticket |
| exit 0, zero commits ahead | claude failed without failing (bad model id, refused task, forgot to commit) | read full logs, fix dispatch or ticket, re-dispatch |
| exit 137 unrequested | OOM or external kill | `docker inspect --format '{{.State.OOMKilled}}'`; raise memory or investigate |

**Recovery invariant:** the clone survives container death untouched by the
kill itself, but may hold partial work. Before any re-dispatch:
`git -C <clones-dir>/<id> reset --hard ticket/<id> && git clean -fd` (or
delete and re-clone — equally cheap). Containers are removed only after their
logs and exit code have been harvested into the ticket's status note.

Agents do not ask for confirmation inside the container. The container is
disposable and the branch is the unit of review. Running a worker outside a
container is permitted only as an explicit fallback decision logged in this
plan's status — never a silent downgrade.

## Standing rules

- One local clone per ticket on branch `ticket/<id>` (see Sandbox — never a
  bind-mounted worktree) — or `accept/<id>` + `impl/<id>` clones where the
  twin-checkout flow applies.
- Ticket status is authoritative in the ticket file; mirror it in the wave tables.
- Merge target is `main` unless a wave says otherwise. Merge each ticket as soon
  as it passes evaluation.
- Before a wave's merges land, run the repo-wide gate: `[command]`.
- Unpredicted file collision between concurrent tickets: serialize. Let the first
  merge, rebase the second, record the miss.

## Failure policy

1. Verification fails → the evaluator repairs in place, within the ticket's
   stated scope, and re-checks. Repair is the default: rejecting forfeits both
   the implementation and the evaluation spend. The evaluator may only reject
   with a written repair-versus-redo estimate concluding redo is cheaper —
   design-level wrongness, or repair rewriting most of the diff.
2. Design-level wrongness, or repair fails twice, or the implementer stalls →
   re-run at the ticket's escalation tier in a fresh session, handing it the
   evaluator's diagnosis rather than the failed diff.
3. Fails at the escalation tier → stop. Re-split the ticket or hand it back. No
   third retry.

**Orchestrator escalation.** Process problems — an untangleable merge, tickets
that contradict each other, a wave that no longer matches the repo — spawn a
`[tier]` session, hand it `[what]`, take its decision, continue. Do not
improvise a design decision you were not given; do not stall waiting for a human.

## Wave 1 — [name] · branches from `[main @ commit]`

Parallel: [ids] — file claims disjoint.

### Shared-read fork group [name] — tickets [ids] · [only when step 4 named one]

One reader session, forked per ticket. All members share the model `[model-id]`.

1. **State volume** (once): named volumes mount root-owned, and the image runs
   as `node`, so pre-chown before first use:

   ```bash
   docker volume create <run>-reader-state
   docker run --rm -u root -v <run>-reader-state:/x [image] chown node:node /x
   ```

2. **Reader:** pristine clone at the wave base commit (no ticket branch).
   `--output-format json` is how the session id is obtained — it is the
   `session_id` field of the JSON result; there is no other way to get it
   headlessly. Read list (union of the members' Read-first sections):
   `[files]`.

   ```bash
   docker run --rm \
     -v <clones-dir>/reader:/work -v <run>-reader-state:/home/node/.claude \
     -e CLAUDE_CODE_OAUTH_TOKEN -w /work \
     [image] claude -p "Read the following files in full: [files]. Do not edit anything, run any mutating command, or propose solutions. When done, say DONE and stop." \
     --model [model-id] --output-format json --dangerously-skip-permissions \
     > <run>-reader-result.json
   ```
3. **Fork per ticket** (only after the reader finishes). Forks sharing one
   state volume race on its config file — give each fork a copy:

   ```bash
   docker volume create <run>-state-<ticket-id>
   docker run --rm -u root -v <run>-reader-state:/src -v <run>-state-<ticket-id>:/dst \
     [image] sh -c 'cp -a /src/. /dst/ && chown -R node:node /dst'
   docker run -d --name <ticket-id> \
     -v <clones-dir>/<ticket-id>:/work -v <ticket-folder>:/tickets:ro \
     -v <run>-state-<ticket-id>:/home/node/.claude -e CLAUDE_CODE_OAUTH_TOKEN -w /work \
     [image] claude --resume <reader-session-id> --fork-session \
     -p "You are now in the clone for <ticket-id>, branch ticket/<ticket-id> — content identical to what you read. Read /tickets/<ticket-id>.md and execute it. Commit on the current branch." \
     --dangerously-skip-permissions
   ```

4. **Conditions — all must hold, or dispatch the members as plain fresh
   sessions and log the downgrade here:** every member clone is at the
   reader's commit; the reader wrote nothing; no merges landed between read
   and fork. Smoke-test the fork mechanism once at run start (fork a trivial
   session across two containers) before relying on it.

| Ticket | Nature | Model | Session | Branches | Evaluator | Status |
|---|---|---|---|---|---|---|
| T-01 | [one line] | sonnet | fresh | accept/T-01 + impl/T-01 | opus | not-started |
| T-02 | [one line] | haiku | fresh | ticket/T-02 | sonnet | not-started |

**Checkpoint C1 — verification.** Fresh evaluator session per ticket at the tier
above, dispatched with the same Sandbox recipe (same image, the ticket's clone
mounted at `/work`, the ticket ro at `/tickets`) — evaluators repair code, so
they need the same isolation as implementers. For twin-checkout tickets: merge
`accept/<id>` and `impl/<id>` into `integrate/<id>`, run the acceptance gate,
iterate to green, ruling each failure as a wrong test or a wrong
implementation. Judge against the ticket only. Merge to `main` on pass, then
run the repo-wide gate.

## Wave 2 — [name] · branches from `main` after C1

Sequenced: T-03 → T-04 (T-04 consumes [what], from [where]).

| Ticket | Nature | Model | Session | Branches | Evaluator | Status |
|---|---|---|---|---|---|---|
| T-03 | [one line] | sonnet | fresh | ticket/T-03 | sonnet | not-started |
| T-04 | [one line] | sonnet | fork T-03 | ticket/T-04 | opus | not-started |

**Checkpoint C2 — replan.** Trigger: wave 2 merged. Fresh `[tier]` session,
re-enter the `create-implementation-plan` skill. Inspect: [merged work, findings,
open questions]. Output: concrete tickets for wave 3, appended here. If wave 2
landed as expected this is a confirmation and the run continues.

## Wave 3 — [intent only, not yet ticketed]

[One paragraph on the intended shape, so the replanner knows the direction.]

**Checkpoint C-final — close the ledger.** Trigger: last wave merged. If the
design carries a ledger or decision log, spawn a fresh session to verify its
claims against the merged result and update it as it declares — finding
statuses, a fresh audit marker. Resolve "verify" to whatever audit skill is
installed.
