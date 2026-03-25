---
name: seo-audit
description: Structured SEO audit process and scoring criteria — used by GrowthForge for comprehensive SEO reviews
---

# SEO Audit Checklist

## Scoring: 100 Points Total

### Technical SEO (25 points)
- [ ] robots.txt exists and doesn't block critical resources (+2)
- [ ] XML sitemap exists with valid lastmod dates (+3)
- [ ] All pages return correct status codes (200, 301, 404 — no soft 404s) (+3)
- [ ] No redirect chains (A→B→C should be A→C) (+2)
- [ ] Canonical URLs on every indexable page (+3)
- [ ] hreflang tags correct and reciprocal (if multilingual) (+2)
- [ ] No accidental noindex on important pages (+3)
- [ ] Rendering: critical content in initial HTML (not JS-rendered) (+4)
- [ ] Clean URL structure (lowercase, hyphenated, descriptive) (+3)

### On-Page SEO (25 points)
- [ ] Unique title tag on every page (50-60 chars, keyword front-loaded) (+4)
- [ ] Unique meta description on every page (150-160 chars, includes CTA) (+3)
- [ ] Exactly one H1 per page with primary keyword (+3)
- [ ] Logical heading hierarchy (H1 → H2 → H3, no skipped levels) (+2)
- [ ] Primary keyword in first 100 words (+2)
- [ ] Internal links with descriptive anchor text (+3)
- [ ] Structured data (JSON-LD) with required properties (+4)
- [ ] Open Graph + Twitter Card meta tags complete (+2)
- [ ] Images have descriptive alt text (+2)

### Performance / Core Web Vitals (25 points)
- [ ] LCP < 2.5s (+5)
- [ ] INP < 200ms (+5)
- [ ] CLS < 0.1 (+5)
- [ ] Total page weight < 1.5MB (+3)
- [ ] JavaScript bundle < 300KB gzipped (+3)
- [ ] Images optimized (WebP/AVIF, proper sizing) (+2)
- [ ] Web fonts: max 2-3 weights, font-display: swap (+2)

### Accessibility (25 points)
- [ ] Semantic HTML (header, nav, main, footer, article) (+4)
- [ ] All interactive elements keyboard-accessible (+4)
- [ ] Visible focus indicators (+3)
- [ ] Color contrast meets WCAG AA (+4)
- [ ] All images have appropriate alt text (+3)
- [ ] Form fields have labels (+3)
- [ ] Skip-to-content link present (+2)
- [ ] No ARIA misuse (prefer native elements) (+2)

## Rating Scale

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | Production-ready, competitive |
| 75-89 | Good | Minor improvements needed |
| 50-74 | Needs Work | Significant gaps in multiple areas |
| 25-49 | Poor | Major issues blocking ranking |
| 0-24 | Critical | Fundamental problems — not indexable or usable |
