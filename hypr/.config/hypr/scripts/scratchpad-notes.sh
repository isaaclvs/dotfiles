#!/bin/bash

NOTES_DIR="$HOME/Documents/Obsidian/Notes"
TODAY_NOTE="$NOTES_DIR/$(date +'%Y-%m-%d').md"

# Verificar se já existe kitty no scratchpad notes
if hyprctl clients | grep -q "special:notes"; then
    # Se existe, apenas toggle
    hyprctl dispatch togglespecialworkspace notes
else
    # Criar nota do dia se não existir
    if [[ ! -f "$TODAY_NOTE" ]]; then
        cat > "$TODAY_NOTE" << EOF
# $(date +'%Y-%m-%d - %A')

## Notas do Dia


## Links


## Ideias


---
*Criado: $(date +'%Y-%m-%d %H:%M:%S')*
EOF
    fi

    # Abrir kitty com neovim (window rules fazem o resto automaticamente)
    kitty -e nvim "$TODAY_NOTE" +4 &
fi
