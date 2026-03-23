# Community Agents

This directory contains agents contributed by the community. Community agents are not part of the core set but provide additional domain coverage.

## Submitting an Agent

1. Use the [agent template](../../templates/AGENT_TEMPLATE.md) as a starting point
2. Follow the guidelines in the [Creating Agents Guide](../../docs/CREATING_AGENTS.md)
3. Include an invocation skill in `skills/<command>/SKILL.md`
4. Test against real projects before submitting
5. Open a PR adding your `.md` file to this directory

## Promotion to Core

Community agents that demonstrate broad utility, thorough methodology, and consistent quality may be promoted to the core `agents/` directory.

## Agent Ideas

Looking for inspiration? Here are some agents the community has requested:

- **accessibility-auditor** — WCAG compliance, ARIA patterns, screen reader testing
- **performance-profiler** — Bottleneck detection, memory profiling, flame graph analysis
- **dependency-manager** — Version updates, breaking change detection, license compliance
- **i18n-reviewer** — Internationalization patterns, translation file management
- **migration-assistant** — Framework migration guides (React class to hooks, Express to Fastify, etc.)
