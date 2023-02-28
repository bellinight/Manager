@echo off

REM Verificar se o winget está instalado
winget --version
if %errorlevel% neq 0 (
  REM Instalar o winget usando PowerShell
  PowerShell -Command "if(!(Get-Command winget -ErrorAction SilentlyContinue)){ Install-PackageProvider -Name winget -Force }"
)
