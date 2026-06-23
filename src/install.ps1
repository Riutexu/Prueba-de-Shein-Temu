# --- CONFIGURACIÓN DE ENTORNO BLINDADA ---
$ErrorActionPreference = "Stop"

# EDITA ESTA LÍNEA CON LA RUTA REAL DE TU CARPETA
$ManualRoot = "C:\Users\USER\Desktop\Prueba-de-Shein-Temu"

# 1. Forzamos la ubicación física
if (-not (Test-Path $ManualRoot)) {
    Write-Host "[!] ERROR: No se encuentra la carpeta en: $ManualRoot" -ForegroundColor Red
    Write-Host "[!] Por favor, edita la variable `$ManualRoot en el script." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    exit
}
Set-Location -Path $ManualRoot

# 2. Configuración de Rutas (Ahora son infalibles)
$Cfg = [PSCustomObject]@{ 
    TargetDir = $ManualRoot
    Python    = Join-Path $ManualRoot ".venv\Scripts\python.exe"
    Pip       = Join-Path $ManualRoot ".venv\Scripts\pip.exe"
    Reqs      = Join-Path $ManualRoot "requirements.txt"
    Run       = Join-Path $ManualRoot "run.py"
}

# --- VALIDACIÓN FINAL ---
if (-not (Test-Path $Cfg.Reqs)) {
    Write-Host "[!] ERROR: Archivo requirements.txt no hallado en $ManualRoot" -ForegroundColor Red
    exit
}

# ... (El resto del código de Menú y Bucle es idéntico al anterior)
