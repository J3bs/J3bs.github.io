param(
    [string]$SourcePath = $PSScriptRoot,
    [string]$DestinationPath = "C:\git\J3bs.github.io",
    [string]$CommitMessage = "Update site from j3-branding",
    [string]$Branch = ""
)

$ErrorActionPreference = "Stop"

function Write-Info([string]$message) {
    Write-Host "[publish] $message"
}

function Require-Path([string]$path, [string]$label) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "$label does not exist: $path"
    }
}

function Require-GitRepo([string]$path, [string]$label) {
    if (-not (Test-Path -LiteralPath (Join-Path $path ".git"))) {
        throw "$label is not a git repository: $path"
    }
}

Require-Path $SourcePath "Source path"
Require-Path $DestinationPath "Destination path"
Require-GitRepo $DestinationPath "Destination path"

$sourceFull = (Resolve-Path -LiteralPath $SourcePath).Path
$destFull = (Resolve-Path -LiteralPath $DestinationPath).Path

Write-Info "Source: $sourceFull"
Write-Info "Destination: $destFull"
Write-Info "Syncing files (excluding .git, docs, README.md)..."

# /E: include subdirectories, including empty ones
# /XD: exclude directories
# /XF: exclude files
# /R: retries, /W: wait between retries, /NFL /NDL reduce noise
robocopy $sourceFull $destFull /E /R:2 /W:2 /XD ".git" "docs" /XF "README.md" /NFL /NDL /NJH /NJS | Out-Null
$rc = $LASTEXITCODE
if ($rc -ge 8) {
    throw "robocopy failed with exit code $rc"
}

if ([string]::IsNullOrWhiteSpace($Branch)) {
    $Branch = (git -C $destFull branch --show-current).Trim()
    if ([string]::IsNullOrWhiteSpace($Branch)) {
        throw "Could not determine destination branch. Pass -Branch explicitly."
    }
}

$status = git -C $destFull status --porcelain
if (-not $status) {
    Write-Info "No changes detected in destination repo. Nothing to commit."
    exit 0
}

Write-Info "Committing changes in destination repo..."
git -C $destFull add -A
git -C $destFull commit -m $CommitMessage

Write-Info "Pushing to origin/$Branch..."
git -C $destFull push origin $Branch

Write-Info "Done."
