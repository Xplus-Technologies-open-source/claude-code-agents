---
name: python-performance-optimization
description: Python profiling and performance optimization techniques — used by CodeCraft when Python performance is a concern
---

# Python Performance Optimization

## Profile Before Optimizing

```python
# CPU profiling
python -m cProfile -s cumtime app.py
# Or use py-spy for live profiling: py-spy top --pid <PID>

# Memory profiling
pip install memory-profiler
python -m memory_profiler app.py

# Line-by-line profiling
pip install line-profiler
kernprof -l -v script.py
```

**Rule: Never optimize without profiling first.** The bottleneck is almost never where you think it is.

## Common Bottlenecks

### Database (Most Common)
- N+1 queries: use `joinedload` / `selectinload` in SQLAlchemy
- Missing indexes: EXPLAIN ANALYZE every slow query
- Connection pool exhaustion: tune `pool_size` and `max_overflow`
- Unnecessary SELECT *: fetch only needed columns

### I/O Bound
- Use `async/await` for concurrent I/O (HTTP calls, DB queries)
- `asyncio.gather()` for parallel async operations
- `aiohttp` or `httpx` instead of `requests` for async HTTP
- Connection pooling for external services

### CPU Bound
- Move heavy computation to background tasks (Celery, RQ, FastAPI BackgroundTasks)
- Use `multiprocessing` for true parallelism (GIL doesn't affect processes)
- Consider Cython, Numba, or Rust extensions for hot paths
- Cache expensive computations with `functools.lru_cache` or Redis

### Memory
- Generators instead of lists for large datasets
- `__slots__` on classes instantiated thousands of times
- Streaming responses for large file downloads
- Weak references for caches that shouldn't prevent GC

## Caching Strategy

```python
# Function-level caching
from functools import lru_cache

@lru_cache(maxsize=256)
def expensive_computation(key: str) -> Result: ...

# Application-level caching (Redis)
# Cache invalidation strategy: TTL + event-based invalidation
# Cache-aside pattern: check cache → miss → compute → store → return
```

## Async Patterns

```python
# WRONG: Sequential async (no benefit)
result1 = await fetch_user(id)
result2 = await fetch_orders(id)

# RIGHT: Concurrent async
result1, result2 = await asyncio.gather(
    fetch_user(id),
    fetch_orders(id),
)
```

- `async def` for I/O-bound operations
- Regular `def` for CPU-bound (async doesn't help, blocks event loop)
- Use `run_in_executor` for blocking calls in async context
