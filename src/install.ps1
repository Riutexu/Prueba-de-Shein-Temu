# --- CONFIGURACIÓN E INTEGRIDAD ---
$ErrorActionPreference = "Stop"
$scriptPath = $PSCommandPath
$projectDir = Split-Path (Split-Path $scriptPath -Parent) -Parent

# Forzamos la navegación al contexto del proyecto
Set-Location -Path $projectDir

# Definición de esquema de rutas (Inmutable)
$Cfg = [PSCustomObject]@{
    Env      = Join-Path $projectDir ".venv"
    Python   = Join-Path $projectDir ".venv\Scripts\python.exe"
    Pip      = Join-Path $projectDir ".venv\Scripts\pip.exe"
    Reqs     = Join-Path $projectDir "requirements.txt"
    Run      = Join-Path $projectDir "run.py"
}

# --- LÓGICA DE INTERFAZ ---
function Show-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n ==========================================" -ForegroundColor Cyan
    Write-Host "    TERMINAL TACTICA DE GESTION [SR-V1]"
    Write-Host " ==========================================`n" -ForegroundColor Cyan
    $items = @(" ARRANQUE", " DESPLIEGUE/DEPENDENCIAS", " SANEAMIENTO", " SALIR")
    for ($i = 0; $i -lt $items.Count; $i++) {
        $color = if ($i -eq $Selected) { "Magenta" } else { "Gray" }
        $prefix = if ($i -eq $Selected) { "  >> " } else { "     " }
        Write-Host "$prefix $($items[$i])" -ForegroundColor $color
    }
}

function Show-Section {
    param([string]$Title)
    Write-Host "`n>>> $Title" -ForegroundColor Cyan
    Write-Host ("=" * ($Title.Length + 4)) -ForegroundColor DarkCyan
}

# --- MOTOR DE EJECUCIÓN ---
$exitSystem = $false
do {
    $sel = 0
    while ($true) {
        Show-Menu -Selected $sel
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 38) { $sel = ($sel - 1 + 4) % 4 }
        elseif ($key.VirtualKeyCode -eq 40) { $sel = ($sel + 1) % 4 }
        elseif ($key.VirtualKeyCode -eq 13) { break }
    }

    Clear-Host
    switch ($sel) {
        0 { 
            if (Test-Path $Cfg.Python) { 
                Show-Section "INICIANDO SISTEMA"
                & $Cfg.Python $Cfg.Run 
            } else { 
                Write-Host "[!] ERROR: Entorno no inicializado. Seleccione opción 2." -ForegroundColor Red; Start-Sleep -Seconds 2 
            }
        }
        1 { 
            Show-Section "PROCESO DE DESPLIEGUE"
            if (-not (Test-Path $Cfg.Reqs)) { 
                Write-Host "[!] CRÍTICO: requirements.txt ausente." -ForegroundColor Red 
            } else {
                python -m venv $Cfg.Env
                & $Cfg.Pip install -r $Cfg.Reqs
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[+] Instalación completada con éxito." -ForegroundColor Green
                    & $Cfg.Python $Cfg.Run
                }
            }
            Start-Sleep -Seconds 2
        }
        2 { 
            Show-Section "SANEAMIENTO DE ENTORNO"
            Remove-Item $Cfg.Env -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Entorno virtual purgado." -ForegroundColor Magenta; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
