# Memory Guide

Persistent memory allows agents to accumulate knowledge across conversations. An agent with memory enabled can recall patterns from previous reviews, avoid repeating false positives, and learn project-specific conventions over time.

## How It Works

When `memory` is set in an agent's frontmatter, Claude Code creates a memory directory and includes instructions in the agent's context for reading and writing to it.

```yaml
memory: user
```

The agent sees the first 200 lines of `MEMORY.md` from its memory directory at startup. It can read additional files and write updates during execution.

## Memory Scopes

| Scope | Location | Shared With | Use Case |
|-------|----------|-------------|----------|
| `user` | `~/.claude/agent-memory/<name>/` | All projects for this user | Cross-project patterns and preferences |
| `project` | `.claude/agent-memory/<name>/` | All users of this project (version-controlled) | Team-shared conventions and project context |
| `local` | `.claude/agent-memory-local/<name>/` | No one (gitignored) | Personal project-specific notes |

All agents in this collection default to `user` scope. This allows agents to build institutional knowledge regardless of which project you are working in.

## Memory Protocol

Every agent in this collection follows the same protocol:

### At the Start of Every Task

1. Read `MEMORY.md` for prior findings, patterns, and preferences
2. Check for project-specific notes in separate topic files
3. Recall any relevant conventions from past reviews
4. Check for known false positives to avoid re-reporting

### At the End of Every Task

1. Update `MEMORY.md` with new patterns discovered
2. Record project-specific conventions (naming patterns, directory structure, preferred approaches)
3. Note false positive patterns to avoid repeating in future runs
4. Record which MCPs and tools were most effective for this stack
5. Keep `MEMORY.md` under 200 lines — move detailed content to separate topic files

## Memory Directory Structure

Each agent maintains its own memory directory:

```
~/.claude/agent-memory/
├── cybersentinel/
│   ├── MEMORY.md              # Main index (< 200 lines)
│   ├── vuln-patterns.md       # Recurring vulnerability patterns
│   ├── false-positives.md     # Known false positives to skip
│   └── project-notes/
│       ├── my-api.md          # Security context for a specific project
│       └── my-frontend.md     # Security context for another project
├── codecraft/
│   ├── MEMORY.md
│   └── conventions.md         # Discovered team conventions
├── testforge/
│   ├── MEMORY.md
│   └── test-patterns.md       # Effective testing patterns per framework
└── ...
```

## What Agents Remember

Each agent type stores different knowledge:

| Agent | Typical Memory Contents |
|-------|------------------------|
| CyberSentinel | Vulnerability patterns, false positives, accepted risks, security architecture notes |
| CodeCraft | Project conventions, tech stack versions, team preferences, previous review findings |
| TestForge | Testing framework configs, effective patterns, coverage history, flaky test notes |
| GrowthForge | SEO baseline scores, content strategies, performance budgets, competitor insights |
| DocMaster | Documentation structure decisions, style preferences, existing doc inventory |
| InfraForge | Server configurations, deployment topology, monitoring setup, incident history |
| DataForge | Schema evolution notes, query performance baselines, migration history |
| APIForge | API versioning decisions, contract patterns, endpoint inventory |

## Managing Memory

### View Memory Contents

```bash
# List all agent memory directories
ls ~/.claude/agent-memory/

# Read a specific agent's memory
cat ~/.claude/agent-memory/cybersentinel/MEMORY.md
```

### Reset Memory

```bash
# Clear a specific agent's memory
rm -rf ~/.claude/agent-memory/cybersentinel/

# Clear all agent memory
rm -rf ~/.claude/agent-memory/

# Clear project-scope memory
rm -rf .claude/agent-memory/
```

The agent starts fresh in the next conversation.

### Prompt the Agent

You can explicitly interact with agent memory during a session:

- "Check your memory first" — Encourages the agent to review past findings before starting
- "Save what you learned" — Prompts the agent to update its memory
- "Forget the false positive for X" — Asks the agent to remove a specific memory entry
- "What do you remember about this project?" — Retrieves project-specific context

## Tips

- Memory works best for agents that review the same projects repeatedly
- Project-scope memory (`project`) is useful when multiple team members use the same agents
- If an agent keeps reporting the same false positive, ask it to record it as a known false positive
- Periodically review and clean memory files to prevent stale information from accumulating
- The 200-line limit on `MEMORY.md` forces agents to keep their index concise — detailed notes go in separate files
