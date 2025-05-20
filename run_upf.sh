#!/bin/bash
set -euo pipefail

# ——— Configuración de rutas ———
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/files/open5gs"
DST_DIR="open5gs/install/etc/open5gs"
DST_FILE="upf.yaml"

# ——— Funciones auxiliares ———
log()   { echo -e "[\e[32mOK\e[0m] $*"; }
warn()  { echo -e "[\e[33mWARN\e[0m] $*"; }
error() { echo -e "[\e[31mERR\e[0m] $*" >&2; exit 1; }

require_root() {
  if [ "$EUID" -ne 0 ]; then
    error "Necesitas ejecutar como root o con sudo."
  fi
}

prompt_choice() {
  echo "¿Qué UPF quieres desplegar?"
  echo "  1) upf_1.yaml + túneles 10.45.0.0/24 & 10.46.0.0/24 & 10.47.0.0/24"
  echo "  2) upf_2.yaml + túnel  10.48.0.0/24 & 10.49.0.0/24 & 10.50.0.0/24"
  read -rp "Elige [1-2]: " choice
  [[ "$choice" =~ ^[12]$ ]] || error "Opción no válida."
}

detect_ip() {
  ip=$(hostname -I | awk '{print $1}')
  [[ -n "$ip" ]] || error "No se ha podido detectar la IP local."
  echo "$ip"
}

copy_and_patch() {
  local src="$1" dst="$2" ip_upf="$3" ip_core="$4"
  [ -e "$dst" ] && { warn "Eliminando $dst existente"; rm -f "$dst"; }
  cp "$src" "$dst"
  sed -i "s/IP_UPF/${ip_upf}/g" "$dst"
  sed -i "s/IP_CORE/${ip_core}/g" "$dst"
  log "Fichero $dst preparado (IP_UPF=${ip_upf})"
}

setup_tunnel() {
  local name=$1 cidr=$2
  if ip link show "$name" &>/dev/null; then
    warn "El interfaz $name ya existe, lo recreamos"
    ip link del "$name"
  fi
  ip tuntap add name "$name" mode tun
  ip addr add "${cidr%.*}.1/${cidr#*/}" dev "$name"
  ip link set "$name" up
  iptables -t nat -C POSTROUTING -s "$cidr" ! -o "$name" -j MASQUERADE 2>/dev/null \
    || iptables -t nat -A POSTROUTING -s "$cidr" ! -o "$name" -j MASQUERADE
  log "Túnel $name configurado ($cidr)"


}

# ——— Script principal ———
require_root

LOCAL_IP=$(detect_ip)
log "IP local detectada: $LOCAL_IP"


sed -i.bak '/^[[:space:]]*#\s*net\.ipv4\.ip_forward=1/s/^[[:space:]]*#\s*//' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

prompt_choice

# Parámetros según selección
if [ "$choice" = "1" ]; then
  SELECTED="upf_1.yaml"
  TUNNELS=( "ogstun1:10.45.0.0/24" "ogstun2:10.46.0.0/24" "ogstun3:10.47.0.0/24" )
else
  SELECTED="upf_2.yaml"
  TUNNELS=( "ogstun4:10.48.0.0/24" "ogstun5:10.49.0.0/24" "ogstun6:10.50.0.0/24" )
fi

# 1) Configuración del fichero UPF
IP_CORE=10.0.0.239
SRC_FILE="$SRC_DIR/$SELECTED"
DEST="$DST_DIR/$DST_FILE"
copy_and_patch "$SRC_FILE" "$DEST" "$LOCAL_IP" "$IP_CORE"

# 2) Creación de túneles y reglas NAT
for t in "${TUNNELS[@]}"; do
  name=${t%%:*}
  cidr=${t#*:}
  setup_tunnel "$name" "$cidr"
done

log "Despliegue completado exitosamente."


./open5gs/install/bin/open5gs-upfd -l ./logs/log1.txt
