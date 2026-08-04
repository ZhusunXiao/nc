# Install AutoHotkey v2 — direct download with mirror fallback
# Run: powershell -ExecutionPolicy Bypass -File install-ahk.ps1 [-Proxy "http://127.0.0.1:7890"]

param(
    [int]$MaxRetries = 3,
    [string]$Proxy = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$AhkUrl     = "https://www.autohotkey.com/download/ahk-v2.exe"
$Mirrors    = @(
    "https://ghproxy.net/",
    "https://mirror.ghproxy.com/"
)
$Installer  = "$env:TEMP\AutoHotkey_Setup.exe"

# ── helpers ──────────────────────────────────────────────
function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host " !! $msg" -ForegroundColor Red }

function Download-WithRetry {
    param([string]$Url, [string]$OutFile, [int]$Retries = $MaxRetries)

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Step "Downloading (attempt $i/$Retries) ..."
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 120 @ProxyArgs
            if (Test-Path $OutFile) {
                $sizeMB = [math]::Round((Get-Item $OutFile).Length / 1MB, 1)
                Write-OK "Downloaded $sizeMB MB"
                return $true
            }
        } catch {
            Write-Err "Attempt $i failed: $_"
            if ($i -lt $Retries) { Start-Sleep -Seconds (2 * $i) }
        }
    }
    Write-Err "Direct download failed after $Retries attempts."
    return $false
}

# ── preparation ─────────────────────────────────────────
$ProxyArgs = @{}
if ($Proxy) {
    $ProxyArgs["Proxy"] = $Proxy
    $ProxyArgs["ProxyUseDefaultCredentials"] = $true
    Write-OK "Using proxy: $Proxy"
}

# ── check existing ───────────────────────────────────────
$ahkExe = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
if (Test-Path $ahkExe) {
    Write-OK "AutoHotkey v2 already installed: $ahkExe"
    exit 0
}

# ── try download (direct + mirrors) ──────────────────────
Write-Step "AutoHotkey v2 Installer"

$success = $false

# Try direct
if (Download-WithRetry -Url $AhkUrl -OutFile $Installer) {
    $success = $true
}

# Try mirrors
if (-not $success) {
    foreach ($mirror in $Mirrors) {
        $mirrorUrl = $mirror + $AhkUrl
        Write-Step "Trying mirror: $mirror"
        if (Download-WithRetry -Url $mirrorUrl -OutFile $Installer) {
            $success = $true
            break
        }
    }
}

if (-not $success) {
    Write-Err "All download sources exhausted."
    Write-Host "    Download manually from: $AhkUrl"
    Write-Host "    Then run the installer and re-run this script to verify."
    exit 1
}

# ── install ──────────────────────────────────────────────
Write-Step "Running installer (silent) ..."
try {
    $proc = Start-Process -FilePath $Installer -ArgumentList "/silent /install" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Err "Installer exited with code $($proc.ExitCode)"
        Write-Host "    Try running manually: $Installer"
        exit 1
    }
    Write-OK "AutoHotkey v2 installed successfully."
} catch {
    Write-Err "Installation failed: $_"
    Write-Host "    Try running manually: $Installer"
    exit 1
}

# Verify
if (Test-Path $ahkExe) {
    Write-OK "Confirmed: $ahkExe"
} else {
    Write-Err "Installer ran but $ahkExe not found."
    exit 1
}

Remove-Item $Installer -Force -ErrorAction SilentlyContinue
Write-Host "AHK v2 ready. Double-click a .ahk script to run." -ForegroundColor Green
