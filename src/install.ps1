<#
    .SYNOPSIS
    Script de gestión táctica para el proyecto.
    Uso: Ejecutar mediante el acceso directo configurado en la raíz.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# --- CONFIGURACIÓN DE RUTA ABSOLUTA (BLINDADA) ---
# Obtenemos la ubicación física real del archivo ignorando el contexto de ejecución
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $rootPath

# --- DEFINICIÓN DE CONFIGURACIÓN ---
$Cfg = [PSCustomObject]@{
    TargetDir = $rootPath
    Python    = Join-Path $rootPath ".venv\Scripts\python.exe"
    Pip       = Join-Path $rootPath ".venv\Scripts\pip.exe"
    Reqs      = Join-Path $rootPath "requirements.txt"
    Run       = Join-Path $rootPath "run.py"
}

# --- VALIDACIÓN DE INTEGRIDAD ---
if (-not (Test-Path $Cfg.Reqs)) {
    Write-Error "CRÍTICO: No se encontró requirements.txt en $rootPath"
    Start-Sleep -Seconds 5
    exit 1
}

# --- FUNCIONES DE INTERFAZ ---
function Show-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n ==========================================" -ForegroundColor Cyan
    Write-Host "    TERMINAL TACTICA DE GESTION"
    Write-Host " ==========================================`n" -ForegroundColor Cyan
    $items = @(" ARRANCAR SISTEMA", " INSTALAR DEPENDENCIAS", " REPARAR ENTORNO", " SALIR")
    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $Selected) { Write-Host "  >> $($items[$i]) <<" -ForegroundColor Magenta }
        else { Write-Host "     $($items[$i])" }
    }
}

# --- BUCLE PRINCIPAL ---
$exitSystem = $false
do {
    $sel = 0
    while ($true) {
        Show-Menu -Selected $sel
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 38) { $sel = ($sel - 1 + 4) % 4 }
        if ($key.VirtualKeyCode -eq 40) { $sel = ($sel + 1) % 4 }
        if ($key.VirtualKeyCode -eq 13) { break }
    }

    Clear-Host
    switch ($sel) {
        0 { 
            if (Test-Path $Cfg.Python) { & $Cfg.Python $Cfg.Run } 
            else { Write-Host "[!] Entorno no detectado. Instala dependencias primero." -ForegroundColor Red; Start-Sleep -Seconds 2 }
        }
        1 { 
            Write-Host ">>> INSTALANDO DEPENDENCIAS..." -ForegroundColor Green
            python -m venv (Join-Path $rootPath ".venv")
            & $Cfg.Pip install -r $Cfg.Reqs
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ">>> ÉXITO: Dependencias instaladas." -ForegroundColor Green
                & $Cfg.Python $Cfg.Run
            } else {
                Write-Host "[!] ERROR: Falló la instalación." -ForegroundColor Red; Start-Sleep -Seconds 3
            }
        }
        2 { 
            Write-Host ">>> Purgando entorno..." -ForegroundColor Yellow
            Remove-Item (Join-Path $rootPath ".venv") -Recurse -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
