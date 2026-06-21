<#
.SYNOPSIS
    Instalador Autónomo Profesional - Entorno Aislado Python.
.DESCRIPTION
    Rutas ajustadas para el contexto de un ejecutable compilado (PS2EXE)
    y manejo de excepciones con pausa en pantalla.
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

$ESC   = [char]27
$RESET = "$ESC[0m"
$BOLD  = "$ESC[1m"
$CYAN  = "$ESC[36m"
$GREEN = "$ESC[32m"
$RED   = "$ESC[31m"
$GRAY  = "$ESC[90m"

function Clear-CurrentLine { return "$ESC[2K$ESC[0G" }

function Show-Progress {
    param (
        [int]$Percent,
        [string]$Status
    )
    $Width = 30
    $Filled = [Math]::Round(($Percent / 100) * $Width)
    $Empty = $Width - $Filled
    $Bar = "█" * $Filled + "░" * $Empty
    Write-Host -NoNewline "$(Clear-CurrentLine)${BOLD}${CYAN}[${Bar}${CYAN}] ${Percent}%${RESET} - ${Status}"
}

# --- RESOLUCIÓN ABSOLUTA DE RUTAS (Modo Script y Modo EXE) ---
if ([string]::IsNullOrEmpty($PSScriptRoot)) {
    # Si se ejecuta como .exe, extraemos la ubicación directamente del proceso padre en Windows
    $ProcessPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $RepoRoot = Split-Path -Parent $ProcessPath
} else {
    # Si se ejecuta como código fuente en desarrollo
    $RepoRoot = $PSScriptRoot
}

$RequirementsPath = Join-Path $RepoRoot "requirements.txt"
$VenvPath         = Join-Path $RepoRoot ".venv"
$IconPath         = Join-Path $RepoRoot "ico\W_D.ico"
$RunScriptPath    = Join-Path $RepoRoot "run.py"

Clear-Host
Write-Host "${BOLD}${CYAN}=================================================="
Write-Host "        SISTEMA DE DESPLIEGUE AUTOMATIZADO"
Write-Host "==================================================${RESET}`n"

try {
    Show-Progress -Percent 15 -Status "Validando intérprete de Python en el sistema..."
    if (-not (Get-Command "python" -ErrorAction SilentlyContinue)) {
        throw "Python no está instalado o no se encuentra en el PATH de Windows."
    }
    Start-Sleep -Milliseconds 300

    Show-Progress -Percent 40 -Status "Creando entorno virtual local (.venv)..."
    if (-not (Test-Path $VenvPath)) {
        & python -m venv $VenvPath
    }
    $VenvPython = Join-Path $VenvPath "Scripts\python.exe"
    if (-not (Test-Path $VenvPython)) { throw "No se pudo crear el entorno virtual (.venv)." }

    Show-Progress -Percent 65 -Status "Instalando dependencias (requirements.txt)..."
    if (Test-Path $RequirementsPath) {
        & $VenvPython -m pip install --upgrade pip --quiet
        & $VenvPython -m pip install -r $RequirementsPath --quiet --no-warn-script-location
    } else {
        throw "No se encontró el archivo 'requirements.txt' en la ruta: $RequirementsPath"
    }

   Show-Progress -Percent 85 -Status "Generando acceso directo en el Escritorio..."
    if (Test-Path $IconPath) {
        $WshShell = New-Object -ComObject WScript.Shell
        
        # CORRECCIÓN: Evaluar y almacenar la ruta del Escritorio antes de concatenar
        $DesktopPath  = [Environment]::GetFolderPath("Desktop")
        $ShortcutPath = Join-Path -Path $DesktopPath -ChildPath "Prueba Shein-Temu.lnk"
        
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $VenvPython
        $Shortcut.Arguments = "`"$RunScriptPath`""
        $Shortcut.WorkingDirectory = $RepoRoot
        $Shortcut.IconLocation = $IconPath
        $Shortcut.Description = "Ejecutar Aplicación local Prueba-de-Shein-Temu"
        $Shortcut.Save()
    } else {
        Write-Host "`n${GRAY}[!] Advertencia: No se encontró el icono en $IconPath. Se creará sin icono personalizado.${RESET}"
    }

    Show-Progress -Percent 100 -Status "Despliegue finalizado con éxito."
    Write-Host "`n`n${GREEN}${BOLD}✔ Entorno aislado configurado. Acceso directo creado en el Escritorio.${RESET}`n"

    Set-Location $env:USERPROFILE
    Start-Sleep -Seconds 2

    if ($Host.Name -eq "ConsoleHost" -and $env:DiscreteEXE -eq "True") {
        [Environment]::Exit(0)
    } else {
        Stop-Process -Id $PID -Force
    }

} catch {
    # CORRECCIÓN DE UX: Forzar pausa para que el usuario pueda leer el error antes de que el EXE muera
    Write-Host "`n`n${RED}${BOLD}❌ ERROR CRÍTICO EN LA INSTALACIÓN:${RESET}"
    Write-Host "${RED}$_${RESET}`n"
    
    Set-Location $env:USERPROFILE
    
    Write-Host "${GRAY}Presiona ENTER para cerrar la ventana...${RESET}"
    Read-Host
    exit 1
}