---
name: remotion-best-practices
description: Best practices for Remotion (video creation in React) — used by CodeCraft for Remotion projects
---

# Remotion Best Practices

## Composition Architecture

- Each `<Composition>` = one video template
- Use `<Sequence>` for timed sections within a composition
- `<Series>` for sequential clips with automatic offset calculation
- Keep compositions pure — no side effects, no API calls during render

## Performance

- `useCurrentFrame()` for animation — not `useState` with timers
- Preload assets with `staticFile()` and `delayRender()` / `continueRender()`
- Use `<Img>` component (not `<img>`) for automatic loading handling
- Avoid re-renders: `React.memo` for heavy components, stable references for props
- `calculateMetadata()` for dynamic duration/dimensions

## Animation

```tsx
const frame = useCurrentFrame();
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateRight: 'clamp',
});
const scale = spring({ frame, fps: 30, config: { damping: 200 } });
```

- `interpolate()` for linear animations between keyframes
- `spring()` for natural physics-based motion
- Always use `extrapolateRight: 'clamp'` to prevent values going past target
- Combine transforms: `transform: \`scale(${scale}) translateY(${y}px)\``

## Data-Driven Videos

- Props defined in `defaultProps` and `schema` (Zod)
- Fetch data in `calculateMetadata()` — runs before render
- Use `getInputProps()` for runtime data in Remotion Player
- Keep data serializable (no functions, no class instances in props)

## Rendering

- `npx remotion render` for CLI rendering
- `renderMedia()` for programmatic rendering
- Lambda for serverless rendering at scale
- Always set explicit `width`, `height`, `fps`, `durationInFrames`
