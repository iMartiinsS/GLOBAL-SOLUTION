#!/usr/bin/env bash
# Remove TODOS os recursos criados (evita consumir créditos depois da avaliação).
set -euo pipefail
source "$(dirname "$0")/variaveis.sh"

echo "Isto vai apagar o grupo de recursos $RESOURCE_GROUP e tudo dentro dele."
read -r -p "Digite o nome do grupo para confirmar: " CONFIRMA
if [ "$CONFIRMA" != "$RESOURCE_GROUP" ]; then
  echo "Cancelado."
  exit 1
fi
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
echo "Exclusão iniciada (leva alguns minutos)."
