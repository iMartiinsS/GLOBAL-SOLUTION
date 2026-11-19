param(
  [string]$ApiUrl = 'http://10.0.2.2:18080',
  [string]$Dispositivo = '',
  [switch]$Demo
)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot 'alagalerta-app')
& flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$flutterArgs = @('run')
if ($Dispositivo) { $flutterArgs += @('-d', $Dispositivo) }
if ($Demo) { $flutterArgs += '--dart-define=DEMO_MODE=true' }
else { $flutterArgs += "--dart-define=API_URL=$ApiUrl" }
& flutter @flutterArgs
exit $LASTEXITCODE
