# Install JetBrainsMono Nerd Font — direct download + mirror fallback
# Run: powershell -ExecutionPolicy Bypass -File install-nerd-font.ps1 [-Proxy "http://127.0.0.1:7890"]

param(
    [string] = "JetBrainsMono",
    [string] = "v3.5.0",
    [string] = ""
)

 = "SilentlyContinue"
 = ":LOCALAPPDATA\Microsoft\Windows\Fonts"
 = "https://github.com/ryanoasis/nerd-fonts/releases/download//.zip"
 = @("https://ghproxy.net/", "https://mirror.ghproxy.com/")

function Write-Step() { Write-Host "==> " -ForegroundColor Cyan }
function Write-OK()   { Write-Host "    " -ForegroundColor Green }
function Write-Err()  { Write-Host " !! " -ForegroundColor Red }

 = @{}
if () { ["Proxy"] = ; Write-OK "Proxy: " }

# Check existing
if (Get-ChildItem  -Filter "**Nerd*" -ErrorAction SilentlyContinue) {
    Write-OK "Already installed."
    exit 0
}

# Try each URL once (direct -> mirrors)
    = ":TEMP${FontName}NerdFont.zip"
 = ":TEMP${FontName}NerdFont"
 = @()
foreach ( in ) {  +=  +  }

 = 
for ( = 0;  -lt .Count; ++) {
     = if ( -eq 0) { "direct" } else { "mirror" }
    Write-Step "Trying  ..."
    try {
        Invoke-WebRequest -Uri [] -OutFile  -UseBasicParsing -TimeoutSec 120 @ProxyArgs
         = [math]::Round((Get-Item ).Length/1MB, 1)
        Write-OK "Downloaded  MB"
         = 
        break
    } catch { Write-Err "Failed: /bin/bash" }
}

if (-not ) {
    Write-Err "All sources exhausted. Manual: "
    exit 1
}

# Extract
Write-Step "Extracting ..."
Expand-Archive -Path  -DestinationPath  -Force

# Install
Write-Step "Installing ..."
 = 0
Get-ChildItem  -Filter "*.ttf" -Recurse | ForEach-Object {
    Copy-Item /bin/bash.FullName (Join-Path  /bin/bash.Name) -Force; Write-OK /bin/bash.Name; ++
}

Add-Type -AssemblyName System.Drawing
 = [System.Drawing.Text.PrivateFontCollection]::new()
Get-ChildItem  -Filter "*.ttf" -Recurse | ForEach-Object { .AddFontFile(/bin/bash.FullName) }

Remove-Item ,  -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Installed  font(s)." -ForegroundColor Green
Write-Host "Terminal font: 'JetBrainsMono Nerd Font Mono'" -ForegroundColor Yellow
