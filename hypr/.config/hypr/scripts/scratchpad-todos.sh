#!/bin/bash

# Verificar se já existe Todoist no scratchpad
if hyprctl clients | grep -q "special:todos"; then
    # Se existe, apenas toggle
    hyprctl dispatch togglespecialworkspace todos
else
    # Se não existe, criar nova instância
    brave --new-window --app=https://app.todoist.com/app/today &
    
    # Pegar address da janela (com prefixo 0x)
    WINDOW_ADDRESS=$(hyprctl clients | grep -A15 "Hoje – Todoist" | grep "Window" | awk '{print $2}' | cut -d' ' -f1)
    
    # Mover para scratchpad
    hyprctl dispatch movetoworkspacesilent special:todos,address:0x$WINDOW_ADDRESS
    
    # Mostrar scratchpad
    hyprctl dispatch togglespecialworkspace todos
fi
