---
name: doc
description: Generate or update documentation using DocMaster agent — README, API docs, changelogs, architecture diagrams, legal documents
context: fork
agent: docmaster
argument-hint: "[target] [type: readme|api|changelog|architecture|legal|all]"
---

Generate or update documentation for $ARGUMENTS.

If no target is specified, audit and improve documentation for the entire project.
If no type is specified, perform a gap analysis and address the most critical needs.

Available document types:
- **readme**: Generate or improve the project README with quick start, features, architecture diagram
- **api**: API endpoint documentation with request/response examples
- **changelog**: Generate changelog from actual git commit history
- **architecture**: Architecture Decision Records (ADRs) and system diagrams via excalidraw
- **legal**: Privacy Policy, Terms of Service, Cookie Policy (DRAFT — requires legal review)
- **all**: Full documentation audit and generation

Start by auditing existing documentation via github and reading your agent memory.
