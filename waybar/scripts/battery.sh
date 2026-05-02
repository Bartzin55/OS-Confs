#!/bin/bash

cap=$(cat /sys/class/power_supply/BAT0/capacity)
stat=$(cat /sys/class/power_supply/BAT0/status) # Charging / Discharging
profile=$(powerprofilesctl get)

if [ "$stat" = "Charging" ]; then
    if [ "$cap" -gt 90 ]; then icon="󰂅";
    elif [ "$cap" -gt 70 ]; then icon="󰂊";
    elif [ "$cap" -gt 50 ]; then icon="󰂉";
    elif [ "$cap" -gt 30 ]; then icon="󰂈";
    elif [ "$cap" -gt 10 ]; then icon="󰂆";
    else icon="󰢟"; fi
else
    if [ "$cap" -gt 90 ]; then icon="󰁹";
    elif [ "$cap" -gt 80 ]; then icon="󰂁";
    elif [ "$cap" -gt 60 ]; then icon="󰁾";
    elif [ "$cap" -gt 40 ]; then icon="󰁼";
    elif [ "$cap" -gt 20 ]; then icon="󰁺";
    else icon="󱃍"; fi
fi

class="normal"
[ "$cap" -le 20 ] && class="warning"
[ "$cap" -le 10 ] && class="critical"
[ "$stat" = "Charging" ] && class="charging"

# Output em JSON para a Waybar
echo "{\"text\": \"$icon\", \"tooltip\": \"Bateria: $cap%\nStatus: $stat\nPerfil: $profile\", \"class\": \"$class\"}"
