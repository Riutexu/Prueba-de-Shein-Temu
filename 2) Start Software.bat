@echo off
:: =======================================================================
:: White-Label E-Commerce Engine - Bootstrapper de Producción
:: =======================================================================
title Servidor E-Commerce (Air-Gapped)
color 0B
clear

:: 1. Forzar el directorio de trabajo correcto
cd /d "C:\wamp64\www\UNELLEZ"

:: 2. Verificación de entorno Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python 3.10+ no esta instalado o no se encuentra en el PATH.
    echo Por favor, configure las variables de entorno del sistema.
    pause
    exit /b
)

echo =======================================================================
echo                 INICIANDO SERVIDOR DE COMERCIO ELECTRONICO
echo =======================================================================
echo [INFO] Inicializando entorno y base de datos...
echo [INFO] Servidor corriendo en: http://localhost:8080
echo [INFO] Panel Admin disponible en: http://localhost:8080/admin
echo -----------------------------------------------------------------------
echo [INFO] Lanzando interfaz en el navegador...

:: 3. Lanzar el navegador web de forma automática
:: Nota: Se usa 'start' para que no bloquee la ejecución del script.
start "" "http://localhost:8080"

:: 4. Ejecutar el servidor de producción de Flask/Waitress
echo [INFO] Servidor en linea. Presione CTRL+C para detener.
echo =======================================================================
python run.py

pause