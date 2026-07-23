# wally-install.ps1
# Wraps the full Wally dependency workflow:
#   1. wally install                -> download/refresh packages into Packages/
#   2. rojo sourcemap               -> regenerate sourcemap.json (types tool needs it)
#   3. wally-package-types          -> patch real type exports onto the installed packages
#
# Run from the project root:  ./scripts/wally-install.ps1

$ErrorActionPreference = "Stop"

# Always operate from the project root (parent of this script's folder).
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root

try {
    Write-Host "==> wally install" -ForegroundColor Cyan
    wally install
    if ($LASTEXITCODE -ne 0) { throw "wally install failed (exit $LASTEXITCODE)" }

    Write-Host "==> rojo sourcemap -> sourcemap.json" -ForegroundColor Cyan
    rojo sourcemap default.project.json --output sourcemap.json
    if ($LASTEXITCODE -ne 0) { throw "rojo sourcemap failed (exit $LASTEXITCODE)" }

    Write-Host "==> wally-package-types" -ForegroundColor Cyan
    wally-package-types --sourcemap sourcemap.json Packages/
    if ($LASTEXITCODE -ne 0) { throw "wally-package-types failed (exit $LASTEXITCODE)" }

    Write-Host "Done. Packages installed and typed." -ForegroundColor Green
}
finally {
    Pop-Location
}
