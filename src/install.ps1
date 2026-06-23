# --- CONFIGURACIÓN DE ENTORNO BLINDADA ---
$ErrorActionPreference = "Stop"

# 1. Autodetección absoluta del script
$scriptPath = $PSCommandPath
if (-not $scriptPath) { $scriptPath = (Get-Variable MyInvocation -Scope Global).Value.MyCommand.Definition }

$scriptDir  = Split-Path -Parent $scriptPath
$projectDir = Split-Path -Parent $scriptDir

# 2. SALTO DE SEGURIDAD: Nos movemos a la raíz del proyecto para evitar errores de contexto
Set-Location -Path $projectDir

# 3. Validación de archivos
if (-not (Test-Path "requirements.txt")) {
    Write-Host "[!] ERROR: No se encontró requirements.txt en $projectDir" -ForegroundColor Red
    Write-Host "[!] Ejecuta este script desde la carpeta src/ o verifica la estructura." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    exit
}

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
        }
        2 { 
            Remove-Item (Join-Path $Cfg.TargetDir ".venv") -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "`n[!] Entorno purgado." -ForegroundColor Magenta; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
