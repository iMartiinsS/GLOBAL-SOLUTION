# Roteiro: deploy na Azure + vídeo DevOps

> Tudo pelo **Azure Cloud Shell (Bash)**: portal.azure.com → ícone `>_` no topo → **Bash**.
> Grave em **1080p ou 720p, com narração** (OBS). Tempo total gravado: cerca de 10 a 12 min. Pode cortar as esperas.
> Este fluxo foi ensaiado com Docker local em 19/11: containers healthy, usuário `alagalerta`, `/app`, CRUD com
> 200/201/204, SELECT e persistência após `down`/`up`. Falta executar na Azure.

---

## Parte A: antes de gravar (preparação, 2 min)

Cole no Cloud Shell:

```bash
az account show --query "{assinatura:name, id:id}" -o table
```

Confira se é a assinatura certa (ex.: *Azure for Students*). Se precisar trocar:
`az account set --subscription "<nome ou id>"`.

**Custo:** VM `Standard_B2als_v2` (2 vCPU, 4 GB) em `northcentralus`, cerca de US$ 0,90 por dia. **Não rode o
`03-remover-tudo.sh` antes da avaliação.**

Clone o repositório:

```bash
git clone -b claude/alagalerta-gs-delivery-v0qss0 https://github.com/iMartiinsS/GLOBAL-SOLUTION.git && cd GLOBAL-SOLUTION/alagalerta-api
```

> Se o script falhar com erro de **região ou tamanho não permitido** (comum na Azure for Students), rode antes
> `export LOCATION=eastus` (ou `export VM_SIZE=Standard_B2s_v2`) e execute de novo.

---

## Parte B: gravação

### 1. Abertura (0:00 a 0:40). Luigi

**Tela:** README da API no GitHub, na parte da arquitetura.

> "Oi, eu sou o Luigi, RM 568381, e com o Pedro, RM 567933, a gente fez o AlagAlerta, um sistema de alerta de
> enchente. Neste vídeo eu vou mostrar o deploy da nossa API Java e do banco PostgreSQL em dois containers,
> dentro de uma VM Linux na Azure, criada só com Azure CLI."

### 2. Criar a VM com Azure CLI (0:40 a 3:00)

```bash
cat infra/azure/variaveis.sh
bash infra/azure/01-criar-vm.sh
```

> "Esse script cria o grupo de recursos, a VM Ubuntu 24.04 com IP público e nome DNS, libera a porta 8080 no
> grupo de segurança e já instala o Docker e o Compose dentro da VM pelo run-command."

(Corte a espera. No fim aparecem o **IP** e o **DNS**: `alagalerta-rm568381.northcentralus.cloudapp.azure.com`.)

Mostre que a 5432 **não** está liberada:

```bash
az network nsg rule list -g rg-alagalerta --nsg-name vm-alagalerta-nsg \
  --query "[].{nome:name, porta:destinationPortRange, acesso:access}" -o table
```

> "No NSG só tem a 22, pro SSH, e a 8080, da API. A porta do Postgres não fica exposta na internet."

### 3. Entrar na VM e subir os containers (3:00 a 6:00)

```bash
IP=$(az vm show -d -g rg-alagalerta -n vm-alagalerta --query publicIps -o tsv); echo $IP
ssh azureuser@$IP
```

Dentro da VM:

```bash
git clone -b claude/alagalerta-gs-delivery-v0qss0 https://github.com/iMartiinsS/GLOBAL-SOLUTION.git && cd GLOBAL-SOLUTION/alagalerta-api

cat > .env <<EOF
POSTGRES_DB=alagalerta
POSTGRES_USER=alagalerta
POSTGRES_PASSWORD=$(openssl rand -hex 16)
JWT_SECRET=$(openssl rand -base64 48 | tr -d '\n')
SEED_ENABLED=true
EOF
chmod 600 .env
```

> "Os segredos ficam num arquivo .env criado aqui dentro da VM, gerados aleatoriamente com openssl. Esse arquivo
> não vai pro GitHub."

**Não dê `cat .env` na gravação.**

```bash
cat Dockerfile
cat docker-compose.yml
docker compose up -d --build
```

> "O Dockerfile é multi-stage: compila com Maven e a imagem final só tem o JRE 21. A aplicação roda com um
> usuário sem privilégio, em /app. O compose sobe a API e o Postgres na mesma rede, com volume nomeado,
> variáveis de ambiente e depends_on esperando o banco ficar saudável."

(O build leva de 3 a 5 min. Corte a espera.)

```bash
docker compose ps
```

> "Os dois containers estão rodando em background e healthy."

### 4. Evidências técnicas (6:00 a 8:00)

```bash
docker images | grep alagalerta
docker logs alagalerta-api --tail 20
docker logs alagalerta-db --tail 10
docker exec alagalerta-api sh -c 'whoami && id && pwd && ls -la'
docker exec alagalerta-api env | grep -E 'SPRING_PROFILES_ACTIVE|DB_URL|PORT'
docker volume ls | grep alagalerta
docker network inspect alagalerta-net --format '{{range .Containers}}{{.Name}} {{end}}'
```

> "Aqui os logs da API e do banco. O whoami mostra o usuário alagalerta, que não é root, e o diretório de
> trabalho é /app. Esse é o volume nomeado e os dois containers na mesma rede."

### 5. CRUD pela internet (8:00 a 10:00)

Saia da VM (`exit`) e rode no Cloud Shell, ou numa aba do seu PC, para mostrar que é acesso externo:

```bash
IP=$(az vm show -d -g rg-alagalerta -n vm-alagalerta --query publicIps -o tsv)
curl -s http://$IP:8080/actuator/health; echo
TOKEN=$(curl -s -X POST http://$IP:8080/auth/login -H "Content-Type: application/json" \
  -d '{"email":"admin@alagalerta.com","senha":"Teste@2026"}' | sed -E 's/.*"token":"([^"]+)".*/\1/')

# CREATE
curl -s -X POST http://$IP:8080/api/regioes -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nome":"Vila Azure","cidade":"São Paulo","uf":"SP","populacaoRisco":5000}'; echo
```

Anote o `"id"` que aparece no fim da resposta e troque `ID=` abaixo:

```bash
ID=5
# READ
curl -s http://$IP:8080/api/regioes/$ID -H "Authorization: Bearer $TOKEN"; echo
# UPDATE
curl -s -X PUT http://$IP:8080/api/regioes/$ID -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nome":"Vila Azure","cidade":"São Paulo","uf":"SP","populacaoRisco":7500}'; echo
# CREATE na tabela relacionada (leitura do sensor gera alerta)
curl -s -X POST http://$IP:8080/api/leituras -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"codigoSensor":"SNS-ROMA-01","nivelAguaCm":170,"chuvaMmHora":60}'; echo
```

Abra no navegador `http://<IP>:8080/swagger-ui.html` e mostre a lista de endpoints (10 s).

> "Criei uma região, consultei, atualizei a população em risco e registrei uma leitura de sensor, que é uma
> tabela relacionada: ela gerou um alerta de emergência pro Jardim Romano."

### 6. SELECT no banco (10:00 a 10:40)

```bash
ssh azureuser@$IP
cd GLOBAL-SOLUTION/alagalerta-api
docker exec -it alagalerta-db psql -U alagalerta -d alagalerta -c '\dt'
docker exec -it alagalerta-db psql -U alagalerta -d alagalerta -c "SELECT * FROM tb_regiao WHERE nome='Vila Azure';"
docker exec -it alagalerta-db psql -U alagalerta -d alagalerta -c \
 "SELECT r.nome, s.codigo, l.nivel_agua_cm, l.nivel_risco FROM tb_leitura l JOIN tb_sensor s ON s.id=l.sensor_id JOIN tb_regiao r ON r.id=s.regiao_id ORDER BY l.data_hora DESC LIMIT 5;"
```

> "No banco aparece a Vila Azure com 7500, que foi o UPDATE, e a leitura que acabei de mandar."

### 7. Persistência + DELETE (10:40 a 11:40)

```bash
docker compose restart
docker compose down && docker compose up -d
sleep 40; docker compose ps
docker exec -it alagalerta-db psql -U alagalerta -d alagalerta -c "SELECT id, nome, populacao_risco FROM tb_regiao WHERE nome='Vila Azure';"
```

> "Reiniciei e até derrubei os containers. Como o banco usa volume nomeado, a Vila Azure continua lá."

Agora o DELETE (no próprio SSH):

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" \
  -d '{"email":"admin@alagalerta.com","senha":"Teste@2026"}' | sed -E 's/.*"token":"([^"]+)".*/\1/')
curl -s -o /dev/null -w "DELETE -> %{http_code}\n" -X DELETE http://localhost:8080/api/regioes/<ID> -H "Authorization: Bearer $TOKEN"
docker exec -it alagalerta-db psql -U alagalerta -d alagalerta -c "SELECT COUNT(*) FROM tb_regiao WHERE nome='Vila Azure';"
```

> "Por fim o DELETE: deu 204 e o SELECT confirma que a linha saiu do banco. Fechamos o CRUD completo."

### 8. Fechamento (11:40 a 12:00)

> "É isso: VM criada por Azure CLI, Docker e Compose na VM, API e banco em containers com usuário sem
> privilégio, volume e rede, CRUD funcionando pela internet e os dados persistindo. Valeu!"

---

## Depois de gravar

1. Suba no YouTube como **Não listado** e me mande o link.
2. Me mande também o **IP/DNS** da VM. Ele vai para o APK e para o `devops.md`.
3. **Deixe a VM ligada** até a avaliação.
