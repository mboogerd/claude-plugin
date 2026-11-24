# Architecture decisions

Durable record of architecture audits. Read before starting a new audit: the
marker sets the incremental baseline, and the declined list prevents
re-litigating settled questions.

This ledger is maintained by whatever process acts on it: resolving a finding
updates its Status; completing a body of work verifies the ledger's claims
against the result and appends a fresh audit marker.

---

## Audit [YYYY-MM-DD]

**Marker:** `[commit SHA]` · **Mode:** full | incremental from `[prev SHA]`
**Principles evaluated:** [list]

### Accepted

| Finding | Severity | Location | Solution | Status |
|---|---|---|---|---|
| [one line] | High | `path:line` | [chosen direction] | planned / in progress / done |

### Declined

| Finding | Severity claimed | Reason declined |
|---|---|---|
| [one line] | Medium | Refuted: [what the refutation showed] |
| [one line] | High | Sanctioned by design: `doc/spec/....md` §N |
| [one line] | Low | No named payer |

Do not re-report these without new evidence. If the reason no longer holds, say
which part changed.

### Guardrails

**Specified:**
- [rule] — mechanism `[tool]`, `[N]` current violations, from finding [id] ·
  status: proposed / implemented in `[test file]`

Status is `proposed` until an implementing run lands the test.

**Considered, not specified:**
- [rule] — [what would have to be true to specify it: e.g. "once the 6 legacy
  violations in `x/` are cleared"]

**Amended:**
- [rule] — [what changed, why] · approved by [human] on [date]

Amendments require human approval. Adding a rule does not.
