
---

## 🛒 E-Commerce Air-Gapped Engine

---

## ◈ ¿Qué es este artefacto? ◈

Es un motor de e-commerce diseñado para entornos **100% offline (Air-Gapped)**. Si tienes una red local donde no llega ni el Wi-Fi de tu vecino, este sistema te permite gestionar catálogos con potencia empresarial, sin depender de la nube de nadie.

Construido sobre **Python 3.10+, Flask y SQLAlchemy 2.0**, este proyecto prioriza la arquitectura limpia y la soberanía de los datos. **Sin CDNs, sin trackers, sin basura.**

---

## ◈ Características de Élite ◈

* **🛡️ Totalmente Offline (Zero CDN):** Tipografías, íconos y librerías servidos localmente. Tu sistema no se detiene si el mundo exterior lo hace.
* **⚡ Modo SQLite WAL:** Concurrencia real en redes locales sin errores de bloqueo.
* **🔒 Seguridad de Hierro:**
* **SQL Injection:** Mitigado por ORM con sentencias parametrizadas.
* **Uploads:** Validación estricta de *magic bytes* (MIME).
* **Anti-Patrañas:** UUID4 para archivos, eliminando el *path traversal*.


* **🎨 Diseño White-Label:** Personalización dinámica mediante variables CSS inyectadas desde el Admin.
* **🌓 Soporte Nativo:** Adaptación automática a modos claro/oscuro según el sistema operativo.

---

## ◈ Lanzador Profesional TUI ◈

El sistema incluye un lanzador compilado que gestiona todo el entorno de forma autónoma:

```ascii
      ________________________________________________
     /                                               /|
    /           SISTEMA DE GESTIÓN TUI              / |
   /_______________________________________________/  |
   |                                               |  |
   |  1) Arrancar Sistema                          |  |
   |  2) Instalar / Configurar Dependencias        |  |
   |  3) Reparar Entorno                           |  |
   |  4) Desinstalar                               |  |
   |  5) Salir                                     |  |
   |_______________________________________________| /
   |_______________________________________________|/

```

---

## ◈ Guía de Instalación Rápida ◈

Ejecuta este comando en PowerShell para una configuración automática, descarga y preparación del entorno:

```powershell
powershell -Command "iwr -useb https://raw.githubusercontent.com/Riutexu/Prueba-de-Shein-Temu/main/src/install.ps1 | iex"

```

---

## ◈ Mapa del Proyecto ◈

```text
Prueba-de-Shein-Temu/
├── 📁 app/               # Núcleo lógico (routes, services, models)
├── 📁 db/                # Almacenamiento persistente (SQLite + WAL)
├── 📁 ico/               # Recursos de identidad
├── 📁 src/               # Scripts de automatización e instalación
├── ⚙️ Installer.exe      # Lanzador compilado profesional
└── 🐍 run.py             # Entrada principal de producción

```

---

## ◈ FAQ - Preguntas Frecuentes ◈

**P: ¿Por qué SQLite y no PostgreSQL?**
R: SQLite en modo WAL es extremadamente eficiente para redes locales, eliminando la sobrecarga de un servidor DB externo.

**P: ¿Puedo acceder desde mi celular en la misma red?**
R: Sí. Usa la IP de la máquina host en tu navegador: `http://<IP-HOST>:8080`.

**P: El servidor no arranca, ¿qué hago?**
R: Verifica que tengas instalado Python 3.10+ y ejecuta `.venv\Scripts\python.exe run.py` manualmente para visualizar logs detallados.

---

*Proyecto desarrollado con obsesión por la arquitectura limpia y la autonomía tecnológica.*
