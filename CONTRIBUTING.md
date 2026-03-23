# Contributing to Claude Code Agents

Thank you for your interest in improving this project. Whether you are fixing a typo in a system prompt, tuning an agent's methodology, or building an entirely new agent, your contribution is welcome.

## How to Contribute

### Improving Existing Agents

The most impactful contributions improve the 8 core agents in `agents/`. Common improvements include:

- **Better methodology phases** — More thorough analysis steps, better ordering
- **More trigger keywords** in the `description` field — Reduces missed delegations
- **Framework-specific sections** — Adding coverage for a framework the agent does not yet handle well
- **Report format improvements** — Clearer structure, better severity classification
- **Hook script refinements** — Catching more dangerous patterns or reducing false positives

To submit an improvement:

1. Fork the repository
2. Edit the agent file in `agents/`
3. Test your change by installing the modified agent locally
4. Open a pull request with a clear explanation of what changed and why

### Creating New Agents

New agents go in `community/agents/` until they are mature enough for promotion to the core set.

1. Start with the [agent template](templates/AGENT_TEMPLATE.md) or read the full [Creating Agents Guide](docs/CREATING_AGENTS.md)
2. Write a focused agent — one domain, one job, done well
3. Include a corresponding invocation skill in `skills/<command>/SKILL.md`
4. Test thoroughly against real projects
5. Submit a pull request to `community/agents/`

If your agent covers a domain that is broadly useful and well-tested, it may be promoted to the core `agents/` directory.

### Adding or Improving Skills

Skills live in `skills/`. Each skill is a directory containing a `SKILL.md` file with YAML frontmatter. See the [Skills Guide](docs/SKILLS_GUIDE.md) for the format.

### Adding Hook Scripts

Hook scripts go in `scripts/`. They must:

- Read JSON from stdin (the tool call payload)
- Exit 0 to allow, exit 2 to block
- Print a clear message to stderr when blocking
- Require `jq` for JSON parsing (document this)

See the [Hooks Guide](docs/HOOKS_GUIDE.md) for the full specification.

## Style Guide for Agent System Prompts

All agent system prompts follow these conventions:

### Voice and Tone

- **Imperative voice**: "Scan the project", not "You should scan the project"
- **Direct and specific**: "Every endpoint MUST have rate limiting" not "Consider adding rate limiting"
- **Concrete over abstract**: Show code examples, not vague advice
- **Confident but honest**: State uncertainty explicitly rather than hedging with qualifiers

### Structure

Every agent system prompt should include these sections in order:

1. **Identity paragraph** — Who the agent is, what it does, its philosophy
2. **Arsenal (MCPs)** — What external tools it uses and when to use each one
3. **Skills Integration** — Which skills to preload and how they affect methodology
4. **Methodology (phases)** — Numbered phases with specific actions per phase
5. **Report Format** — Exact output structure with the agent's color tag prefix
6. **Memory Protocol** — What to read at start, what to update at end
7. **Stack Detection** — How to detect and adapt to the project's technology
8. **Handoff Protocol** — When and how to recommend passing work to another agent
9. **Golden Rules** — Non-negotiable principles (5 maximum)

### Formatting

- Use `##` headers for top-level sections
- Use `###` for phases and subsections
- Use code blocks for example commands, configs, and output formats
- Use tables for classifications (severity levels, smell catalogs, etc.)
- Prefix every line of example report output with the agent's color tag (e.g., `[SEC]`)

## Pull Request Process

1. **One concern per PR.** A methodology improvement and a new hook script should be separate PRs.
2. **Test locally.** Install the modified files and verify the agent works as expected with Claude Code CLI.
3. **Describe the change clearly.** Explain what changed, why, and how you tested it.
4. **Keep diffs minimal.** Do not reformat entire files or change whitespace unless that is the purpose of the PR.

## Issue Templates

Use the appropriate template when opening an issue:

- **Bug Report** — An agent behaves incorrectly or produces wrong output
- **Feature Request** — Suggest an improvement to an existing agent or the system
- **New Agent** — Propose or share a new agent for the community

## Development Setup

```bash
git clone https://github.com/Xplus-Technologies-open-source/claude-code-agents.git
cd claude-code-agents

# Install locally to test
./install.sh --scope project

# Or install to user scope
./install.sh --scope user

# Verify
# (restart Claude Code after install)
/agents-status
```

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold these standards.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
