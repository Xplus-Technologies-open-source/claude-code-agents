# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do not open a public issue.** Instead, send a description of the vulnerability to the project maintainers through a private channel (GitHub Security Advisory or direct contact).

Include:
- A description of the vulnerability
- Steps to reproduce it
- The potential impact
- Any suggested fix (optional)

We will acknowledge receipt within 48 hours and aim to provide a fix or mitigation within 7 days for critical issues.

## Scope

This project consists of Markdown files (agent definitions, skills, documentation) and shell scripts (hook validators, installers). The primary security concern is:

- **Hook script bypasses**: If a hook script can be tricked into allowing a destructive command, that is a vulnerability.
- **Installer injection**: If the installer scripts can be manipulated to execute unintended commands.
- **Agent prompt injection**: If an agent's system prompt can be manipulated through crafted file contents in a project being analyzed.

## Supported Versions

Only the latest release is supported with security updates.
