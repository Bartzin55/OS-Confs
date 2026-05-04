#!/bin/bash

# 1. Lista dispositivos montados em /run/media de forma "raw" (sem caracteres de árvore)
# O formato 'NAME MOUNTPOINT' facilita a extração posterior
devices=$(lsblk -rno NAME,MOUNTPOINT | grep "/run/media")

if [ -z "$devices" ]; then
    notify-send "USB" "Nenhum dispositivo removível encontrado em /run/media."
    exit 0
fi

# 2. Abre o Wofi
selection=$(echo "$devices" | wofi --dmenu -p "Ejetar dispositivo:" --width 500 --height 250)

if [ -n "$selection" ]; then
    # 3. Extrai apenas o nome do dispositivo (ex: sda1)
    identifier=$(echo "$selection" | awk '{print $1}')
    
    # 4. Tenta ejetar usando o udiskie
    udiskie-umount "/dev/$identifier"
fi
