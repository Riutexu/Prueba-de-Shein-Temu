<#
.SYNOPSIS
    Lanzador Maestro - Instalación y Gestión de Entorno Python.
    Versión 3.0 - Integración total de despliegue y gestión.
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# Configuración Visual
$CYAN_LIGHT = "$([char]27)[96m"; $WHITE = "$([char]27)[97m"; $GREEN = "$([char]27)[92m"
$RED = "$([char]27)[91m"; $MAGENTA = "$([char]27)[35m"; $RESET = "$([char]27)[0m"

# Rutas
$RepoRoot   = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }
$VenvPath   = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvPath "Scripts\python.exe"
$RunScript  = Join-Path $RepoRoot "run.py"

function Show-Header {
    Clear-Host
    Write-Host "`n${CYAN_LIGHT} ╔══════════════════════════════════════════════╗"
    Write-Host " ║      SISTEMA DE GESTIÓN Y DESPLIEGUE         ║"
    Write-Host " ╚══════════════════════════════════════════════╝`n"
}

# --- MENÚ PRINCIPAL ---
$salir = $false
while (-not $salir) {
    Show-Header
    Write-Host "  ${CYAN_LIGHT}1)${WHITE} Arrancar Sistema"
    Write-Host "  ${CYAN_LIGHT}2)${WHITE} Instalar / Actualizar Sistema (Despliegue Remoto)"
    Write-Host "  ${CYAN_LIGHT}3)${WHITE} Configurar/Reparar Entorno Python"
    Write-Host "  ${RED}4)${WHITE} Salir"
    Write-Host ""
    
    $choice = Read-Host "  ${MAGENTA}▶${WHITE} Seleccione una opción"
    
    switch ($choice) {
        "1" {
            if (Test-Path $VenvPython) {
                Start-Process "cmd" -ArgumentList "/c cd /d `"$RepoRoot`" && `"$VenvPython`" `"$RunScript`"" -WindowStyle Hidden
                Write-Host "${GREEN} [*] Servidor iniciado.${RESET}"; Start-Sleep -Seconds 2
            } else { Write-Host "${RED}[!] Entorno no detectado.${RESET}"; Start-Sleep -Seconds 2 }
        }
        "2" {
            # Lógica de Despliegue Integrada
            Write-Host "${GREEN}[*] Iniciando descarga de repositorio remoto...${RESET}"
            try {
                $zip = Join-Path $env:TEMP "repo.zip"
                $tmp = Join-Path $env:TEMP "tmp_extract"
                Invoke-WebRequest -Uri "https://github.com/Riutexu/Prueba-de-Shein-Temu/archive/refs/heads/main.zip" -OutFile $zip
                Expand-Archive $zip -DestinationPath $tmp -Force
                $root = (Get-ChildItem $tmp -Directory).FullName
                Copy-Item -Path "$root\*" -Destination $RepoRoot -Recurse -Force
                Remove-Item $zip, $tmp -Recurse -Force
                Write-Host "${GREEN}[+] Despliegue exitoso. Por favor reinicie el lanzador.${RESET}"
            } catch { Write-Host "${RED}[!] Error: $($_.Exception.Message)${RESET}" }
            Start-Sleep -Seconds 3
        }
        "3" {
            Write-Host "${GREEN}[*] Configurando entorno local...${RESET}"
            if (-not (Test-Path $VenvPath)) { & python -m venv $VenvPath }
            & $VenvPython -m pip install --upgrade pip --no-cache-dir --quiet
            & $VenvPython -m pip install -r (Join-Path $RepoRoot "requirements.txt") --no-cache-dir --quiet
            Write-Host "${GREEN}[+] Entorno listo.${RESET}"; Start-Sleep -Seconds 2
        }
        "4" { $salir = $true }
    }
}
