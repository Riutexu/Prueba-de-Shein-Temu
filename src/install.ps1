<#
.SYNOPSIS
    Lanzador Profesional TUI - Gestión de Entorno Python.
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# Configuración Visual
$ESC   = [char]27
$RESET = "$ESC[0m"
$BOLD  = "$ESC[1m"
$CYAN  = "$ESC[36m"
$GREEN = "$ESC[32m"
$RED   = "$ESC[31m"
$GRAY  = "$ESC[90m"

$RepoRoot      = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }
$VenvPath      = Join-Path $RepoRoot ".venv"
$VenvPython    = Join-Path $VenvPath "Scripts\python.exe"
$RunScript     = Join-Path $RepoRoot "run.py"
$AppUrl        = "http://127.0.0.1:5000"

function Show-Header {
    Clear-Host
    Write-Host "${BOLD}${CYAN}=================================================="
    Write-Host "         SISTEMA DE GESTIÓN DE APLICACIÓN         "
    Write-Host "==================================================${RESET}`n"
}

function Invoke-App {
    Write-Host "${GREEN}[*] Iniciando aplicación y lanzando navegador...${RESET}"
    # Ejecuta en una ventana oculta redirigiendo errores al vacío (solución a Waitress)
    Start-Process -FilePath "cmd" -ArgumentList "/c `"$VenvPython`" `"$RunScript`" 2> `"$null`"" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Start-Process $AppUrl
    exit
}

# --- BUCLE DE MENÚ TUI ---
$salir = $false
while (-not $salir) {
    Show-Header
    Write-Host " 1) ${CYAN}Arrancar Sistema${RESET}"
    Write-Host " 2) ${CYAN}Instalar / Configurar Dependencias${RESET}"
    Write-Host " 3) ${CYAN}Reparar Entorno${RESET}"
    Write-Host " 4) ${CYAN}Desinstalar${RESET}"
    Write-Host " 5) ${RED}Salir${RESET}"
    Write-Host "`n"
    
    $choice = Read-Host " Seleccione una opción"

    try {
        switch ($choice) {
            "1" {
                if (Test-Path $VenvPython) { Invoke-App }
                else { Write-Host "${RED}[!] Entorno no encontrado. Opción 2 primero.${RESET}"; Start-Sleep -Seconds 2 }
            }
            "2" {
                Write-Host "${GREEN}[*] Instalando dependencias...${RESET}"
                & python -m venv $VenvPath
                & $VenvPython -m pip install --upgrade pip --quiet
                & $VenvPython -m pip install -r (Join-Path $RepoRoot "requirements.txt") --quiet
                Write-Host "${GREEN}[+] Configuración exitosa.${RESET}"; Start-Sleep -Seconds 2
            }
            "3" {
                Write-Host "${CYAN}[*] Reparando...${RESET}"
                Remove-Item $VenvPath -Recurse -Force -ErrorAction SilentlyContinue
                & python -m venv $VenvPath
                & $VenvPython -m pip install -r (Join-Path $RepoRoot "requirements.txt") --quiet
                Write-Host "${GREEN}[+] Reparación completa.${RESET}"; Start-Sleep -Seconds 2
            }
            "4" {
                $confirm = Read-Host "${RED}[!] ¿Confirmar desinstalación? (s/n)${RESET}"
                if ($confirm -eq "s") {
                    Remove-Item $VenvPath -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "${GRAY}[-] Entorno eliminado.${RESET}"; Start-Sleep -Seconds 2
                }
            }
            "5" { $salir = $true }
            Default { Write-Host "${RED}Opción no válida.${RESET}"; Start-Sleep -Seconds 1 }
        }
    } catch {
        Write-Host "${RED}`n[!] Error crítico: $_${RESET}"
        Read-Host "Presione ENTER para continuar..."
    }
}
