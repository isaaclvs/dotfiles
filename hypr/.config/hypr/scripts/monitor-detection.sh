#!/bin/bash

# Script de detecção automática de monitores (sem toggles manuais)

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
LOCK_FILE="/tmp/hyprland_monitor_switch.lock"

# Função para detectar se monitor externo está conectado
has_external_monitor() {
    hyprctl monitors -j | jq -r '.[].name' | grep -q "HDMI-A-1"
}

# Função para atualizar configuração da Waybar
update_waybar_config() {
    local output_monitor="$1"
    
    # Backup do config atual
    cp "$WAYBAR_CONFIG" "$WAYBAR_CONFIG.backup"
    
    # Atualizar output no config da Waybar (mantendo formato de array)
    jq --arg monitor "$output_monitor" '.output = [$monitor]' "$WAYBAR_CONFIG.backup" > "$WAYBAR_CONFIG"
    
    echo "📱 Waybar configurada para output: [$output_monitor]"
}

# Função para configurar modo dual monitor
setup_dual_monitor() {
    echo "🖥️  Configurando modo dual monitor..."
    
    # Configurar monitores no Hyprland
    hyprctl keyword monitor "eDP-1,1366x768@60,0x0,1"
    hyprctl keyword monitor "HDMI-A-1,1920x1080@60,1366x0,1"
    
    # Mover workspaces para monitor principal (externo)
    for i in {1..5}; do
        hyprctl dispatch moveworkspacetomonitor "$i HDMI-A-1" 2>/dev/null
    done
    
    # Atualizar e recarregar Waybar no monitor externo
    update_waybar_config "HDMI-A-1"
    pkill waybar 2>/dev/null
    sleep 1
    waybar &
    
    echo "✅ Modo dual monitor ativado - Waybar no monitor externo"
}

# Função para configurar modo single monitor (notebook)
setup_single_monitor() {
    echo "💻 Configurando modo single monitor (notebook)..."
    
    # Configurar apenas monitor do notebook
    hyprctl keyword monitor "eDP-1,1366x768@60,0x0,1"
    hyprctl keyword monitor "HDMI-A-1,disable"
    
    # Mover todas as workspaces para o monitor do notebook
    for i in {1..5}; do
        hyprctl dispatch moveworkspacetomonitor "$i eDP-1" 2>/dev/null
    done
    
    # Atualizar e recarregar Waybar no monitor do notebook
    update_waybar_config "eDP-1"
    pkill waybar 2>/dev/null
    sleep 1
    waybar &
    
    echo "✅ Modo single monitor ativado - Waybar no notebook"
}

# Função principal de detecção automática
main() {
    # Evitar execuções múltiplas simultâneas
    if [[ -f "$LOCK_FILE" ]]; then
        exit 0
    fi
    
    touch "$LOCK_FILE"
    trap "rm -f $LOCK_FILE" EXIT
    
    echo "🔍 Detectando configuração de monitores..."
    
    # Aguardar um pouco para hardware estabilizar
    sleep 1
    
    if has_external_monitor; then
        echo "🖥️  Monitor externo detectado (HDMI-A-1)"
        setup_dual_monitor
        
        # Notificação de sucesso
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "🖥️ Monitor" "Modo dual ativado - Waybar no monitor externo" -t 3000
        fi
    else
        echo "💻 Apenas monitor interno detectado (eDP-1)"
        setup_single_monitor
        
        # Notificação de sucesso
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "💻 Monitor" "Modo notebook ativado - Waybar no notebook" -t 3000
        fi
    fi
    
    echo "✨ Configuração automática concluída!"
}

# Executar detecção automática
main "$@"
