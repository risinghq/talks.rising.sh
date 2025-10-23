# Uninstall Typst package from local packages directory

$ErrorActionPreference = "Stop"

$sourceDir = Join-Path $PSScriptRoot "..\linear"
$tomlPath = Join-Path $sourceDir "typst.toml"

# Read info from typst.toml
$tomlContent = Get-Content $tomlPath -Raw
$packageName = if ($tomlContent -match 'name\s*=\s*"([^"]+)"') { $Matches[1] } else { throw "Package name not found in typst.toml" }
$packageVersion = if ($tomlContent -match 'version\s*=\s*"([^"]+)"') { $Matches[1] } else { throw "Package version not found in typst.toml" }

$destDir = "$env:APPDATA\typst\packages\local\$packageName\$packageVersion"

Write-Host "Uninstalling $packageName v$packageVersion..." -ForegroundColor Cyan

if (Test-Path $destDir) {
    Remove-Item -Path $destDir -Recurse -Force
    Write-Host "Done! Package removed." -ForegroundColor Green
} else {
    Write-Host "Package not found." -ForegroundColor Yellow
}
