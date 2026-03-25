---
name: react-doctor
description: React-specific issue detection and remediation — used by CodeCraft and TestForge to catch common React bugs and anti-patterns
---

# React Doctor — Issue Detection

## Common Bugs

### Stale Closures
```jsx
// BUG: count is always 0 inside the interval
useEffect(() => {
  const id = setInterval(() => setCount(count + 1), 1000);
  return () => clearInterval(id);
}, []); // count captured at mount time

// FIX: Use functional updater
useEffect(() => {
  const id = setInterval(() => setCount(c => c + 1), 1000);
  return () => clearInterval(id);
}, []);
```

### Missing Dependency Array
```jsx
// BUG: Runs on every render (infinite loop if it sets state)
useEffect(() => { fetchData(); });

// FIX: Specify dependencies
useEffect(() => { fetchData(); }, [userId]);
```

### Object/Array in Dependency Array
```jsx
// BUG: New object reference every render → infinite loop
useEffect(() => { ... }, [{ id: userId }]);

// FIX: Use primitive values or useMemo
useEffect(() => { ... }, [userId]);
```

### Key Prop Issues
```jsx
// BUG: Index as key causes state bugs on reorder/delete
items.map((item, i) => <Item key={i} ... />)

// FIX: Use stable unique identifier
items.map(item => <Item key={item.id} ... />)
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Props drilling > 3 levels | Fragile, hard to refactor | Context or composition |
| `useEffect` for derived state | Unnecessary re-renders | `useMemo` or compute inline |
| State for URL data | Out of sync with browser | Use URL params / search params |
| `forceUpdate` / key reset | Symptom of wrong data flow | Fix the state architecture |
| Inline function in JSX (perf-critical path) | New function reference each render | `useCallback` if measured to matter |
| `useEffect` + setState for transform | Causes extra render | Compute during render |

## Performance Checklist

- [ ] No unnecessary re-renders (check with React DevTools Profiler)
- [ ] Lists > 100 items use virtualization (react-window, react-virtual)
- [ ] Images lazy-loaded below the fold
- [ ] Heavy components code-split with `React.lazy` / `next/dynamic`
- [ ] Context providers scoped narrowly (not wrapping entire app for local state)
- [ ] Expensive computations in `useMemo` with proper deps

## Testing Priorities

1. User interactions (click, type, submit) → React Testing Library
2. Async data flows (loading, error, success states)
3. Conditional rendering (auth state, permissions, feature flags)
4. Form validation (client-side rules)
5. Accessibility (role, label, keyboard navigation)
