---
name: ops
description: Run an infrastructure and DevOps review using InfraForge agent — Docker, CI/CD, deployment, monitoring, security hardening
context: fork
agent: infraforge
argument-hint: "[target] [focus: docker|cicd|deploy|monitoring|security|all]"
---

Perform an infrastructure review on $ARGUMENTS.

If no target is specified, review the entire project's infrastructure configuration.
If no focus is specified, run a comprehensive review.

Available focus areas:
- **docker**: Dockerfile and docker-compose review (multi-stage, security, layer caching)
- **cicd**: CI/CD pipeline review (GitHub Actions, GitLab CI, build optimization)
- **deploy**: Deployment strategy review (blue-green, canary, rollback plans)
- **monitoring**: Logging, metrics, alerting, and observability setup
- **security**: Infrastructure security hardening (SSL, headers, firewall, SSH)
- **all**: Full 6-phase infrastructure review (default)

Start by running network-monitor scans and reviewing server configurations.
