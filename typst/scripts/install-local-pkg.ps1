# Install Typst package to local packages directory

$sourceDir = Join-Path $PSScriptRoot "..\linear"
$tomlPath = Join-Path $sourceDir "typst.toml"

# Read info from typst.toml
$tomlContent = Get-Content $tomlPath -Raw
$packageName = if ($tomlContent -match 'name\s*=\s*"([^"]+)"') { $Matches[1] } else { throw "Package name not found in typst.toml" }
$packageVersion = if ($tomlContent -match 'version\s*=\s*"([^"]+)"') { $Matches[1] } else { throw "Package version not found in typst.toml" }

$destDir = "$env:APPDATA\typst\packages\local\$packageName\$packageVersion"

Write-Host "Installing $packageName v$packageVersion..." -ForegroundColor Cyan

# Create destination and copy files
New-Item -ItemType Directory -Path $destDir -Force | Out-Null
Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force

Write-Host "Done! Package installed to: $destDir" -ForegroundColor Green
Write-Host "`nUse in your .typ files with:" -ForegroundColor Yellow
Write-Host "#import `"@local/$packageName`:$packageVersion`": $packageName" -ForegroundColor White
