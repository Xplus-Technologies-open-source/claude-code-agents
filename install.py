#!/usr/bin/env python3
"""
Claude Code Agents — Universal Installer (Python 3)

Cross-platform installer that works on Linux, macOS, and Windows.
No external dependencies required.

Usage:
    python install.py                   Interactive mode
    python install.py --all             Full install
    python install.py --scope user      Global install
    python install.py --scope project   Project-local install
    python install.py --uninstall       Remove everything
"""

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

VERSION = "2.0.0"
SCRIPT_DIR = Path(__file__).parent.resolve()

AGENTS = [
    "cybersentinel", "codecraft", "testforge", "growthforge",
    "docmaster", "infraforge", "dataforge", "apiforge",
]

SKILLS = [
    "sec", "bpr", "tst", "seo", "doc", "ops", "db", "api",
    "audit", "agents-status",
]

HOOKS = [
    "validate-no-destructive.sh",
    "validate-readonly-query.sh",
    "validate-infra-commands.sh",
]

AGENT_TAGS = {
    "cybersentinel": ("SEC", "\033[1;31m"),
    "codecraft":     ("BPR", "\033[1;34m"),
    "testforge":     ("TST", "\033[1;33m"),
    "growthforge":   ("SEO", "\033[1;32m"),
    "docmaster":     ("DOC", "\033[1;35m"),
    "infraforge":    ("OPS", "\033[1;36m"),
    "dataforge":     ("DB",  "\033[1;38;5;208m"),
    "apiforge":      ("API", "\033[1;37m"),
}

RESET = "\033[0m"

# ============================================================================
# Helpers
# ============================================================================

def log(msg):
    print(f"\033[1;32m[+]\033[0m {msg}")

def warn(msg):
    print(f"\033[1;33m[!]\033[0m {msg}")

def error(msg):
    print(f"\033[1;31m[x]\033[0m {msg}")

def info(msg):
    print(f"\033[2m    {msg}\033[0m")

def has_command(name):
    return shutil.which(name) is not None

def home_dir():
    return Path.home()

# ============================================================================
# Prerequisites
# ============================================================================

def check_prerequisites():
    log("Checking prerequisites...")

    if not has_command("claude"):
        error("Claude Code CLI not found.")
        if platform.system() == "Windows":
            print("  Install: irm https://claude.ai/install.ps1 | iex")
        else:
            print("  Install: curl -fsSL https://claude.ai/install.sh | bash")
        sys.exit(1)
    info("Claude Code CLI: found")

    if has_command("node"):
        info("Node.js: found")
    else:
        warn("Node.js not found. MCP auto-install will be skipped.")

    if platform.system() != "Windows" and has_command("jq"):
        info("jq: found")
    elif platform.system() != "Windows":
        warn("jq not found. Hook scripts require it.")

    print()

# ============================================================================
# Scope Resolution
# ============================================================================

def resolve_scope(scope):
    if not scope:
        print()
        print("\033[1;36mWhere should agents be installed?\033[0m")
        print()
        print("  1) User scope   — Available in ALL projects")
        print("  2) Project scope — Available only in THIS project")
        print()
        choice = input("  Choose [1/2] (default: 1): ").strip()
        scope = "project" if choice == "2" else "user"

    if scope == "user":
        base = home_dir() / ".claude"
    else:
        base = Path(".claude")

    return {
        "agents": base / "agents",
        "skills": base / "skills",
        "scripts": base / "agent-scripts",
    }

# ============================================================================
# Install Functions
# ============================================================================

def install_agents(dirs):
    log("Installing agents...")
    agents_dir = dirs["agents"]
    agents_dir.mkdir(parents=True, exist_ok=True)

    count = 0
    for md_file in sorted((SCRIPT_DIR / "agents").glob("*.md")):
        name = md_file.stem
        shutil.copy2(md_file, agents_dir / md_file.name)
        tag, color = AGENT_TAGS.get(name, ("   ", ""))
        print(f"  {color}{tag}{RESET}  {name}")
        count += 1

    log(f"{count} agents installed to {agents_dir}")
    print()


def install_skills(dirs):
    log("Installing invocation skills...")
    skills_dir = dirs["skills"]

    count = 0
    for skill_path in sorted((SCRIPT_DIR / "skills").iterdir()):
        if not skill_path.is_dir():
            continue
        skill_file = skill_path / "SKILL.md"
        if not skill_file.exists():
            continue

        dest = skills_dir / skill_path.name
        dest.mkdir(parents=True, exist_ok=True)
        shutil.copy2(skill_file, dest / "SKILL.md")
        info(f"/{skill_path.name}")
        count += 1

    log(f"{count} skills installed to {skills_dir}")
    print()


def install_hooks(dirs):
    log("Installing hook scripts...")
    scripts_dir = dirs["scripts"]
    scripts_dir.mkdir(parents=True, exist_ok=True)

    count = 0
    for script in sorted((SCRIPT_DIR / "scripts").glob("*.sh")):
        dest = scripts_dir / script.name
        shutil.copy2(script, dest)
        if platform.system() != "Windows":
            dest.chmod(0o755)
        info(script.name)
        count += 1

    # Update paths in agent files
    abs_scripts = str(scripts_dir.resolve())
    for agent_file in dirs["agents"].glob("*.md"):
        content = agent_file.read_text()
        if "./scripts/" in content:
            content = content.replace("./scripts/", f"{abs_scripts}/")
            agent_file.write_text(content)

    log(f"{count} hook scripts installed to {scripts_dir}")
    if platform.system() == "Windows":
        warn("Hook scripts require WSL or Git Bash on Windows")
    print()


def install_mcps():
    log("Checking MCP servers...")

    if not has_command("claude"):
        warn("Claude CLI not available. Skipping.")
        return

    try:
        result = subprocess.run(
            ["claude", "mcp", "list"],
            capture_output=True, text=True, timeout=30
        )
        mcp_list = result.stdout
    except Exception:
        mcp_list = ""

    # Auto-installable
    npm_mcps = {"context7": ["npx", "-y", "@upstash/context7-mcp@latest"]}

    for name, cmd in npm_mcps.items():
        if name in mcp_list:
            info(f"{name}: already configured")
        elif has_command("npx"):
            log(f"Installing {name}...")
            try:
                if platform.system() == "Windows":
                    full_cmd = ["claude", "mcp", "add", "-s", "user", name, "--", "cmd", "/c"] + cmd
                else:
                    full_cmd = ["claude", "mcp", "add", "-s", "user", name, "--"] + cmd
                subprocess.run(full_cmd, capture_output=True, timeout=30)
                info(f"{name}: installed")
            except Exception:
                warn(f"{name}: failed — add manually")

    # Custom MCPs
    print()
    log("Custom MCPs (manual setup required):")
    for name in ["cybersec", "server-admin", "local-admin", "api-tester",
                  "network-monitor", "github", "tavily", "excalidraw", "app-tester"]:
        if name in mcp_list:
            info(f"{name}: configured")
        else:
            warn(f"{name}: not configured — see docs/MCPS_GUIDE.md")
    print()

# ============================================================================
# Uninstall
# ============================================================================

def uninstall():
    log("Uninstalling Claude Code Agents...")

    search_dirs = [home_dir() / ".claude", Path(".claude")]
    for base in search_dirs:
        agents_dir = base / "agents"
        if agents_dir.exists():
            for agent in AGENTS:
                f = agents_dir / f"{agent}.md"
                f.unlink(missing_ok=True)
            info(f"Cleaned: {agents_dir}")

        skills_dir = base / "skills"
        if skills_dir.exists():
            for skill in SKILLS:
                d = skills_dir / skill
                if d.exists():
                    shutil.rmtree(d)
            info(f"Cleaned: {skills_dir}")

        scripts_dir = base / "agent-scripts"
        if scripts_dir.exists():
            shutil.rmtree(scripts_dir)
            info(f"Cleaned: {scripts_dir}")

    log("Uninstall complete.")

# ============================================================================
# Verification
# ============================================================================

def verify(dirs):
    log("Verifying installation...")
    print()

    ac = sum(1 for a in AGENTS if (dirs["agents"] / f"{a}.md").exists())
    sc = sum(1 for s in SKILLS if (dirs["skills"] / s / "SKILL.md").exists())

    print(f"  Agents: {ac}/8")
    print(f"  Skills: {sc}/10")
    print()
    print("\033[1;36mQuick start:\033[0m")
    print("  Restart Claude Code, then try:")
    print("    /sec  /bpr  /tst  /seo  /doc  /ops  /db  /api  /audit")
    print()

# ============================================================================
# Banner
# ============================================================================

def banner():
    print()
    print(f"\033[1;36m{'=' * 64}\033[0m")
    print(f"\033[1;36m  Claude Code Agents — Installer v{VERSION}\033[0m")
    print(f"\033[1;36m{'=' * 64}\033[0m")
    print()

# ============================================================================
# Main
# ============================================================================

def main():
    parser = argparse.ArgumentParser(description="Claude Code Agents Installer")
    parser.add_argument("--scope", choices=["user", "project"], default="")
    parser.add_argument("--all", action="store_true", help="Full install")
    parser.add_argument("--agents-only", action="store_true")
    parser.add_argument("--skills-only", action="store_true")
    parser.add_argument("--mcps-only", action="store_true")
    parser.add_argument("--uninstall", action="store_true")
    args = parser.parse_args()

    banner()

    if args.uninstall:
        uninstall()
        return

    check_prerequisites()

    scope = args.scope or ("user" if args.all else "")
    dirs = resolve_scope(scope)

    if args.agents_only:
        install_agents(dirs)
    elif args.skills_only:
        install_skills(dirs)
    elif args.mcps_only:
        install_mcps()
    else:
        install_agents(dirs)
        install_skills(dirs)
        install_hooks(dirs)
        install_mcps()

    verify(dirs)


if __name__ == "__main__":
    main()
