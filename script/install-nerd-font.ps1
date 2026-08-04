# Install JetBrainsMono Nerd Font — direct download + mirror fallback
# Run: powershell -ExecutionPolicy Bypass -File install-nerd-font.ps1 [-Proxy "http://127.0.0.1:7890"]

param(
    [string]$FontName = "JetBrainsMono",
    [string]$Version  = "v3.5.0",
    [string]$Proxy    = "",
    [int]$TimeoutSec  = 15
)

$ProgressPreference = "SilentlyContinue"
$FontDir    = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$DirectUrl  = "https://github.com/ryanoasis/nerd-fonts/releases/download/$Version/${FontName}.zip"
$Mirrors    = @("https://ghproxy.net/", "https://mirror.ghproxy.com/")

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
$urls = @($DirectUrl)
foreach ($m in $Mirrors) { $urls += $m + $DirectUrl }

$ok = $false
for ($i = 0; $i -lt $urls.Count; $i++) {
    $label = if ($i -eq 0) { "direct ($TimeoutSec s)" } else { "mirror" }
    Write-Step "Trying $label ..."

    $job = Start-Job -ScriptBlock {
        param($u, $f, $t, $pa)
        try {
            Invoke-WebRequest -Uri $u -OutFile $f -UseBasicParsing -TimeoutSec $t @pa
            return $true
        } catch { return $false }
    } -ArgumentList $urls[$i], $ZipPath, $TimeoutSec, $ProxyArgs

    $done = Wait-Job $job -Timeout $($TimeoutSec + 5)
    $result = Receive-Job $job
    Remove-Job $job -Force

    if ($result) {
        $sz = [math]::Round((Get-Item $ZipPath).Length/1MB, 1)
        Write-OK "Downloaded $sz MB"
        $ok = $true
        break
    }
    Write-Err "Failed (timeout)"
}

if (-not $ok) {
    Write-Err "All sources exhausted. Manual: $DirectUrl"
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
