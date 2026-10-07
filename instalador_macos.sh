#!/bin/bash

# Colores para la terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}⚡ Iniciando instalación y workarounds para CCIE Macro Injector (macOS)...${NC}"

# 1. Solicitar permisos de administrador al inicio
echo -e "\n${YELLOW}[1/4] Solicitando permisos de administrador para corregir el sistema...${NC}"
sudo -v

# 2. Workarounds profundos para Homebrew (Permisos rotos en Apple Silicon)
echo -e "\n${YELLOW}[2/4] Aplicando workarounds de permisos para /opt/homebrew...${NC}"
if [ -d "/opt/homebrew" ]; then
    echo "🔓 Liberando bloqueos de inmutabilidad (chflags)..."
    sudo chflags -R nouchg /opt/homebrew 2>/dev/null
    
    echo "👤 Ajustando propietario al usuario actual ($USER)..."
    sudo chown -R $(whoami) /opt/homebrew 2>/dev/null
    
    echo "✍️ Otorgando permisos de escritura..."
    chmod -R u+w /opt/homebrew 2>/dev/null
    echo -e "${GREEN}✔ Workarounds de directorios aplicados exitosamente.${NC}"
else
    echo "El directorio /opt/homebrew no existe aún. Se creará limpio en el siguiente paso."
fi

# 3. Instalación y Reparación de Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "\n${YELLOW}Homebrew no detectado. Instalando desde cero...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Añadir Homebrew al PATH temporalmente para que el script pueda seguir usándolo
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo -e "\n${GREEN}✔ Homebrew detectado. Actualizando repositorios...${NC}"
    brew update
fi

# 4. Instalar OrbStack (Alternativa nativa a Docker)
echo -e "\n${YELLOW}[3/4] Verificando motor de contenedores...${NC}"
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker no detectado. Instalando OrbStack (ligero para M1/M2) vía Homebrew..."
    brew install --cask orbstack
    echo "🚀 Iniciando OrbStack por primera vez..."
    open -a OrbStack
    echo "⏳ Esperando 10 segundos a que el motor de contenedores inicie..."
    sleep 10
else
    echo -e "${GREEN}✔ Motor de contenedores (Docker CLI) ya está instalado.${NC}"
    # Asegurarnos de que la app esté abierta
    open -a OrbStack 2>/dev/null || open -a Docker 2>/dev/null
fi

# 5. Construir y levantar el inyector
echo -e "\n${YELLOW}[4/4] Configurando y levantando el proyecto CCIE Macro Injector...${NC}"
echo "📁 Verificando carpeta de persistencia de datos..."
mkdir -p data

echo "📦 Construyendo la imagen de la aplicación..."
docker build -t ccie-injector .

echo "🧹 Limpiando instancias anteriores si existen..."
# Busca y detiene el contenedor anterior si quedó "pegado"
docker rm -f ccie-injector-app 2>/dev/null

echo "🌐 Levantando el servidor de Sinatra..."
# Ejecutamos el contenedor con un nombre fijo (--name) para que sea más fácil administrarlo luego
docker run -d --name ccie-injector-app -p 4567:4567 -v "$(pwd)/data":/app/data ccie-injector

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}✅ ¡INSTALACIÓN Y DESPLIEGUE COMPLETADOS CON ÉXITO!${NC}"
echo -e "La aplicación ya está corriendo en segundo plano."
echo -e "Abre tu navegador y entra a: ${YELLOW}http://localhost:4567${NC}"
echo -e "${GREEN}====================================================${NC}\n"