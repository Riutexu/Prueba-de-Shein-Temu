<#
.SYNOPSIS
    Pipeline de Automatización para compilar el instalador.
.DESCRIPTION
    Fuerza la compilación a un binario standalone x64 inyectando el icono del repositorio.
#>

$ErrorActionPreference = "Stop"

# Rutas estricta del repositorio basado en tu estructura actual
$RepoRoot     = $PSScriptRoot
$SourceScript = Join-Path $RepoRoot "src\install.ps1"
$IconPath     = Join-Path $RepoRoot "ico\W_D.ico"
$OutputPath   = Join-Path $RepoRoot "Installer.exe" # Se genera directo en la raíz

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   COMPILANDO ARTEFACTO: Installer.exe"
Write-Host "==================================================" -ForegroundColor Cyan

# Validaciones de Seguridad
if (-not (Test-Path $SourceScript)) {
    Write-Host "❌ Error: Crea primero el script origen en: $SourceScript" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $IconPath)) {
    Write-Host "❌ Error de Recursos: No se encontró el icono en: $IconPath" -ForegroundColor Red
    Write-Host "Asegúrate de que el archivo 'W_D.ico' esté dentro de la carpeta 'ico/'" -ForegroundColor Yellow
    exit 1
}

# Comprobar e instalar el compilador PS2EXE en el entorno local de desarrollo
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "`n[!] Módulo 'ps2exe' no detectado. Instalando..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
}

# Remover binario viejo si existe para evitar conflictos de reemplazo
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

# Parámetros del Compilador
$CompileArgs = @{
    InputFile    = $SourceScript
    OutputFile   = $OutputPath
    IconFile     = $IconPath
    Title        = "Instalador Prueba Shein-Temu"
    Description  = "Instalador automatizado para entorno local"
    Architecture = "x64"
}

try {
    Write-Host "`n[+] Ejecutando enlazador de recursos..." -ForegroundColor Blue
    Invoke-PS2EXE @CompileArgs
    Write-Host "`n✔ ¡ÉXITO! 'Installer.exe' generado en la raíz del repositorio con el icono W_D.ico" -ForegroundColor Green
} catch {
    Write-Host "`n❌ Falló el proceso de compilación: $_" -ForegroundColor Red
    exit 1
}
