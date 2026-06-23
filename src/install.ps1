# --- CONFIGURACIÓN DE ENTORNO ---
$ErrorActionPreference = "Stop"

# Obtenemos la ruta absoluta del archivo en ejecución
$basePath = Split-Path -Parent $PSCommandPath
# Si el script está en /src, el proyecto raíz es el padre de $basePath
$projectRoot = Split-Path -Parent $basePath

# FORZAMOS el directorio de trabajo al de la raíz del proyecto
Set-Location -Path $projectRoot

# --- VERIFICACIÓN DE SEGURIDAD (DEBUG) ---
$reqFile = Join-Path $projectRoot "requirements.txt"
if (-not (Test-Path $reqFile)) {
    Write-Host "--- ERROR DE RUTA DETECTADO ---" -ForegroundColor Red
    Write-Host "Ruta de Proyecto calculada: $projectRoot" -ForegroundColor Yellow
    Write-Host "Archivo buscado: $reqFile" -ForegroundColor Yellow
    Write-Host "Contenido de la carpeta:" -ForegroundColor Cyan
    Get-ChildItem $projectRoot | Select-Object Name
    Write-Host "-------------------------------" -ForegroundColor Red
    Start-Sleep -Seconds 10
    exit
}

# --- CONFIGURACIÓN DE RUTAS ---
$Cfg = [PSCustomObject]@{ 
    TargetDir = $projectRoot
    Python    = Join-Path $projectRoot ".venv\Scripts\python.exe"
    Pip       = Join-Path $projectRoot ".venv\Scripts\pip.exe"
    Reqs      = $reqFile
    Run       = Join-Path $projectRoot "run.py"
}
