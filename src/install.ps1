# --- INICIALIZACIÓN GLOBAL ---
$ErrorActionPreference = "Stop"
$global:targetDir = Join-Path ([Environment]::GetFolderPath('Desktop')) "Prueba-de-Shein-Temu"

# Asegurar que el entorno de ejecución siempre sea el correcto
if (-not (Test-Path $global:targetDir)) { New-Item -Path $global:targetDir -ItemType Directory | Out-Null }
Set-Location $global:targetDir

function Show-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n ==========================================" -ForegroundColor Cyan
    Write-Host "    TERMINAL TACTICA DE GESTION"
    Write-Host " ==========================================$RESET`n" -ForegroundColor Cyan
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
            $pythonPath = Join-Path $global:targetDir ".venv\Scripts\python.exe"
            if (Test-Path $pythonPath) { 
                & $pythonPath (Join-Path $global:targetDir "run.py") 
            } else { 
                Write-Host "[!] ERROR: Entorno no detectado." -ForegroundColor Red; Start-Sleep -Seconds 2 
            }
        }
        1 { 
            $reqPath = Join-Path $global:targetDir "requirements.txt"
            if (Test-Path $reqPath) {
                Show-Section "INSTALANDO DEPENDENCIAS"
                python -m venv (Join-Path $global:targetDir ".venv")
                & (Join-Path $global:targetDir ".venv\Scripts\pip.exe") install -r $reqPath
                
                if ($LASTEXITCODE -eq 0) {
                    Show-Section "INSTALACION EXITOSA"
                    Show-Section "VERIFICANDO"
                    Start-Sleep -Seconds 1
                    Show-Section "LANZANDO PROGRAMA AUTOMATICAMENTE"
                    & (Join-Path $global:targetDir ".venv\Scripts\python.exe") (Join-Path $global:targetDir "run.py")
                } else {
                    Write-Host "`n[!] ERROR: La instalación falló." -ForegroundColor Red; Start-Sleep -Seconds 3
                }
            } else {
                Write-Host "`n[!] ERROR CRÍTICO: requirements.txt no encontrado en $global:targetDir" -ForegroundColor Red
                Start-Sleep -Seconds 3
            }
        }
        2 { 
            Write-Host "`n[!] Purga de entorno completada." -ForegroundColor Magenta
            Remove-Item (Join-Path $global:targetDir ".venv") -Recurse -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
