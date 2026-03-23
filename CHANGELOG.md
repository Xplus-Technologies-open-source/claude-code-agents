# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-03-22

### Added

- 3 new agents: InfraForge (DevOps), DataForge (databases), APIForge (API design) — total: 8 agents
- 10 invocation skills with slash commands: `/sec`, `/bpr`, `/tst`, `/seo`, `/doc`, `/ops`, `/db`, `/api`, `/audit`, `/agents-status`
- 3 hook scripts for command validation: destructive command blocking (SEC), SQL write blocking (DB), infrastructure command blocking (OPS)
- Persistent memory support for all agents via `memory: user` field
- MCP server scoping per agent via `mcpServers` field
- Skill preloading per agent via `skills` field
- Permission modes: `plan` for read-only auditors, `acceptEdits` for agents that write files
- Multi-agent audit pipeline via `/audit` command (SEC -> BPR -> TST -> DOC)
- Agent status dashboard via `/agents-status` command
- Windows installer (`install.ps1`)
- Universal Python installer (`install.py`) — cross-platform, no dependencies
- Uninstall support: `./install.sh --uninstall`
- Complete documentation suite: Skills Guide, MCPs Guide, Hooks Guide, Memory Guide, Creating Agents Guide
- Full agent template with all frontmatter fields documented and commented
- Issue templates for bug reports, feature requests, and new agent proposals
- Code of Conduct (Contributor Covenant v2.1)
- Security policy for vulnerability reporting

### Changed

- All 5 original agents rewritten with structured methodology phases, MCP integration, skills preloading, memory protocol, and handoff protocol
- Agent descriptions expanded with comprehensive trigger keywords for better auto-delegation
- Report formats standardized with color-tagged prefixes and consistent structure across all agents
- Installer rewritten with MCP auto-detection, skill installation, hook script deployment, and verification
- README rewritten for public GitHub release (English, professional)
- CONTRIBUTING guide expanded with style guide, PR process, and issue templates
- Agent template expanded from basic skeleton to full production template with all sections

### Removed

- Godot-specific MCP server references (godot-mcp, godot-full, godot-debug, godot-docs) — agents still support Godot projects via stack detection
- Spanish-only documentation (replaced with English for public release)

## [1.0.0] - 2026-02-15

### Added

- Initial release with 5 agents: CyberSentinel, CodeCraft, TestForge, GrowthForge, DocMaster
- Basic bash installer for Linux/macOS
- Skills and MCPs documentation
- Agent template
- MIT License
