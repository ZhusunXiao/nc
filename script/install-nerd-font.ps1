# Install JetBrainsMono Nerd Font — direct download + mirror fallback
# Run: powershell -ExecutionPolicy Bypass -File install-nerd-font.ps1 [-Proxy "http://127.0.0.1:7890"]

param(
    [string]$FontName = "JetBrainsMono",
    [string]$Version = "v3.5.0",     # bump when a new release drops
    [int]$MaxRetries = 3,
    [string]$Proxy = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$FontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

# Direct URL + mirrors (no GitHub API — mirrors often block it)
$DirectUrl   = "https://github.com/ryanoasis/nerd-fonts/releases/download/$Version/${FontName}.zip"
$Mirrors     = @(
    "https://ghproxy.net/",
    "https://mirror.ghproxy.com/"
)

# ── helpers ──────────────────────────────────────────────
function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host " !! $msg" -ForegroundColor Red }

function Download-One {
    param([string]$Url, [string]$OutFile)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 120 @ProxyArgs
        return (Test-Path $OutFile)
    } catch {
        return $false
    }
}

function Try-All-Urls {
    param([string]$OutFile)

    $urls = @($DirectUrl)
    foreach ($m in $Mirrors) { $urls += $m + $DirectUrl }

    for ($i = 0; $i -lt $urls.Count; $i++) {
        $url = $urls[$i]
        $label = if ($i -eq 0) { "direct" } else { "mirror $(($i))" }
        Write-Step "Trying $label ..."
        for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
            Write-Step "  Attempt $attempt/$MaxRetries"
            if (Download-One -Url $url -OutFile $OutFile) {
                $sizeMB = [math]::Round((Get-Item $OutFile).Length / 1MB, 1)
                Write-OK "Downloaded $sizeMB MB from $label"
                return $true
            }
            Write-Err "  Failed"
            if ($attempt -lt $MaxRetries) { Start-Sleep -Seconds (2 * $attempt) }
        }
    }
    return $false
}

# ── setup ────────────────────────────────────────────────
$ProxyArgs = @{}
if ($Proxy) {
    $ProxyArgs["Proxy"] = $Proxy
    $ProxyArgs["ProxyUseDefaultCredentials"] = $true
    Write-OK "Using proxy: $Proxy"
}

# ── check existing ───────────────────────────────────────
$existing = Get-ChildItem $FontDir -Filter "*${FontName}*Nerd*" -ErrorAction SilentlyContinue
if ($existing) {
    Write-OK "Nerd Font already installed: $($existing[0].Name)"
    Write-Host "    To reinstall, delete it from $FontDir and re-run."
    exit 0
}

# ── download ─────────────────────────────────────────────
Write-Step "Downloading ${FontName} Nerd Font $Version ..."
$ZipPath    = "$env:TEMP\${FontName}NerdFont.zip"
$ExtractDir = "$env:TEMP\${FontName}NerdFont"

if (-not (Try-All-Urls -OutFile $ZipPath)) {
    Write-Err "All download sources exhausted."
    Write-Host "    Download manually: $DirectUrl"
    Write-Host "    Extract and copy .ttf files to $FontDir"
    exit 1
}

# ── extract ──────────────────────────────────────────────
Write-Step "Extracting ..."
try {
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force
    Write-OK "Extracted"
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

Add-Type -AssemblyName System.Drawing
$fc = [System.Drawing.Text.PrivateFontCollection]::new()
foreach ($font in $fonts) { $null = $fc.AddFontFile($font.FullName) }

Remove-Item $ZipPath, $ExtractDir -Force -Recurse -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Installed $installed font(s)." -ForegroundColor Green
Write-Host "Windows Terminal: Settings > Profiles > Appearance > Font = 'JetBrainsMono Nerd Font Mono'" -ForegroundColor Yellow
