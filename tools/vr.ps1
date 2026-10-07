[CmdletBinding()]
param(
    [ValidateSet('Desktop', 'XR', 'Verify', 'Rebuild')]
    [string]$Mode = 'Desktop',
    [string]$GodotPath = 'C:\Users\sebas\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Compatibility
)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ($env:GODOT_PATH) { $GodotPath = $env:GODOT_PATH }
if (Test-Path -LiteralPath $GodotPath -PathType Container) {
    $GodotPath = Join-Path $GodotPath 'Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "No se encuentra Godot: $GodotPath. Usa -GodotPath o GODOT_PATH."
}
$godotArgs = @('--path', $projectRoot)
if ($Mode -eq 'Verify' -or $Mode -eq 'Rebuild') {
    & $GodotPath @godotArgs --headless --xr-mode off --editor --import
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $scriptPath = if ($Mode -eq 'Verify') { 'res://tools/verify_template.gd' } else { 'res://tools/build_template.gd' }
    & $GodotPath @godotArgs --headless --xr-mode off --script $scriptPath -- --desktop
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($Mode -eq 'Rebuild') {
        & $GodotPath @godotArgs --headless --xr-mode off --editor --import
    }
} elseif ($Mode -eq 'Desktop') {
    if ($Compatibility) { $godotArgs += @('--rendering-method', 'gl_compatibility') }
    & $GodotPath @godotArgs --xr-mode off -- --desktop
} else {
    & $GodotPath @godotArgs --xr-mode on
}
exit $LASTEXITCODE
