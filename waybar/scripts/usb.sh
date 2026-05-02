#!/bin/bash

# Busca dispositivos montados
devices=$(lsblk -no NAME,MODEL,SIZE,MOUNTPOINT | grep "/run/media/$USER")

if [ -z "$devices" ]; then
    # Se não houver nada, envia JSON vazio para a Waybar ocultar o ícone
    echo "{\"text\": \"\", \"class\": \"empty\"}"
    exit 0
fi

# Formata o texto para o Tooltip
tooltip="Dispositivos Conectados:\n"
while read -r line; do
    # Extrai o modelo (coluna 2) e o tamanho (coluna 3)
    name=$(echo "$line" | awk '{print $2}')
    size=$(echo "$line" | awk '{print $3}')
    tooltip="$tooltip • $name ($size)\n"
done <<< "$devices"

# Remove a última quebra de linha para evitar erro de parse no JSON
tooltip_escaped=$(echo -e "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\": \"\", \"tooltip\": \"$tooltip_escaped\"}"
