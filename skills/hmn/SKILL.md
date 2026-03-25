---
name: hmn
description: Detect AI-generated code patterns and humanize code using HumanForge agent — pattern detection, git hygiene, commit validation, code authenticity
context: fork
agent: humanforge
argument-hint: "[target] [focus: code|git|docs|full]"
---

Perform a code authenticity review on $ARGUMENTS.

If no target is specified, analyze the entire project for AI-generated code patterns and git history violations.
If no focus is specified, run a full analysis covering all phases.

Available focus areas:
- **code**: Scan source code for AI-generated patterns (comments, naming, structure, error handling)
- **git**: Audit git history for AI mentions in commits, PRs, branch names, and co-author tags
- **docs**: Check documentation (README, comments, docstrings) for AI writing patterns
- **full**: Complete 5-phase authenticity review (default)

Start by detecting the project stack, loading framework conventions via context7, and reading your agent memory for prior findings.
