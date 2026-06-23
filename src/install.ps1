$ErrorActionPreference = "Stop"
$Cfg = [PSCustomObject]@{ TargetDir = Join-Path ([Environment]::GetFolderPath('Desktop')) "Prueba-de-Shein-Temu" }

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
            $py = Join-Path $Cfg.TargetDir ".venv\Scripts\python.exe"
            if (Test-Path $py) { & $py (Join-Path $Cfg.TargetDir "run.py") } 
            else { Write-Host "[!] Entorno no detectado." -ForegroundColor Red; Start-Sleep -Seconds 2 }
        }
        1 { 
            $req = Join-Path $Cfg.TargetDir "requirements.txt"
            if (Test-Path $req) {
                Show-Section "INSTALANDO DEPENDENCIAS"
                python -m venv (Join-Path $Cfg.TargetDir ".venv")
                & (Join-Path $Cfg.TargetDir ".venv\Scripts\pip.exe") install -r $req
                if ($LASTEXITCODE -eq 0) {
                    Show-Section "INSTALACION EXITOSA"
                    & (Join-Path $Cfg.TargetDir ".venv\Scripts\python.exe") (Join-Path $Cfg.TargetDir "run.py")
                }
            } else { Write-Host "Archivo $req no encontrado." -ForegroundColor Red; Start-Sleep -Seconds 3 }
        }
        2 { Remove-Item (Join-Path $Cfg.TargetDir ".venv") -Recurse -Force -ErrorAction SilentlyContinue }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
