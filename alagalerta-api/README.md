# AlagAlerta API — Java Advanced

> Global Solution 2026/2 · **CitizenTech** · FIAP 2TDS

API REST em Spring Boot que sustenta o **AlagAlerta**, uma CitizenTech de **alerta de enchentes**. Estações IoT
(Arduino + sensor ultrassônico + pluviômetro) instaladas em córregos enviam o **nível da água** e a **chuva**.
A API classifica o risco, gera alertas para quem mora na região e recebe relatos de alagamento feitos pelos
próprios moradores no app mobile.

- **Cidadão beneficiado:** moradores de bairros às margens de córregos que alagam todo verão
  (ex.: Jardim Pantanal, Jardim Romano, Vila Prudente em SP; Centro de Franco da Rocha).
- **Problema:** hoje o morador só descobre a enchente quando a água chega à porta. O AlagAlerta antecipa o
  aviso com dados do próprio córrego e devolve à Defesa Civil a informação que vem da rua.
- **ODS:** 11 (Cidades e comunidades sustentáveis) e 13 (Ação contra a mudança global do clima).

## Integrantes

| Nome | RM | Turma |
|---|---|---|
| Pedro Relich | RM567933 | 2TDSPA |
| Luigi Martins | RM568381 | 2TDSPA |

**Vídeo pitch:** _cole aqui o link do YouTube_

## Tecnologias

Java 21 · Spring Boot 4.0 · Spring Web MVC · Spring Data JPA · Bean Validation · Spring Security (JWT/OAuth2 Resource
Server) · Spring Cache · Spring HATEOAS · Actuator · springdoc-openapi (Swagger) · H2 (padrão) / PostgreSQL (profile `postgres`).

## Como rodar

Pré-requisito: **JDK 21**. Não precisa instalar Maven nem banco (o wrapper baixa o Maven e o padrão é H2 em memória).

```bash
# Windows
mvnw.cmd spring-boot:run
# Linux / macOS
./mvnw spring-boot:run
```

- Swagger UI: http://localhost:8080/swagger-ui.html
- Health: http://localhost:8080/actuator/health
- Console H2: http://localhost:8080/h2-console (JDBC URL `jdbc:h2:mem:alagalerta`, usuário `sa`, sem senha)

Ao subir, a API carrega regiões, sensores, leituras, um alerta ativo e ocorrências de exemplo.

### Variáveis de ambiente

| Variável | Padrão | Uso |
|---|---|---|
| `JWT_SECRET` | _(vazio → chave aleatória por execução)_ | Segredo HS256, mínimo de 32 caracteres. **Defina em produção.** |
| `JWT_EXPIRATION_MINUTES` | `120` | Validade do token |
| `SPRING_PROFILES_ACTIVE` | — | `postgres` para usar PostgreSQL |
| `DB_URL` / `DB_USER` / `DB_PASSWORD` | H2 em memória | Conexão com o banco |
| `CORS_ORIGINS` | `*` | Origens liberadas para o app Mobile |
| `SEED_ENABLED` | `true` | Carga de dados de demonstração |

Nenhuma senha ou chave real fica versionada no repositório.

### Testes

```bash
mvnw.cmd test
```

### Docker / Azure

A API roda com PostgreSQL em dois containers (`Dockerfile` + `docker-compose.yml`) em uma VM provisionada por
Azure CLI. O passo a passo completo está em **[docs/DEVOPS.md](docs/DEVOPS.md)**. Para subir localmente:

```bash
cp .env.example .env   # defina POSTGRES_PASSWORD e JWT_SECRET
docker compose up -d --build
```

## Usuários de teste por papel

Todos com a senha **`Teste@2026`** (somente dados de demonstração):

| Papel | E-mail | Pode |
|---|---|---|
| `CIDADAO` | cidadao@alagalerta.com | ver alertas, regiões, sensores e leituras; registrar e corrigir as próprias ocorrências |
| `AGENTE` | agente@alagalerta.com | tudo do cidadão + emitir/alterar/encerrar alertas, mudar status de ocorrências, enviar leituras |
| `AGENTE` | gateway@alagalerta.com | conta de serviço usada pelo gateway IoT para enviar leituras |
| `ADMIN` | admin@alagalerta.com | tudo + cadastrar/excluir regiões e sensores, ver métricas do Actuator |

Novos moradores se cadastram em `POST /auth/cadastro` e recebem sempre o papel `CIDADAO`.

### Fluxo rápido no Swagger

1. `POST /auth/login` com `{"email":"gateway@alagalerta.com","senha":"Teste@2026"}` → copie o `token`.
2. Clique em **Authorize** e cole o token.
3. `POST /api/leituras` com `{"codigoSensor":"SNS-ROMA-01","nivelAguaCm":170,"chuvaMmHora":60}` → resposta traz
   `nivelRisco: EMERGENCIA` e o link `alerta` gerado.
4. `GET /api/alertas/ativos` (público) mostra o novo alerta para os moradores do Jardim Romano.

## Endpoints

| Método | Rota | Papel |
|---|---|---|
| POST | `/auth/cadastro`, `/auth/login` | público |
| GET | `/api/alertas/ativos` | público (cache) |
| GET | `/api/usuarios/me` | logado |
| GET | `/api/regioes?cidade=&page=&size=&sort=` · `/api/regioes/{id}` | logado |
| POST · PUT · DELETE | `/api/regioes` · `/api/regioes/{id}` | ADMIN |
| GET | `/api/sensores?regiaoId=&status=` · `/api/sensores/{id}` · `/api/sensores/silenciosos?minutos=30` | logado |
| POST · PUT · DELETE | `/api/sensores` · `/api/sensores/{id}` | ADMIN |
| POST | `/api/leituras` | AGENTE, ADMIN |
| GET | `/api/leituras/{id}` · `/api/leituras/sensor/{sensorId}?horas=24` · `/api/leituras/resumo?horas=24` | logado |
| GET | `/api/alertas?regiaoId=&nivelMinimo=&ativo=` · `/api/alertas/{id}` | logado |
| POST · PUT · PATCH `/encerrar` | `/api/alertas` · `/api/alertas/{id}` | AGENTE, ADMIN |
| GET | `/api/ocorrencias?status=&regiaoId=&desde=&ate=&alturaMinimaCm=&texto=` · `/api/ocorrencias/{id}` | logado |
| POST · PUT | `/api/ocorrencias` · `/api/ocorrencias/{id}` | logado (PUT: autor enquanto ABERTA ou agente) |
| PATCH | `/api/ocorrencias/{id}/status` | AGENTE, ADMIN |
| DELETE | `/api/leituras/{id}` · `/api/alertas/{id}` · `/api/ocorrencias/{id}` | ADMIN |

Códigos de resposta: `200` leitura/alteração · `201` + `Location` na criação · `204` exclusão · `400` validação
(com lista de campos) · `401` sem token · `403` papel sem permissão · `404` não encontrado · `409` conflito de
regra/duplicidade · `422` operação inválida para o estado. Todo erro segue o mesmo JSON:

```json
{"timestamp":"...","status":400,"erro":"Bad Request","mensagem":"Dados inválidos","caminho":"/api/regioes",
 "campos":[{"campo":"uf","mensagem":"uf deve ter 2 letras maiúsculas"}]}
```

## Diagrama das entidades

```mermaid
erDiagram
    REGIAO ||--o{ SENSOR : "possui"
    REGIAO ||--o{ ALERTA : "recebe"
    REGIAO ||--o{ OCORRENCIA : "tem"
    REGIAO |o--o{ USUARIO : "mora em"
    SENSOR ||--o{ LEITURA : "envia"
    SENSOR |o--o{ ALERTA : "dispara"
    USUARIO ||--o{ OCORRENCIA : "registra"

    REGIAO { long id PK; string nome; string cidade; string uf; int populacaoRisco }
    SENSOR { long id PK; string codigo UK; string localizacao; double latitude; double longitude; int nivelAlertaCm; int nivelCriticoCm; enum status; datetime ultimaLeituraEm; long regiao_id FK }
    LEITURA { long id PK; double nivelAguaCm; double chuvaMmHora; datetime dataHora; enum nivelRisco; long sensor_id FK }
    ALERTA { long id PK; enum nivel; string mensagem; enum origem; boolean ativo; datetime emitidoEm; datetime encerradoEm; long regiao_id FK; long sensor_id FK }
    OCORRENCIA { long id PK; string descricao; string endereco; int alturaAguaCm; int pessoasAfetadas; enum status; datetime registradaEm; long regiao_id FK; long usuario_id FK }
    USUARIO { long id PK; string nome; string email UK; string senhaHash; enum papel; long regiao_id FK }
```

### Decisões de modelagem (cascade e fetch)

- **Todos os `@ManyToOne` são `LAZY`.** Uma lista de 50 leituras não precisa carregar 50 sensores e 50 regiões.
  Onde a resposta precisa da região/sensor, os repositórios usam `@EntityGraph` ou `join fetch` para trazer tudo
  em **uma** query e evitar o problema N+1.
- **`Regiao → sensores` é `@OneToMany(mappedBy)` sem `cascade`.** Um sensor carrega histórico de leituras e alertas
  que serve de evidência para a Defesa Civil; apagar a região não pode apagar isso em cascata. Por isso a exclusão
  de região com vínculos devolve **409**, e sensor com histórico deve ser marcado como `INATIVO` em vez de excluído.
- **`Alerta.sensor` é opcional:** alertas emitidos manualmente pela Defesa Civil não têm sensor de origem.
- **Senha nunca é gravada:** só o hash BCrypt (`senhaHash`).

## Regra de negócio central

`ClassificadorRisco` transforma cada leitura em nível de risco, usando os limites de cada ponto (cada córrego
transborda em uma altura diferente):

| Nível | Condição |
|---|---|
| `EMERGENCIA` | água ≥ nível crítico do sensor |
| `ALERTA` | água ≥ nível de alerta, **ou** água ≥ 70% do alerta com chuva ≥ 50 mm/h |
| `ATENCAO` | água ≥ 70% do alerta, **ou** chuva ≥ 30 mm/h |
| `NORMAL` | demais casos |

Se o nível for `ATENCAO` ou maior, `AlertaService.emitirAutomatico` cria um alerta para a região. Se já existir
alerta ativo, ele **só é elevado**, nunca rebaixado automaticamente. Quem encerra o alerta é um agente da Defesa
Civil, que confirma em campo que a situação normalizou. Sensor em `MANUTENCAO`/`INATIVO` tem leituras recusadas (422).

## Justificativa das consultas

| Consulta | Tipo | Por quê |
|---|---|---|
| `SensorRepository.findByCodigo` | query method derivado | o gateway IoT identifica a estação pelo código gravado no firmware, não pelo id do banco |
| `RegiaoRepository.findByCidadeIgnoreCase` | query method derivado + paginação | filtro simples por igualdade; o nome do método já descreve a consulta |
| `AlertaRepository.findByAtivoTrueOrderByEmitidoEmDesc` | query method derivado | tela inicial do app: só alertas vigentes, mais recentes primeiro |
| `LeituraRepository.buscarHistorico` | `@Query` JPQL | janela de tempo por sensor para o gráfico do app, com paginação |
| `LeituraRepository.resumoPorRegiao` | `@Query` JPQL com `group by` + projeção em DTO (`select new`) | agregações (`max`, `avg`, `count`) não são expressáveis por nome de método; o DTO evita carregar milhares de entidades só para somar |
| `SensorRepository.buscarSensoresSilenciosos` | `@Query` JPQL com `join fetch` | regra composta (ativo **e** sem dados há N minutos, nulos primeiro) para a equipe de manutenção; o `join fetch` evita N+1 |
| `OcorrenciaSpecs` / `AlertaSpecs` | **Specification** (filtros dinâmicos) | a Defesa Civil combina status, região, período, altura mínima e texto livre em qualquer combinação; com Specification cada filtro preenchido vira um predicado, sem escrever uma query por combinação |

## Justificativa do cache

| Cache | Onde | Por quê | Invalidação |
|---|---|---|---|
| `alertasAtivos` | `AlertaService.listarAtivos()` → `GET /api/alertas/ativos` (público) | é a rota mais acessada: todo morador abre o app quando começa a chover, e o pico de acesso coincide com o pico de risco. Servir do cache protege o banco exatamente no momento crítico | `@CacheEvict(allEntries = true)` em **toda** escrita de alerta (manual, automático via leitura, alteração, encerramento, exclusão) e na alteração de região (o nome da região aparece no alerta) |
| `regioes` | `RegiaoService.buscar(id)` | regiões quase nunca mudam e são referenciadas por todos os outros recursos | `@CacheEvict(key = "#id")` em atualizar e excluir |

Leituras **não** são cacheadas: mudam a cada minuto e o valor delas está em estar atualizado.
Os caches podem ser inspecionados em `GET /actuator/caches` (ADMIN).

## HATEOAS

Cada recurso volta em HAL com `self`, links para os relacionados e para as **ações possíveis no estado atual**.
Por exemplo, um alerta ativo traz `encerrar` e `atualizar`, e um encerrado não traz. Uma ocorrência `ABERTA`
traz `atualizar` e `alterar-status`, e uma `RESOLVIDA` não traz nenhum dos dois. Listagens paginadas trazem
`first`/`prev`/`next`/`last` e o bloco `page`.

## Segurança

- Login gera um JWT HS256 assinado (`NimbusJwtEncoder`) com as claims `sub` (e-mail), `uid`, `nome` e `roles`.
- O Resource Server do Spring Security valida a assinatura e a expiração a cada requisição (stateless, sem sessão).
- A claim `roles` vira `ROLE_CIDADAO`/`ROLE_AGENTE`/`ROLE_ADMIN`. As regras ficam em `SecurityConfig`.
- Senhas com BCrypt. CORS configurável para o app Mobile. Respostas 401/403 no mesmo JSON de erro da API.

## Uso de IA generativa

Este projeto foi desenvolvido com apoio do assistente **Claude (Anthropic)** para gerar a estrutura inicial do
código, sugerir a modelagem e redigir a documentação. Todo o código foi revisado, executado e testado pelo grupo,
que é capaz de explicar cada parte.
