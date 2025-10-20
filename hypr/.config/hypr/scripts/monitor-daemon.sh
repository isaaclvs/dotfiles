#!/bin/bash

# Daemon corrigido para monitoramento de mudanças de hardware em tempo real

DAEMON_NAME="hyprland-monitor-daemon"
PID_FILE="/tmp/${DAEMON_NAME}.pid"
LOG_FILE="$HOME/.local/share/hyprland/${DAEMON_NAME}.log"
DETECTION_SCRIPT="$HOME/.config/hypr/scripts/monitor-detection.sh"

# Criar diretório de logs se não existir
mkdir -p "$(dirname "$LOG_FILE")"

# Função de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Função para verificar se o daemon já está rodando
is_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Função para parar o daemon
stop_daemon() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log "🛑 Parando daemon (PID: $pid)"
            kill "$pid"
            rm -f "$PID_FILE"
            return 0
        fi
    fi
    log "ℹ️  Daemon não estava rodando"
    return 1
}

# Função para obter estado detalhado dos monitores
get_monitor_state() {
    # Usar múltiplas fontes para detectar mudanças
    local hyprctl_output=""
    local wlr_outputs=""
    local drm_status=""
    
    # 1. Estado do Hyprland
    if hyprctl_output=$(hyprctl monitors -j 2>/dev/null); then
        echo "HYPR:$(echo "$hyprctl_output" | jq -r 'sort_by(.name) | .[].name' | tr '\n' ',')"
    fi
    
    # 2. Estado do Wayland compositor (wlr-randr se disponível)
    if command -v wlr-randr >/dev/null 2>&1; then
        if wlr_outputs=$(wlr-randr 2>/dev/null | grep -E "^[A-Z]" | awk '{print $1}' | sort); then
            echo "WLR:$(echo "$wlr_outputs" | tr '\n' ',')"
        fi
    fi
    
    # 3. Estado do DRM (kernel level)
    if [[ -d /sys/class/drm ]]; then
        drm_status=$(find /sys/class/drm -name "card*-*" -type d | while read connector; do
            if [[ -f "$connector/status" ]]; then
                local name=$(basename "$connector")
                local status=$(cat "$connector/status" 2>/dev/null)
                echo "$name:$status"
            fi
        done | sort | tr '\n' ',')
        echo "DRM:$drm_status"
    fi
}

# Função para iniciar o daemon em background
start_daemon() {
    if is_running; then
        log "⚠️  Daemon já está rodando"
        return 1
    fi
    
    # Verificar dependências
    if ! command -v jq >/dev/null 2>&1; then
        log "❌ Dependência 'jq' não encontrada. Instale com: sudo pacman -S jq"
        return 1
    fi
    
    # Iniciar em background
    {
        # Salvar PID
        echo $$ > "$PID_FILE"
        
        log "🚀 Iniciando daemon de monitoramento automático (PID: $$)"
        
        # Estado anterior dos monitores
        local previous_state=""
        local check_interval=1  # Verificar a cada 1 segundo para maior responsividade
        local stabilization_delay=2  # Aguardar 2s após mudança
        local consecutive_changes=0
        
        # Tratamento de sinais para cleanup
        trap 'log "🛑 Daemon interrompido"; rm -f "$PID_FILE"; exit 0' SIGTERM SIGINT
        
        # Estado inicial
        previous_state=$(get_monitor_state)
        log "📊 Estado inicial: $previous_state"
        
        while true; do
            # Verificar se Hyprland ainda está rodando
            if ! pgrep -x "Hyprland" >/dev/null; then
                log "❌ Hyprland não está rodando. Parando daemon."
                break
            fi
            
            # Verificar estado atual dos monitores
            local current_state=$(get_monitor_state)
            
            # Se houve mudança, executar reconfiguração
            if [[ "$current_state" != "$previous_state" ]] && [[ -n "$current_state" ]]; then
                consecutive_changes=$((consecutive_changes + 1))
                log "📡 Mudança #$consecutive_changes detectada:"
                log "   Anterior: $previous_state"
                log "   Atual:    $current_state"
                
                # Aguardar hardware estabilizar apenas na primeira mudança
                if [[ $consecutive_changes -eq 1 ]]; then
                    log "⏳ Aguardando estabilização ($stabilization_delay s)..."
                    sleep "$stabilization_delay"
                fi
                
                # Verificar se ainda é uma mudança válida após estabilização
                local final_state=$(get_monitor_state)
                if [[ "$final_state" != "$previous_state" ]]; then
                    log "🔄 Executando reconfiguração automática..."
                    
                    # Executar script de detecção automática
                    if [[ -x "$DETECTION_SCRIPT" ]]; then
                        if "$DETECTION_SCRIPT" >> "$LOG_FILE" 2>&1; then
                            log "✅ Reconfiguração concluída com sucesso"
                        else
                            log "⚠️  Reconfiguração executada com avisos"
                        fi
                    else
                        log "❌ Script de detecção não encontrado ou não executável: $DETECTION_SCRIPT"
                        
                        # Fallback: recarregar configuração do Hyprland
                        log "🔄 Executando fallback: hyprctl reload"
                        hyprctl reload >> "$LOG_FILE" 2>&1
                    fi
                    
                    previous_state="$final_state"
                    consecutive_changes=0
                else
                    log "🔄 Estado estabilizou, ignorando mudança temporária"
                fi
            else
                # Reset contador se não houve mudanças
                if [[ $consecutive_changes -gt 0 ]]; then
                    consecutive_changes=0
                fi
            fi
            
            sleep "$check_interval"
        done
        
        # Cleanup ao sair
        rm -f "$PID_FILE"
        log "🏁 Daemon finalizado"
        
    } &
    
    # Aguardar um momento para verificar se iniciou corretamente
    sleep 1
    if is_running; then
        local pid=$(cat "$PID_FILE")
        log "✅ Daemon iniciado em background (PID: $pid)"
        return 0
    else
        log "❌ Falha ao iniciar daemon"
        return 1
    fi
}

# Função para mostrar status detalhado
show_status() {
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "✅ Daemon rodando (PID: $pid)"
        echo "📄 Log: $LOG_FILE"
        
        # Mostrar estado atual dos monitores
        echo ""
        echo "📊 Estado atual dos monitores:"
        get_monitor_state | while IFS= read -r line; do
            echo "   $line"
        done
        
        # Mostrar últimas 8 linhas do log
        if [[ -f "$LOG_FILE" ]]; then
            echo ""
            echo "📋 Últimas atividades:"
            tail -8 "$LOG_FILE"
        fi
    else
        echo "❌ Daemon não está rodando"
        echo ""
        echo "📊 Estado atual dos monitores (sem daemon):"
        get_monitor_state | while IFS= read -r line; do
            echo "   $line"
        done
    fi
}

# Função para testar detecção manual
test_detection() {
    echo "🧪 Testando detecção de monitores..."
    echo ""
    echo "Estado atual:"
    get_monitor_state
    echo ""
    echo "Aguardando mudanças (Ctrl+C para parar)..."
    
    local previous_state=$(get_monitor_state)
    while true; do
        local current_state=$(get_monitor_state)
        if [[ "$current_state" != "$previous_state" ]]; then
            echo ""
            echo "🔔 MUDANÇA DETECTADA!"
            echo "Anterior: $previous_state"
            echo "Atual:    $current_state"
            echo ""
            previous_state="$current_state"
        fi
        sleep 1
    done
}

# Processamento de comandos
case "$1" in
    "start")
        start_daemon
        ;;
    "stop")
        stop_daemon
        ;;
    "restart")
        stop_daemon
        sleep 2
        start_daemon
        ;;
    "status") 
        show_status
        ;;
    "test")
        test_detection
        ;;
    "debug")
        echo "🔍 Informações de debug:"
        echo ""
        echo "Hyprland rodando: $(pgrep -x Hyprland >/dev/null && echo "✅ SIM" || echo "❌ NÃO")"
        echo "jq disponível: $(command -v jq >/dev/null && echo "✅ SIM" || echo "❌ NÃO")"
        echo "wlr-randr disponível: $(command -v wlr-randr >/dev/null && echo "✅ SIM" || echo "❌ NÃO")"
        echo ""
        echo "Estado atual detalhado:"
        get_monitor_state
        ;;
    "")
        # Comportamento padrão: iniciar se não estiver rodando
        if ! is_running; then
            start_daemon
        else
            show_status
        fi
        ;;
    *)
        echo "🔧 Uso: $0 {start|stop|restart|status|test|debug}"
        echo ""
        echo "Comandos:"
        echo "  start   - Iniciar daemon"
        echo "  stop    - Parar daemon"
        echo "  restart - Reiniciar daemon"
        echo "  status  - Mostrar status e últimas atividades"
        echo "  test    - Testar detecção de mudanças em tempo real"
        echo "  debug   - Mostrar informações de debug"
        echo ""
        echo "O daemon monitora automaticamente mudanças de hardware"
        echo "e executa reconfiguração sem intervenção manual."
        exit 1
        ;;
esac
