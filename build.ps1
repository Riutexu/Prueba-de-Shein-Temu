<#
.SYNOPSIS
    Script de Compilación de Repositorio.
.DESCRIPTION
    Compila src/install.ps1 en Installer.exe en la raíz inyectando el icono ico/W_D.ico.
#>

$ErrorActionPreference = "Stop"

$RepoRoot     = $PSScriptRoot
$SourceScript = Join-Path $RepoRoot "src\install.ps1"
$IconPath     = Join-Path $RepoRoot "ico\W_D.ico"
$OutputPath   = Join-Path $RepoRoot "Installer.exe"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   PIPELINE DE COMPILACIÓN: GENERANDO BINARIO"
Write-Host "==================================================" -ForegroundColor Cyan

# Validaciones de Integridad de Código
if (-not (Test-Path $SourceScript)) {
    Write-Host "❌ Error: Archivo de origen ausente en $SourceScript" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $IconPath)) {
    Write-Host "❌ Error: Icono obligatorio no encontrado en $IconPath" -ForegroundColor Red
    exit 1
}

# Verificación de la herramienta PS2EXE en la máquina de desarrollo
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "`n[!] Descargando e instalando compilador ps2exe..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
}

# Limpieza preventiva de compilaciones anteriores
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

# Argumentos corregidos: Se elimina el parámetro 'Architecture' obsoleto
$CompileArgs = @{
    InputFile    = $SourceScript
    OutputFile   = $OutputPath
    IconFile     = $IconPath
    Title        = "Instalador Automático Profesional"
    Description  = "Instalador de producción para Prueba-de-Shein-Temu"
}

try {
    Write-Host "`n[+] Compilando script e inyectando recursos nativos..." -ForegroundColor Blue
    Invoke-PS2EXE @CompileArgs
    Write-Host "`n✔ 'Installer.exe' generado exitosamente en la raíz del proyecto." -ForegroundColor Green
} catch {
    Write-Host "`n❌ Error en el proceso de enlazado del ejecutable: $_" -ForegroundColor Red
    exit 1
}