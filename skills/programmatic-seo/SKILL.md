---
name: programmatic-seo
description: Template-based page generation at scale for SEO — used by GrowthForge for programmatic SEO projects
---

# Programmatic SEO

## When to Use
- Directory sites (business listings, product catalogs)
- Location pages ("service + city" combinations)
- Comparison pages ("X vs Y")
- Integration pages ("connect X with Y")
- Template-driven content at scale (1000+ pages)

## Page Template Requirements

Each template page MUST have:
1. **Unique `<title>`** with the target keyword: `{Service} in {City} | Brand`
2. **Unique `<meta description>`** — not just find-replace, genuinely different value proposition per page
3. **Unique `<h1>`** — matches search intent for that specific combination
4. **Unique body content** — minimum 300 words of genuinely useful content (not just variable substitution)
5. **Internal links** to related pages (other cities, other services, parent category)
6. **Structured data** (LocalBusiness, Product, or appropriate schema)
7. **Canonical URL** — self-referencing, unique per page

## Content Quality Rules

- **No thin content**: Template + variable substitution alone is NOT enough. Add location-specific data, stats, testimonials, or contextual information.
- **No duplicate content**: Google detects templates. Each page needs > 30% unique content.
- **No doorway pages**: Every page must provide genuine value to the visitor, not just redirect to a main page.

## Sitemap Strategy

- Dynamic `sitemap.xml` generated at build time or on-demand
- Split into sitemap index + category sitemaps for sites > 10,000 pages
- Include `lastmod` with actual update timestamps
- Submit to Google Search Console

## Monitoring

- Track indexed pages: `site:domain.com/pattern/` in Google
- Monitor for "soft 404" detection in Search Console
- Watch for "duplicate content" warnings
- Track organic traffic per template type, not just total
