# src/install.ps1 - Despliegue Totalmente Autónomo y TUI Táctica
$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
$desktop = [Environment]::GetFolderPath('Desktop')
$targetDir = Join-Path $desktop "Prueba-de-Shein-Temu"
$shortcutPath = Join-Path $desktop "Lanzar Sistema.lnk"

# 1. Despliegue automático (si no existe la carpeta)
if (-not (Test-Path $targetDir)) {
    $zip = Join-Path $env:TEMP "repo.zip"
    Invoke-WebRequest -Uri "https://github.com/Riutexu/Prueba-de-Shein-Temu/archive/refs/heads/main.zip" -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
    Move-Item "$env:TEMP\Prueba-de-Shein-Temu-main" $targetDir -Force
    Remove-Item $zip
}

# 2. Autonomía: Crear acceso directo persistente
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetDir\src\install.ps1`""
$shortcut.WorkingDirectory = $targetDir
$shortcut.IconLocation = "$targetDir\ico\W_D.ico"
$shortcut.Save()

# 3. TUI Táctica Profesional
$RGB_CYAN    = "`e[38;2;0;255;255m"
$RGB_MAGENTA = "`e[38;2;255;0;255m"
$RGB_GREEN   = "`e[38;2;50;255;50m"
$RESET       = "`e[0m"

function Show-Bar {
    param($percent)
    $width = 30
    $filled = [math]::Floor(($percent / 100) * $width)
    $bar = ("█" * $filled).PadRight($width, "░")
    Write-Host -NoNewline "`r $RGB_MAGENTA[$bar] $percent% $RESET"
}

function Show-Menu {
    param([int]$Selected)
    Clear-Host
    Write-Host "`n $RGB_CYAN ╔══════════════════════════════════════════════╗"
    Write-Host " ║          TERMINAL TÁCTICA DE GESTIÓN         ║"
    Write-Host " ╚══════════════════════════════════════════════╝$RESET`n"
    
    $items = @(" ARRANCAR SISTEMA", " INSTALAR DEPENDENCIAS", " REPARAR ENTORNO", " SALIR")
    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $Selected) { Write-Host " $RGB_MAGENTA >$($items[$i]) <$RESET" } 
        else { Write-Host "   $($items[$i])" }
    }
}

$sel = 0
while ($true) {
    Show-Menu -Selected $sel
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 38) { $sel = ($sel - 1 + 4) % 4 }
    if ($key.VirtualKeyCode -eq 40) { $sel = ($sel + 1) % 4 }
    if ($key.VirtualKeyCode -eq 13) { break }
}

Clear-Host
Write-Host "$RGB_CYAN [*] INICIANDO PROCESO... $RESET`n"
for ($i = 0; $i -le 100; $i+=10) { Show-Bar -percent $i; Start-Sleep -Milliseconds 100 }

switch ($sel) {
    0 { 
        if (Test-Path "$targetDir\.venv\Scripts\python.exe") { & "$targetDir\.venv\Scripts\python.exe" "$targetDir\run.py" } 
        else { Write-Host "`n$RGB_MAGENTA [!] Entorno no detectado. Instala dependencias primero. $RESET"; Start-Sleep -Seconds 2 }
    }
    1 { 
        Write-Host "`n$RGB_GREEN [!] Desplegando dependencias... $RESET"
        python -m venv "$targetDir\.venv"
        & "$targetDir\.venv\Scripts\pip.exe" install -r "$targetDir\requirements.txt"
    }
    2 { 
        Write-Host "`n$RGB_MAGENTA [!] Purga de entorno completada. $RESET"
        Remove-Item "$targetDir\.venv" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
    3 { exit }
}
