---
name: frontend-design
description: Frontend design patterns, component architecture, responsive design, and accessibility — used by CodeCraft when reviewing frontend code
---

# Frontend Design Patterns

## Component Architecture

### Composition Over Configuration
- Prefer composable components over prop-heavy components
- Use children/slots for flexible content areas
- Compound components for related UI elements (Tabs + TabPanel)
- Render props or hooks for shared behavior (not HOCs — they are legacy)

### Component Categories
| Type | Purpose | State | Examples |
|------|---------|-------|---------|
| Layout | Structure and spacing | None | Grid, Stack, Container, Sidebar |
| UI | Visual elements | Minimal | Button, Input, Card, Badge |
| Feature | Business logic + UI | Own state | LoginForm, ProductCard, Cart |
| Page | Route entry points | Data fetching | Dashboard, ProductPage |

### File Organization
```
components/
  ui/           # Reusable, no business logic
  features/     # Business-specific components
  layout/       # Structural components
```

## Responsive Design

### Mobile-First
- Start with mobile layout, add complexity with `min-width` breakpoints
- Common breakpoints: 640px (sm), 768px (md), 1024px (lg), 1280px (xl)
- Use relative units (rem, em, %) over fixed pixels for spacing and typography
- `clamp()` for fluid typography: `font-size: clamp(1rem, 2.5vw, 1.5rem)`

### Layout Systems
- CSS Grid for 2D layouts (page structure, galleries, dashboards)
- Flexbox for 1D layouts (navigation, card rows, form controls)
- Container queries for component-level responsiveness (preferred over media queries for reusable components)

## Accessibility (Mandatory)

- Semantic HTML first: `<button>`, `<nav>`, `<main>`, `<article>` — not `<div onclick>`
- Every image has descriptive `alt` text (empty `alt=""` for decorative images)
- Color contrast: 4.5:1 minimum for normal text, 3:1 for large text
- Keyboard navigation: all interactive elements focusable and operable
- Focus indicators visible on all focusable elements
- `aria-label` on icon-only buttons
- Skip-to-content link as first focusable element
- Form fields have associated `<label>` elements (not just placeholder text)

## CSS Methodology

- Use CSS Modules, Tailwind, or CSS-in-JS (styled-components, Emotion) — pick ONE per project
- Avoid global CSS except for resets and CSS custom properties
- CSS custom properties (variables) for theming: `--color-primary`, `--spacing-md`
- Avoid `!important` — fix specificity issues at the source
- `box-sizing: border-box` globally
