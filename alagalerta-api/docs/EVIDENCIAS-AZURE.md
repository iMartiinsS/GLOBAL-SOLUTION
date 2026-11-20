# Evidências do deploy na Azure (20/11/2026, ~01:00–01:15 UTC)

Executado com Azure CLI (assinatura Azure for Students). Saídas copiadas sem edição.

- **API:** http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080
- **Swagger:** http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080/swagger-ui.html
- **Health:** http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080/actuator/health
- **VM:** vm-alagalerta · Ubuntu 24.04 · Standard_B2als_v2 · northcentralus · IP 20.98.40.151

## 1. VM criada (az vm create) e Docker instalado (az vm run-command)
```
ResourceGroup    PowerState    PublicIpAddress    Fqdns                                                  PrivateIpAddress    MacAddress         Location
---------------  ------------  -----------------  -----------------------------------------------------  ------------------  -----------------  --------------
rg-alagalerta    VM running    20.98.40.151       alagalerta-rm568381.northcentralus.cloudapp.azure.com  10.0.0.4            00-0D-3A-3D-88-DA  northcentralus
```

## 2. NSG: só 22 e 8080 (5432 não exposta)
```
Nome               Porta    Acesso    Prioridade
-----------------  -------  --------  ------------
default-allow-ssh  22       Allow     1000
open-port-8080     8080     Allow     1010
```

## 3. Deploy (docker compose up -d --build dentro da VM)
```
NAME             IMAGE                COMMAND                  SERVICE   CREATED          STATUS                    PORTS
alagalerta-api   alagalerta-api:1.0   "sh -c 'exec java $J…"   api       29 seconds ago   Up 18 seconds (healthy)   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
alagalerta-db    postgres:17-alpine   "docker-entrypoint.s…"   db        31 seconds ago   Up 29 seconds (healthy)   127.0.0.1:5432->5432/tcp
usuario: alagalerta  dir: /app
```

## 4. Rotas públicas testadas de fora da Azure
```
== Teste externo (pela internet) da API na VM Azure: http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080 — 2026-11-20 01:12 UTC
GET /actuator/health -> {"groups":["liveness","readiness"],"status":"UP"}
GET /swagger-ui.html -> 200
POST /auth/login (cidadao) -> 200
GET /api/alertas/ativos -> 200
```

## 5. CRUD, SELECT, persistência e usuário não-root (na VM, pelo endereço público)
```
== CRUD pelo endereço público (http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080), 2026-11-20 01:13 UTC
POST /api/regioes -> 201 (id=5)
GET /api/regioes/5 -> 200
PUT /api/regioes/5 -> 200
POST /api/leituras -> "nivelRisco":"EMERGENCIA"
-- SELECT após PUT:
 id |    nome    | populacao_risco 
----+------------+-----------------
  5 | Vila Azure |            7500
(1 row)

      nome       |   codigo    | nivel_agua_cm | nivel_risco 
-----------------+-------------+---------------+-------------
 Jardim Romano   | SNS-ROMA-01 |           170 | EMERGENCIA
 Jardim Pantanal | SNS-PANT-02 |           150 | ATENCAO
 Jardim Pantanal | SNS-PANT-01 |           128 | ALERTA
(3 rows)

-- docker compose restart + down/up:
alagalerta-api Up 20 seconds (healthy)
alagalerta-db Up 31 seconds (healthy)
-- SELECT após reiniciar (persistência):
 id |    nome    | populacao_risco 
----+------------+-----------------
  5 | Vila Azure |            7500
(1 row)

DELETE /api/regioes/5 -> 204
 linhas Vila Azure após DELETE: 0

-- usuário do container da API:
alagalerta
uid=100(alagalerta) gid=101(alagalerta) groups=101(alagalerta)
/app
```
