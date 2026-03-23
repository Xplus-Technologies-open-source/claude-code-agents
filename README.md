# Claude Code Agents

> Production-ready subagents for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — 8 specialized agents covering security, code quality, testing, SEO, documentation, infrastructure, databases, and API design.

Each agent runs as an independent subagent with its own context window, system prompt, tool permissions, MCP server access, and domain expertise. They can be invoked individually with slash commands, chained into pipelines, or run as a full audit suite.

---

## What Are Subagents?

Claude Code supports [custom agents](https://docs.anthropic.com/en/docs/claude-code/agents) — markdown files placed in `.claude/agents/` that define specialized personas with their own tools, permissions, and knowledge. When you invoke a subagent:

- It runs in a **separate context window** from your main conversation
- It has access to **only the tools and MCP servers you specify** in its frontmatter
- It loads **domain-specific knowledge** via skills preloading
- It follows a **structured methodology** defined in its system prompt
- It can enforce **safety constraints** through hook scripts

This project provides 8 battle-tested agents that cover the most common engineering needs.

## Agents

| Agent | Tag | Domain | Command | Key Capabilities |
|-------|-----|--------|---------|-----------------|
| **CyberSentinel** | SEC | Security | `/sec` | OWASP Top 10 audit, CVE scanning, penetration testing, secret detection, dependency analysis |
| **CodeCraft** | BPR | Code Quality | `/bpr` | Architecture review, code smells, SOLID/DRY/KISS, framework-specific best practices |
| **TestForge** | TST | Testing & QA | `/tst` | Unit/integration/e2e generation, coverage analysis, security regression tests |
| **GrowthForge** | SEO | SEO & Performance | `/seo` | Technical SEO, Core Web Vitals, structured data, accessibility, conversion optimization |
| **DocMaster** | DOC | Documentation | `/doc` | README, API docs, changelogs, legal documents, architecture diagrams |
| **InfraForge** | OPS | DevOps | `/ops` | Docker, CI/CD pipelines, deployment review, monitoring, server configuration |
| **DataForge** | DB | Databases | `/db` | Schema review, query optimization, migration safety, index analysis, N+1 detection |
| **APIForge** | API | API Design | `/api` | REST/GraphQL design, contract validation, endpoint testing, versioning strategy |

## Quick Start

### One-line Install (Linux / macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/Xplus-Technologies-open-source/claude-code-agents/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/Xplus-Technologies-open-source/claude-code-agents.git
cd claude-code-agents
./install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/Xplus-Technologies-open-source/claude-code-agents.git
cd claude-code-agents
.\install.ps1
```

### Universal (Python 3)

Works on all platforms with no external dependencies:

```bash
python install.py
```

### Install Options

```bash
./install.sh                    # Interactive mode (recommended)
./install.sh --all              # Full install, no prompts
./install.sh --scope user       # Install to ~/.claude/ (all projects)
./install.sh --scope project    # Install to .claude/ (current project only)
./install.sh --agents-only      # Install only agent definitions
./install.sh --skills-only      # Install only slash command skills
./install.sh --mcps-only        # Check and install MCP servers only
./install.sh --uninstall        # Remove all installed components
```

### Verify Installation

After installing, restart Claude Code and run:

```
/agents-status
```

This shows all installed agents, connected MCPs, available skills, and hook script status.

## Usage

### Slash Commands

Each agent has a dedicated slash command via an invocation skill:

```
/sec                     Run a full security audit on the project
/sec auth.ts             Audit a specific file
/sec quick               Critical and high findings only
/sec deps                Dependency-only CVE audit
/bpr                     Code quality and architecture review
/bpr src/api/            Review a specific directory
/tst                     Generate tests for the project
/tst src/auth/login.ts   Generate tests for a specific file
/seo                     Full SEO and performance audit
/doc                     Generate or update documentation
/ops                     Infrastructure and deployment review
/db                      Database schema and query audit
/api                     API design and contract review
```

Two additional commands manage the agent system itself:

```
/audit                   Run the full multi-agent pipeline (SEC -> BPR -> TST -> DOC)
/audit quick             Pipeline with only critical findings
/audit deep              Maximum thoroughness on every agent
/agents-status           Show installation status of all agents and MCPs
```

### Automatic Delegation

Each agent's `description` field contains keywords that trigger automatic delegation. When you discuss security topics in your main Claude Code session, Claude may suggest invoking CyberSentinel. When you write code, it may suggest CodeCraft for review.

The descriptions are intentionally broad — a false positive (unnecessary invocation) costs nothing, but a missed vulnerability or code smell costs real time.

### Agent Pipelines

Agents can be chained. The `/audit` skill runs a predefined pipeline:

```
1. CyberSentinel  — Finds vulnerabilities and security issues
2. CodeCraft      — Reviews architecture and code quality
3. TestForge      — Generates regression tests for security findings
4. DocMaster      — Updates documentation based on all findings
```

Each agent's output informs the next. TestForge generates security regression tests specifically for the vulnerabilities CyberSentinel found. DocMaster documents the fixes and architectural decisions from all previous agents.

### Handoff Protocol

In individual mode, agents **suggest** handoffs at the end of their report:

```
[SEC] -> Recommended handoff to TestForge:
[SEC]    Generate regression tests for SEC-001, SEC-003, SEC-005
```

You decide whether to follow the recommendation. In pipeline mode (`/audit`), handoffs are automatic.

## Features

### MCP Server Integration

Each agent declares which [MCP servers](https://modelcontextprotocol.io) it needs in its frontmatter:

```yaml
mcpServers:
  - cybersec
  - network-monitor
  - tavily
  - context7
```

Claude Code scopes tool access per agent — CyberSentinel gets security scanning tools, DataForge gets database tools, and so on. Agents without a particular MCP simply cannot use those tools.

See [docs/MCPS_GUIDE.md](docs/MCPS_GUIDE.md) for the complete MCP setup guide.

### Skill Preloading

Agents declare domain knowledge to preload via the `skills` field:

```yaml
skills:
  - security-review
  - security-requirement-extraction
```

When an agent starts, it checks `.claude/skills/` and `~/.claude/skills/` for matching skill files. If found, the skill's methodology takes priority over the agent's default approach. This lets you customize agent behavior per project without editing the agent file.

See [docs/SKILLS_GUIDE.md](docs/SKILLS_GUIDE.md) for the full skills reference.

### Persistent Memory

Agents with `memory: user` read and update a shared memory file across sessions:

```yaml
memory: user
```

This enables cross-session learning: previous audit findings, known false positives, project-specific conventions, and technology stack details are remembered. The agent reads memory at the start and updates it at the end of each invocation.

See [docs/MEMORY_GUIDE.md](docs/MEMORY_GUIDE.md) for details on memory scopes and management.

### Safety Hooks

Hook scripts validate agent commands before execution. For example, CyberSentinel is blocked from running destructive shell commands during audits:

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-no-destructive.sh"
```

Three hook scripts are included:

| Script | Agent | Purpose |
|--------|-------|---------|
| `validate-no-destructive.sh` | CyberSentinel | Blocks `rm -rf /`, `mkfs`, `shutdown`, and other destructive commands |
| `validate-readonly-query.sh` | DataForge | Blocks INSERT, UPDATE, DELETE, DROP — only SELECT queries allowed |
| `validate-infra-commands.sh` | InfraForge | Blocks `docker system prune`, `terraform destroy`, `kubectl delete namespace` |

See [docs/HOOKS_GUIDE.md](docs/HOOKS_GUIDE.md) for creating custom hooks.

### Permission Modes

Each agent runs with an appropriate permission level:

| Mode | Agents | Behavior |
|------|--------|----------|
| `plan` | CyberSentinel, GrowthForge | Read-only. Can analyze and report but cannot modify files. |
| `acceptEdits` | CodeCraft, TestForge | Can propose and apply file edits with user approval. |
| Default | DocMaster, InfraForge, DataForge, APIForge | Standard Claude Code permission model. |

## Configuration

### Frontmatter Reference

Every agent file supports these YAML frontmatter fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Agent identifier. Used for invocation and file naming. |
| `description` | string | Yes | Keywords and context for automatic delegation. Be generous with trigger words. |
| `tools` | string | No | Comma-separated list of allowed tools: `Read`, `Grep`, `Glob`, `Bash`, `Edit`, `Write`. |
| `model` | string | No | Model to use: `sonnet`, `opus`, `haiku`. Default: `sonnet`. |
| `color` | string | No | Display color: `red`, `blue`, `yellow`, `green`, `purple`, `cyan`, `orange`, `white`. |
| `effort` | string | No | Reasoning effort: `low`, `medium`, `high`. Default: `medium`. |
| `maxTurns` | number | No | Maximum agentic turns before stopping. Prevents runaway agents. |
| `memory` | string | No | Memory scope: `user`, `project`, `local`. Enables cross-session learning. |
| `permissionMode` | string | No | Permission level: `plan` (read-only), `acceptEdits` (can edit with approval), default. |
| `mcpServers` | list | No | MCP servers this agent can access. Must be configured in Claude Code. |
| `skills` | list | No | Skills to preload at startup. Checked in `.claude/skills/` and `~/.claude/skills/`. |
| `hooks` | object | No | PreToolUse hooks for command validation. See [Hooks Guide](docs/HOOKS_GUIDE.md). |

### Customizing Agents

Agent files are plain markdown. To customize an agent:

1. Open the installed file (e.g., `~/.claude/agents/cybersentinel.md`)
2. Edit the frontmatter to change tools, MCPs, or permissions
3. Edit the system prompt to adjust methodology, report format, or focus areas
4. Restart Claude Code to pick up changes

To create a new agent from scratch, use the [template](templates/AGENT_TEMPLATE.md) or see [docs/CREATING_AGENTS.md](docs/CREATING_AGENTS.md).

## Requirements

| Requirement | Purpose | Required? |
|-------------|---------|-----------|
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | Runtime environment | Yes |
| Node.js 18+ | MCP server installation (npx-based MCPs) | Recommended |
| jq | Hook script JSON parsing (Linux/macOS) | Recommended |
| Python 3.8+ | Universal installer (`install.py`) | Optional |

MCP servers have their own dependencies. See [docs/MCPS_GUIDE.md](docs/MCPS_GUIDE.md) for details.

## Project Structure

```
claude-code-agents/
├── agents/                          # Agent definitions (8 agents)
│   ├── cybersentinel.md             #   SEC — Security
│   ├── codecraft.md                 #   BPR — Code Quality
│   ├── testforge.md                 #   TST — Testing & QA
│   ├── growthforge.md               #   SEO — SEO & Performance
│   ├── docmaster.md                 #   DOC — Documentation
│   ├── infraforge.md                #   OPS — DevOps
│   ├── dataforge.md                 #   DB  — Databases
│   └── apiforge.md                  #   API — API Design
├── skills/                          # Invocation skills (slash commands)
│   ├── sec/SKILL.md                 #   /sec
│   ├── bpr/SKILL.md                 #   /bpr
│   ├── tst/SKILL.md                 #   /tst
│   ├── seo/SKILL.md                 #   /seo
│   ├── doc/SKILL.md                 #   /doc
│   ├── ops/SKILL.md                 #   /ops
│   ├── db/SKILL.md                  #   /db
│   ├── api/SKILL.md                 #   /api
│   ├── audit/SKILL.md               #   /audit (multi-agent pipeline)
│   └── agents-status/SKILL.md       #   /agents-status (system check)
├── scripts/                         # Hook scripts for safety
│   ├── validate-no-destructive.sh   #   Blocks destructive commands (SEC)
│   ├── validate-readonly-query.sh   #   Blocks SQL writes (DB)
│   └── validate-infra-commands.sh   #   Blocks risky infra commands (OPS)
├── templates/
│   └── AGENT_TEMPLATE.md            # Template for creating new agents
├── community/
│   └── agents/                      # Community-contributed agents
├── docs/
│   ├── SKILLS_GUIDE.md              # Skills system documentation
│   ├── MCPS_GUIDE.md                # MCP server setup guide
│   ├── HOOKS_GUIDE.md               # Hook scripts guide
│   ├── MEMORY_GUIDE.md              # Persistent memory guide
│   └── CREATING_AGENTS.md           # Guide to writing new agents
├── install.sh                       # Linux/macOS installer
├── install.ps1                      # Windows installer
├── install.py                       # Universal Python installer
├── CONTRIBUTING.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── LICENSE                          # MIT
```

## Compatibility

These agents are designed for Claude Code CLI. They use standard Claude Code features:

- Agent files with YAML frontmatter (`agents/*.md`)
- Invocation skills with context/fork modes (`skills/*/SKILL.md`)
- PreToolUse hook scripts (`scripts/*.sh`)
- MCP server scoping via `mcpServers` field
- Persistent memory via `memory` field

No custom runtime, framework, or build step is required. The installer copies files to the right directories and optionally configures MCP servers.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on improving agents, creating new ones, and submitting community agents.

## License

[MIT](LICENSE)
