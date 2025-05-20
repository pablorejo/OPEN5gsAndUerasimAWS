#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Parámetros: modifica solo si lo necesitas
###############################################################################
SRC_DIR="files/open5gs"                # dónde están los ficheros de origen
DST_DIR="open5gs/install/etc/open5gs"  # destino final

IP_UPF_1="10.0.0.77"
IP_UPF_2="10.0.0.93"

# Primera IP privada que devuelva hostname -I  ➜ válida en la mayoría de casos.
# Cámbiala si tu servidor tiene varias NIC y quieres otra IP.
IP_CORE=$(hostname -I | awk '{print $1}')

###############################################################################
# No hace falta tocar nada a partir de aquí
###############################################################################
echo "Usando IP_CORE = ${IP_CORE}"

mkdir -p "${DST_DIR}"

for FILE in amf.yaml nrf.yaml smf.yaml; do
    SRC_FILE="${SRC_DIR}/${FILE}"
    DST_FILE="${DST_DIR}/${FILE}"

    if [[ ! -f "${SRC_FILE}" ]]; then
        echo "⚠️  No se encuentra ${SRC_FILE}; lo salto."
        continue
    fi

    # Creamos un temporal con las sustituciones
    TMP=$(mktemp)
    sed -e "s|IP_UPF_1|${IP_UPF_1}|g" \
        -e "s|IP_UPF_2|${IP_UPF_2}|g" \
        -e "s|IP_CORE|${IP_CORE}|g" \
        "${SRC_FILE}" > "${TMP}"

    # Copiamos (sobrescribe si ya existe), conservando permisos razonables
    install -m 644 "${TMP}" "${DST_FILE}"
    rm -f "${TMP}"

    echo "✔︎  ${FILE} actualizado y copiado a ${DST_DIR}"
done

echo "🎉  ¡Todo listo!"
