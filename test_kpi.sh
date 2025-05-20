#!/usr/bin/env bash
# Script: test_tuneles_iperf.sh
# Descripción: A cada interfaz uesimtun* le asigna un ancho de banda distinto
#              de la lista `bandwidth`, arranca iperf3 en UDP y guarda logs.

set -euo pipefail

# Host y puerto destino de iperf3
DESTINO="51.92.182.86"
PUERTO_INICIAL=3000

# Lista de anchos de banda (uno por interfaz en orden)
bandwidth=('10K' '2M' '10M' '50M' '100M' '200M')

# Directorio de logs
mkdir -p logs

# Contador de puerto
PUERTO=$PUERTO_INICIAL

# Array para almacenar PIDs
pids=()

# Leer todas las interfaces que coincidan y guardarlas en un array
mapfile -t IFACES < <(ls /sys/class/net | grep -E '^uesimtun[0-9]+$' | sort)

# Comprueba que haya ancho de banda para cada interfaz
if (( ${#IFACES[@]} > ${#bandwidth[@]} )); then
  echo "ERROR: Hay más interfaces (${#IFACES[@]}) que anchos de banda (${#bandwidth[@]}) definidos."
  exit 1
fi

# Itera usando índices para emparejar iface ↔ bandwidth
for idx in "${!IFACES[@]}"; do
  IFACE=${IFACES[idx]}
  ANCHO=${bandwidth[idx]}

  # Extrae la IP (sin máscara) de la interfaz
  IP=$(ip -4 -o addr show dev "$IFACE" \
         | awk '{print $4}' \
         | cut -d'/' -f1)

  if [[ -z "$IP" ]]; then
    echo "(!) No se encontró IP para la interfaz $IFACE, saltando…"
    continue
  fi

  echo "=== Probando $IFACE (IP: $IP), BW: $ANCHO, puerto: $PUERTO ==="
  logfile="logs/${IFACE}_${ANCHO}.json"
  iperf3 -B "$IP" -c "$DESTINO" -p "$PUERTO" -b "$ANCHO" -t 10 --json > "$logfile" &
  pids+=($!)
  ((PUERTO++))
  sleep 0.3
  echo
done

# Espera a que todos los iperf3 terminen
for pid in "${pids[@]}"; do
  wait "$pid"
done

echo "Todos los procesos han terminado"
