---
name: python-design-patterns
description: Pythonic design patterns and architecture principles — used by CodeCraft for Python projects
---

# Python Design Patterns

## Core Principles

### KISS (Keep It Simple)
- If a function needs a comment to explain what it does, rename it
- Prefer flat over nested: early returns instead of deep if/else
- One class = one reason to change (SRP)
- Don't build frameworks — build solutions

### Composition Over Inheritance
```python
# WRONG: Deep inheritance for behavior sharing
class Animal: ...
class Dog(Animal): ...
class GuideDog(Dog): ...

# RIGHT: Composition with protocols/protocols
class Dog:
    def __init__(self, behavior: WalkBehavior): ...
```

### Separation of Concerns
- Business logic NEVER imports framework (FastAPI, Django, Flask)
- Data access layer (repositories) separate from business rules
- Side effects (HTTP, DB, filesystem) pushed to the edges
- Pure functions at the core — easy to test, easy to reason about

## Pythonic Patterns

### Context Managers
```python
# Every resource that needs cleanup
with open(path) as f: ...
async with aiohttp.ClientSession() as session: ...
with db.transaction(): ...
```

### Generators for Large Data
```python
# Don't load everything into memory
def read_large_file(path):
    with open(path) as f:
        yield from f
```

### Type Hints
- All public function signatures and class attributes
- `from __future__ import annotations` for forward references
- `Protocol` classes instead of ABCs for structural typing
- `TypeAlias` for complex types: `UserId: TypeAlias = int`

### Modern Python (3.10+)
- `match` / `case` instead of long if/elif chains
- `|` union syntax: `str | None` instead of `Optional[str]`
- `pathlib.Path` over `os.path`
- f-strings exclusively (no `.format()` or `%`)
- `dataclasses` or `Pydantic` models instead of plain dicts

## Anti-Patterns to Flag

- God classes (>300 lines, multiple responsibilities)
- Mutable default arguments: `def f(items=[])`
- Bare `except:` clauses (catch specific exceptions)
- `import *` (pollutes namespace, hides dependencies)
- String concatenation for SQL (use parameterized queries)
- `type()` checks instead of `isinstance()` or protocols
- Nested functions more than 2 levels deep
- Using `dict` where a dataclass/NamedTuple is clearer
