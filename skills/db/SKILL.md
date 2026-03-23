---
name: db
description: Run a database audit using DataForge agent — schema review, query optimization, migration safety, index recommendations
context: fork
agent: dataforge
argument-hint: "[target] [focus: schema|queries|migrations|indexes|all]"
---

Perform a database architecture review on $ARGUMENTS.

If no target is specified, analyze all database-related code in the project.
If no focus is specified, run a comprehensive review.

Available focus areas:
- **schema**: Schema design, normalization, constraints, data types, relationships
- **queries**: Query optimization, N+1 detection, EXPLAIN ANALYZE recommendations
- **migrations**: Migration safety, zero-downtime patterns, rollback plans
- **indexes**: Index strategy, missing indexes, redundant indexes, covering indexes
- **all**: Full 6-phase database review (default)

Start by discovering ORM models, migration files, and query patterns in the codebase.
