---
name: codex
description: Use when dispatching Codex Cloud tasks, reading their results, or running local codex exec/review from scripts.
---

# Codex from scripts

Verified on this Mac with `codex-cli 0.171.0`. CLI help, matching versioned source,
existing cloud tasks, authenticated GET requests, local apply, and a local exec smoke
run were checked. No cloud task was started during verification.
Cloud submission behavior below is source-verified, not submission-tested.

## Dispatch and collect cloud work

Give Codex a bounded outcome, repository context, acceptance checks, and expected
deliverables. Dispatch only when authorized; retain the task ID and inspect results.

```sh
codex cloud exec --env "$ENV" [--branch "$REF"] [--attempts N] "Task prompt"
codex cloud status "$TASK"
codex cloud list [--env "$ENV"] [--limit N] [--cursor "$CURSOR"] [--json]
codex cloud diff "$TASK" [--attempt N]
codex cloud apply "$TASK" [--attempt N]
```

- Bracketed arguments are optional syntax notation, not literal shell arguments.
- `exec`: stdout is one task URL, normally `https://chatgpt.com/codex/tasks/task_...`.
  Capture it with `url=$(codex cloud exec ...); task_id=${url##*/}`; check exit status
  before extracting. A missing query or query `-` reads stdin through EOF.
- `status`, `diff`, and `apply` accept either an ID or task URL, stripping query/fragment.
- `status` stdout has three lines: `[READY] Title`, `environment  •  relative time`,
  `+A/-D • F files` (singular `file`, or `no diff`). Environment can be omitted.
  Other first-line labels: `[PENDING]`, `[APPLIED]`, `[ERROR]`.
  Exit is 0 ONLY for READY; every other status exits 1. Distinguish pending from
  failure by the label; do not let `set -e` terminate a polling loop on PENDING.
- `list` without JSON prints each URL followed by the three indented status lines,
  blank lines between tasks, and a next-page command when applicable; empty result:
  `No tasks found.` Limit is 1–20, default 20.
- `list --json` emits ONE pretty-printed JSON object, not JSONL:
  `{ "tasks": [...], "cursor": "..." }`; cursor may be null.
  Task fields: `id`, `url`, `title`, `status`, `updated_at`, `environment_id`,
  `environment_label`, `summary:{files_changed,lines_added,lines_removed}`,
  `is_review`, `attempt_total`. Status strings are lowercase; environment fields
  may be null. Extract IDs with `jq -r '.tasks[].id'`; reuse `.cursor` verbatim.
- `diff` prints the raw unified Git diff, without a JSON wrapper. No available diff
  is an error, including for a completed task that produced no patch.
- `apply` patches the CURRENT LOCAL working directory; run it in the intended repo.
  Success stdout: `Applied task ID locally (N files)`; exit 0. Partial/failure
  messages: `Apply partially succeeded for task ID (applied=A, skipped=S, conflicts=C)`
  or `Apply failed for task ID (applied=A, skipped=S, conflicts=C)`; exit 1.
  Partial application can change files. Inspect Git afterward; the reported file
  count was 0 in our probe despite creating a file. Apply does not commit or push.
- `--attempt` is 1-based, default 1, selecting among available diffs sorted by
  placement, then creation time when placement is absent; attempts without diffs
  are omitted. `exec --attempts` defaults to 1 and requests best-of-N generation.
- Only `list` has cloud `--json`; status/exec/diff/apply do not.

## Environment and branch rules

- `--env` is required for `cloud exec`; it is optional as a `list` filter.
  Resolver trims whitespace, enumerates environments, tries exact case-sensitive ID,
  then a case-insensitive exact label. Distinct IDs with the same label are ambiguous.
  Arbitrary IDs are NOT passed straight through to task creation.
- This CLI enumerates older repository environments via
  `/backend-api/wham/environments` plus `/wham/environments/by-repo/github/OWNER/REPO`
  for parsed local GitHub origins, merging by ID. Run `codex cloud` for the TUI picker.
  App `ccarenv_...` environments are not reachable through this resolver's catalog;
  there is no CLI switch to use the app-environment service. The live older catalog
  contained one environment and no `ccarenv_` IDs; individual app-ID rejection
  was not live-tested. Unfiltered task listing can still show tasks from other origins.
- `--branch` selects the cloud task's STARTING Git ref, not its output branch name.
  A nonempty override is trimmed; otherwise: local current branch, local default
  branch, then `main`. The request sends that ref; it does not upload local commits
  or uncommitted files. Availability of an unpushed ref remotely is unverified.
- An existing task's diagnostic diff verified an empty `git remote -v`, no credential
  helper, no provisioned GitHub token helper, and failure resolving `origin`.
  Treat cloud sandboxes as having no remote or push capability unless that environment's
  setup provides a remote, credentials, and network access. This is observed environment
  behavior, not a guarantee that every custom environment lacks remotes.
  The Mac's credentials are not automatically the sandbox's credentials.

## Local non-interactive execution and review

```sh
codex exec -C "$REPO" -s workspace-write \
  -c sandbox_workspace_write.network_access=true \
  --json -o final.txt "Implement the scoped task and run its checks" </dev/null
codex exec --skip-git-repo-check -s read-only "Analyze this directory" </dev/null
codex review --uncommitted </dev/null
codex review --base main </dev/null
codex review --commit "$SHA" --title "Change title" </dev/null
codex exec --json -o review.txt review --base main </dev/null
```

- Sandbox values: `read-only`, `workspace-write`, `danger-full-access`.
  Workspace-write network access defaults false in the versioned config schema;
  the override above enables it subject to host policy. Network connectivity was
  not probed inside a local generated shell command. `--add-dir DIR` adds writable roots.
  `--dangerously-bypass-approvals-and-sandbox` disables both protections; use only
  when explicitly justified by an externally sandboxed execution environment.
- `exec` is headless; source defaults approval policy to `never`. Explicit sandbox
  and configuration choices make scripts predictable. `--skip-git-repo-check`
  permits execution outside a Git repository; it does not create one.
- Even with a positional prompt, piped stdin is read to EOF and appended as a
  `<stdin>` block. Use `</dev/null` when there is no input; an inherited open pipe
  can otherwise stall. Omitted prompt or `-` reads the prompt from stdin.
- Normal scripted exec stdout is the final message; progress/diagnostics go to stderr.
  `--json` changes stdout to JSONL events: observed `thread.started`, `turn.started`,
  `item.completed` with `item.type="agent_message"` and `item.text`, then
  `turn.completed` with usage. `-o FILE` writes final text separately (verified).
  Check process exit status and error events, not merely whether a file exists.
- `--ephemeral` avoids session persistence; it does not mean no filesystem writes.
- `codex review [OPTIONS] [PROMPT]` is local, non-interactive. Choose ONE of
  `--uncommitted`, `--base BRANCH`, `--commit SHA`, or custom prompt; selectors
  conflict with one another and with a prompt. `--title` requires `--commit`.
  Use `codex exec --json -o FILE review ...` for structured events/final capture.
  Review help/source were checked; a full review run was not performed.

## Read a task's results without a TUI

There is no cloud CLI `logs`, `show`, or final-message export subcommand in this version, and
there is no supported API for it. Do not read `~/.codex/auth.json` or call private endpoints with
its tokens. Instead, ask the task to write everything you need (each command and its full output,
its report, a `VERDICT:` line) into a file in the repository, then read it with
`codex cloud diff "$TASK"` (verified: a diagnostics task's log arrived this way). Never let the
task write secret values into that file.

Cloud CLI commands append `./error.log` even on success; verified to contain the
account ID. Delete it after every invocation, including failures, with
`trap 'rm -f -- error.log' EXIT` in a dedicated script; never commit or attach it.

Verification sources: installed `--help`; [cloud CLI](https://github.com/openai/codex/blob/rust-v0.171.0/codex-rs/cloud-tasks/src/lib.rs), [environment resolver](https://github.com/openai/codex/blob/rust-v0.171.0/codex-rs/cloud-tasks/src/env_detect.rs), [cloud client](https://github.com/openai/codex/blob/rust-v0.171.0/codex-rs/cloud-tasks-client/src/http.rs), [local exec](https://github.com/openai/codex/blob/rust-v0.171.0/codex-rs/exec/src/lib.rs), [config schema](https://github.com/openai/codex/blob/rust-v0.171.0/codex-rs/core/config.schema.json).
