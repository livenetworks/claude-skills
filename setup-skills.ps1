<#
.SYNOPSIS
    Initialize or update the claude-skills submodule in the current project.

.DESCRIPTION
    Run this script from the root of any project that uses (or should use)
    the livenetworks/claude-skills submodule at .claude/skills/.

    - If the submodule is not yet added, it adds it.
    - If it already exists, it pulls the latest from main.

.EXAMPLE
    .\setup-skills.ps1
    .\setup-skills.ps1 -Branch main
#>

param(
    [string]$Branch = "main",
    [string]$Remote = "https://github.com/livenetworks/claude-skills.git",
    [string]$Path = ".claude/skills"
)

$ErrorActionPreference = "Stop"

# Ensure we're in a git repo
if (-not (Test-Path ".git")) {
    Write-Error "Not a git repository. Run this from a project root."
    exit 1
}

# Check if submodule already exists
$submoduleExists = $false
if (Test-Path ".gitmodules") {
    $content = Get-Content ".gitmodules" -Raw
    if ($content -match [regex]::Escape($Path)) {
        $submoduleExists = $true
    }
}

if ($submoduleExists) {
    Write-Host "Submodule already registered. Updating to latest..." -ForegroundColor Cyan
    git submodule update --init --recursive $Path
    Push-Location $Path
    git checkout $Branch
    git pull origin $Branch
    Pop-Location
    Write-Host "Skills updated to latest $Branch." -ForegroundColor Green
}
else {
    Write-Host "Adding claude-skills submodule..." -ForegroundColor Cyan
    git submodule add -b $Branch $Remote $Path
    git submodule update --init --recursive $Path
    Write-Host "Submodule added at $Path" -ForegroundColor Green
    Write-Host ""
    Write-Host "Don't forget to commit:" -ForegroundColor Yellow
    Write-Host "  git add .gitmodules $Path" -ForegroundColor Yellow
    Write-Host "  git commit -m 'Add claude-skills submodule'" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Current skills:" -ForegroundColor Cyan
Get-ChildItem -Path $Path -Directory | ForEach-Object {
    $skill = $_.Name
    $hasMd = Test-Path (Join-Path $_.FullName "SKILL.md")
    $status = if ($hasMd) { "[OK]" } else { "[MISSING SKILL.md]" }
    Write-Host "  $status $skill"
}
