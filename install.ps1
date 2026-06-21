[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$repoUrl = "https://github.com/Riutexu/Prueba-de-Shein-Temu/archive/refs/heads/main.zip"
$destPath = "$([Environment]::GetFolderPath('Desktop'))\Prueba-de-Shein-Temu"
$zipPath = "$destPath\temp.zip"

Write-Host "Iniciando instalación..." -ForegroundColor Cyan

# Crear directorio
if (!(Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath | Out-Null }

# Descargar
Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $destPath -Force
Remove-Item $zipPath

# Corregir estructura: Mover archivos de la carpeta interna a la raíz
$subDir = Get-ChildItem $destPath -Directory | Select-Object -First 1
Move-Item -Path "$($subDir.FullName)\*" -Destination $destPath -Force
Remove-Item -Path $subDir.FullName -Recurse

# Ejecutar instalador con el contexto correcto
Write-Host "Instalando dependencias..." -ForegroundColor Yellow
$batFile = "$destPath\1) Install Dependencies.bat"
Start-Process -FilePath $batFile -WorkingDirectory $destPath -Wait

# Iniciar software
Write-Host "Iniciando..." -ForegroundColor Green
$startFile = "$destPath\2) Start Software.bat"
Start-Process -FilePath $startFile -WorkingDirectory $destPath

# Crear acceso directo
$shortcutPath = "$([Environment]::GetFolderPath('Desktop'))\Software.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$destPath\2) Start Software.bat"
$shortcut.WorkingDirectory = $destPath
$shortcut.Save()
