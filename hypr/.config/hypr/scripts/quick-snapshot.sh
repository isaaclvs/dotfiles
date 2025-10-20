timestamp=$(date +%H%M%S)
description="Manual-$timestamp"

# Tentar criar snapshot
if sudo snapper -c root create -d "$description"; then
    # Sucesso
    notify-send "✅ Snapshot" "Criado: $description" --icon=dialog-information
    echo "✅ Snapshot criado: $description"
else
    # Erro
    notify-send "❌ Erro" "Falha ao criar snapshot" --icon=dialog-error
    echo "❌ Erro ao criar snapshot"
fi
