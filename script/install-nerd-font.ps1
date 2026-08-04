# Install JetBrainsMono Nerd Font — direct download, no package manager
# Run: powershell -ExecutionPolicy Bypass -File install-nerd-font.ps1

param(
    [string]$FontName = "JetBrainsMono",
    [int]$MaxRetries = 3
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Repo      = "ryanoasis/nerd-fonts"
$ReleaseUrl = "https://api.github.com/repos/$Repo/releases/latest"
$FontDir    = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

# ── helpers ──────────────────────────────────────────────
function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host " !! $msg" -ForegroundColor Red }

function Download-WithRetry {
    param([string]$Url, [string]$OutFile, [int]$Retries = $MaxRetries)

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Step "Downloading (attempt $i/$Retries) ..."
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 120
            if (Test-Path $OutFile) {
                $sizeMB = [math]::Round((Get-Item $OutFile).Length / 1MB, 1)
                Write-OK "Downloaded $sizeMB MB"
                return $true
            }
        } catch {
            Write-Err "Attempt $i failed: $_"
            Start-Sleep -Seconds (2 * $i)
        }
    }
    Write-Err "Download failed after $Retries attempts."
    return $false
}

# ── main ─────────────────────────────────────────────────
Write-Step "Finding latest Nerd Font release ..."
try {
    $Release = Invoke-RestMethod -Uri $ReleaseUrl -UseBasicParsing -TimeoutSec 30
} catch {
    Write-Err "Cannot reach GitHub API: $_"
    Write-Host "    Check your network or try: https://www.nerdfonts.com/font-downloads"
    exit 1
}

$Tag = $Release.tag_name
Write-OK "Latest release: $Tag"

$Pattern = "${FontName}.zip"
$Asset = $Release.assets | Where-Object { $_.name -match $Pattern } | Select-Object -First 1
if (-not $Asset) {
    Write-Err "No asset matching '$Pattern' found in release $Tag"
    Write-Host "    Available assets:"
    $Release.assets | ForEach-Object { Write-Host "      $($_.name)" }
    exit 1
}

$DownloadUrl = $Asset.browser_download_url
$ZipPath     = "$env:TEMP\${FontName}NerdFont.zip"
$ExtractDir  = "$env:TEMP\${FontName}NerdFont"

Write-Step "Downloading $($Asset.name) ..."
if (-not (Download-WithRetry -Url $DownloadUrl -OutFile $ZipPath)) {
    Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Step "Extracting ..."
try {
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force
    Write-OK "Extracted to $ExtractDir"
} catch {
    Write-Err "Extraction failed: $_"
    Remove-Item $ZipPath, $ExtractDir -Force -Recurse -ErrorAction SilentlyContinue
    exit 1
}

Write-Step "Installing fonts ..."
$installed = 0
$fonts = Get-ChildItem -Path $ExtractDir -Filter "*.ttf" -Recurse -ErrorAction SilentlyContinue
if (-not $fonts) {
    $fonts = Get-ChildItem -Path $ExtractDir -Filter "*.otf" -Recurse -ErrorAction SilentlyContinue
}

foreach ($font in $fonts) {
    $dest = Join-Path $FontDir $font.Name
    try {
        Copy-Item -Path $font.FullName -Destination $dest -Force
        Write-OK "Installed: $($font.Name)"
        $installed++
    } catch {
        Write-Err "Failed to install $($font.Name): $_"
    }
}

# Register with the system so apps can see the font immediately
Add-Type -AssemblyName System.Drawing
$fc = [System.Drawing.Text.PrivateFontCollection]::new()
foreach ($font in $fonts) {
    $null = $fc.AddFontFile($font.FullName)
}

# Cleanup
Remove-Item $ZipPath, $ExtractDir -Force -Recurse -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Installed $installed font(s)." -ForegroundColor Green
Write-Host "Set in Windows Terminal: Settings > Profiles > Appearance > Font = 'JetBrainsMono Nerd Font Mono'" -ForegroundColor Yellow
