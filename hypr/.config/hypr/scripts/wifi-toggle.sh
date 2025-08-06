#!/bin/bash

# Script para ligar/desligar WiFi com notificação
WIFI_STATUS=$(nmcli radio wifi)

if [ "$WIFI_STATUS" = "enabled" ]; then
    # WiFi está ligado, desligar
    nmcli radio wifi off
    notify-send "📶 WiFi" "WiFi desligado" -t 3000 -u low
else
    # WiFi está desligado, ligar
    nmcli radio wifi on
    notify-send "📶 WiFi" "WiFi ligado" -t 3000 -u low
    sleep 2
    # Scan automático após ligar
    nmcli device wifi rescan
fi
