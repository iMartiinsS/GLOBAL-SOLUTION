#!/usr/bin/env bash
# Executado DENTRO da VM (via az vm run-command no script 01, ou manualmente com sudo).
# Instala Docker Engine, Buildx e o plugin Docker Compose a partir do repositório oficial da Docker.
# $1 = usuário que poderá usar o docker sem sudo (padrão: azureuser)
set -euo pipefail
USUARIO="${1:-azureuser}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ca-certificates curl git

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker
usermod -aG docker "$USUARIO"

docker --version
docker compose version
echo "Docker instalado. O usuário $USUARIO precisa sair e entrar de novo no SSH para usar docker sem sudo."
