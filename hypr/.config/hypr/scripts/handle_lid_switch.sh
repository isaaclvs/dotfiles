#!/usr/bin/env sh

output=$(hyprctl monitors)

# Conta quantos monitores estão ativos
monitor_count=$(echo "$output" | grep -c "^Monitor")

# Só desabilita o monitor interno se houver monitor externo
if [ "$monitor_count" -gt 1 ]; then
    hyprctl keyword monitor "eDP-1, disable"
    notify-send "Monitor" "Monitor interno desabilitado (externo detectado)" -i display
else
    notify-send "Monitor" "Monitor interno mantido ativo (único monitor)" -i display
fi
