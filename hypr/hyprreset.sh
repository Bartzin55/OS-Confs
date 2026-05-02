#!/bin/bash


killall .waybar-wrapped waybar 2>/dev/null
killall hyprpaper 2>/dev/null
killall mako 2>/dev/null
killall hypridle 2>/dev/null
killall hyprlock 2>/dev/null
killall udiskie 2>/dev/null

sleep 0.5

hyprpaper & disown
waybar & disown
mako & disown
udiskie -n & disown

hypridle & disown

hyprctl reload

notify-send "Hyprland" "Interface restarted."
