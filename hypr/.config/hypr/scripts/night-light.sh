#!/bin/bash

# Script simples para controle da luz noturna com wlsunset
# Localização: ~/.config/hypr/scripts/night-light.sh

# Configurações para Teresina-PI
LATITUDE="-5.0892"
LONGITUDE="-42.8019"
TEMP_NIGHT="4000"    # Temperatura noturna (mínima do wlsunset)
TEMP_DAY="6500"      # Temperatura dia (padrão)

# Verificar se wlsunset está instalado
if ! command -v wlsunset &> /dev/null; then
    notify-send "❌ Erro" "wlsunset não encontrado. Instale com: sudo pacman -S wlsunset" -t 5000
    exit 1
fi

# Função para verificar se wlsunset está rodando
is_running() {
    pgrep wlsunset > /dev/null
}

# Função para parar wlsunset
stop_filter() {
    if is_running; then
        pkill wlsunset
        notify-send "💡 Luz Noturna" "Desativada - Cores normais" -t 2000 -a "wlsunset"
        return 0
    else
        notify-send "💡 Luz Noturna" "Já estava desativada" -t 2000 -a "wlsunset"
        return 1
    fi
}

# Função para iniciar wlsunset (modo automático)
start_auto() {
    if is_running; then
        pkill wlsunset
        sleep 0.5
    fi
    
    # Inicia com automação completa baseada na localização
    wlsunset -l $LATITUDE -L $LONGITUDE &
    
    notify-send "🌙 Luz Noturna" "Modo automático ativado" -t 2000 -a "wlsunset"
}

# Função para iniciar com temperatura fixa
start_fixed() {
    local temp=${1:-$TEMP_NIGHT}
    
    if is_running; then
        pkill wlsunset
        sleep 0.5
    fi
    
    # Inicia com temperatura fixa
    wlsunset -l $LATITUDE -L $LONGITUDE -T $temp &
    
    notify-send "🌙 Luz Noturna" "Temperatura fixa: ${temp}K" -t 2000 -a "wlsunset"
}

# Função para toggle simples
toggle_filter() {
    if is_running; then
        stop_filter
    else
        start_auto
    fi
}

# Função para mostrar status
show_status() {
    if is_running; then
        notify-send "🌙 Luz Noturna" "Ativa - Filtro aplicado" -t 3000 -a "wlsunset"
    else
        notify-send "💡 Luz Noturna" "Inativa - Cores normais" -t 3000 -a "wlsunset"
    fi
}

# Parser de argumentos
case "${1:-toggle}" in
    "on"|"start"|"auto")
        start_auto
        ;;
    "fixed"|"night")
        start_fixed $TEMP_NIGHT
        ;;
    "off"|"stop")
        stop_filter
        ;;
    "toggle")
        toggle_filter
        ;;
    "status")
        show_status
        ;;
    *)
        echo "Uso: $0 {on|off|toggle|fixed|status}"
        echo ""
        echo "Comandos:"
        echo "  on/auto   - Liga modo automático (segue horário solar)"
        echo "  fixed     - Liga com temperatura fixa (4000K)"
        echo "  off/stop  - Desliga filtro"
        echo "  toggle    - Alterna on/off"
        echo "  status    - Mostra status atual"
        exit 1
        ;;
esac
