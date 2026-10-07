# ⚡ CCIE Macro Injector

Una herramienta web ligera y contenerizada para automatizar la inyección de macros y configuraciones (OSPF, BGP, Frame Relay, HSRP, etc.) en equipos de red Cisco. Diseñada para ingenieros de red y candidatos a CCIE que necesitan agilizar despliegues sin lidiar con 120 scripts de texto separados.

## 🚀 Características
* **Interfaz Web Minimalista:** No necesitas tocar código, todo se maneja desde el navegador.
* **Base de Datos Integrada:** Guarda todas tus plantillas recurrentes en una base de datos SQLite preconfigurada.
* **Multiplataforma y Aislada:** Funciona a través de Docker. No contamina tu sistema operativo ni tiene conflictos con versiones antiguas de Ruby o Python.
* **Ejecución en Tiempo Real:** Envía los comandos vía SSH (`net-ssh`) y visualiza el log del equipo directamente en la pantalla.

---

## 🛠️ Requisitos Previos

Antes de empezar, asegúrate de tener instalado en tu sistema un motor de contenedores:
* En **macOS (M1/M2/M3)**: Se recomienda encarecidamente usar [OrbStack](https://orbstack.dev/) en lugar de Docker Desktop por su bajo consumo de recursos.
* En **Linux / Windows**: Docker y Docker Compose estándar.
* **Git** para clonar el repositorio.

---

## 📦 Instalación y Despliegue Rápido (Quick Start)

**1. Clonar el repositorio**
Descarga la aplicación y la base de datos de plantillas a tu máquina local:
```bash
git clone https://github.com/TU-USUARIO/inyector-ccie.git
cd inyector-ccie
```
*(Nota: Si el creador original ya subió plantillas, estas vendrán incluidas automáticamente en la carpeta `/data`).*

**2. Construir la imagen de Docker**
Empaqueta la aplicación (solo tomará unos segundos si es la primera vez):
```bash
docker build -t ccie-injector .
```

**3. Levantar el servidor**
Inicia el contenedor mapeando el puerto web y creando un volumen persistente para que no pierdas tus macros guardadas:
```bash
docker run -d -p 4567:4567 -v "$(pwd)/data":/app/data ccie-injector
```

**4. Acceder a la consola**
Abre tu navegador web favorito y dirígete a:
👉 **[http://localhost:4567](http://localhost:4567)**

---

## 📖 Cómo utilizar la App

El flujo de trabajo está dividido en dos paneles simples:

### Opción 1: Guardar una Nueva Macro
Si tienes una configuración recurrente (ej. la configuración base de una interfaz IPv6 o una sesión BGP):
1. Ve al panel **"Guardar Nueva Macro en DB"**.
2. Asigna un nombre claro (ej: `OSPF Area 0 Base`).
3. Pega los comandos limpios en el cuadro de texto. Asegúrate de incluir saltos de línea claros.
4. Presiona **GUARDAR**. Tu macro ahora vive en la base de datos y no se borrará aunque apagues tu computadora.

### Opción 2: Inyectar Configuración a la Red
Para mandar los comandos al equipo físico o emulado (GNS3 / EVE-NG):
1. En el panel inferior, ingresa la **IP de Gestión** del router/switch.
2. Ingresa el **Usuario** y **Contraseña** del equipo. *(Nota: La aplicación no guarda tus credenciales en ninguna base de datos por seguridad).*
3. Selecciona una macro desde el **menú desplegable**, o pega una macro temporal en el cuadro de texto de abajo si no quieres guardarla.
4. Presiona **INYECTAR**. 
5. Observa cómo la pantalla de terminal te devuelve el log en vivo de las acciones ejecutadas en el switch.

---

## 🛑 Comandos de Mantenimiento

**Para apagar la aplicación cuando termines de estudiar:**
Busca el ID del contenedor corriendo con `docker ps` y luego detenlo:
```bash
docker stop <ID_DEL_CONTENEDOR>
```

**Para hacer un backup manual de tus macros:**
Tus configuraciones viven en el archivo `data/macros.db`. Simplemente copia ese archivo a un pendrive, la nube, o haz un `git push` para respaldarlas.

---
*Diseñado para entornos de laboratorio y certificación. Utilizar en producción bajo su propio riesgo, verificando siempre las llaves SSH de los dispositivos.*