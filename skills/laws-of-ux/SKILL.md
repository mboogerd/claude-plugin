---
name: laws-of-ux
description: The 30 Laws of UX (lawsofux.com) — psychology and perception principles for UI/UX decisions. Use when designing or reviewing layouts, navigation, menus, forms, onboarding, choice sets, CTAs, loading states, touch targets, grouping/spacing, or progress flows, and when you need a principled reason for a design choice (e.g. "how many options?", "how big should this button be?", "how should these elements be grouped?").
---

# Laws of UX

A collection of 30 principles (Jon Yablonski, lawsofux.com) from psychology and HCI research. Use them to **make** decisions and to **justify** them: name the law and the concrete consequence in one line. They are heuristics with known limits, not formulas — research with real users beats any law.

## How to apply

1. Identify the decision type below and scan only that section.
2. Pick the laws that actually bear on it; note conflicts (e.g. Hick's vs. Tesler's) and resolve toward the user's primary task.
3. State the choice + law: "Primary CTA full-width at bottom of the sheet (Fitts's Law: large and within thumb reach)."
4. Don't cite a law to justify an arbitrary number (see Miller's Law caveat).

---

## 1. Choices, menus, and decisions

- **Hick's Law** (Hick & Hyman, 1952) — Decision time grows with the number and complexity of choices.
  → Cut options where speed matters; split complex tasks into steps; highlight a recommended option; onboard progressively. Don't simplify to the point of vagueness.
- **Choice Overload** (Toffler, 1970) — Too many options overwhelm and degrade the experience ("paradox of choice").
  → Curate what's shown; offer search/filters to narrow; enable side-by-side comparison when a choice is required (e.g. pricing tiers).
- **Serial Position Effect** (Ebbinghaus) — First and last items in a series are remembered best.
  → Put key items at the start/end of lists and navigation; bury the least important in the middle.
- **Pareto Principle** (Pareto) — ~80% of effects come from ~20% of causes.
  → Prioritize the few features/flows that serve most users; spend design effort there.
- **Cognitive Bias** (Tversky & Kahneman, 1972) — Mental shortcuts systematically skew judgment.
  → Expect users (and designers — confirmation bias) to decide non-rationally; validate with research. Never exploit biases deceptively (dark patterns).

## 2. Memory and cognitive load

- **Cognitive Load** (Sweller, 1988) — The mental effort required to understand and use an interface.
  → Intrinsic load (the task itself) is fixed; eliminate extraneous load (decorative, confusing, or redundant UI). Overload → missed details, slower tasks.
- **Working Memory** (Miller, Galanter, Pribram; Atkinson & Shiffrin) — Temporarily holds ~4–7 chunks, each fading in ~20–30 s.
  → Favor recognition over recall (visited-link styles, breadcrumbs, visible state); make the system carry memory (comparison tables, persistent summaries).
- **Miller's Law** (Miller, 1956) — People hold roughly 7±2 items in working memory.
  → Chunk content. **Caveat:** don't use "7" to cap menus/tabs arbitrarily; capacity varies by person and context.
- **Chunking** (Miller, 1956) — Grouping pieces of information into meaningful wholes.
  → Break content into visually distinct modules with clear hierarchy; format data (phone numbers, card numbers) in groups.
- **Paradox of the Active User** (Rosson & Carroll, 1987) — Users skip manuals and start using the product immediately.
  → Don't depend on tutorials or docs; put guidance in context (tooltips, inline hints, empty states).
- **Zeigarnik Effect** (Zeigarnik, 1920s) — Unfinished tasks are remembered better than finished ones.
  → Signal more content to encourage exploration; show incomplete progress to pull users back (e.g. profile completeness).

## 3. Visual grouping and layout (Gestalt)

- **Law of Proximity** — Things close together are seen as a group.
  → Spacing *is* structure: tighter spacing within a group, larger between groups. Labels must sit closer to their own field than to the next one.
- **Law of Common Region** — Elements sharing a bounded area are seen as a group.
  → Use cards, borders, or background fills to group related content.
- **Law of Similarity** — Visually similar elements are seen as related, even when apart.
  → Same color/shape/size = same meaning. Make interactive elements (links, buttons) look distinct from static text; keep that styling consistent.
- **Law of Uniform Connectedness** — Visually connected elements are seen as more related than unconnected ones.
  → Lines, arrows, frames, and shared color bands express relationships (steppers, flow diagrams, grouped toggles).
- **Law of Prägnanz** (Wertheimer, 1910) — People interpret ambiguous or complex images in the simplest form possible.
  → Prefer simple, unambiguous shapes and icons; simple figures are processed and remembered better.
- **Von Restorff Effect** (von Restorff, 1933) — The item that differs from its peers is remembered.
  → Make the one key action/fact visually distinct. Use restraint — multiple competing highlights cancel out or look like ads. Don't rely on color alone; mind motion sensitivity.
- **Selective Attention** — People focus on the stimuli that match their goal and filter out the rest.
  → Guide attention to what matters. Banner blindness: don't make content look like ads. Change blindness: don't change multiple things at once or out of view without signaling it.

## 4. Interaction, targets, and input

- **Fitts's Law** (Fitts, 1954) — Time to hit a target depends on its distance and size.
  → Large touch targets, ample spacing between them, placed within easy reach (thumb zone, near the cursor's current focus, screen edges/corners on desktop).
- **Postel's Law** (Postel; robustness principle) — Be liberal in what you accept, conservative in what you send.
  → Accept varied input formats (phone numbers with spaces, dates in multiple forms), normalize them, define clear limits, and give clear feedback.
- **Tesler's Law** (Tesler, 1980s) — Every system has irreducible complexity; someone must handle it.
  → Absorb complexity in the system (smart defaults, inference, autofill) rather than pushing it to users. Don't design for an idealized, perfectly rational user.
- **Occam's Razor** — Among equally good options, prefer the one with fewest assumptions.
  → Avoid complexity rather than managing it. Remove elements until removing more would hurt function.

## 5. Time, feedback, and motivation

- **Doherty Threshold** (Doherty & Thadani, 1982) — Productivity soars when system response is under ~400 ms so neither side waits.
  → Respond within 400 ms. Use perceived performance (optimistic UI, skeletons, animation) for longer work; show progress bars even when imprecise. A deliberate short delay can sometimes increase perceived value/trust.
- **Goal-Gradient Effect** (Hull, 1932) — Motivation rises as the goal gets nearer.
  → Show clear progress; giving an artificial head start (e.g. 2 of 10 stamps pre-filled) increases completion.
- **Parkinson's Law** (Parkinson, 1955) — Work expands to fill the time available.
  → Make tasks take less time than users expect; autofill, sensible defaults, and fewer fields.
- **Peak-End Rule** (Kahneman et al., 1993) — Experiences are judged by their peak and their end, not the average.
  → Invest in the most intense moments and the finish (confirmation, success, error recovery). Negative peaks are remembered more vividly — fix painful moments first.
- **Flow** (Csíkszentmihályi, 1975) — Full, energized immersion in an activity.
  → Balance challenge against skill (too hard = frustration, too easy = boredom); give immediate feedback; remove friction.

## 6. Expectations and conventions

- **Jakob's Law** (Nielsen) — Users spend most of their time on other products and expect yours to work the same way.
  → Use established patterns (logo top-left links home, cart top-right, standard checkout). For redesigns, let users keep the old version for a while.
- **Mental Model** (Craik, 1943) — Users' compressed belief of how a system works, carried from similar systems.
  → Match the design to users' existing models (product cards, checkout flows, file/folder metaphors); use research to close the gap between the designer's model and the user's.
- **Aesthetic-Usability Effect** (Kurosu & Kashimura, 1995) — Attractive designs are perceived as more usable.
  → Visual polish raises trust and tolerance of minor issues. **Caveat:** it can also mask usability problems in testing — measure task success, not just satisfaction.

---

## Common tensions

| Tension | Resolution |
|---|---|
| Hick's / Occam's (fewer options) vs. Tesler's (complexity must live somewhere) | Remove what's unnecessary; for the remainder, move it into the system (defaults, inference), then progressive disclosure. |
| Von Restorff (make it stand out) vs. Similarity (consistency) | One emphasized element per view; everything else stays consistent. |
| Jakob's Law (convention) vs. novel differentiation | Default to convention for navigation, forms, and core flows; innovate in content and moments of delight (Peak-End). |
| Aesthetic-Usability vs. honest evaluation | Polish ships; testing measures behavior. |

## Quick checklist for a UI review

- [ ] Number of choices per decision minimized; recommended option highlighted (Hick, Choice Overload)
- [ ] Key items at start/end of lists and nav (Serial Position)
- [ ] Spacing, regions, and styling make grouping obvious (Proximity, Common Region, Similarity)
- [ ] Exactly one visually dominant primary action per view (Von Restorff)
- [ ] Nothing important looks like an ad (Selective Attention)
- [ ] Targets large, spaced, and reachable (Fitts)
- [ ] Input formats forgiving; complexity handled by the system (Postel, Tesler)
- [ ] Feedback < 400 ms or a progress/perceived-performance treatment (Doherty)
- [ ] Multi-step flows show progress (Goal-Gradient, Zeigarnik)
- [ ] Nothing the user must remember across screens (Working Memory, Chunking)
- [ ] Follows platform/industry conventions (Jakob, Mental Model)
- [ ] The end of the flow and the high-stakes moments are good (Peak-End)

Source: https://lawsofux.com/ (paraphrased). For general usability evaluation, pair with the `nielsen-usability-heuristics` skill.
