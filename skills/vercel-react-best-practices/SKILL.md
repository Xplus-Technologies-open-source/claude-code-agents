---
name: vercel-react-best-practices
description: React and Next.js performance optimization guidelines — used by CodeCraft for React/Next.js projects
---

# React & Next.js Best Practices

## Server Components (Default in App Router)

- Server Components by default — only add `'use client'` when genuinely needed
- `'use client'` triggers: event handlers, useState, useEffect, browser APIs, React context consumers
- Push `'use client'` boundary as low as possible in the component tree
- Server Components can import Client Components, NOT the reverse

## Data Fetching

```
WRONG: useEffect + useState for data fetching in App Router
RIGHT: async Server Components with direct data fetching
RIGHT: Server Actions for mutations (form submissions, state changes)
```

- Fetch in Server Components, pass data as props to Client Components
- Use `cache()` to deduplicate identical requests in a single render
- `revalidateTag()` and `revalidatePath()` for on-demand cache invalidation
- `unstable_cache()` for non-fetch data sources (database queries)

## Performance

### Bundle Size
- Dynamic imports with `next/dynamic` for heavy client components
- `next/image` for all images (never raw `<img>` tags) — automatic WebP/AVIF, lazy loading, sizing
- `next/font` for web fonts — zero layout shift, automatic subsetting
- Check `next build` output — any first-load JS chunk > 100KB needs investigation

### Rendering
- Streaming with `<Suspense>` boundaries around slow data fetches
- `loading.tsx` for route-level loading states (automatic Suspense boundary)
- `generateStaticParams()` for static generation of dynamic routes
- ISR (Incremental Static Regeneration) with `revalidate` option for semi-static content

### Client Components
- `React.memo()` only after measuring — premature memo is worse than no memo
- `useMemo` / `useCallback` only for expensive computations or stable references in dependency arrays
- Avoid creating objects/arrays in JSX — extract to constants or useMemo
- State colocation: keep state as close to where it's used as possible

## Metadata

```typescript
// Static metadata
export const metadata: Metadata = { title: '...', description: '...' };

// Dynamic metadata
export async function generateMetadata({ params }): Promise<Metadata> { ... }
```

- Use Metadata API (not `<head>` or `next/head`)
- `opengraph-image.tsx` convention for auto-generated OG images
- `sitemap.ts` and `robots.ts` as route handlers (not static files)

## Error Handling

- `error.tsx` at each route segment level for granular error boundaries
- `not-found.tsx` for custom 404 pages
- `global-error.tsx` for root layout errors
- Server Actions: return structured errors, don't throw (client can't catch server throws)

## Anti-Patterns to Flag

- `useEffect` for data fetching in App Router components
- `getServerSideProps` / `getStaticProps` in App Router (Pages Router only)
- `next/head` in App Router (use Metadata API)
- `'use client'` at the top of a page component (push it down)
- Fetching in layout.tsx without caching (runs on every navigation)
- `router.push()` for simple navigation (use `<Link>`)
