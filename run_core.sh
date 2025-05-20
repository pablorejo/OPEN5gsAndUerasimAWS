#!/usr/bin/env bash
./config_files_core.sh


set -euo pipefail

BIN_DIR="./open5gs/install/bin"
PATTERN="$BIN_DIR/open5gs-"
SLEEP=2      # segundos entre los 3 primeros servicios

# --- función común para matar ------------------------------------------------
kill_open5gs() {
    mapfile -t PIDS < <(pgrep -f "$PATTERN") || true

    if [[ ${#PIDS[@]} -eq 0 ]]; then
        echo "› No hay procesos Open5GS ejecutándose"
        return
    fi

    echo "› Deteniendo ${#PIDS[@]} procesos: ${PIDS[*]}"
    kill "${PIDS[@]}"
    sleep 5

    mapfile -t ALIVE < <(pgrep -f "$PATTERN") || true
    if [[ ${#ALIVE[@]} -eq 0 ]]; then
        echo "✓ Todos los procesos Open5GS se han detenido"
    else
        echo "⚠ Persisten ${#ALIVE[@]} procesos, enviando SIGKILL..."
        kill -9 "${ALIVE[@]}"
        echo "✓ Forzados a terminar: ${ALIVE[*]}"
    fi
}

# --- modo “kill-only” ---------------------------------------------------------
if [[ ${1:-} == "-k" ]]; then
    kill_open5gs
    exit 0
fi

# --- lanzar el 5GC ------------------------------------------------------------
echo "▶ Iniciando Open5GS 5GC…"

# Cola de arranque (sleep sólo entre los 3 primeros)
"$BIN_DIR/open5gs-nrfd" &            PIDLIST=("$!") && sleep "$SLEEP"
"$BIN_DIR/open5gs-scpd" &            PIDLIST+=("$!") && sleep "$SLEEP"
"$BIN_DIR/open5gs-amfd" &            PIDLIST+=("$!") && sleep "$SLEEP"
"$BIN_DIR/open5gs-smfd" &            PIDLIST+=("$!")
"$BIN_DIR/open5gs-ausfd" &           PIDLIST+=("$!")
"$BIN_DIR/open5gs-udmd" &            PIDLIST+=("$!")
"$BIN_DIR/open5gs-udrd" &            PIDLIST+=("$!")
"$BIN_DIR/open5gs-pcfd" &            PIDLIST+=("$!")
"$BIN_DIR/open5gs-nssfd" &           PIDLIST+=("$!")
"$BIN_DIR/open5gs-bsfd" &            PIDLIST+=("$!")

echo "✓ Servicios lanzados (PIDs: ${PIDLIST[*]})"
echo "• Pulsa Ctrl+C para detenerlos"

# --- capturar Ctrl+C ----------------------------------------------------------
trap 'echo; echo "⚑ Interrupt recibido → cerrando…"; kill_open5gs; exit 0' INT TERM

# Mantener vivo el script mientras los hijos existan
wait -n "${PIDLIST[@]}"   # termina si uno muere
echo "✗ Algún proceso salió inesperadamente"
kill_open5gs
exit 1
