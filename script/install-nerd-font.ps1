# Install JetBrainsMono Nerd Font — direct download, GitHub mirror fallback
# Run: powershell -ExecutionPolicy Bypass -File install-nerd-font.ps1

param(
    [string]$FontName = "JetBrainsMono",
    [int]$MaxRetries = 3,
    [string]$Proxy = ""      # e.g. "http://127.0.0.1:7890"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Repo        = "ryanoasis/nerd-fonts"
$ReleaseApi  = "https://api.github.com/repos/$Repo/releases/latest"
$Mirrors     = @(
    "https://ghproxy.net/",           # mirror 1
    "https://mirror.ghproxy.com/"     # mirror 2
)
$FontDir     = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

# ── helpers ──────────────────────────────────────────────
function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host " !! $msg" -ForegroundColor Red }

function Test-Url {
    param([string]$Url, [int]$TimeoutSec = 5)
    try {
        $req = [System.Net.WebRequest]::Create($Url)
        $req.Timeout = $TimeoutSec * 1000
        if ($Proxy) { $req.Proxy = [System.Net.WebProxy]::new($Proxy) }
        $req.Method = "HEAD"
        $resp = $req.GetResponse()
        $resp.Close()
        return $true
    } catch { return $false }
}

function Get-MirroredUrl {
    param([string]$OriginalUrl, [string]$AcceptHeader = "application/octet-stream")

    # Try direct first
    Write-Step "Trying direct connection ..."
    $headers = @{}
    if ($AcceptHeader) { $headers["Accept"] = $AcceptHeader }
    try {
        $result = Invoke-WebRequest -Uri $OriginalUrl -UseBasicParsing -TimeoutSec 10 @ProxyArgs -Headers $headers
        Write-OK "Direct connection OK"
        return $OriginalUrl
    } catch {
        Write-Err "Direct connection failed. Trying mirrors ..."
    }

    # Try mirrors
    foreach ($mirror in $Mirrors) {
        $mirrored = $mirror + $OriginalUrl
        Write-Step "Trying $mirrored"
        try {
            $result = Invoke-WebRequest -Uri $mirrored -UseBasicParsing -TimeoutSec 15 @ProxyArgs -Headers $headers
            Write-OK "Mirror OK: $mirror"
            return $mirrored
        } catch {
            Write-Err "Mirror failed: $mirror"
        }
    }

    Write-Err "All connections failed."
    return $null
}

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
            Start-Sleep -Seconds (2 * $i)
        }
    }
    Write-Err "Download failed after $Retries attempts."
    return $false
}

# ── prepare ──────────────────────────────────────────────
$ProxyArgs = @{}
if ($Proxy) {
    $ProxyArgs["Proxy"] = $Proxy
    $ProxyArgs["ProxyUseDefaultCredentials"] = $true
    Write-OK "Using proxy: $Proxy"
}

# ── get release info ─────────────────────────────────────
Write-Step "Finding latest Nerd Font release ..."
$resolvedReleaseApi = Get-MirroredUrl -Url $ReleaseApi -AcceptHeader "application/vnd.github+json"
if (-not $resolvedReleaseApi) { exit 1 }

try {
    $Release = Invoke-RestMethod -Uri $resolvedReleaseApi -UseBasicParsing -TimeoutSec 30 @ProxyArgs
} catch {
    Write-Err "Cannot fetch release info: $_"
    exit 1
}

$Tag = $Release.tag_name
Write-OK "Latest release: $Tag"

$Pattern = "${FontName}.zip"
$Asset = $Release.assets | Where-Object { $_.name -match $Pattern } | Select-Object -First 1
if (-not $Asset) {
    Write-Err "No asset matching '$Pattern' found in release $Tag"
    $Release.assets | ForEach-Object { Write-Host "      $($_.name)" }
    exit 1
}

# ── download ─────────────────────────────────────────────
$DownloadUrl = $Asset.browser_download_url
$ZipPath     = "$env:TEMP\${FontName}NerdFont.zip"
$ExtractDir  = "$env:TEMP\${FontName}NerdFont"

Write-Step "Resolving download URL for $($Asset.name) ..."
$resolvedDownload = Get-MirroredUrl -Url $DownloadUrl
if (-not $resolvedDownload) { exit 1 }

if (-not (Download-WithRetry -Url $resolvedDownload -OutFile $ZipPath)) {
    Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue
    exit 1
}

# ── extract ──────────────────────────────────────────────
Write-Step "Extracting ..."
try {
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force
    Write-OK "Extracted to $ExtractDir"
} catch {
    Write-Err "Extraction failed: $_"
    Remove-Item $ZipPath, $ExtractDir -Force -Recurse -ErrorAction SilentlyContinue
    exit 1
}

# ── install ──────────────────────────────────────────────
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

# Register with the system
Add-Type -AssemblyName System.Drawing
$fc = [System.Drawing.Text.PrivateFontCollection]::new()
foreach ($font in $fonts) {
    $null = $fc.AddFontFile($font.FullName)
}

Remove-Item $ZipPath, $ExtractDir -Force -Recurse -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Installed $installed font(s)." -ForegroundColor Green
Write-Host "Windows Terminal: Settings > Profiles > Appearance > Font = 'JetBrainsMono Nerd Font Mono'" -ForegroundColor Yellow
