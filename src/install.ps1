<#
.SYNOPSIS
    Lanzador Profesional TUI - Gestión de Entorno Python.
    Versión 2.0 - Alta Resiliencia y Estilo Elegante.
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# Configuración Visual
$ESC        = [char]27
$RESET      = "$ESC[0m"
$BOLD       = "$ESC[1m"
$CYAN       = "$ESC[36m"
$CYAN_LIGHT = "$ESC[96m"
$MAGENTA    = "$ESC[35m"
$WHITE      = "$ESC[97m"
$GREEN      = "$ESC[92m"
$RED        = "$ESC[91m"
$GRAY       = "$ESC[90m"

# Rutas
$RepoRoot      = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }
$VenvPath      = Join-Path $RepoRoot ".venv"
$VenvPython    = Join-Path $VenvPath "Scripts\python.exe"
$RunScript     = Join-Path $RepoRoot "run.py"
$AppUrl        = "http://127.0.0.1:8080"

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "${CYAN} ╔══════════════════════════════════════════════╗"
    Write-Host " ║       SISTEMA DE GESTIÓN DE APLICACIÓN       ║"
    Write-Host " ╚══════════════════════════════════════════════╝"
    Write-Host ""
}

function Kill-AppProcesses {
    Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$VenvPath*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

function Invoke-App {
    Write-Host "${GREEN} [*] Iniciando aplicación y lanzando navegador...${RESET}"
    Start-Process -FilePath "cmd" -ArgumentList "/c `"$VenvPython`" `"$RunScript`" 2> `"$null`"" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Start-Process $AppUrl
}

# --- BUCLE PRINCIPAL ---
$salir = $false
while (-not $salir) {
    Show-Header
    Write-Host "  ${CYAN_LIGHT}1)${WHITE} Arrancar Sistema"
    Write-Host "  ${CYAN_LIGHT}2)${WHITE} Instalar / Configurar Dependencias"
    Write-Host "  ${CYAN_LIGHT}3)${WHITE} Reparar Entorno"
    Write-Host "  ${CYAN_LIGHT}4)${WHITE} Desinstalar"
    Write-Host "  ${RED}5)${WHITE} Salir"
    Write-Host ""
    
    $choice = Read-Host "  ${MAGENTA}▶${WHITE} Seleccione una opción"
    
    try {
        switch ($choice) {
            "1" {
    if (Test-Path $VenvPython) {
        Write-Host "${GREEN} [*] Arrancando sistema...${RESET}"
        
        # FORZAR EJECUCIÓN DESDE LA CARPETA RAÍZ
        # Esto soluciona errores de "File not found" o rutas relativas incorrectas
        $cmd = "cd /d `"$RepoRoot`" && `"$VenvPython`" `"$RunScript`""
        
        Start-Process -FilePath "cmd" -ArgumentList "/c $cmd" -WindowStyle Hidden
        
        Write-Host "${GRAY} [+] Servidor iniciado. El navegador se abrirá en breve...${RESET}"
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "`n ${RED}[!] Entorno no encontrado. Configure primero.${RESET}"
        Start-Sleep -Seconds 2
    }
}
            "2" {
                Write-Host "`n ${GREEN}[*] Instalando dependencias...${RESET}"
                & python -m venv $VenvPath
                & $VenvPython -m pip install --upgrade pip --quiet
                & $VenvPython -m pip install -r (Join-Path $RepoRoot "requirements.txt") --quiet
                Write-Host " ${GREEN}[+] Configuración exitosa.${RESET}"; Start-Sleep -Seconds 2
            }
            "3" {
                Write-Host "`n ${CYAN}[*] Reparando entorno...${RESET}"
                Kill-AppProcesses
                if (Test-Path $VenvPath) { Remove-Item $VenvPath -Recurse -Force -ErrorAction SilentlyContinue }
                & python -m venv $VenvPath
                & $VenvPython -m pip install -r (Join-Path $RepoRoot "requirements.txt") --quiet
                Write-Host " ${GREEN}[+] Reparación completa.${RESET}"; Start-Sleep -Seconds 2
            }
            "4" {
                $confirm = Read-Host "`n ${RED}[!] ¿Confirmar desinstalación total? (s/n)${RESET}"
                if ($confirm -eq "s") {
                    Kill-AppProcesses
                    Remove-Item $VenvPath -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host " ${GRAY}[-] Entorno eliminado.${RESET}"; Start-Sleep -Seconds 2
                }
            }
            "5" { $salir = $true }
            Default { Write-Host "`n ${RED}Opción no válida.${RESET}"; Start-Sleep -Seconds 1 }
        }
    } catch {
        Write-Host "`n ${RED}[!] Error crítico: $_${RESET}"
        Read-Host " Presione ENTER para continuar..."
    }
}
