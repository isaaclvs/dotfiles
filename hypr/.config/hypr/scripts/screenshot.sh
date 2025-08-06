#!/bin/bash

# Script de screenshots com detecção automática do monitor em foco
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Função para detectar monitor em foco
get_focused_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

case "$1" in
    "focused")
        # Screenshot do monitor que está em foco
        FOCUSED_MONITOR=$(get_focused_monitor)
        FILE="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"
        grim -o "$FOCUSED_MONITOR" "$FILE"
        notify-send "📸 Screenshot" "Monitor em foco ($FOCUSED_MONITOR)\n$FILE" -t 3000 -u low
        ;;
    "area")
        # Área selecionada (funciona em qualquer monitor)
        FILE="$SCREENSHOT_DIR/screenshot-area-$TIMESTAMP.png"
        grim -g "$(slurp)" "$FILE" && \
        notify-send "📸 Screenshot" "Área selecionada salva\n$FILE" -t 3000 -u low
        ;;
    "window")
        # Janela ativa (sempre funciona no monitor correto)
        FILE="$SCREENSHOT_DIR/screenshot-window-$TIMESTAMP.png"
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$FILE"
        notify-send "📸 Screenshot" "Janela ativa salva\n$FILE" -t 3000 -u low
        ;;
    "clipboard")
        # Área para clipboard
        grim -g "$(slurp)" - | wl-copy && \
        notify-send "📋 Screenshot" "Área copiada para clipboard" -t 3000 -u low
        ;;
    "clipboard-focused")
        # Monitor em foco para clipboard
        FOCUSED_MONITOR=$(get_focused_monitor)
        grim -o "$FOCUSED_MONITOR" - | wl-copy
        notify-send "📋 Screenshot" "Monitor em foco ($FOCUSED_MONITOR) copiado" -t 3000 -u low
        ;;
    "all")
        # Todos os monitores (caso especial)
        FILE="$SCREENSHOT_DIR/screenshot-all-$TIMESTAMP.png"
        grim "$FILE"
        notify-send "📸 Screenshot" "Todos os monitores salvos\n$FILE" -t 3000 -u low
        ;;
esac
