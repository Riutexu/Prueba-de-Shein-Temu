# --- CONFIGURACIÓN DE ENTORNO ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# Carácter de escape ANSI real
$ESC = [char]27
$RGB_CYAN    = "$ESC[38;2;0;255;255m"
$RGB_MAGENTA = "$ESC[38;2;255;0;255m"
$RGB_GREEN   = "$ESC[38;2;50;255;50m"
$RESET       = "$ESC[0m"

function Show-Bar {
    param($percent)
    $width = 30
    $filled = [math]::Floor(($percent / 100) * $width)
    # Usamos caracteres simples para evitar problemas de codificación
    $bar = ("#" * $filled).PadRight($width, "-")
    Write-Host -NoNewline "`r $RGB_MAGENTA [$bar] $percent% $RESET"
}

function Show-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n$RGB_CYAN =========================================="
    Write-Host "    TERMINAL TACTICA DE GESTION"
    Write-Host " ==========================================$RESET`n"
    
    $items = @(" ARRANCAR SISTEMA", " INSTALAR DEPENDENCIAS", " REPARAR ENTORNO", " SALIR")
    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $Selected) { 
            Write-Host "$RGB_MAGENTA  >> $($items[$i]) <<$RESET" 
        } else { 
            Write-Host "     $($items[$i])" 
        }
    }
}

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
