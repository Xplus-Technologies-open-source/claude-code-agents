---
name: audit
description: Run a full multi-agent audit pipeline — security, code quality, testing, and documentation in sequence
disable-model-invocation: true
argument-hint: "[quick|deep] [target-path]"
---

Run a comprehensive audit pipeline across all agents. This is the most thorough analysis available.

## Audit Depth

- **quick**: Each agent focuses on critical findings only. Faster, less verbose.
- **deep**: Maximum thoroughness on every agent. Full reports with all severity levels.
- Default (no argument): Standard audit with balanced depth.

## Pipeline Order

Execute agents in this exact sequence. Each agent's findings inform the next:

1. **@agent-cybersentinel** — Security audit first. Identifies vulnerabilities, exposed secrets, auth issues.
2. **@agent-codecraft** — Code quality review. Architecture, patterns, code smells, tech debt.
3. **@agent-testforge** — Test coverage analysis. Generate regression tests for security findings from step 1.
4. **@agent-docmaster** — Documentation completeness. Update docs based on findings from steps 1-3.

## Instructions

- Run each agent as a background subagent when possible for parallel execution
- Collect all findings into a unified executive summary at the end
- The summary should include: total issues by severity, top 5 most critical findings, recommended priority order for fixes
- Target: $ARGUMENTS (if empty, audit the entire project)
