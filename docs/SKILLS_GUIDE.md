# Skills Guide

Skills provide domain-specific knowledge that agents load at startup. They customize agent behavior without modifying the agent file itself.

## How Skills Work

There are two types of skills in Claude Code:

### Knowledge Skills (Preloaded by Agents)

Agents declare skills to preload in their frontmatter:

```yaml
skills:
  - security-review
  - security-requirement-extraction
```

When the agent starts, it searches for these skills in two locations:

1. `.claude/skills/<skill-name>/` — Project-specific skills (checked first)
2. `~/.claude/skills/<skill-name>/` — User-global skills (fallback)

If found, the agent reads the skill's `SKILL.md` file and incorporates its methodology. The skill's instructions take priority over the agent's built-in approach, allowing you to customize behavior per project.

### Invocation Skills (Slash Commands)

Invocation skills provide slash commands that trigger agent execution. This project includes 10 invocation skills:

| Command | Skill Name | Mode | Agent | Description |
|---------|-----------|------|-------|-------------|
| `/sec` | sec | fork | cybersentinel | Security audit with configurable depth |
| `/bpr` | bpr | fork | codecraft | Code quality and architecture review |
| `/tst` | tst | fork | testforge | Test generation and coverage analysis |
| `/seo` | seo | fork | growthforge | SEO and performance audit |
| `/doc` | doc | fork | docmaster | Documentation generation |
| `/ops` | ops | fork | infraforge | Infrastructure review |
| `/db` | db | fork | dataforge | Database audit |
| `/api` | api | fork | apiforge | API design review |
| `/audit` | audit | — | Multi-agent pipeline | Full audit: SEC -> BPR -> TST -> DOC |
| `/agents-status` | agents-status | — | — | Show system status |

Invocation skills use the `context: fork` and `agent: <name>` frontmatter fields to spawn the specified agent in a new context window when invoked.

## Skill File Format

Every skill is a directory containing a `SKILL.md` file:

```
skills/
└── sec/
    └── SKILL.md
```

The `SKILL.md` file uses YAML frontmatter:

```markdown
---
name: sec
description: Run a security audit using CyberSentinel agent
context: fork
agent: cybersentinel
argument-hint: "[target] [audit-type: full|quick|deps|config|auth]"
---

Instructions for the agent when this skill is invoked.
Use $ARGUMENTS to reference the user's input.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier. Becomes the slash command name. |
| `description` | Yes | Shown in skill listings. Describes when to use this skill. |
| `context` | No | `fork` spawns a new context window. Omit for inline execution. |
| `agent` | No | Which agent to run. Required when `context: fork`. |
| `argument-hint` | No | Usage hint shown to the user. Documents expected arguments. |
| `disable-model-invocation` | No | If `true`, prevents the model from auto-invoking. User must type the command. |

## Skills Included by Agent

### CyberSentinel (SEC)

| Skill | Purpose |
|-------|---------|
| `security-review` | Project-specific security review process and checklist |
| `security-requirement-extraction` | Extract security controls based on data classification and compliance |
| `solidity-security` | Smart contract audit (loaded only for Solidity projects) |

### CodeCraft (BPR)

| Skill | Purpose |
|-------|---------|
| `frontend-design` | Layout systems, responsive design, accessibility, component architecture |
| `vercel-react-best-practices` | Server Components, App Router, caching, streaming patterns |
| `api-design-principles` | REST resource naming, HTTP semantics, pagination, versioning |
| `python-design-patterns` | Pythonic patterns, SOLID in Python, decorators, protocol classes |
| `python-performance-optimization` | Profiling, async patterns, caching, memory management |

### TestForge (TST)

| Skill | Purpose |
|-------|---------|
| `api-design-principles` | API contract validation and endpoint testing patterns |

### GrowthForge (SEO)

| Skill | Purpose |
|-------|---------|
| `seo` | Core SEO methodology and technical checklist |
| `seo-audit` | Structured audit process for comprehensive SEO reviews |
| `programmatic-seo` | Template-based page generation at scale |
| `web-design-guidelines` | Design patterns that impact SEO and conversion |

## Creating Your Own Skills

### Knowledge Skill (Agent Preload)

Create a directory in `.claude/skills/` or `~/.claude/skills/`:

```bash
mkdir -p ~/.claude/skills/my-custom-review
```

Write the `SKILL.md`:

```markdown
---
name: my-custom-review
description: Custom code review checklist for our team conventions
---

When reviewing code in this project, enforce these rules:

1. All API responses must use the standard envelope format
2. Database queries must go through the repository layer
3. Error messages must never expose internal details
...
```

Then reference it in your agent's `skills` list:

```yaml
skills:
  - my-custom-review
```

### Invocation Skill (Slash Command)

Create a directory in `.claude/skills/` or `~/.claude/skills/`:

```bash
mkdir -p ~/.claude/skills/my-command
```

Write the `SKILL.md`:

```markdown
---
name: my-command
description: Run my custom workflow
context: fork
agent: codecraft
argument-hint: "[target-directory]"
---

Perform a focused review of $ARGUMENTS using these criteria:
...
```

After restarting Claude Code, `/my-command` will be available as a slash command.
