# --- CONFIGURACIÓN DE RUTA AUTOMÁTICA ---
# Esto obtiene la ubicación real del archivo, sin importar desde dónde lo lances.
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir  = Split-Path -Parent $scriptPath
$projectDir = Split-Path -Parent $scriptDir

$ErrorActionPreference = "Stop"

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
            $py = Join-Path $projectDir ".venv\Scripts\python.exe"
            if (Test-Path $py) { & $py (Join-Path $projectDir "run.py") } 
            else { Write-Host "[!] ERROR: Entorno no detectado." -ForegroundColor Red; Start-Sleep -Seconds 2 }
        }
        1 { 
            $req = Join-Path $projectDir "requirements.txt"
            if (Test-Path $req) {
                Show-Section "INSTALANDO DEPENDENCIAS"
                python -m venv (Join-Path $projectDir ".venv")
                & (Join-Path $projectDir ".venv\Scripts\pip.exe") install -r $req
                
                if ($LASTEXITCODE -eq 0) {
                    Show-Section "INSTALACION EXITOSA"
                    Show-Section "LANZANDO PROGRAMA"
                    & (Join-Path $projectDir ".venv\Scripts\python.exe") (Join-Path $projectDir "run.py")
                } else {
                    Write-Host "`n[!] ERROR: La instalación falló." -ForegroundColor Red; Start-Sleep -Seconds 3
                }
            } else {
                Write-Host "`n[!] ERROR: No se encuentra requirements.txt en $projectDir" -ForegroundColor Red
                Start-Sleep -Seconds 3
            }
        }
        2 { 
            Remove-Item (Join-Path $projectDir ".venv") -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "`n[!] Entorno purgado." -ForegroundColor Magenta; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
