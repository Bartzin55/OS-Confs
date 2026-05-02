#!/bin/bash

entries="󰍹  Monitors\n󰘙  Personalization"

# Adicionamos --hide-scroll e ajustamos o modo de interação
selected=$(echo -e "$entries" | wofi --dmenu \
    --prompt "Settings:" \
    --hide-scroll \
    --allow-markup \
    --insensitive \
    --cache-file /dev/null \
    -i)

case $selected in
  *Monitors*)
    nwg-displays ;;
  *Personalization*)
    nwg-look ;;
esac
