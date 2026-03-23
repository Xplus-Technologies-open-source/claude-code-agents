---
name: tst
description: Generate and run tests using TestForge agent — unit, integration, e2e, security regression, and load testing
context: fork
agent: testforge
argument-hint: "[target] [type: unit|integration|e2e|security|load|all]"
---

Generate and execute tests for $ARGUMENTS.

If no target is specified, analyze the project and generate tests for uncovered code.
If no type is specified, generate the appropriate mix based on the testing pyramid.

Available test types:
- **unit**: Unit tests with edge cases, error paths, and boundary conditions
- **integration**: API endpoint tests, database integration tests
- **e2e**: End-to-end critical user flow tests
- **security**: Regression tests for known vulnerabilities (pairs with /sec findings)
- **load**: Load and stress testing via api-tester
- **all**: Full test suite generation following the testing pyramid

Start by checking existing test infrastructure and loading framework docs via context7.
