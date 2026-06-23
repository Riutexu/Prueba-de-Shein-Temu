# --- CONFIGURACIÓN DE ENTORNO ---
$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
$targetDir = Join-Path ([Environment]::GetFolderPath('Desktop')) "Prueba-de-Shein-Temu"

# Asegurar que estamos en el directorio de destino
if ($PWD.Path -ne $targetDir) {
    if (-not (Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory | Out-Null }
    Set-Location $targetDir
}

# --- TUI TÁCTICA (Configuración de Colores) ---
$RGB_CYAN    = "`e[38;2;0;255;255m"
$RGB_MAGENTA = "`e[38;2;255;0;255m"
$RGB_GREEN   = "`e[38;2;50;255;50m"
$RESET       = "`e[0m"

function Draw-Bar {
    param($percent)
    $width = 30
    $filled = [math]::Floor(($percent / 100) * $width)
    $bar = ("█" * $filled).PadRight($width, "░")
    Write-Host -NoNewline "`r $RGB_MAGENTA[$bar] $percent% $RESET"
}

function Draw-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n $RGB_CYAN ╔══════════════════════════════════════════════╗"
    Write-Host " ║          TERMINAL TÁCTICA DE GESTIÓN         ║"
    Write-Host " ╚══════════════════════════════════════════════╝$RESET`n"
    
    $items = @(" ARRANCAR SISTEMA", " INSTALAR DEPENDENCIAS", " REPARAR ENTORNO", " SALIR")
    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $Selected) { Write-Host " $RGB_MAGENTA >$items[$i] <$RESET" } 
        else { Write-Host "   $items[$i]" }
    }
}

# --- BUCLE DE INTERACCIÓN ---
$sel = 0
while ($true) {
    Draw-Menu -Selected $sel
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 38) { $sel = ($sel - 1 + 4) % 4 }
    if ($key.VirtualKeyCode -eq 40) { $sel = ($sel + 1) % 4 }
    if ($key.VirtualKeyCode -eq 13) { break }
}

# --- PROCESAMIENTO ---
Clear-Host
Write-Host "$RGB_CYAN [*] INICIANDO PROCESO... $RESET`n"
for ($i = 0; $i -le 100; $i+=10) { Draw-Bar -percent $i; Start-Sleep -Milliseconds 100 }

switch ($sel) {
    0 { 
        if (Test-Path ".venv/Scripts/python.exe") { & .venv/Scripts/python.exe run.py } 
        else { Write-Host "`n$RGB_MAGENTA [!] Entorno no detectado. Instala dependencias primero. $RESET" }
    }
    1 { 
        Write-Host "`n$RGB_GREEN [!] Desplegando entorno virtual y dependencias... $RESET"
        python -m venv .venv; .venv/Scripts/pip install -r requirements.txt
    }
    2 { 
        Write-Host "`n$RGB_MAGENTA [!] Purga de entorno completada. $RESET"
        Remove-Item .venv -Recurse -Force -ErrorAction SilentlyContinue
    }
    3 { exit }
}
