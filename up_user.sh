#!/usr/bin/env bash
set -euo pipefail

UE_BIN="UERANSIM/build/nr-ue"
CFG_DIR="files/config"
PATTERN="nr-ue -c ${CFG_DIR}/open5gs-ue"       # solo los nuestros
DEFAULT_N=6

# --- helpers ---------------------------------------------------------------
log()   { printf '\e[32m[%(%T)T OK ]\e[0m %s\n' -1 "$*"; }
warn()  { printf '\e[33m[%(%T)T ?? ]\e[0m %s\n' -1 "$*"; }
err()   { printf '\e[31m[%(%T)T ERR]\e[0m %s\n' -1 "$*" >&2; exit 1; }

require_root() { [[ $EUID -eq 0 ]] || err "Ejecuta con sudo o como root"; }

kill_ues() {
  mapfile -t PIDS < <(pgrep -f "$PATTERN") || true
  (( ${#PIDS[@]} == 0 )) && { warn "No hay nr-ue vivos"; return 0; }

  warn "Deteniendo ${#PIDS[@]} procesos: ${PIDS[*]}"
  kill "${PIDS[@]}"
  sleep 3
  mapfile -t PIDS < <(pgrep -f "$PATTERN") || true
  if (( ${#PIDS[@]} )); then
    warn "Persisten ${PIDS[*]} – SIGKILL"
    kill -9 "${PIDS[@]}"
  fi
  log "UE(s) detenidos"
}

usage() {
  cat <<EOF
Uso: $0 [-h] [-k] [-n NUM]

  -h          esta ayuda
  -k          no arranca nada; mata UEs previos
  -n NUM      número de instancias a lanzar (def: ${DEFAULT_N})
EOF
  exit 0
}

# --- parse args ------------------------------------------------------------
N="$DEFAULT_N"; KILL_ONLY=false
while getopts ":n:kh" opt; do
  case $opt in
    n) N="$OPTARG" ;;
    k) KILL_ONLY=true ;;
    h) usage ;;
    *) err "Opción desconocida";;
  esac
done
shift $((OPTIND-1))

require_root

$KILL_ONLY && { kill_ues; exit 0; }

# --- lanzar ----------------------------------------------------------------
log "Arrancando $N UE(s)…"
PIDLIST=()
for i in $(seq 0 $((N-1))); do
  CFG="$CFG_DIR/open5gs-ue${i}.yaml"
  [[ -f $CFG ]] || err "Falta $CFG"
  log "Arrancando UE $i con $CFG"
  "$UE_BIN" -c "$CFG" &
  PIDLIST+=("$!")
  sleep 0.5         # evita ráfaga de arranque
done
log "PIDs: ${PIDLIST[*]}"
log "Ctrl+C para terminar…"

trap 'echo; warn "Señal recibida, limpiando…"; kill_ues; exit 0' INT TERM

# espera a que uno muera espontáneamente
wait -n "${PIDLIST[@]}" || true
warn "Algún UE terminó inesperadamente"
kill_ues
exit 1