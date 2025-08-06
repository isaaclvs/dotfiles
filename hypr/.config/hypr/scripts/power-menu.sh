#!/bin/bash
# Script de power management integrado com wofi e tema Everforest

# Opções do menu
options="⏻ Desligar\n🔄 Reiniciar\n🌙 Suspender\n🔒 Bloquear\n❌ Cancelar"

# Mostrar menu com wofi
chosen=$(echo -e "$options" | wofi \
    --dmenu \
    --prompt "Ações do Sistema" \
    --width 300 \
    --height 200 \
    --cache-file /dev/null \
    --hide-scroll \
    --matching fuzzy \
    --insensitive)

# Executar ação baseada na escolha
case $chosen in
    "⏻ Desligar")
        # Confirmar desligamento
        confirm=$(echo -e "Sim\nNão" | wofi \
            --dmenu \
            --prompt "Confirmar desligamento?" \
            --width 250 \
            --height 100 \
            --cache-file /dev/null)
        
        if [ "$confirm" = "Sim" ]; then
            systemctl poweroff
        fi
        ;;
    "🔄 Reiniciar")
        # Confirmar reinicialização
        confirm=$(echo -e "Sim\nNão" | wofi \
            --dmenu \
            --prompt "Confirmar reinicialização?" \
            --width 250 \
            --height 100 \
            --cache-file /dev/null)
        
        if [ "$confirm" = "Sim" ]; then
            systemctl reboot
        fi
        ;;
    "🌙 Suspender")
        systemctl suspend
        ;;
    "🔒 Bloquear")
        # Se você usar um lock screen, descomente a linha abaixo
        # swaylock -f -c 000000
        
        # Alternativa: apenas suspender
        systemctl suspend
        ;;
    "❌ Cancelar")
        exit 0
        ;;
esac
