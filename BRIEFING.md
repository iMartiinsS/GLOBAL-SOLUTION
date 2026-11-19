# Global Solution 2026/2 — CitizenTech (2TDS, turmas de agosto)

Resumo extraído da apresentação oficial (86 slides).

## Geral
- Tema: **CitizenTech** — tecnologia que entrega benefício concreto ao cidadão (cidade, campo, clima/emergências, serviços e direitos).
- Uma única solução serve de base para as 7 disciplinas. Vale 60% da nota do semestre.
- Grupos de até 5. Cadastro dos grupos até **13/11**. Entrega no Portal FIAP até **19/11/2026 23h55** (sem prorrogação).
- Apresentações presenciais **23 a 27/11** (30% da nota de cada disciplina).
- Toda proposta deve deixar claro: cidadão beneficiado, problema, como funciona, tecnologias, ecossistema, como medir impacto. Indicar ODS (2, 3, 4, 9, 10, 11, 13).
- Premiação: nota ≥ 90 em todas as disciplinas e no vídeo pitch de Java.

## .NET — Advanced Business Development
- ASP.NET Core 8 Web API (controllers) + EF Core + Oracle (oracle.fiap.com.br) + Migrations versionadas.
- ≥ 2 entidades relacionadas 1:N; CRUD completo (GET lista, GET id, POST 201, PUT 204, DELETE 204).
- 400 com JSON para inválido, 404 para id inexistente. README (como executar/testar). Vídeo ≤ 5 min mostrando CRUD e tabelas no Oracle.
- Penalidades: não compila/migrations não aplicam −30; senha Oracle versionada ou tabela sem migration −15.
- Pontos: compila/README 20 · modelo 1:N + validações 20 · EF+Oracle+Migrations 25 · CRUD/status 20 · 400/404 10 · README 5.

## Compliance, QA & Tests — Arquitetura TOGAF/ArchiMate
- Diagrama ArchiMate (ferramenta Archi) com camadas Motivação, Negócio, Aplicação, Tecnologia + documento descritivo.
- Documento: nome do projeto, equipe (nome/RM), problema; público-alvo com estimativas de impacto baseadas em dados.
- Entrega: .ZIP com documento, arquivo .archi e PDF em alta resolução do diagrama. Uso obrigatório do Archi.

## DevOps Tools & Cloud Computing
- VM Azure provisionada por Azure CLI (comandos no repo), Docker + Dockerfile + docker-compose.yml na VM.
- ≥ 2 containers: API (Java ou .NET) + banco (volume nomeado, env, porta, ≥ 2 tabelas relacionadas).
- Dockerfile: usuário não-root, WORKDIR, ENV, EXPOSE. Compose: app, banco, network, volume, portas, env, depends_on.
- Evidências: arquitetura macro, containers, logs, exec, usuário, diretórios, CRUD, persistência, SELECT no banco.
- Entregas: GitHub público, vídeo YouTube não listado ≥ 720p com narração, PDF com nome/integrantes/links.
- Somente localhost = nota zero.

## Disruptive Architectures — IoT
- Protótipo com Arduino (sensores/atuadores) + proposta de comunicação em rede (dispositivos, meios, componentes, caminho dos dados).
- Requisitos: problema 10 · protótipo 25 · componentes e fluxo de rede 20 · diagrama de arquitetura 15 · testes/evidências 20 · documentação 10.
- Entrega: somente .txt com RM/nomes + link do GitHub (código, README com diagrama, evidências, limitações).

## Java Advanced
- Spring Boot API REST consumida pelo app Mobile. Obrigatórios: Spring Web, Data JPA, Bean Validation, Security + JWT, Cache, HATEOAS, Actuator, Swagger/OpenAPI.
- Relacionamentos JPA, DTOs, paginação/ordenação; query method + @Query JPQL + Specification/QBE; @RestControllerAdvice;
  @Cacheable/@CacheEvict; links HATEOAS; actuator health/info/metrics; cadastro/login JWT, BCrypt, papéis, CORS.
- README: integrantes, link do pitch, como rodar, usuários de teste por papel, diagrama, justificativa de consultas/cache.
- Penalidades: um único commit −20; senhas reais commitadas −10.
- **Vídeo pitch** ≤ 5 min (problema → solução → demo → modelo de negócio → impacto/ODS).

## Mastering Database — Oracle PL/SQL
- ≥ 4 tabelas relacionadas, ≥ 10 linhas cada. Bloco anônimo (variáveis, SELECT INTO, DBMS_OUTPUT), IF/ELSIF/ELSE,
  laço FOR/WHILE/LOOP, cursor explícito, 2 procedures (uma de operação, uma de consulta/processamento).
- Entregas: scripts .sql, README/PDF (problema, regras, execução, resultados), prints das execuções.

## Mobile — Flutter/Dart
- Primeira versão funcional; dados mockados permitidos. ≥ 5 telas com navegação e passagem de parâmetros.
- Widgets: Scaffold, AppBar, Column, Row, Container, Padding, SizedBox, Card, Image, Icon, ListView, GridView.
- StatefulWidget + setState; Form + GlobalKey<FormState> + TextFormField + SnackBar/AlertDialog.
- Git incremental (commits claros, um idioma). README: solução, cidadão, ODS, **declaração de uso de IA generativa**.
- Vídeo ≤ 5 min narrado em emulador/dispositivo (não navegador). App publicado. Professor como colaborador do repo.
