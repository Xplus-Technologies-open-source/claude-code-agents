---
name: seo
description: Run an SEO and performance audit using GrowthForge agent — technical SEO, Core Web Vitals, structured data, accessibility
context: fork
agent: growthforge
argument-hint: "[target] [focus: technical|content|performance|accessibility|full]"
---

Perform an SEO and performance audit on $ARGUMENTS.

If no target is specified, audit the entire project's public-facing pages.
If no focus is specified, run a full audit covering all phases.

Available focus areas:
- **technical**: robots.txt, sitemap, canonical URLs, crawl budget, rendering strategy
- **content**: Title tags, meta descriptions, heading hierarchy, content signals
- **performance**: Core Web Vitals (LCP, INP, CLS), bundle size, image optimization
- **accessibility**: WCAG 2.1 AA compliance, semantic HTML, ARIA, keyboard navigation
- **full**: Complete 7-phase audit (default)

Start by researching the competitive landscape via tavily before analyzing code.
