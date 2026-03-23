---
name: sec
description: Run a security audit using CyberSentinel agent — vulnerability scanning, OWASP analysis, dependency auditing, and penetration testing
context: fork
agent: cybersentinel
argument-hint: "[target] [audit-type: full|quick|deps|config|auth]"
---

Perform a security audit on $ARGUMENTS.

If no target is specified, audit the entire project directory.
If no audit type is specified, run a full audit covering all phases.

Available audit types:
- **full**: Complete 6-phase security audit (default)
- **quick**: Critical and high severity issues only — skip info/low findings
- **deps**: Dependency-only audit — check every package for known CVEs
- **config**: Configuration audit — .env, Docker, nginx, CI/CD, headers
- **auth**: Authentication and authorization focused audit

Start by detecting the project stack and reading your agent memory for prior findings on this codebase.
