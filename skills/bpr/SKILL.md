---
name: bpr
description: Run a code quality and best practices review using CodeCraft agent — architecture, patterns, code smells, and framework-specific guidance
context: fork
agent: codecraft
argument-hint: "[target] [focus: architecture|quality|performance|refactor]"
---

Perform a code quality review on $ARGUMENTS.

If no target is specified, review the entire project.
If no focus is specified, run a comprehensive review covering all categories.

Available focus areas:
- **architecture**: Project structure, separation of concerns, dependency graph
- **quality**: Code smells, naming, complexity, duplication, dead code
- **performance**: Bottlenecks, unnecessary allocations, caching opportunities
- **refactor**: Actionable refactoring suggestions with before/after examples

Start by loading current framework docs via context7 and reading your agent memory for project conventions.
