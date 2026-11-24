# mboogerd's Claude Code plugin

My skills (and later agents), shared across laptops.

## Install

```
claude plugin marketplace add mboogerd/claude-plugin
claude plugin install mboogerd@mboogerd
```

Update after a push: `claude plugin marketplace update mboogerd && claude plugin update mboogerd@mboogerd`.

## Layout

- `skills/`: one folder per skill.
- `agents/`: subagent definitions (none yet).
- `scripts/`: `spec-lint.sh` and `spec-quotes.sh`, used by the spec skills. The watane-mods factory's
  `sync.sh` copies `foreman`, the `spec-*` skills and these scripts from a checkout of this repo into
  each project, because cloud sessions load no plugins.
