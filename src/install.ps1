# --- CONFIGURACIÓN DE ENTORNO ---
$ErrorActionPreference = "Stop"
# Obtenemos la ruta absoluta de donde vive este script y retrocedemos al directorio raíz
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectDir = Split-Path -Parent $scriptDir

# Estructura de configuración inyectable
$Cfg = [PSCustomObject]@{ 
    TargetDir = $projectDir
    Python    = Join-Path $projectDir ".venv\Scripts\python.exe"
    Pip       = Join-Path $projectDir ".venv\Scripts\pip.exe"
    Reqs      = Join-Path $projectDir "requirements.txt"
    Run       = Join-Path $projectDir "run.py"
}

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

function Show-Section {
    param([string]$Title)
    Write-Host "`n==========================================" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
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
            else { Write-Host "[!] ERROR: Entorno no detectado. Instala dependencias primero." -ForegroundColor Red; Start-Sleep -Seconds 2 }
        }
        1 { 
            if (Test-Path $Cfg.Reqs) {
                Show-Section "INSTALANDO DEPENDENCIAS"
                python -m venv (Join-Path $Cfg.TargetDir ".venv")
                & $Cfg.Pip install -r $Cfg.Reqs
                
                if ($LASTEXITCODE -eq 0) {
                    Show-Section "INSTALACION EXITOSA"
                    Show-Section "LANZANDO PROGRAMA"
                    & $Cfg.Python $Cfg.Run
                } else {
                    Write-Host "`n[!] ERROR: La instalación falló." -ForegroundColor Red; Start-Sleep -Seconds 3
                }
            } else {
                Write-Host "`n[!] ERROR: requirements.txt no encontrado en $($Cfg.TargetDir)" -ForegroundColor Red
                Start-Sleep -Seconds 3
            }
        }
        2 { 
            Remove-Item (Join-Path $Cfg.TargetDir ".venv") -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "`n[!] Entorno purgado." -ForegroundColor Magenta; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
