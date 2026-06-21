# Definir variables
$repoUrl = "https://github.com/Riutexu/Prueba-de-Shein-Temu/archive/refs/heads/main.zip"
$destPath = "$([Environment]::GetFolderPath('Desktop'))\Prueba-de-Shein-Temu"
$zipPath = "$destPath\temp.zip"

Write-Host "Iniciando instalación en el Escritorio..." -ForegroundColor Cyan

# 1. Crear carpeta en el escritorio
if (!(Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath | Out-Null }

# 2. Descargar el repositorio completo
Write-Host "Descargando archivos..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath

# 3. Descomprimir
Expand-Archive -Path $zipPath -DestinationPath $destPath -Force
Remove-Item $zipPath

# Mover contenido de la subcarpeta creada por GitHub a la raíz de la carpeta
$extractedFolder = Get-ChildItem -Path $destPath | Where-Object { $_.PSIsContainer }
Move-Item -Path "$($extractedFolder.FullName)\*" -Destination $destPath
Remove-Item -Path $extractedFolder.FullName

# 4. Ejecutar archivo 1 (Instalar dependencias)
Write-Host "Ejecutando instalador de dependencias..." -ForegroundColor Yellow
Start-Process -FilePath "$destPath\1) Install Dependencies.bat" -Wait -NoNewWindow

# 5. Ejecutar archivo 2 (Iniciar software)
Write-Host "Iniciando software..." -ForegroundColor Yellow
Start-Process -FilePath "$destPath\2) Start Software.bat" -WindowStyle Hidden

# 6. Crear acceso directo en el escritorio
$shortcutPath = "$([Environment]::GetFolderPath('Desktop'))\Iniciar Software.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$destPath\2) Start Software.bat"
$shortcut.WorkingDirectory = $destPath
$shortcut.Description = "Acceso directo a Prueba-de-Shein-Temu"
$shortcut.Save()

Write-Host "¡Instalación completada y acceso directo creado!" -ForegroundColor Green
