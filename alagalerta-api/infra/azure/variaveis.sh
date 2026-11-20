#!/usr/bin/env bash
# Variáveis compartilhadas pelos scripts de infraestrutura.
# Azure for Students: a política só permite brazilsouth, eastus, northcentralus, chilecentral e mexicocentral.
# Em 19/11/2026 o B2s estava sem capacidade em brazilsouth/eastus; usamos B2als_v2 em northcentralus.
export RESOURCE_GROUP="${RESOURCE_GROUP:-rg-alagalerta}"
export LOCATION="${LOCATION:-northcentralus}"
export VM_NAME="${VM_NAME:-vm-alagalerta}"
export VM_SIZE="${VM_SIZE:-Standard_B2als_v2}"
export VM_IMAGE="${VM_IMAGE:-Canonical:ubuntu-24_04-lts:server:latest}"
export ADMIN_USER="${ADMIN_USER:-azureuser}"
export API_PORT=8080
# rótulo DNS do IP público: <DNS_LABEL>.<LOCATION>.cloudapp.azure.com
export DNS_LABEL="${DNS_LABEL:-alagalerta-rm568381}"
