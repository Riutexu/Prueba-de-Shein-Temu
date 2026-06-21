@echo off
:: Configuración de entorno
cd /d "%~dp0"
title Servidor E-Commerce (Air-Gapped)
color 0B

:: 2. Verificación de Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python 3.10+ no esta instalado.
    pause
    exit /b
)

echo ==================================================
echo         INICIANDO SERVIDOR DE COMERCIO
echo ==================================================
echo [INFO] Inicializando entorno en: %~dp0
echo [INFO] Servidor corriendo en: http://localhost:8080

:: 3. Lanzar navegador
start "" "http://localhost:8080"

:: 4. Ejecutar servidor
python run.py

pause
