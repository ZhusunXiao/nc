# Install JetBrainsMono Nerd Font — mirror-first, direct fallback
# Run: powershell -ExecutionPolicy Bypass -File install-nerd-font.ps1 [-Proxy "http://127.0.0.1:7890"]

param(
    [string]$FontName = "JetBrainsMono",
    [string]$Version  = "v3.5.0",
    [string]$Proxy    = ""
)

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

$FontDir   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$UrlPath   = "/ryanoasis/nerd-fonts/releases/download/$Version/${FontName}.zip"
$GithubUrl = "https://github.com${UrlPath}"

# Mirror first (GitHub blocked in CN), direct as last resort
$urls = @(
    "https://mirror.ghproxy.com${UrlPath}",
    "https://ghproxy.net${UrlPath}",
    $GithubUrl
)

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-OK($m)   { Write-Host "    $m" -ForegroundColor Green }
function Write-Err($m)  { Write-Host " !! $m" -ForegroundColor Red }

$ProxyArgs = @{}
if ($Proxy) { $ProxyArgs["Proxy"] = $Proxy; Write-OK "Proxy: $Proxy" }

if (Get-ChildItem $FontDir -Filter "*${FontName}*Nerd*" -ErrorAction SilentlyContinue) {
    Write-OK "Already installed."
    exit 0
}

$ZipPath    = "$env:TEMP\${FontName}NerdFont.zip"
$ExtractDir = "$env:TEMP\${FontName}NerdFont"

$ok = $false
for ($i = 0; $i -lt $urls.Count; $i++) {
    $label = if ($urls[$i] -eq $GithubUrl) { "direct" } else { "mirror" }
    Write-Step "Trying $label ..."
    try {
        Invoke-WebRequest -Uri $urls[$i] -OutFile $ZipPath -UseBasicParsing -TimeoutSec 120 @ProxyArgs
        $sz = [math]::Round((Get-Item $ZipPath).Length/1MB, 1)
        Write-OK "Downloaded $sz MB"
        $ok = $true
        break
    } catch {
        Write-Err "Failed"
        Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue
    }
}

if (-not $ok) {
    Write-Err "All sources exhausted. Manual: $GithubUrl"
    exit 1
}

Write-Step "Extracting ..."
Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force

Write-Step "Installing ..."
$n = 0
Get-ChildItem $ExtractDir -Filter "*.ttf" -Recurse | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $FontDir $_.Name) -Force; Write-OK $_.Name; $n++
}

Add-Type -AssemblyName System.Drawing
$fc = [System.Drawing.Text.PrivateFontCollection]::new()
Get-ChildItem $ExtractDir -Filter "*.ttf" -Recurse | ForEach-Object { $fc.AddFontFile($_.FullName) }

Remove-Item $ZipPath, $ExtractDir -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Installed $n font(s)." -ForegroundColor Green
Write-Host "Terminal font: 'JetBrainsMono Nerd Font Mono'" -ForegroundColor Yellow
