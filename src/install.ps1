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
            Show-Section "INSTALANDO DEPENDENCIAS"
            python -m venv .venv
            & .venv\Scripts\pip install -r requirements.txt
            
            Show-Section "INSTALACION EXITOSA"
            Show-Section "VERIFICANDO"
            Start-Sleep -Seconds 1
            Show-Section "LANZANDO PROGRAMA AUTOMATICAMENTE"
            & .venv\Scripts\python.exe run.py
        }
        2 { 
            Write-Host "`n[!] Purga de entorno completada." -ForegroundColor Magenta
            Remove-Item .venv -Recurse -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1
        }
        3 { $exitSystem = $true }
    }
} while (-not $exitSystem)
