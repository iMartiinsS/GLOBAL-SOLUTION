#!/usr/bin/env bash
# Provisiona a infraestrutura do AlagAlerta na Azure usando somente Azure CLI.
# Uso (Azure Cloud Shell ou terminal com "az login" feito):
#   bash infra/azure/01-criar-vm.sh
set -euo pipefail
source "$(dirname "$0")/variaveis.sh"

echo ">> 1/5 Grupo de recursos $RESOURCE_GROUP em $LOCATION"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags projeto=alagalerta disciplina=devops gs=2026-2 \
  --output table

echo ">> 2/5 VM $VM_NAME ($VM_IMAGE, $VM_SIZE) com chave SSH"
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$VM_IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --nsg "${VM_NAME}-nsg" \
  --nsg-rule SSH \
  --os-disk-size-gb 30 \
  --output table

echo ">> 3/5 Liberando a porta da API ($API_PORT) no NSG"
az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port "$API_PORT" \
  --priority 1010 \
  --output none

echo ">> 4/5 Instalando Docker Engine + Docker Compose na VM (run-command)"
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts @"$(dirname "$0")/02-instalar-docker.sh" \
  --parameters "$ADMIN_USER" \
  --query "value[0].message" -o tsv

echo ">> 5/5 Pronto"
IP=$(az vm show -d -g "$RESOURCE_GROUP" -n "$VM_NAME" --query publicIps -o tsv)
echo "IP público: $IP"
echo "Acesse:     ssh $ADMIN_USER@$IP"
echo "Depois siga o passo 'Deploy na VM' do README."
