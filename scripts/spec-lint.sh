#!/bin/sh
# .claude/factory/spec-lint.sh [--diff <base>] [<project root>]: the mechanical checks M1 to M10 of a
# project's VISION, FUNCTIONAL and TECHNICAL documents (skills/spec-change/references/links.md, "What
# spec-lint checks"). Reads `[spec]` `levels` and `subsystems` from factory/config.toml. A project
# without `[spec]` is not adopted yet: every finding is then a warning and it exits 0, so a gate can
# run it before spec-adopt has. Prints `ERROR|WARN|NOTE <check> <file>:<line>: <what>` lines, then
# `SPEC-LINT PASS|FAIL (...)`; exits 1 when there is an error. BASE (as check.sh sets it) or --diff
# lists candidate new terms (M10) in the documents' diff since that commit.
set -u
DIFF=${BASE:-}
while [ $# -gt 0 ]; do
  case $1 in
    --diff) DIFF=${2:?usage: spec-lint.sh [--diff <base>] [<project root>]}; shift 2 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) break ;;
  esac
done
ROOT=${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}
cd "$ROOT" || exit 2
CONF=factory/config.toml
T=$(mktemp -d "${TMPDIR:-/tmp}/spec-lint.XXXXXX") || exit 2
trap 'rm -rf "$T"' EXIT

# conf <table> <key>: the items of a one-line array in config.toml, one per line ("" = top level).
conf() {
  [ -f "$CONF" ] || return 0
  awk -v t="$1" -v k="$2" '
    /^[[:space:]]*\[/ { cur = $0; gsub(/[][[:space:]]/, "", cur); next }
    cur == t && $0 ~ "^[[:space:]]*" k "[[:space:]]*=" {
      s = $0; sub(/^[^=]*=[[:space:]]*/, "", s); sub(/\][^]]*$/, "", s); gsub(/[][",]/, " ", s)
      n = split(s, a, " "); for (i = 1; i <= n; i++) print a[i]; exit }' "$CONF"
}

LEVELS=$(conf spec levels)
if [ -n "$LEVELS" ]; then
  ADOPT=1; SUBS=$(conf spec subsystems | tr '\n' ' ')
else
  ADOPT=0; LEVELS=$(conf "" spec)
  [ -n "$LEVELS" ] || LEVELS="spec/VISION.md spec/FUNCTIONAL.md spec/TECHNICAL.md"
  # Not adopted: guess the subsystems from the folders that hold a VISION.md beside a FUNCTIONAL.md.
  TOP=$(dirname "$(echo "$LEVELS" | head -1)")
  SUBS=$(for d in */; do d=${d%/}
    [ "$d" != "$TOP" ] && [ -f "$d/VISION.md" ] && [ -f "$d/FUNCTIONAL.md" ] && printf '%s ' "$d"
  done)
fi
SEV=WARN; [ $ADOPT = 1 ] && SEV=ERROR
say() { echo "$SEV $1 $2: $3" >> "$T/out"; }
: > "$T/out"

# The manifest: path, subsystem ("-" for the project), role (V F T for the three, L for LOG.md).
: > "$T/man"; i=0
for f in $LEVELS; do
  i=$((i + 1)); r=$(echo "V F T" | cut -d' ' -f$i)
  [ -n "$r" ] || { say M9 "$CONF:1" "[spec] levels has more than three files; the fourth and later are not read"; continue; }
  if [ -f "$f" ]; then printf '%s\t-\t%s\n' "$f" "$r" >> "$T/man"
  else say M9 "$CONF:1" "the spec level $f does not exist"; fi
done
TOP=$(dirname "$(echo "$LEVELS" | head -1)")
[ -f "$TOP/LOG.md" ] && printf '%s\t-\tL\n' "$TOP/LOG.md" >> "$T/man"
for s in $SUBS; do
  for r in V F T; do
    case $r in V) f=$s/VISION.md ;; F) f=$s/FUNCTIONAL.md ;; T) f=$s/TECHNICAL.md ;; esac
    if [ -f "$f" ]; then printf '%s\t%s\t%s\n' "$f" "$s" "$r" >> "$T/man"
    else say M6 "$CONF:1" "subsystem $s has no $f"; fi
  done
  [ -f "$s/LOG.md" ] && printf '%s\t%s\tL\n' "$s/LOG.md" "$s" >> "$T/man"
done
[ -s "$T/man" ] || { echo "spec-lint: no spec documents found in $ROOT"; exit 0; }

# M9 links: every relative link in the documents points at a file or folder that exists.
cut -f1 "$T/man" | while read -r f; do
  d=$(dirname "$f")
  grep -n -o '](\([^) ]*\)' "$f" | sed 's/](//' | while IFS=: read -r n l; do
    l=${l%%#*}
    case $l in ''|*:*) continue ;; esac
    case $l in /*) t=".$l" ;; *) t="$d/$l" ;; esac
    [ -e "$t" ] || echo "$SEV M9 $f:$n: broken link $l" >> "$T/out"
  done
done

# M9 code: section citations `(TECHNICAL n.m)` in tracked files other than Markdown.
git grep -n -I -E 'TECHNICAL(\.md)?`? +(section +)?[0-9]+' -- . ':(exclude)*.md' > "$T/code" 2>/dev/null || :
# M10: the lines added to the documents since DIFF.
: > "$T/diff"
[ -n "$DIFF" ] && git diff -U0 "$DIFF" -- $(cut -f1 "$T/man") > "$T/diff" 2>/dev/null

awk -v SEV="$SEV" -v SUBS="$SUBS" -v MAN="$T/man" -v CODE="$T/code" -v DIFF="$T/diff" '
function out(c, loc, m) { print SEV " " c " " loc ": " m }
function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
# scan(s): the ids in s, into TOK[1..n]; text in backticks was removed before.
function scan(s,   n, b, a) {
  n = 0
  while (match(s, IDRE)) {
    b = RSTART > 1 ? substr(s, RSTART - 1, 1) : ""
    a = substr(s, RSTART + RLENGTH, 1)
    if (b !~ /[A-Za-z0-9_-]/ && a !~ /[A-Za-z0-9_]/) TOK[++n] = substr(s, RSTART, RLENGTH)
    s = substr(s, RSTART + RLENGTH)
  }
  return n
}
function core(t) { sub(/^[a-z0-9_-]+:/, "", t); return t }
function kindof(t,   c) { c = core(t); if (c ~ /^[A-Z0-9]+-F-[0-9]+$/ || c ~ /^F-/) return "F"; if (c ~ /^VB/) return "VB"; return "V" }
function scopeof(t,   p) {
  if (index(t, ":")) { p = t; sub(/:.*/, "", p); return p }
  if (t ~ /^[A-Z0-9]+-F-[0-9]+$/) { p = t; sub(/-F-.*/, "", p); return tolower(p) }
  return "-"
}
function areaof(t) { sub(/[0-9]+$/, "", t); return t }
function closeh2() {
  if (role == "T" && h2line && !h2real && h2kind !~ /^(ndy|open|later)$/)
    out("M3", path ":" h2line, "section \"" h2title "\" has no Realises: line")
  h2line = 0
}
# reftarget(hit, own): the TECHNICAL a section citation points at, "" when it lies outside this set.
function reftarget(hit, own,   w, sep) {
  if (!match(hit, /^[A-Za-z0-9_-]+[\/[:space:]]/)) return TP[own]
  w = substr(hit, 1, RLENGTH - 1); sep = substr(hit, RLENGTH, 1)
  if (w in ISSUB) return TP[w]
  if (sep == "/") return ISDOC[w "/TECHNICAL.md"] ? w "/TECHNICAL.md" : ""
  if (w == "project" || w == "spec") return TP["-"]
  return (w ~ /[-_]/) ? "" : TP[own]
}
function define(t,   k) {
  k = kindof(t)
  if (scopeof(t) != sc)
    out("M1", loc, sc == "-" ? "the project document defines the subsystem id " t : "subsystem " sc " defines " t " without its prefix (" sc ":" t ")")
  if (t in DEF) { out("M1", loc, t " is defined twice; also at " DEF[t]); return }
  DEF[t] = loc; DEFK[t] = k; DEFLATER[t] = (sect == "later")
  if (k == "F") { HASREQ[area] = 1; if (sect == "later") AREALATER[area] = 1 }
}
BEGIN {
  ns = split(SUBS, SL, " "); pre = ""; leg = ""
  for (i = 1; i <= ns; i++) { ISSUB[SL[i]] = 1; pre = pre (pre ? "|" : "") SL[i]; leg = leg (leg ? "|" : "") toupper(SL[i]) }
  C = "(VB[0-9]+|V[0-9]+|F-[A-Z][A-Z0-9]*-[0-9]+)"
  IDRE = ns ? "((" pre "):)?" C "|(" leg ")-F-[0-9]+" : C
  WILDRE = ns ? "((" pre "):)?F-[A-Z][A-Z0-9]*-[*]|(" leg ")-F-[*]" : "F-[A-Z][A-Z0-9]*-[*]"
  VOC = "(^|[^a-z])(shall|ought to|try to|if possible|where possible|as appropriate|where appropriate|ideally|make sure|it is important|may not)([^a-z]|$)"
  CAPS = "(^|[^A-Za-z])(MUST|SHALL|SHOULD|NEVER|REQUIRED|CRITICAL|IMPORTANT)([^A-Za-z]|$)"
  OPENW = "(^|[^A-Za-z])(TODO|TBD|FIXME)([^A-Za-z]|$)"
  REF = "([A-Za-z0-9_-]+(/|[[:space:]]+))?TECHNICAL(\\.md)?`?:?[[:space:]]+(section[[:space:]]+)?[0-9]+(\\.[0-9]+)*"
  nd = 0
  while ((getline m < MAN) > 0) { split(m, x, "\t"); nd++; DP[nd] = x[1]; DS[nd] = x[2]; DR[nd] = x[3]; ISDOC[x[1]] = 1; if (x[3] == "T") TP[x[2]] = x[1]; if (x[3] == "V") VDOC[x[2]] = 1 }
  for (d = 1; d <= nd; d++) {
    path = DP[d]; sc = DS[d]; role = DR[d]
    fence = 0; k2 = ""; k3 = ""; area = ""; h2line = 0; interms = 0; ln = 0
    while ((getline raw < path) > 0) {
      ln++; loc = path ":" ln
      if (raw ~ /^[[:space:]]*(```|~~~)/) { fence = !fence; continue }
      if (fence) continue
      if (role == "L") { if (tolower(raw) ~ /retired:/) { n = scan(raw); for (i = 1; i <= n; i++) RET[TOK[i]] = loc } continue }
      s = raw; gsub(/`[^`]*`/, "", s)
      if (raw ~ /^#+[[:space:]]/) {
        match(raw, /^#+/); lev = RLENGTH
        t = tolower(raw); sub(/^#+[[:space:]]+/, "", t); sub(/^[0-9.]+[[:space:]]*/, "", t)
        kind = (t ~ /not designed yet/) ? "ndy" : (t ~ /^open/) ? "open" : (t ~ /^later/) ? "later" : (t ~ /goals served/) ? "gs" : ""
        if (lev <= 2) { closeh2(); k2 = kind; k3 = ""; if (lev == 2) { h2line = ln; h2title = trim(substr(raw, 3)); h2real = 0; h2kind = kind } }
        else if (lev == 3) k3 = kind
        num = raw; sub(/^#+[[:space:]]+/, "", num)
        if (match(num, /^[0-9]+(\.[0-9]+)*/)) HNUM[path SUBSEP substr(num, 1, RLENGTH)] = 1
        area = loc; AREAT[area] = trim(raw)
        p = index(tolower(s), "serves"); if (p && role == "F") { n = scan(substr(s, p)); for (i = 1; i <= n; i++) { SERV[area] = SERV[area] " " TOK[i]; SERVED[TOK[i]] = 1 } }
        interms = 0
      }
      sect = (k3 != "") ? k3 : k2
      if (role == "F" && s ~ /^[[:space:]]*[*_]*[Ss]erves:/) { n = scan(s); for (i = 1; i <= n; i++) { SERV[area] = SERV[area] " " TOK[i]; SERVED[TOK[i]] = 1 } }
      # M7: terms tables are the tables whose first header cell is "Term".
      if (raw ~ /^[[:space:]]*\|/) {
        nc = split(raw, cell, "|"); c1 = tolower(trim(cell[2])); gsub(/[`*]/, "", c1); c2 = tolower(trim(cell[3]))
        if (c1 ~ /^terms?$/) interms = 1
        else if (interms && raw !~ /^[[:space:]|:-]+$/ && c1 != "") {
          if (c2 ~ /^use[[:space:]]/) { REJ[c1] = c2; REJLOC[c1] = loc }
          else if (c1 in TERM) out("M7", loc, "the term \"" c1 "\" is defined twice; also at " TERM[c1])
          else TERM[c1] = loc
        }
      } else interms = 0
      # M1: definitions start a list item, a paragraph or a heading: **F-X-1** or ### F-X-1.
      defd = ""; y = s; sub(/^[[:space:]]*([-*+][[:space:]]+|[0-9]+\.[[:space:]]+|#+[[:space:]]+)?/, "", y)
      if (substr(y, 1, 2) == "**") y = substr(y, 3); else if (raw !~ /^#+[[:space:]]/) y = ""
      if (y != "" && match(y, "^(" IDRE ")") && substr(y, RLENGTH + 1, 1) !~ /[A-Za-z0-9_]/) {
        defd = substr(y, 1, RLENGTH); k = kindof(defd)
        if (k == "F" && role == "F" || k != "F" && role == "V") define(defd); else defd = ""
      }
      # M2: every other id on the line is a citation.
      n = scan(s); skip = defd
      for (i = 1; i <= n; i++) {
        t = TOK[i]; if (t == skip) { skip = ""; continue }
        if (!((t SUBSEP loc) in SEEN)) { SEEN[t SUBSEP loc] = 1; NC++; CL[NC] = t; CLOC[NC] = loc }
        if (role == "T" && sect == "ndy") DEFER[t] = 1
        if (role == "F" && sect == "later") LATER[t] = 1
        if (role == "V" && sc != "-" && sect == "gs" && scopeof(t) == "-" && kindof(t) == "V") GSV[sc]++
      }
      if (role == "T" && s ~ /^[[:space:]]*[*_]*Realises:/) {
        h2real = 1; for (i = 1; i <= n; i++) REAL[TOK[i]] = 1
        w = s; while (match(w, WILDRE)) { a = substr(w, RSTART, RLENGTH - 1); WREAL[a] = loc; w = substr(w, RSTART + RLENGTH) }
      }
      # M8: words outside the vocabulary; quotes (> lines) and code are exempt.
      if (s !~ /^[[:space:]]*>/) {
        ls = tolower(s)
        if (match(ls, VOC)) { wd = substr(ls, RSTART, RLENGTH); gsub(/^[^a-z]+|[^a-z]+$/, "", wd); out("M8", loc, "\"" wd "\" is not in the rule vocabulary (references/language.md)") }
        else if (match(s, CAPS)) { wd = substr(s, RSTART, RLENGTH); gsub(/^[^A-Z]+|[^A-Z]+$/, "", wd); out("M8", loc, "\"" wd "\" in capitals: capitals add no weight; write it lowercase") }
        if (sect != "open" && sect != "ndy" && match(s, OPENW)) out("M8", loc, "TODO or TBD outside an Open or Not designed yet section")
      }
      # M9: section citations into a TECHNICAL of this set.
      r = raw
      while (match(r, REF)) {
        hit = substr(r, RSTART, RLENGTH); r = substr(r, RSTART + RLENGTH)
        match(hit, /[0-9]+(\.[0-9]+)*$/); nm = substr(hit, RSTART, RLENGTH)
        tg = reftarget(hit, sc)
        if (tg != "") { NR2++; RT[NR2] = tg; RN[NR2] = nm; RL[NR2] = loc }
      }
      LTXT[++NL] = tolower(s); LLOC[NL] = loc; LTERM[NL] = interms
    }
    close(path); closeh2()
  }
  while ((getline g < CODE) > 0) {
    p1 = index(g, ":"); f = substr(g, 1, p1 - 1); rest = substr(g, p1 + 1); p2 = index(rest, ":"); cl = substr(rest, 1, p2 - 1); rest = substr(rest, p2 + 1)
    top = f; sub(/\/.*/, "", top); if (!(top in ISSUB && f ~ /\//)) top = "-"
    while (match(rest, REF)) {
      hit = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
      tg = reftarget(hit, top); if (tg == "") continue
      match(hit, /[0-9]+(\.[0-9]+)*$/)
      NR2++; RT[NR2] = tg; RN[NR2] = substr(hit, RSTART, RLENGTH); RL[NR2] = f ":" cl
    }
  }
}
END {
  for (t in RET) if (t in DEF) out("M1", DEF[t], t " is retired (" RET[t] ") and defined again")
  for (c = 1; c <= NC; c++) { t = CL[c]
    if (t in DEF) continue
    out("M2", CLOC[c], (t in RET) ? "cites the retired id " t : t " is cited but defined nowhere")
  }
  for (a in WREAL) { found = 0; for (t in DEF) if (DEFK[t] == "F" && areaof(t) == a) { found = 1; break }
    if (!found) out("M2", WREAL[a], a "* matches no requirement") }
  for (a in HASREQ) { if (a in AREALATER) continue
    ok = 0; n = scan(SERV[a]); for (i = 1; i <= n; i++) if (kindof(TOK[i]) != "VB") ok = 1
    if (!ok) out("M3", a, "the area \"" AREAT[a] "\" cites no goal it serves: add (serves V..)") }
  for (t in DEF) {
    if (DEFK[t] == "F" && !DEFLATER[t] && !(t in REAL) && !(areaof(t) in WREAL) && !(t in DEFER))
      out("M4", DEF[t], t " is realised by no TECHNICAL section (Realises:) and is not under Not designed yet")
    if (DEFK[t] == "V" && !(t in SERVED) && !(t in LATER))
      out("M5", DEF[t], "the goal " t " is served by no functional area (serves) and is not listed under Later")
  }
  for (i = 1; i <= ns; i++) if ((SL[i] in VDOC) && !(SL[i] in GSV)) out("M6", SL[i] "/VISION.md:0", "the vision of " SL[i] " maps to no project goal under Goals served")
  for (w in REJ) for (i = 1; i <= NL; i++) if (!LTERM[i] && match(LTXT[i], "(^|[^a-z])" w "([^a-z]|$)"))
    out("M7", LLOC[i], "\"" w "\" is a rejected synonym (" REJLOC[w] ": " REJ[w] ")")
  for (i = 1; i <= NR2; i++) if (!((RT[i] SUBSEP RN[i]) in HNUM)) out("M9", RL[i], RT[i] " has no section " RN[i])
  # M10: bold phrases added since the base that no terms table defines, as input for spec-check J1.
  while ((getline g < DIFF) > 0) {
    if (g ~ /^\+\+\+ /) { df = g; sub(/^\+\+\+ (b\/)?/, "", df); continue }
    if (g ~ /^@@/) { match(g, /\+[0-9]+/); dl = substr(g, RSTART + 1, RLENGTH - 1) - 1; continue }
    if (g !~ /^\+/) continue
    dl++; w = g
    while (match(w, /\*\*[^*]+\*\*/)) {
      c = trim(substr(w, RSTART + 2, RLENGTH - 4)); w = substr(w, RSTART + RLENGTH)
      sub(/[.:,;]+$/, "", c); if (scan(c)) continue
      c = tolower(c); if (c in TERM || length(c) > 60) continue
      print "NOTE M10 " df ":" dl ": candidate new term \"" c "\""
    }
  }
}' < /dev/null >> "$T/out"

cat "$T/out"
E=$(grep -c '^ERROR' "$T/out"); W=$(grep -c '^WARN' "$T/out"); N=$(grep -c '^NOTE' "$T/out")
BY=$(awk '$1 != "NOTE" { print $2 }' "$T/out" | sort | uniq -c | awk '{ printf "%s%s %s", s, $2, $1; s = ", " }')
[ $ADOPT = 1 ] || echo "spec-lint: not adopted (no [spec] levels in $CONF): findings are warnings; spec-adopt fixes them"
if [ "$E" -gt 0 ]; then echo "SPEC-LINT FAIL ($E errors, $W warnings, $N notes${BY:+: $BY})"; exit 1; fi
echo "SPEC-LINT PASS ($E errors, $W warnings, $N notes${BY:+: $BY})"
