#!/bin/bash

# Daemon que monitora mudanças de hardware automaticamente (sem intervenção manual)

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

# Função para iniciar o daemon em background
start_daemon() {
    if is_running; then
        log "⚠️  Daemon já está rodando"
        return 1
    fi
    
    # Iniciar em background
    {
        # Salvar PID
        echo $$ > "$PID_FILE"
        
        log "🚀 Iniciando daemon de monitoramento automático"
        
        # Estado anterior dos monitores
        local previous_state=""
        local check_interval=2  # Verificar a cada 2 segundos
        local stabilization_delay=3  # Aguardar 3s após mudança
        
        # Tratamento de sinais para cleanup
        trap 'log "🛑 Daemon interrompido"; rm -f "$PID_FILE"; exit 0' SIGTERM SIGINT
        
        while true; do
            # Verificar se Hyprland ainda está rodando
            if ! pgrep -x "Hyprland" >/dev/null; then
                log "❌ Hyprland não está rodando. Parando daemon."
                break
            fi
            
            # Verificar estado atual dos monitores
            local current_state=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | sort | tr '\n' ',')
            
            # Se houve mudança, executar reconfiguração
            if [[ "$current_state" != "$previous_state" ]] && [[ -n "$current_state" ]]; then
                log "📡 Mudança detectada: '$previous_state' → '$current_state'"
                
                # Aguardar hardware estabilizar
                sleep "$stabilization_delay"
                
                # Executar script de detecção automática
                if [[ -x "$DETECTION_SCRIPT" ]]; then
                    log "🔄 Executando reconfiguração automática..."
                    "$DETECTION_SCRIPT" >> "$LOG_FILE" 2>&1
                    log "✅ Reconfiguração concluída"
                else
                    log "❌ Script de detecção não encontrado: $DETECTION_SCRIPT"
                fi
                
                previous_state="$current_state"
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
        log "✅ Daemon iniciado em background"
        return 0
    else
        log "❌ Falha ao iniciar daemon"
        return 1
    fi
}

# Função para mostrar status
show_status() {
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "✅ Daemon rodando (PID: $pid)"
        echo "📄 Log: $LOG_FILE"
        
        # Mostrar últimas 5 linhas do log
        if [[ -f "$LOG_FILE" ]]; then
            echo ""
            echo "📋 Últimas atividades:"
            tail -5 "$LOG_FILE"
        fi
    else
        echo "❌ Daemon não está rodando"
    fi
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
        sleep 1
        start_daemon
        ;;
    "status") 
        show_status
        ;;
    "")
        # Comportamento padrão: iniciar se não estiver rodando
        if ! is_running; then
            start_daemon
        fi
        ;;
    *)
        echo "🔧 Uso: $0 {start|stop|restart|status}"
        echo ""
        echo "O daemon monitora automaticamente mudanças de hardware"
        echo "e executa reconfiguração sem intervenção manual."
        exit 1
        ;;
esac
