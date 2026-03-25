---
name: web-design-guidelines
description: Web interface design guidelines covering layout, UX, and conversion patterns — used by GrowthForge when evaluating design impact on SEO and CRO
---

# Web Design Guidelines

## Visual Hierarchy

1. **F-pattern for text-heavy pages**: Users scan left-to-right, then down the left side
2. **Z-pattern for landing pages**: Logo (top-left) → CTA (top-right) → Content (bottom-left) → CTA (bottom-right)
3. **Size signals importance**: Largest element = most important. Period.
4. **Whitespace is not wasted space**: It guides attention and improves readability.

## Above the Fold

The first viewport MUST answer three questions:
1. **What is this?** — Clear headline (< 10 words)
2. **Why should I care?** — Value proposition (1 sentence)
3. **What do I do next?** — Single, clear CTA

## Call-to-Action (CTA) Design

- One primary CTA per page section (not three competing buttons)
- Contrast color from the page palette (not the same as other elements)
- Action-oriented text: "Start free trial" not "Submit" or "Click here"
- Visible without scrolling on desktop and mobile
- Adequate size: minimum 44x44px tap target on mobile (WCAG)

## Typography

- Maximum 2 font families per site (heading + body)
- Body text: 16px minimum, 1.5 line-height for readability
- Heading scale: consistent ratio (1.25x or 1.333x per level)
- Maximum 75 characters per line (measure) for comfortable reading
- `font-display: swap` for all web fonts

## Color

- Primary + secondary + neutral palette (3-5 colors total)
- WCAG AA contrast ratios: 4.5:1 normal text, 3:1 large text
- Semantic colors: green for success, red for error, yellow for warning
- Dark mode: not just inverted colors — redesigned contrast and emphasis

## Mobile-First Design

- Touch targets: 44x44px minimum with 8px spacing between
- No hover-dependent interactions (mobile has no hover)
- Bottom navigation for primary actions (thumb-friendly zone)
- Full-width buttons on mobile (no tiny inline buttons)
- Avoid horizontal scrolling — ever

## Forms (Conversion Critical)

- Minimum viable fields (every extra field reduces conversion ~7%)
- Inline validation (show errors as the user types, not on submit)
- Clear labels above fields (not inside as placeholder text)
- Progress indicator for multi-step forms
- Smart defaults and autofill support (`autocomplete` attributes)
