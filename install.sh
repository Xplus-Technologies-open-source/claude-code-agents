#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Claude Code Agents — Installer (Linux / macOS)
# ============================================================================
# Installs agents, skills, hook scripts, and optionally configures MCP servers.
#
# Usage:
#   ./install.sh                   Interactive mode (recommended)
#   ./install.sh --all             Full install, no prompts
#   ./install.sh --scope user      Install agents globally (~/.claude/)
#   ./install.sh --scope project   Install agents to current project (.claude/)
#   ./install.sh --agents-only     Install only agents
#   ./install.sh --skills-only     Install only skills
#   ./install.sh --mcps-only       Install only MCP servers
#   ./install.sh --uninstall       Remove installed agents, skills, and hooks
# ============================================================================

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
ORANGE='\033[1;38;5;208m'
DIM='\033[2m'
RESET='\033[0m'

# ============================================================================
# Helpers
# ============================================================================

log()   { echo -e "${GREEN}[+]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[x]${RESET} $1"; }
info()  { echo -e "${DIM}    $1${RESET}"; }

check_command() {
  command -v "$1" &>/dev/null
}

# ============================================================================
# Prerequisites
# ============================================================================

check_prerequisites() {
  log "Checking prerequisites..."

  if ! check_command claude; then
    error "Claude Code CLI not found."
    echo "  Install: curl -fsSL https://claude.ai/install.sh | bash"
    exit 1
  fi
  info "Claude Code CLI: found"

  if check_command node; then
    info "Node.js: $(node --version)"
  else
    warn "Node.js not found. MCP auto-install will be skipped."
  fi

  if check_command jq; then
    info "jq: found (required for hook scripts)"
  else
    warn "jq not found. Hook scripts require it."
    echo "  Install: sudo apt install jq  |  brew install jq"
  fi

  echo ""
}

# ============================================================================
# Scope Resolution
# ============================================================================

resolve_scope() {
  local scope="${1:-}"

  if [ -z "$scope" ]; then
    echo ""
    echo -e "${CYAN}Where should agents be installed?${RESET}"
    echo ""
    echo "  1) User scope   — Available in ALL your projects (~/.claude/)"
    echo "  2) Project scope — Available only in THIS project (.claude/)"
    echo ""
    read -rp "  Choose [1/2] (default: 1): " choice
    case "$choice" in
      2|project) scope="project" ;;
      *)         scope="user" ;;
    esac
  fi

  case "$scope" in
    user|--global)
      AGENTS_DIR="$HOME/.claude/agents"
      SKILLS_DIR="$HOME/.claude/skills"
      SCRIPTS_DIR="$HOME/.claude/agent-scripts"
      ;;
    project|--project)
      AGENTS_DIR=".claude/agents"
      SKILLS_DIR=".claude/skills"
      SCRIPTS_DIR=".claude/agent-scripts"
      ;;
    *)
      AGENTS_DIR="$scope/agents"
      SKILLS_DIR="$scope/skills"
      SCRIPTS_DIR="$scope/agent-scripts"
      ;;
  esac
}

# ============================================================================
# Install Agents
# ============================================================================

install_agents() {
  log "Installing agents..."
  mkdir -p "$AGENTS_DIR"

  local count=0
  for agent_file in "$SCRIPT_DIR"/agents/*.md; do
    [ -f "$agent_file" ] || continue
    local name
    name=$(basename "$agent_file" .md)
    cp "$agent_file" "$AGENTS_DIR/"

    case "$name" in
      cybersentinel)  echo -e "  ${RED}SEC${RESET}  $name" ;;
      codecraft)      echo -e "  ${BLUE}BPR${RESET}  $name" ;;
      testforge)      echo -e "  ${YELLOW}TST${RESET}  $name" ;;
      growthforge)    echo -e "  ${GREEN}SEO${RESET}  $name" ;;
      docmaster)      echo -e "  ${PURPLE}DOC${RESET}  $name" ;;
      infraforge)     echo -e "  ${CYAN}OPS${RESET}  $name" ;;
      dataforge)      echo -e "  ${ORANGE}DB${RESET}   $name" ;;
      apiforge)       echo -e "  ${WHITE}API${RESET}  $name" ;;
      *)              echo -e "       $name" ;;
    esac
    count=$((count + 1))
  done

  log "$count agents installed to $AGENTS_DIR"
  echo ""
}

# ============================================================================
# Install Skills
# ============================================================================

install_skills() {
  log "Installing invocation skills..."

  local count=0
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    [ -f "${skill_dir}SKILL.md" ] || continue
    local name
    name=$(basename "$skill_dir")
    mkdir -p "$SKILLS_DIR/$name"
    cp "${skill_dir}SKILL.md" "$SKILLS_DIR/$name/"
    info "/$name"
    count=$((count + 1))
  done

  log "$count skills installed to $SKILLS_DIR"
  echo ""
}

# ============================================================================
# Install Hook Scripts
# ============================================================================

install_hooks() {
  log "Installing hook scripts..."
  mkdir -p "$SCRIPTS_DIR"

  local count=0
  for script in "$SCRIPT_DIR"/scripts/*.sh; do
    [ -f "$script" ] || continue
    cp "$script" "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR/$(basename "$script")"
    info "$(basename "$script")"
    count=$((count + 1))
  done

  # Update hook paths in installed agent files
  for agent_file in "$AGENTS_DIR"/*.md; do
    [ -f "$agent_file" ] || continue
    if grep -q '\./scripts/' "$agent_file" 2>/dev/null; then
      local abs_scripts
      abs_scripts="$(cd "$SCRIPTS_DIR" 2>/dev/null && pwd || echo "$SCRIPTS_DIR")"
      sed -i.bak "s|\./scripts/|$abs_scripts/|g" "$agent_file"
      rm -f "${agent_file}.bak"
    fi
  done

  log "$count hook scripts installed to $SCRIPTS_DIR"
  echo ""
}

# ============================================================================
# Install MCP Servers
# ============================================================================

install_mcps() {
  log "Checking MCP servers..."

  if ! check_command claude; then
    warn "Claude CLI not available. Skipping MCP check."
    return
  fi

  local mcp_list
  mcp_list=$(claude mcp list 2>/dev/null || echo "")

  # Auto-installable MCPs (npx-based)
  local -A NPM_MCPS
  NPM_MCPS[context7]="npx -y @upstash/context7-mcp@latest"

  for mcp_name in "${!NPM_MCPS[@]}"; do
    if echo "$mcp_list" | grep -q "$mcp_name"; then
      info "$mcp_name: already configured"
    elif check_command npx; then
      log "Installing $mcp_name..."
      eval "claude mcp add -s user $mcp_name -- ${NPM_MCPS[$mcp_name]}" 2>/dev/null && \
        info "$mcp_name: installed" || \
        warn "$mcp_name: failed — add manually"
    else
      warn "$mcp_name: npx not available"
    fi
  done

  # HTTP MCPs
  local -A HTTP_MCPS
  HTTP_MCPS[excalidraw]="https://mcp.excalidraw.com"

  for mcp_name in "${!HTTP_MCPS[@]}"; do
    if echo "$mcp_list" | grep -q "$mcp_name"; then
      info "$mcp_name: already configured"
    else
      log "Installing $mcp_name (HTTP)..."
      claude mcp add-json -s user "$mcp_name" \
        "{\"type\":\"http\",\"url\":\"${HTTP_MCPS[$mcp_name]}\"}" 2>/dev/null && \
        info "$mcp_name: installed" || \
        warn "$mcp_name: failed — add manually"
    fi
  done

  # Custom MCPs — inform only
  echo ""
  log "Custom MCP servers (require manual setup):"
  for mcp_name in cybersec server-admin local-admin api-tester network-monitor app-tester github tavily; do
    if echo "$mcp_list" | grep -q "$mcp_name"; then
      info "$mcp_name: configured"
    else
      warn "$mcp_name: not configured — see docs/MCPS_GUIDE.md"
    fi
  done

  echo ""
}

# ============================================================================
# Uninstall
# ============================================================================

uninstall() {
  log "Uninstalling Claude Code Agents..."

  local agents=(cybersentinel codecraft testforge growthforge docmaster infraforge dataforge apiforge)
  local skills=(sec bpr tst seo doc ops db api audit agents-status)

  for dir in "$HOME/.claude/agents" ".claude/agents"; do
    [ -d "$dir" ] || continue
    for agent in "${agents[@]}"; do
      rm -f "$dir/$agent.md"
    done
    info "Cleaned: $dir"
  done

  for dir in "$HOME/.claude/skills" ".claude/skills"; do
    [ -d "$dir" ] || continue
    for skill in "${skills[@]}"; do
      rm -rf "${dir:?}/$skill"
    done
    info "Cleaned: $dir"
  done

  for dir in "$HOME/.claude/agent-scripts" ".claude/agent-scripts"; do
    [ -d "$dir" ] && rm -rf "$dir" && info "Cleaned: $dir"
  done

  log "Uninstall complete."
}

# ============================================================================
# Verification
# ============================================================================

verify() {
  log "Verifying installation..."
  echo ""

  local agent_count=0
  for agent in cybersentinel codecraft testforge growthforge docmaster infraforge dataforge apiforge; do
    if [ -f "$AGENTS_DIR/$agent.md" ]; then
      agent_count=$((agent_count + 1))
    fi
  done

  local skill_count=0
  for skill in sec bpr tst seo doc ops db api audit agents-status; do
    [ -f "$SKILLS_DIR/$skill/SKILL.md" ] && skill_count=$((skill_count + 1))
  done

  local hook_count=0
  for hook in validate-no-destructive.sh validate-readonly-query.sh validate-infra-commands.sh; do
    [ -x "$SCRIPTS_DIR/$hook" ] 2>/dev/null && hook_count=$((hook_count + 1))
  done

  echo -e "  Agents:  ${GREEN}$agent_count/8${RESET}"
  echo -e "  Skills:  ${GREEN}$skill_count/10${RESET}"
  echo -e "  Hooks:   ${GREEN}$hook_count/3${RESET}"
  echo ""

  echo -e "${CYAN}Quick start:${RESET}"
  echo "  Restart Claude Code, then try:"
  echo "    /sec      — Security audit"
  echo "    /bpr      — Code quality review"
  echo "    /tst      — Generate tests"
  echo "    /seo      — SEO audit"
  echo "    /doc      — Documentation"
  echo "    /ops      — Infrastructure review"
  echo "    /db       — Database audit"
  echo "    /api      — API design review"
  echo "    /audit    — Full multi-agent pipeline"
  echo ""
}

# ============================================================================
# Banner
# ============================================================================

banner() {
  echo ""
  echo -e "${CYAN}================================================================${RESET}"
  echo -e "${CYAN}  Claude Code Agents — Installer v${VERSION}${RESET}"
  echo -e "${CYAN}================================================================${RESET}"
  echo ""
  echo -e "  ${RED}SEC${RESET} CyberSentinel   ${GREEN}SEO${RESET} GrowthForge   ${CYAN}OPS${RESET} InfraForge"
  echo -e "  ${BLUE}BPR${RESET} CodeCraft       ${YELLOW}TST${RESET} TestForge     ${ORANGE}DB${RESET}  DataForge"
  echo -e "  ${PURPLE}DOC${RESET} DocMaster       ${WHITE}API${RESET} APIForge"
  echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
  banner

  local scope=""
  local mode="all"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scope)        scope="$2"; shift 2 ;;
      --all)          mode="all"; scope="${scope:-user}"; shift ;;
      --agents-only)  mode="agents"; shift ;;
      --skills-only)  mode="skills"; shift ;;
      --mcps-only)    mode="mcps"; shift ;;
      --uninstall)    uninstall; exit 0 ;;
      --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "  --scope user|project  Where to install (default: interactive)"
        echo "  --all                 Full install without prompts"
        echo "  --agents-only         Agents only"
        echo "  --skills-only         Skills only"
        echo "  --mcps-only           MCP servers only"
        echo "  --uninstall           Remove everything"
        echo "  -h, --help            Show this help"
        exit 0
        ;;
      *) error "Unknown option: $1"; exit 1 ;;
    esac
  done

  check_prerequisites
  resolve_scope "$scope"

  case "$mode" in
    all)
      install_agents
      install_skills
      install_hooks
      install_mcps
      ;;
    agents) install_agents ;;
    skills) install_skills ;;
    mcps)   install_mcps ;;
  esac

  verify
}

main "$@"
