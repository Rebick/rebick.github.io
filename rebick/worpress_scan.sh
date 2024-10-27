#!/bin/bash

# Colores
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # Sin color

# Verificar si se ha proporcionado un argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <URL>"
  exit 1
fi

# Asegurar que la URL termine con "/"
DOMAIN="$1"
[[ "${DOMAIN: -1}" != "/" ]] && DOMAIN="${DOMAIN}/"

# Función para extraer información de plugins y temas
sitios_recursivo() {
  local url="$1"

  echo -e "${GREEN}Plugins disponibles:${NC}"
  plugins=($(curl -s -X GET "$url" | \
    sed 's/href=/\n/g' | \
    sed 's/src=/\n/g' | \
    grep 'wp-content/plugins/' | \
    cut -d"'" -f2 | \
    sed "s|$url||g" | \
    sed 's|wp-content/plugins/\([^/]*\)/.*|\1|' | \
    sort -u))

  for plugin in "${plugins[@]}"; do
    echo -e "${CYAN}/$plugin${NC}"
  done

  echo -e "${GREEN}Temas disponibles:${NC}"
  temas=($(curl -s -X GET "$url" | \
    sed 's/href=/\n/g' | \
    sed 's/src=/\n/g' | \
    grep 'wp-content/themes/' | \
    cut -d"'" -f2 | \
    sed "s|$url||g" | \
    sed 's|wp-content/themes/\([^/]*\)/.*|\1|' | \
    sort -u))

  for tema in "${temas[@]}"; do
    echo -e "${CYAN}/$tema${NC}"
  done
}

# Función para buscar archivos dentro de plugins detectados
buscar_archivos_plugins() {
  local url="$1"
  echo -e "${YELLOW}Archivos dentro de plugins:${NC}"
  for plugin in "${plugins[@]}"; do
    echo -e "${BLUE}Plugin: /$plugin${NC}"
    archivos=$(curl -s -X GET "${url}wp-content/plugins/$plugin/" | grep -oP '(?<=href=")[^"]+\.(php|js|css|html)' | sort -u)
    
    if [ -z "$archivos" ]; then
      echo "  Ningún archivo encontrado en /$plugin"
    else
      for archivo in $archivos; do
        echo -e "  ${BLUE}$archivo${NC}"
      done
    fi
  done
}

# Función para buscar archivos dentro de temas detectados
buscar_archivos_temas() {
  local url="$1"
  echo -e "${YELLOW}Archivos dentro de temas:${NC}"
  for tema in "${temas[@]}"; do
    echo -e "${BLUE}Tema: /$tema${NC}"
    archivos=$(curl -s -X GET "${url}wp-content/themes/$tema/" | grep -oP '(?<=href=")[^"]+\.(php|js|css|html)' | sort -u)
    
    if [ -z "$archivos" ]; then
      echo "  Ningún archivo encontrado en /$tema"
    else
      for archivo in $archivos; do
        echo -e "  ${BLUE}$archivo${NC}"
      done
    fi
  done
}
buscar_directorios_plugin() {
  local url="$1"
  local plugin="$2"
  
  echo -e "${YELLOW}Directorios dentro de /wp-content/plugins/$plugin:${NC}"
  carpetas=$(curl -s -X GET "${url}wp-content/plugins/$plugin/" | html2text | grep -oP '^[^ ]+/' | grep -v '\.\./' | sed 's|/$||')
  
  if [ -z "$carpetas" ]; then
    echo "  Ningún directorio encontrado en /wp-content/plugins/$plugin"
  else
    echo "$carpetas" | while IFS= read -r dir; do
      echo -e "  ${BLUE}$dir${NC}"
    done
  fi
}

# Función para buscar directorios dentro de un tema
buscar_directorios_tema() {
  local url="$1"
  local tema="$2"
  
  echo -e "${YELLOW}Directorios dentro de /wp-content/themes/$tema:${NC}"
  carpetas=$(curl -s -X GET "${url}wp-content/themes/$tema/" | html2text | grep -oP '^[^ ]+/' | grep -v '\.\./' | sed 's|/$||')
  
  if [ -z "$carpetas" ]; then
    echo "  Ningún directorio encontrado en /wp-content/themes/$tema"
  else
    echo "$carpetas" | while IFS= read -r dir; do
      echo -e "  ${BLUE}$dir${NC}"
    done
  fi
}

# Llamada a la función priSncipal con el dominio proporcionado
sitios_recursivo "$DOMAIN"

# Llamada a las funciones de búsqueda de directorios para cada plugin y tema
for plugin in "${plugins[@]}"; do
  buscar_directorios_plugin "$DOMAIN" "$plugin"
done

for tema in "${temas[@]}"; do
  buscar_directorios_tema "$DOMAIN" "$tema"
done
