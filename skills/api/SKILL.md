---
name: api
description: Run an API design review using APIForge agent — REST/GraphQL design, contracts, versioning, rate limiting, endpoint testing
context: fork
agent: apiforge
argument-hint: "[target] [focus: design|contracts|security|testing|all]"
---

Perform an API architecture review on $ARGUMENTS.

If no target is specified, discover and review all API endpoints in the project.
If no focus is specified, run a comprehensive review.

Available focus areas:
- **design**: Resource naming, HTTP methods, status codes, URL structure
- **contracts**: Request/response schemas, error format (RFC 7807), pagination, filtering
- **security**: Auth, rate limiting, CORS, input validation
- **testing**: Hit every endpoint with api-tester, verify responses match documentation
- **all**: Full 6-phase API review (default)

Start by mapping all endpoints and loading framework routing docs via context7.
