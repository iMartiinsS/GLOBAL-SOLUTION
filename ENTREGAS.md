# Global Solution 2026/2 — AlagAlerta · Checklist de entrega

**Solução:** AlagAlerta, CitizenTech de alerta de enchentes. Estações IoT medem o nível dos córregos e a chuva, a
API gera alertas por bairro, o app avisa os moradores e recebe relatos, e a Defesa Civil prioriza o atendimento.
ODS 11 e 13.

**Prazos:** cadastro dos grupos até **13/11** · entrega no Portal até **19/11 às 23h55** · apresentações **23 a 27/11**.

## O que está pronto em cada pasta

| Pasta | Disciplina | Situação |
|---|---|---|
| `alagalerta-api/` | **Java Advanced** + **DevOps** | API Spring Boot completa (JWT, papéis, cache, HATEOAS, Actuator, Swagger, Specification, @Query), testada localmente com 40+ chamadas. Dockerfile, docker-compose (API + PostgreSQL) e scripts Azure CLI em `infra/azure`, how-to em `docs/DEVOPS.md` |
| `alagalerta-app/` | **Mobile** | App Flutter com 9 telas, integração REST com a API Java (JWT, alertas, sensores e ocorrências), modo demo opcional; 5 testes aprovados e build web validado em 17/11/2026 |
| `alagalerta-dotnet/` | **.NET** | ASP.NET Core 8 + EF Core Oracle, Regiao 1:N Sensor, Migration `CriacaoInicial`, CRUD com 201/204/400/404/409, arquivo `.http` de testes |
| `alagalerta-plsql/` | **Banco de dados** | 7 scripts: DDL (5 tabelas), carga (≥10 linhas), bloco anônimo + IF, FOR/WHILE, cursor explícito, 2 procedures, execução |
| `alagalerta-iot/` | **IoT** | Sketch Arduino + circuito Wokwi (compilado e executado no Wokwi), gateway Node.js testado contra a API, proposta de rede |
| `alagalerta-arquitetura/` | **Compliance/QA** | Modelo `AlagAlerta.archi` (4 camadas, 5 visões) + documento descritivo com público-alvo e fontes (PDF) |

Cada pasta já é um repositório Git com histórico de commits por etapa e tem um README com o que a disciplina pede.

## O que só o grupo pode fazer

### Para todas as disciplinas
- [ ] **Cadastrar o grupo no portal até 13/11.**
- [x] Preencher **nomes, RMs e turmas** nos READMEs: Pedro Relich (RM567933) e Luigi Martins (RM568381), turma 2TDSPA.
- [ ] **Ler e entender o código**: todas as apresentações têm perguntas individuais sobre ele.
- [ ] Revisar a declaração de **uso de IA generativa** nos READMEs e ajustar à regra que os professores definirem.

### Java Advanced (`alagalerta-api`)
- [ ] Criar o repositório **público** no GitHub e fazer `git push` (o histórico tem 13 commits).
- [ ] Gravar o **vídeo pitch de até 5 min** (roteiro: problema → solução → demo → modelo de negócio → impacto/ODS)
      e colocar o link no README.
- [ ] Entregar o `.txt` com o link do repositório (`entregas/java-advanced.txt`).

### DevOps (mesmo repositório da API)
- [ ] Rodar `bash infra/azure/01-criar-vm.sh` no Azure Cloud Shell, fazer o deploy na VM conforme `docs/DEVOPS.md`
      e **testar na nuvem**. Docker e Azure não estavam disponíveis aqui, então essa parte não foi executada.
- [ ] Gravar o vídeo (≥ 720p, com narração) seguindo o roteiro de evidências do `docs/DEVOPS.md`.
- [ ] Gerar o **PDF** com nome da solução, integrantes, link do GitHub e link do vídeo (modelo em `entregas/devops.md`).
- [ ] Depois da avaliação: `bash infra/azure/03-remover-tudo.sh` para não gastar créditos.

### Mobile (`alagalerta-app`)
- [ ] Repositório **público** no GitHub e **e-mail do professor como colaborador**.
- [ ] Rodar em **emulador Android ou celular** (`flutter run`) e gravar o vídeo narrado de até 5 min (não pode ser no navegador).
- [ ] **Publicar o app** conforme o professor pediu (ex.: `flutter build apk --release` e anexar o APK em um
      Release do GitHub).
- [ ] **Nenhum commit depois do prazo** (−30 pts).
- [ ] `.txt` com nome do grupo, integrantes, link do vídeo e do GitHub (`entregas/mobile.txt`).

### .NET (`alagalerta-dotnet`)
- [ ] Instalar o **.NET 8 SDK** (aqui só havia o .NET 11 RC).
- [ ] `dotnet user-secrets set "ConnectionStrings:Oracle" "..."` com o seu RM/senha → `dotnet tool restore` →
      `dotnet ef database update` → `dotnet run`. Testar com `AlagAlerta.Api.http`. Sem acesso ao Oracle da FIAP,
      o CRUD só foi testado aqui com banco em memória; a migration foi gerada e o SQL conferido.
- [ ] Gravar o vídeo (CRUD + tabelas no Oracle) e entregar o `.txt` (`entregas/dotnet.txt`).

### Banco de dados (`alagalerta-plsql`)
- [ ] Rodar os scripts **01 → 07** no SQL Developer, conectado ao Oracle da FIAP. **Não foram executados aqui**
      (sem Oracle disponível); se aparecer erro, me mande a mensagem.
- [ ] Tirar prints de cada execução e salvar em `evidencias/`.
- [ ] Compactar scripts + README + prints + `.txt` de identificação em um `.zip`.

### IoT (`alagalerta-iot`)
- [ ] Criar o projeto no **Wokwi** com `estacao.ino`, `diagram.json` e a biblioteca LiquidCrystal I2C, **salvar** e
      colocar o link no README.
- [ ] Rodar os cenários 1–7 da tabela de testes, registrar o resultado e salvar os prints em `evidencias/`.
- [ ] Repositório no GitHub e `.txt` com RM/nomes e link (`entregas/iot.txt`).

### Compliance, QA & Tests (`alagalerta-arquitetura`)
- [ ] Abrir `AlagAlerta.archi` no **Archi**, ajustar o layout, validar e **exportar o PDF em alta resolução**
      (passo a passo no README da pasta). O arquivo foi gerado aqui e passou na validação de XML, mas não foi
      aberto no Archi.
- [ ] Preencher a equipe no documento descritivo e gerar o PDF de novo.
- [ ] `.zip` com documento + `.archi` + PDF do diagrama (o identificador vai no próprio documento).

## Usuários de teste (somente dados de demonstração)

Senha de todos: `Teste@2026`. Usuários: `cidadao@`, `agente@`, `gateway@` e `admin@alagalerta.com`.

## Atualização de 17/11/2026

Ver `COMECE-AQUI-LUIGI.md` para o estado atual e as pendências reduzidas. Integração Mobile–Java validada de ponta a ponta, gateway IoT validado contra a API local, sete testes Java aprovados e API .NET compilada. Azure, Oracle, Android e validação no Archi continuam pendentes.
