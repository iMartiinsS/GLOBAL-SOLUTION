param([int]$Porta = 18080)
$ErrorActionPreference = 'Stop'
$env:PORT = "$Porta"
Set-Location (Join-Path $PSScriptRoot 'alagalerta-api')
Write-Host "Iniciando API local: http://localhost:$Porta/swagger-ui.html"
Write-Host 'Este modo usa H2 em memoria; Azure usa PostgreSQL pelo Docker Compose.'
& .\mvnw.cmd spring-boot:run
exit $LASTEXITCODE
