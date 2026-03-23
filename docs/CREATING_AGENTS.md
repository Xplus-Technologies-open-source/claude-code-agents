# Creating Agents

This guide covers everything you need to create a custom Claude Code subagent, from the file format to testing and distribution.

## Anatomy of an Agent File

An agent is a Markdown file with YAML frontmatter. The frontmatter configures the agent's metadata and capabilities. The Markdown body becomes the system prompt that guides the agent's behavior.

```markdown
---
name: my-agent
description: >
  When to invoke this agent. Include all relevant trigger keywords
  so Claude delegates work to it automatically.
tools: Read, Grep, Glob, Bash
model: sonnet
color: orange
effort: high
maxTurns: 25
memory: user
---

You are [AgentName], an expert in [domain]. Your mission is [objective].

## Methodology
...
```

Place the file in `~/.claude/agents/` (user scope) or `.claude/agents/` (project scope).

## Frontmatter Reference

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique identifier, lowercase with hyphens. Used for invocation. |
| `description` | string | When Claude should delegate to this agent. Include trigger keywords generously. |

### Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `tools` | string | All | Comma-separated list of allowed tools: `Read`, `Grep`, `Glob`, `Bash`, `Edit`, `Write` |
| `disallowedTools` | list | None | Tools to explicitly deny (denylist approach, alternative to `tools`) |
| `model` | string | `sonnet` | `sonnet`, `opus`, `haiku`, `inherit`, or a full model ID |
| `color` | string | None | UI color: `red`, `green`, `blue`, `yellow`, `purple`, `cyan`, `orange`, `white` |
| `effort` | string | `medium` | Reasoning effort: `low`, `medium`, `high` |
| `maxTurns` | number | None | Maximum agentic turns before stopping. Prevents runaway agents. |
| `memory` | string | None | `user`, `project`, or `local`. See [Memory Guide](MEMORY_GUIDE.md). |
| `permissionMode` | string | `default` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `mcpServers` | list | None | MCP servers this agent can access |
| `skills` | list | None | Skills to preload at startup |
| `hooks` | object | None | Lifecycle hooks for tool call validation |
| `background` | boolean | `false` | Set `true` to always run as a background task |
| `isolation` | string | None | Set `worktree` for an isolated git worktree copy |

### Permission Modes Explained

| Mode | Behavior | Best For |
|------|----------|----------|
| `plan` | Read-only. Cannot modify files. | Auditors (security, SEO, database analysis) |
| `acceptEdits` | Can propose edits. User must approve each one. | Code review, refactoring, test generation |
| `default` | Standard Claude Code permission model | General-purpose agents |
| `dontAsk` | Skips confirmation for most operations | Trusted automation agents |
| `bypassPermissions` | No restrictions | Fully trusted, unsupervised agents (use with caution) |

### Description Writing Tips

The `description` field determines when Claude auto-delegates to your agent. Write it to maximize recall:

- Include all domain-specific keywords a user might mention
- Include tool names and framework names relevant to your domain
- Use the phrase "Invoke PROACTIVELY when:" followed by a list of triggers
- End with "When in doubt about whether to invoke this agent, invoke it"

Example from CyberSentinel:

```yaml
description: >
  Elite cybersecurity auditor. Invoke PROACTIVELY when: any code is written
  or modified, PRs are reviewed, config files are touched, deploys are prepared,
  dependencies are added, authentication logic changes, or any of these keywords
  appear: security, vulnerability, audit, OWASP, CVE, secret, auth, encrypt,
  XSS, SQL injection, SSRF, IDOR, rate limit, password, TLS, firewall.
```

## System Prompt Structure

Follow this standard structure for consistency with the core agents:

### 1. Identity and Philosophy (required)

Who the agent is, what it values, how it approaches work. Start with a strong identity statement, then 3-5 core principles.

```markdown
You are [Name], a [role description]. Your mission is [objective].

## Philosophy

[Core principles that guide decision-making]
```

### 2. Arsenal — MCP Integration (if using MCPs)

For each MCP in `mcpServers`, document when and how the agent should use it. This makes the agent self-documenting and ensures it uses its tools effectively.

```markdown
## Arsenal (MCPs)

**context7** — Pull current framework documentation before every recommendation.
Use `resolve-library-id` then `get-library-docs` for the detected stack.

**tavily** — Search for CVEs, advisories, and current best practices.
Query pattern: "{package} {version} CVE vulnerability advisory"
```

### 3. Skills Integration (if preloading skills)

Explain what each preloaded skill provides and how it affects methodology.

```markdown
## Skills Integration

**security-review** — If found, follow its methodology as the primary workflow.
Supplement with your own expertise. The skill takes precedence.
```

### 4. Methodology (required)

Numbered phases with specific actions. This is the core of the agent.

- **Phase 0**: Reconnaissance / context gathering (always start here)
- **Phases 1-N**: Domain-specific analysis steps
- **Final phase**: Verification or summary

Each phase should produce actionable output, not just observations. Typical count: 4-6 phases.

### 5. Report Format (required)

Define the exact output structure. Use the agent's color tag as a prefix on every line. Include a scoring or severity system if appropriate.

```markdown
## Report Format

[TAG] ━━━━━━━━━━━━━━━━━━━━━━━━━━━
[TAG] REPORT TITLE
[TAG] Project: {name} | Stack: {detected} | Date: {date}
[TAG] ━━━━━━━━━━━━━━━━━━━━━━━━━━━
[TAG]
[TAG] SUMMARY: ...
```

### 6. Memory Protocol (if memory enabled)

What to read at start, what to update at end. See the [Memory Guide](MEMORY_GUIDE.md).

### 7. Stack Detection (recommended)

How to detect the project's technology stack and adapt recommendations.

```markdown
## Stack Detection

Check: package.json, requirements.txt, Cargo.toml, go.mod, project.godot
Read the config to determine exact framework + version.
Adapt all recommendations to the specific stack.
```

### 8. Handoff Protocol (recommended)

When to suggest another agent's involvement. Be specific about conditions.

```markdown
## Handoff Protocol

Suggest handoffs at the end of your report:
- If security issues found -> recommend CyberSentinel
- If untested code found -> recommend TestForge
```

### 9. Golden Rules (required)

5 non-negotiable principles. Keep them concrete and actionable.

```markdown
## Golden Rules

1. **[Principle]** — [Explanation]
2. **[Principle]** — [Explanation]
...
```

## Creating an Invocation Skill

Each agent should have a corresponding slash command. Create `skills/<command>/SKILL.md`:

```markdown
---
name: my-command
description: Run [agent-name] for [purpose]
context: fork
agent: my-agent
argument-hint: "[target] [options]"
---

Perform [task] on $ARGUMENTS.
If no target specified, analyze the entire project.
```

The `context: fork` and `agent` fields spawn your agent as a subagent when the user types `/my-command`.

## Testing Your Agent

1. Install to user scope: `cp my-agent.md ~/.claude/agents/`
2. Install the skill: `mkdir -p ~/.claude/skills/my-cmd && cp skill.md ~/.claude/skills/my-cmd/SKILL.md`
3. Restart Claude Code
4. Verify it appears in `/agents`
5. Test automatic delegation: describe a task matching the agent's description keywords
6. Test explicit invocation: "Use the my-agent subagent to [task]"
7. Test the slash command: `/my-cmd`
8. Verify MCP access works (if applicable)
9. Verify hook scripts block what they should (if applicable)
10. Check memory reads and writes (if applicable)

## Distribution

| Method | Location | Visibility |
|--------|----------|-----------|
| Project scope | `.claude/agents/` | Team members who clone the repo |
| User scope | `~/.claude/agents/` | Only you, across all projects |
| Community contribution | `community/agents/` in this repo | Anyone who installs this project |

## Template

Use [AGENT_TEMPLATE.md](../templates/AGENT_TEMPLATE.md) as a starting point. It includes all frontmatter fields (with comments) and the full system prompt skeleton.
