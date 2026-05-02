#!/bin/bash

hora=$(date +%H)

if [ "$hora" -ge 18 ] || [ "$hora" -lt 6 ]; then
  is_night=true
else
  is_night=false
fi

weather=$(curl -s "wttr.in/Betim?format=j1")

if [ -z "$weather" ]; then
  echo "{\"text\": \"󰖐\", \"tooltip\": \"Sem conexão\"}"
  exit 1
fi

temp=$(echo "$weather" | jq -r '.current_condition[0].temp_C')
condition_code=$(echo "$weather" | jq -r '.current_condition[0].weatherCode')

desc=$(echo "$weather" | jq -r '.current_condition[0].weatherDesc[0].value')

case $condition_code in
113) # Céu Limpo / Ensolarado
  if [ "$is_night" = true ]; then icon="󰖔"; else icon="󰖙"; fi ;;
116) # Parcialmente Nublado
  if [ "$is_night" = true ]; then icon=""; else icon="󰖕"; fi ;;
119 | 122) # Nublado / Encoberto
  icon="󰖐" ;;
176 | 263 | 266 | 293 | 296 | 299 | 302 | 305 | 308 | 353 | 356 | 359) # Chuva
  if [ "$is_night" = true ]; then icon="󰖔"; else icon="󰖗"; fi ;;
200 | 386 | 389 | 392 | 395) # Tempestade
  icon="" ;;
*)
  icon="󰖐"
  ;;
esac

echo "{\"text\": \"$icon $temp°C\", \"tooltip\": \"Condition: $desc\nSensação: $(echo "$weather" | jq -r '.current_condition[0].FeelsLikeC')°C\nCity: Betim-MG\"}"
