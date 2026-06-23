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

# --- BUCLE PRINCIPAL (Relanzamiento Automático) ---
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
            if (Test-Path ".venv\Scripts\python.exe") { 
                & .venv\Scripts\python.exe run.py 
            } else { 
                Write-Host "[!] ERROR: Entorno no detectado." -ForegroundColor Red; Start-Sleep -Seconds 2 
            }
        }
       1 { 
            $reqPath = Join-Path $targetDir "requirements.txt"
            
            if (Test-Path $reqPath) {
                Show-Section "INSTALANDO DEPENDENCIAS"
                
                # Ejecutamos y capturamos el resultado
                python -m venv "$targetDir\.venv"
                & "$targetDir\.venv\Scripts\pip.exe" install -r $reqPath
                
                # Verificamos si pip tuvo éxito (código de salida 0 es éxito)
                if ($LASTEXITCODE -eq 0) {
                    Show-Section "INSTALACION EXITOSA"
                    Show-Section "VERIFICANDO"
                    Start-Sleep -Seconds 1
                    
                    Show-Section "LANZANDO PROGRAMA AUTOMATICAMENTE"
                    & "$targetDir\.venv\Scripts\python.exe" "$targetDir\run.py"
                } else {
                    Write-Host "`n[!] ERROR: La instalación de dependencias falló." -ForegroundColor Red
                    Start-Sleep -Seconds 3
                }
            } else {
                Write-Host "`n[!] ERROR CRÍTICO: No se encuentra 'requirements.txt' en $reqPath" -ForegroundColor Red
                Start-Sleep -Seconds 3
            }
        }
        2 { 
            Write-Host "`n[!] Purga de entorno completada." -ForegroundColor Magenta
            Remove-Item .venv -Recurse -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
