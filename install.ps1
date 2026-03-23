# ============================================================================
# Claude Code Agents — Installer (Windows PowerShell)
# ============================================================================
# Usage:
#   .\install.ps1                    Interactive mode
#   .\install.ps1 -Scope user        Install globally
#   .\install.ps1 -Scope project     Install to current project
#   .\install.ps1 -All               Full install, no prompts
#   .\install.ps1 -Uninstall         Remove everything
# ============================================================================

param(
    [ValidateSet("user", "project")]
    [string]$Scope = "",
    [switch]$All,
    [switch]$AgentsOnly,
    [switch]$SkillsOnly,
    [switch]$McpsOnly,
    [switch]$Uninstall,
    [switch]$Help
)

$Version = "2.0.0"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================================================
# Helpers
# ============================================================================

function Write-Log   { param($Msg) Write-Host "[+] $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "[!] $Msg" -ForegroundColor Yellow }
function Write-Err   { param($Msg) Write-Host "[x] $Msg" -ForegroundColor Red }
function Write-Info  { param($Msg) Write-Host "    $Msg" -ForegroundColor DarkGray }

function Test-Command {
    param($Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

# ============================================================================
# Prerequisites
# ============================================================================

function Test-Prerequisites {
    Write-Log "Checking prerequisites..."

    if (-not (Test-Command "claude")) {
        Write-Err "Claude Code CLI not found."
        Write-Host "  Install: irm https://claude.ai/install.ps1 | iex"
        exit 1
    }
    Write-Info "Claude Code CLI: found"

    if (Test-Command "node") {
        Write-Info "Node.js: $(node --version)"
    } else {
        Write-Warn "Node.js not found. MCP auto-install will be skipped."
    }

    Write-Host ""
}

# ============================================================================
# Scope Resolution
# ============================================================================

function Resolve-InstallScope {
    if (-not $Scope) {
        Write-Host ""
        Write-Host "Where should agents be installed?" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  1) User scope   - Available in ALL projects"
        Write-Host "  2) Project scope - Available only in THIS project"
        Write-Host ""
        $choice = Read-Host "  Choose [1/2] (default: 1)"
        if ($choice -eq "2") { $script:Scope = "project" } else { $script:Scope = "user" }
    }

    switch ($Scope) {
        "user" {
            $script:AgentsDir  = Join-Path $env:USERPROFILE ".claude\agents"
            $script:SkillsDir  = Join-Path $env:USERPROFILE ".claude\skills"
            $script:ScriptsDir = Join-Path $env:USERPROFILE ".claude\agent-scripts"
        }
        "project" {
            $script:AgentsDir  = ".claude\agents"
            $script:SkillsDir  = ".claude\skills"
            $script:ScriptsDir = ".claude\agent-scripts"
        }
    }
}

# ============================================================================
# Install Agents
# ============================================================================

function Install-Agents {
    Write-Log "Installing agents..."
    New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null

    $colors = @{
        cybersentinel = "Red"; codecraft = "Blue"; testforge = "Yellow"
        growthforge = "Green"; docmaster = "Magenta"; infraforge = "Cyan"
        dataforge = "DarkYellow"; apiforge = "White"
    }
    $tags = @{
        cybersentinel = "SEC"; codecraft = "BPR"; testforge = "TST"
        growthforge = "SEO"; docmaster = "DOC"; infraforge = "OPS"
        dataforge = "DB"; apiforge = "API"
    }

    $count = 0
    Get-ChildItem "$ScriptDir\agents\*.md" | ForEach-Object {
        $name = $_.BaseName
        Copy-Item $_.FullName -Destination $AgentsDir -Force
        $tag = $tags[$name]
        $color = $colors[$name]
        if ($tag) {
            Write-Host "  $tag  $name" -ForegroundColor $color
        } else {
            Write-Host "       $name"
        }
        $count++
    }

    Write-Log "$count agents installed to $AgentsDir"
    Write-Host ""
}

# ============================================================================
# Install Skills
# ============================================================================

function Install-Skills {
    Write-Log "Installing invocation skills..."

    $count = 0
    Get-ChildItem "$ScriptDir\skills" -Directory | ForEach-Object {
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $dest = Join-Path $SkillsDir $_.Name
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            Copy-Item $skillFile -Destination $dest -Force
            Write-Info "/$($_.Name)"
            $count++
        }
    }

    Write-Log "$count skills installed to $SkillsDir"
    Write-Host ""
}

# ============================================================================
# Install Hook Scripts
# ============================================================================

function Install-Hooks {
    Write-Log "Installing hook scripts..."
    New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null

    $count = 0
    Get-ChildItem "$ScriptDir\scripts\*.sh" | ForEach-Object {
        Copy-Item $_.FullName -Destination $ScriptsDir -Force
        Write-Info $_.Name
        $count++
    }

    # Update paths in agent files
    Get-ChildItem "$AgentsDir\*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -match '\./scripts/') {
            $absPath = (Resolve-Path $ScriptsDir -ErrorAction SilentlyContinue).Path
            if (-not $absPath) { $absPath = $ScriptsDir }
            $content = $content -replace '\./scripts/', "$absPath/"
            Set-Content $_.FullName -Value $content -NoNewline
        }
    }

    Write-Log "$count hook scripts installed"
    Write-Warn "Hook scripts require WSL or Git Bash on Windows"
    Write-Host ""
}

# ============================================================================
# Install MCPs
# ============================================================================

function Install-Mcps {
    Write-Log "Checking MCP servers..."

    if (-not (Test-Command "claude")) {
        Write-Warn "Claude CLI not available. Skipping."
        return
    }

    $mcpList = claude mcp list 2>$null

    # NPM-based MCPs
    $npmMcps = @{
        context7 = "npx -y @upstash/context7-mcp@latest"
    }

    foreach ($mcp in $npmMcps.GetEnumerator()) {
        if ($mcpList -match $mcp.Key) {
            Write-Info "$($mcp.Key): already configured"
        } elseif (Test-Command "npx") {
            Write-Log "Installing $($mcp.Key)..."
            $args = $mcp.Value -split ' '
            & claude mcp add -s user $mcp.Key -- cmd /c $mcp.Value 2>$null
            if ($LASTEXITCODE -eq 0) { Write-Info "$($mcp.Key): installed" }
            else { Write-Warn "$($mcp.Key): failed - add manually" }
        }
    }

    Write-Host ""
    Write-Log "Custom MCPs (manual setup required):"
    foreach ($name in @("cybersec", "server-admin", "local-admin", "api-tester", "network-monitor", "github", "tavily")) {
        if ($mcpList -match $name) { Write-Info "$name`: configured" }
        else { Write-Warn "$name`: not configured - see docs/MCPS_GUIDE.md" }
    }
    Write-Host ""
}

# ============================================================================
# Uninstall
# ============================================================================

function Invoke-Uninstall {
    Write-Log "Uninstalling Claude Code Agents..."

    $agents = @("cybersentinel","codecraft","testforge","growthforge","docmaster","infraforge","dataforge","apiforge")
    $skills = @("sec","bpr","tst","seo","doc","ops","db","api","audit","agents-status")

    foreach ($dir in @((Join-Path $env:USERPROFILE ".claude\agents"), ".claude\agents")) {
        if (Test-Path $dir) {
            foreach ($a in $agents) { Remove-Item "$dir\$a.md" -ErrorAction SilentlyContinue }
            Write-Info "Cleaned: $dir"
        }
    }

    foreach ($dir in @((Join-Path $env:USERPROFILE ".claude\skills"), ".claude\skills")) {
        if (Test-Path $dir) {
            foreach ($s in $skills) { Remove-Item "$dir\$s" -Recurse -ErrorAction SilentlyContinue }
            Write-Info "Cleaned: $dir"
        }
    }

    foreach ($dir in @((Join-Path $env:USERPROFILE ".claude\agent-scripts"), ".claude\agent-scripts")) {
        if (Test-Path $dir) { Remove-Item $dir -Recurse -Force; Write-Info "Cleaned: $dir" }
    }

    Write-Log "Uninstall complete."
}

# ============================================================================
# Verification
# ============================================================================

function Show-Verification {
    Write-Log "Verifying installation..."
    Write-Host ""

    $ac = (Get-ChildItem "$AgentsDir\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
    $sc = 0
    foreach ($s in @("sec","bpr","tst","seo","doc","ops","db","api","audit","agents-status")) {
        if (Test-Path "$SkillsDir\$s\SKILL.md") { $sc++ }
    }

    Write-Host "  Agents: $ac/8" -ForegroundColor Green
    Write-Host "  Skills: $sc/10" -ForegroundColor Green
    Write-Host ""
    Write-Host "Quick start:" -ForegroundColor Cyan
    Write-Host "  Restart Claude Code, then try:"
    Write-Host "    /sec   /bpr   /tst   /seo   /doc   /ops   /db   /api   /audit"
    Write-Host ""
}

# ============================================================================
# Banner
# ============================================================================

function Show-Banner {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "  Claude Code Agents - Installer v$Version" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  SEC CyberSentinel   SEO GrowthForge   OPS InfraForge"
    Write-Host "  BPR CodeCraft       TST TestForge     DB  DataForge"
    Write-Host "  DOC DocMaster       API APIForge"
    Write-Host ""
}

# ============================================================================
# Main
# ============================================================================

if ($Help) {
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "  -Scope user|project  Where to install"
    Write-Host "  -All                 Full install"
    Write-Host "  -AgentsOnly          Agents only"
    Write-Host "  -SkillsOnly          Skills only"
    Write-Host "  -McpsOnly            MCP servers only"
    Write-Host "  -Uninstall           Remove everything"
    Write-Host "  -Help                Show this help"
    exit 0
}

Show-Banner

if ($Uninstall) { Invoke-Uninstall; exit 0 }

Test-Prerequisites
Resolve-InstallScope

if ($All) { $Scope = if ($Scope) { $Scope } else { "user" } }

if ($AgentsOnly) { Install-Agents }
elseif ($SkillsOnly) { Install-Skills }
elseif ($McpsOnly) { Install-Mcps }
else {
    Install-Agents
    Install-Skills
    Install-Hooks
    Install-Mcps
}

Show-Verification
