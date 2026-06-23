# --- 1. DEFINICIÓN DE FUNCIONES ---
function Show-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n ==========================================" -ForegroundColor Cyan
    Write-Host "    TERMINAL TACTICA DE GESTION"
    Write-Host " ==========================================`n" -ForegroundColor Cyan
    
    $items = @(" ARRANCAR SISTEMA", " INSTALAR DEPENDENCIAS", " REPARAR ENTORNO", " SALIR")
    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $Selected) { 
            Write-Host "  >> $($items[$i]) <<" -ForegroundColor Magenta
        } else { 
            Write-Host "     $($items[$i])"
        }
    }
}

function Show-Bar {
    param([int]$percent)
    $width = 30
    $filled = [math]::Floor(($percent / 100) * $width)
    $bar = ("#" * $filled).PadRight($width, "-")
    Write-Host -NoNewline "`r [ $bar ] $percent% " -ForegroundColor Magenta
}

# --- 2. LÓGICA PRINCIPAL ---
$ErrorActionPreference = "Stop"
$desktop = [Environment]::GetFolderPath('Desktop')
$targetDir = Join-Path $desktop "Prueba-de-Shein-Temu"

# Configuración del entorno de trabajo
if ($PWD.Path -ne $targetDir) {
    if (-not (Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory | Out-Null }
    Set-Location $targetDir
}

# Bucle de Interacción
$sel = 0
while ($true) {
    Show-Menu -Selected $sel
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 38) { $sel = ($sel - 1 + 4) % 4 }
    if ($key.VirtualKeyCode -eq 40) { $sel = ($sel + 1) % 4 }
    if ($key.VirtualKeyCode -eq 13) { break }
}

# Ejecución
Clear-Host
Write-Host " [*] INICIANDO PROCESO...`n" -ForegroundColor Cyan
for ($i = 0; $i -le 100; $i+=10) { Show-Bar -percent $i; Start-Sleep -Milliseconds 100 }

switch ($sel) {
    0 { 
        if (Test-Path ".venv\Scripts\python.exe") { & .venv\Scripts\python.exe run.py } 
        else { Write-Host "`n [!] Entorno no detectado." -ForegroundColor Magenta; Start-Sleep -Seconds 2 }
    }
    1 { 
        Write-Host "`n [!] Instalando dependencias..." -ForegroundColor Green
        python -m venv .venv; .venv\Scripts\pip install -r requirements.txt
    }
    2 { 
        Write-Host "`n [!] Limpiando entorno..." -ForegroundColor Magenta
        Remove-Item .venv -Recurse -Force -ErrorAction SilentlyContinue
    }
    3 { exit }
}
