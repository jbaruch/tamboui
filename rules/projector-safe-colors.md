---
alwaysApply: true
---

# Projector-Safe Colors

Demo and conference-talk TUIs run on terminals with unpredictable background colors — usually a light-themed projector at the venue and a dark-themed laptop at home. `.dim()` renders as gray-on-white on the projector (invisible) and gray-on-black on the laptop (fine). **Why:** styles that depend on contrast with one background tone disappear on the other; saturated foreground primaries survive both because the chroma carries the signal, not the brightness delta.

## Avoid for Foreground Text

- `.dim()` — renders as low-contrast gray; invisible against light terminal backgrounds
- `Color.GRAY` — same problem at a different level of the stack
- Custom RGBs near neutral gray (`#888`, `#bbb`) — fail for the same reason

## Prefer For Foreground Text

- Saturated primaries: `.cyan()`, `.magenta()`, `.green()`, `.yellow()`, `.red()`, `.blue()`
- Use `.bold()` to add weight without depending on contrast
- A small named palette per app (e.g., USER=cyan, SYSTEM=magenta, ERROR=red) keeps the visual language consistent

## Backgrounds Are Different

- `.dim()` on a *background* (e.g., a faint header bar) is usually fine — the foreground text still has full contrast against it
- `Color.GRAY` as a background can work, but bias toward distinct color blocks (a magenta divider, a cyan title bar) over neutral panels

## When You Can Ignore This Rule

- Internal tools nobody projects (CLI dashboards, dev-only TUIs) — `.dim()` reads as "secondary" and works fine
- The rule fires for demos, livestreams, conference talks, recorded screencasts — anything an audience sees through a projector or a compressed video codec
