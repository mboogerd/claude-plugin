#!/bin/sh
# .claude/factory/spec-quotes.sh <blocks file> [<project root>]: keeps the findings (or accepted
# entries) whose quotes are still in the files (skills/spec-check/SKILL.md, "Finding format"). A
# block starts at a line `## `; each `quote:` line must appear verbatim, white space aside, in the
# file of the `file:` line above it. Prints the blocks that hold; names each dropped one on stderr.
set -u
B=$(cd "$(dirname "${1:?usage: spec-quotes.sh <blocks file> [<project root>]}")" && pwd)/$(basename "$1")
cd "${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" || exit 2
awk '
function norm(s) { gsub(/[[:space:]]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
function text(f,   l, s) {
  if (f in CACHE) return CACHE[f]
  s = ""; while ((getline l < f) > 0) s = s " " l
  close(f); CACHE[f] = norm(s); return CACHE[f]
}
function flush() {
  if (n == 0) return
  if (ok) printf "%s", blk; else print "dropped: " head " (" why ")" > "/dev/stderr"
  n = 0
}
/^## / { flush(); n = 1; ok = 1; why = ""; head = substr($0, 4); blk = $0 "\n"; file = ""; next }
n == 0 { print; next }
{ blk = blk $0 "\n" }
/^file:/ { file = $0; sub(/^file:[[:space:]]*/, "", file); sub(/[[:space:]]+$/, "", file) }
/^quote:/ && ok {
  q = $0; sub(/^quote:[[:space:]]*/, "", q); q = norm(q)
  if (file == "" || q == "" || index(text(file), q) == 0) { ok = 0; why = "quote not found in " (file == "" ? "(no file: line)" : file) ": " substr(q, 1, 60) }
}
END { flush() }' "$B"
