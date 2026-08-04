# Install AutoHotkey v2 — direct download from official site, no package manager
# Run: powershell -ExecutionPolicy Bypass -File install-ahk.ps1

param(
    [int]$MaxRetries = 3
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$AhkUrl     = "https://www.autohotkey.com/download/ahk-v2.exe"
$Installer  = "$env:TEMP\AutoHotkey_Setup.exe"

# ── helpers ──────────────────────────────────────────────
function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host " !! $msg" -ForegroundColor Red }

function Download-WithRetry {
    param([string]$Url, [string]$OutFile, [int]$Retries = $MaxRetries)

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Step "Downloading AHK v2 installer (attempt $i/$Retries) ..."
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

# ── check existing ───────────────────────────────────────
$ahkExe = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
if (Test-Path $ahkExe) {
    $ver = & $ahkExe /? 2>$null | Select-Object -First 2
    Write-OK "AutoHotkey v2 already installed: $ahkExe"
    exit 0
}

# ── main ─────────────────────────────────────────────────
Write-Step "AutoHotkey v2 Installer"
Write-Host "    Source: $AhkUrl"

if (-not (Download-WithRetry -Url $AhkUrl -OutFile $Installer)) {
    Remove-Item $Installer -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Step "Running installer ..."
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
