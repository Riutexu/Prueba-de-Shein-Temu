# --- CONFIGURACIÓN DE ENTORNO ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# --- CONFIGURACIÓN DE COLORES ---
# Usamos directamente las secuencias de control ANSI estándar
$CYAN_ON  = "$([char]27)[38;2;0;255;255m"
$MAG_ON   = "$([char]27)[38;2;255;0;255m"
$GRN_ON   = "$([char]27)[38;2;50;255;50m"
$RESET    = "$([char]27)[0m"

$ErrorActionPreference = "Stop"

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

# (Resto de tu lógica igual, pero usa -ForegroundColor para todos los Write-Host)

# --- BUCLE DE INTERACCIÓN ---
$sel = 0
while ($true) {
    Show-Menu -Selected $sel
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 38) { $sel = ($sel - 1 + 4) % 4 }
    if ($key.VirtualKeyCode -eq 40) { $sel = ($sel + 1) % 4 }
    if ($key.VirtualKeyCode -eq 13) { break }
}

# --- PROCESAMIENTO ---
Clear-Host
Write-Host "$RGB_CYAN [*] INICIANDO PROCESO... $RESET`n"
for ($i = 0; $i -le 100; $i+=10) { Show-Bar -percent $i; Start-Sleep -Milliseconds 100 }

# ... (El resto de tu lógica del switch permanece igual)
