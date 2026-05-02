#!/bin/bash

# 1. Encontra a interface ativa
iface=$(ip route show default | awk '/default/ {print $5}' | head -n 1)

# Se não tem rota default, procura interface com IP (conectado, mas sem gateway)
if [ -z "$iface" ]; then
    iface=$(ip -o -4 route show scope link | awk '{print $3}' | head -n 1)
fi

# Completamente offline
if [ -z "$iface" ]; then
    echo "{\"text\": \"󰲜\", \"class\": \"disconnected\", \"tooltip\": \"Disconnected\"}"
    exit 0
fi

# 2. Coleta de dados de Rede (L3)
ip_cidr=$(ip -o -f inet addr show dev "$iface" 2>/dev/null | awk '{print $4}' | head -n 1)
gateway=$(ip route show default dev "$iface" 2>/dev/null | awk '/default/ {print $3}' | head -n 1)
[ -z "$gateway" ] && gateway="None"

dnss=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | awk '{print " • " $2}')
[ -z "$dnss" ] && dnss="None"

# 3. Teste de Internet (Ping 8.8.8.8)
if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
    internet=true
    class="Online"
else
    internet=false
    class="no-internet"
fi

# 4. Lógica por tipo de conexão (Cabo vs Wi-Fi)
if [[ "$iface" == w* ]]; then
    # --- WI-FI ---
    iw_info=$(iw dev "$iface" link 2>/dev/null)
        
    ssid=$(echo "$iw_info" | awk -F 'SSID: ' '/SSID:/ {print $2}')
    [ -z "$ssid" ] && ssid="Disconnected"
    
    freq=$(echo "$iw_info" | awk '/freq:/ {print $2}')
    [ -z "$freq" ] && freq="0"
    
    dbm=$(echo "$iw_info" | awk '/signal:/ {print $2}')
    
    # Calcula a potência do sinal em % baseada no dBm (-100 a -50)
	dbm=$(echo "$iw_info" | awk '/signal:/ {print $2}' | sed 's/[^0-9-]*//g')

	# 2. Valida se dbm é um número válido
	if [[ -n "$dbm" && "$dbm" =~ ^-?[0-9]+$ ]]; then
    	# Calcula a potência do sinal em % baseada no dBm (-100 a -50)
    	if [ "$dbm" -ge -50 ]; then 
        	quality=100
    	elif [ "$dbm" -le -100 ]; then 
        	quality=0
    	else 
        	# Cálculo: 2 * (dBm + 100)
        	quality=$(( 2 * (dbm + 100) ))
    	fi
	else
    	quality=0
    	dbm="N/A"
	fi

    # Define os ícones baseados no sinal e na internet
    if [ "$quality" -ge 80 ]; then
        $internet && icon="󰤨 " || icon="󰤩"
    elif [ "$quality" -ge 60 ]; then
        $internet && icon="󰤥 " || icon="󰤦"
    elif [ "$quality" -ge 40 ]; then
        $internet && icon="󰤢 " || icon="󰤣"
    elif [ "$quality" -ge 20 ]; then
        $internet && icon="󰤟 " || icon="󰤠"
    else
        $internet && icon="󰤯 " || icon="󰤫"
    fi

    tooltip="IP/CIDR: $ip_cidr\nGATEWAY: $gateway\nDNSs: $dnss\n\nSSID: $ssid\nSignal: $quality% ($dbm dBm)\nFrequency: $freq MHz"

else
    # --- CABO ---
    if $internet; then
        icon="󰲝"
    else
        icon="󰲚"
    fi
    tooltip="IP/CIDR: $ip_cidr\nGATEWAY: $gateway\nDNSs:\n$dnss\n\nSSID: $ssid\nSIGNAL: $quality% ($dbm dBm)\nFREQ: $freq MHz"
fi

# ... (restante do seu script acima permanece igual)

if [[ "$iface" == w* ]]; then
    # Montagem do Tooltip para Wi-Fi
    # Note o \n logo após DNSs:
    tooltip="IP/CIDR: $ip_cidr\nGATEWAY: $gateway\n----DNSs----\n$dnss\n\nSSID: $ssid\nSinal: $quality% ($dbm dBm)\nFreq: $freq MHz"
else
    # Montagem do Tooltip para Cabo
    tooltip="IP/CIDR: $ip_cidr\nGATEWAY: $gateway\nDNSs:\n$dnss"
fi

# O segredo para o JSON aceitar as quebras de linha do Bash
tooltip_escaped="${tooltip//$'\n'/\\n}"

echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip_escaped\", \"class\": \"$class\"}"
