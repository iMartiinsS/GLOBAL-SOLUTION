#!/usr/bin/env bash
# Variáveis compartilhadas pelos scripts de infraestrutura.
# Ajuste LOCATION se a sua assinatura (Azure for Students) não permitir a região.
export RESOURCE_GROUP="${RESOURCE_GROUP:-rg-alagalerta}"
export LOCATION="${LOCATION:-brazilsouth}"
export VM_NAME="${VM_NAME:-vm-alagalerta}"
export VM_SIZE="${VM_SIZE:-Standard_B2s}"
export VM_IMAGE="${VM_IMAGE:-Ubuntu2404}"
export ADMIN_USER="${ADMIN_USER:-azureuser}"
export API_PORT=8080
# rótulo DNS do IP público: <DNS_LABEL>.<LOCATION>.cloudapp.azure.com
export DNS_LABEL="${DNS_LABEL:-alagalerta-rm568381}"
