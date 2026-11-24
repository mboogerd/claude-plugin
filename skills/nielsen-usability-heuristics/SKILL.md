---
name: nielsen-usability-heuristics
description: Jakob Nielsen's 10 usability heuristics (NN/g) — broad rules of thumb for interaction design and heuristic evaluation. Use when designing or reviewing any UI/UX (screens, flows, forms, error messages, empty/loading states, navigation, settings, destructive actions, onboarding/help), when auditing an interface for usability problems, or when deciding how a system should give feedback, prevent errors, or let users undo.
---

# Nielsen's 10 Usability Heuristics

Jakob Nielsen (with Rolf Molich, 1990; refined 1994 from a factor analysis of 249 usability problems; descriptions refreshed by NN/g in 2020, heuristics unchanged). They are **broad rules of thumb, not specific guidelines** — use them to generate design decisions and to find problems, then verify with users.

## How to apply

**When designing:** for each screen or flow, walk the 10 heuristics and ask the question under each. Resolve the answer into a concrete design decision.

**When reviewing (heuristic evaluation):**
1. Walk through the interface by task, not by page.
2. For each problem, record: location, heuristic violated, what happens, a fix.
3. Rate severity (common NN/g practice, not part of the heuristics article): 0 not a problem · 1 cosmetic · 2 minor · 3 major · 4 catastrophe. Weigh frequency, impact, and persistence.
4. Report highest severity first. One problem may violate several heuristics — list the most specific.

---

## 1. Visibility of system status

Keep users informed about what's going on through appropriate, timely feedback. Predictable, communicative systems earn trust.

**Ask:** Does the user always know where they are, what just happened, and what is happening now?
- Give feedback immediately for every action (pressed state, inline save confirmation, spinner/progress).
- Communicate state *before* consequential actions (what will be charged, sent, overwritten).
- Show location (active nav item, breadcrumbs, step 2 of 4), selection, sync/save status, and long-running progress.
- *Analogy:* "You are here" marker on a mall map.

## 2. Match between the system and the real world

Speak the users' language — words, phrases, and concepts familiar to them, not internal jargon. Follow real-world conventions and present information in a natural, logical order.

**Ask:** Would a user understand every label without looking it up?
- Don't assume your terms (or your team's data-model names) match users'; learn their vocabulary through research.
- Order and lay out controls to match their real-world counterparts and the user's task sequence.
- Use familiar metaphors and icons only where they truly map.
- *Analogy:* stovetop knobs laid out like the burners they control.

## 3. User control and freedom

Users often act by mistake and need a clearly marked "emergency exit" to leave the unwanted action without an extended process.

**Ask:** Can the user back out of, or reverse, anything they just did?
- Support Undo and Redo; prefer undo over "Are you sure?" dialogs for reversible actions.
- Always offer a visible Cancel / Close / Back; Escape closes modals; the browser back button works.
- Don't trap users in flows, modals, or wizards; preserve their input when they leave and return.

## 4. Consistency and standards

Users shouldn't wonder whether different words, situations, or actions mean the same thing. Follow platform and industry conventions (Jakob's Law: users spend most of their time in *other* products).

**Ask:** Does the same thing look and behave the same everywhere — and like it does in other products?
- **Internal consistency:** one term, one icon, one interaction pattern per concept across the product (family).
- **External consistency:** follow platform conventions (OS controls, web patterns, standard shortcuts, standard placement).
- Consistency improves learnability; deviate only for a clear, tested benefit.

## 5. Error prevention

Good error messages matter, but preventing errors is better. Eliminate error-prone conditions, or check for them and ask for confirmation before the user commits.

Two kinds of errors:
- **Slips** — unconscious, from inattention (the user knows the goal, executes wrong). Prevent with constraints, good defaults, and forgiving formats.
- **Mistakes** — conscious, from a mismatched mental model. Prevent with clear labels, previews, and warnings.

**Ask:** What is the most expensive error a user can make here, and what stops it?
- Prevent high-cost errors first (data loss, payments, sending, deletion).
- Constrain input (pickers, disabled invalid options, inline validation before submit).
- Reduce memory burden, support undo, and warn before destructive or unusual actions — confirmations should name the consequence ("Delete 12 files permanently").
- *Analogy:* guard rails on a mountain road.

## 6. Recognition rather than recall

Minimize memory load by making elements, actions, and options visible. Users shouldn't have to remember information from one part of the interface to another; help should be visible or easy to retrieve when needed.

**Ask:** Does the user have to remember anything the screen could show them?
- Show options instead of requiring typed commands; show recent items, previous values, and history.
- Keep relevant context on screen across steps (order summary, the item being edited).
- Provide in-context help over upfront tutorials to memorize; labels on icons.
- *Analogy:* "Is Lisbon the capital of Portugal?" is easier than "What is the capital of Portugal?"

## 7. Flexibility and efficiency of use

Shortcuts — hidden from novices — speed up interaction for experts, so the design serves both. Let users tailor frequent actions.

**Ask:** Is there a faster path for frequent users that doesn't burden new ones?
- Accelerators: keyboard shortcuts, command palettes, gestures, bulk actions.
- Personalization (system-adapted: recents, suggestions) and customization (user-configured: saved views, favorites).
- Defaults that serve beginners; power features discoverable but not in the way.

## 8. Aesthetic and minimalist design

Interfaces shouldn't contain irrelevant or rarely needed information. Every extra unit of information competes with the relevant ones and reduces their visibility. (This is about focus, not flat design.)

**Ask:** What on this screen does not support the user's primary goal?
- Cut or demote secondary content; progressive disclosure for rarely needed options.
- Clear visual hierarchy so the primary content and action dominate.
- Decoration must not hinder use.
- *Analogy:* an ornate teapot whose decorations make it hard to pour.

## 9. Help users recognize, diagnose, and recover from errors

Error messages should be expressed in plain language (no error codes), precisely indicate the problem, and constructively suggest a solution.

**Ask:** When something fails, does the user know what happened, why, and what to do next?
- Use conventional error visuals (red text/icon, placed next to the cause), not color alone.
- Plain language, no jargon or raw codes; say what went wrong specifically ("Card expired", not "Invalid input").
- Offer a fix or a shortcut to it (retry, correct the field, alternative path); keep the user's input.
- *Analogy:* a "Wrong way" road sign.

## 10. Help and documentation

Best if the system needs no explanation. When help is needed, make it easy to search, focused on the user's task, concise, and listing concrete steps.

**Ask:** Where would a stuck user look, and will they find the answer there?
- Prefer contextual help (tooltips, inline hints, empty-state guidance) at the moment of need.
- Searchable docs, organized by task, with numbered concrete steps.
- *Analogy:* an airport information kiosk.

---

## Quick review template

| # | Location | Heuristic | Problem | Severity (0–4) | Fix |
|---|---|---|---|---|---|

## Fast checklist

- [ ] Every action gets immediate, visible feedback; location and state are always visible (H1)
- [ ] Labels use the user's words; order matches the task (H2)
- [ ] Undo, Cancel, Back, and Escape work everywhere; no traps (H3)
- [ ] One term/pattern per concept; platform conventions followed (H4)
- [ ] Costly errors prevented by constraints, defaults, or specific confirmations (H5)
- [ ] Nothing must be remembered between screens (H6)
- [ ] Shortcuts/bulk actions for frequent users (H7)
- [ ] Each screen focused on its primary goal (H8)
- [ ] Errors: plain language, specific, next to the cause, with a fix (H9)
- [ ] Contextual, task-oriented help available (H10)

Source: https://www.nngroup.com/articles/ten-usability-heuristics/ (Nielsen, 1994; paraphrased). For psychology-based rationale (choice counts, target sizes, grouping, timing), pair with the `laws-of-ux` skill.
