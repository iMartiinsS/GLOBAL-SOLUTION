# AlagAlerta - finalizar a entrega

Equipe: Pedro Relich (RM567933) e Luigi Martins (RM568381), turma 2TDSPA.

Prazo conforme o briefing fornecido: 19/11/2026, às 23h55.

## O que já foi adiantado

- Identificação preenchida nos documentos, READMEs e arquivos de entrega.
- Documento descritivo em HTML e PDF atualizado com a equipe.
- Integração Flutter com a API Java: autenticação JWT, regiões, sensores e histórico, alertas ativos e envio de ocorrências.
- Modo independente com mocks continua disponível usando `--dart-define=DEMO_MODE=true`.
- Erros de conexão/autenticação são exibidos; dados simulados não substituem falhas do modo conectado.
- Sete testes Java passaram; cinco testes Flutter passaram, incluindo login e envio/consulta de ocorrência na API real local.
- API .NET compilada com destino net8.0, sem erros. Isso ainda não comprova as migrations no Oracle.
- Gateway Node.js enviou oito leituras à API real local; a última chegou a EMERGENCIA.
- Scripts para iniciar API/app e executar os scripts Oracle em sequência.
- Pitch dividido entre Pedro e Luigi; projeções identificadas como estimativas.
- Código-fonte e históricos Git preservados no pacote.

## 1. Publicar os repositórios

Cada pasta `alagalerta-*` já possui seu repositório Git local. Crie um repositório público correspondente no GitHub, sem inicializar outro README. Dentro de cada pasta:

```powershell
git status
git add .
git commit -m "Finaliza identificacao e preparacao da entrega"
git branch --show-current
git remote add origin https://github.com/SEU-USUARIO/NOME-DO-REPOSITORIO.git
git push -u origin HEAD
```

Use `git remote set-url origin ...` se `origin` já existir. Não publique `.env`, senhas Oracle ou tokens.
O ZIP não inclui esses arquivos locais. Preserve os commits antigos, exigidos nas disciplinas.
Adicione o professor como colaborador do repositório Mobile e confirme o acesso.

## 2. Azure - principal etapa de infraestrutura pendente

Siga `alagalerta-api/docs/DEVOPS.md`, usando Bash no Azure Cloud Shell.
Os scripts criam recursos pagos na assinatura escolhida; confira a assinatura antes de executar.

1. Publique o repositório da API para poder cloná-lo na VM.
2. Execute `infra/azure/01-criar-vm.sh`.
3. Na VM, clone o repositório, copie `.env.example` para `.env` e defina segredos próprios.
4. Execute `docker compose up -d --build` e teste pelo IP público.
5. Grave os containers, logs, usuário, diretório, CRUD, SELECT e persistência após reiniciar.
6. Preencha `entregas/devops.md` com links reais e exporte para PDF.
7. Remova os recursos somente depois de não serem mais necessários à avaliação.

A execução local em H2 não substitui esta etapa. O diagrama inclui propostas de evolução (como MQTT/push); o protótipo do gateway envia HTTP diretamente.

## 3. Oracle - .NET e PL/SQL

São entregas diferentes, usando prefixos de tabelas diferentes.

### .NET

1. Tenha .NET 8 disponível para executar o projeto net8.0.
2. Configure a conexão com sua conta Oracle conforme o README, usando user-secrets.
3. Execute `dotnet tool restore`, `dotnet ef database update` e `dotnet run`.
4. Teste as requisições de `AlagAlerta.Api.http`, mostrando sucesso e erros 400/404.
5. Grave até 5 minutos com o CRUD e as tabelas Oracle.

### PL/SQL

1. Conecte o SQL Developer ao Oracle FIAP.
2. Abra `00_executar_tudo.sql` e execute como script (F5).
3. Atenção: o script 01 recria as cinco tabelas GS_* e remove os dados anteriores delas.
4. Confira a saída do script 08: cinco tabelas com pelo menos dez linhas e as duas procedures VALID, sem erros de compilação.
5. Tire prints das execuções e salve em `alagalerta-plsql/evidencias`.
6. Monte o ZIP da disciplina com SQLs, README, prints e identificação.

O arquivo de log gerado por SPOOL ajuda na revisão, mas os prints ainda precisam ser capturados.

## 4. Conferir IoT e arquitetura nas ferramentas exigidas

- Wokwi: importe os três arquivos de `alagalerta-iot/estacao`, salve o projeto e registre o link. Execute os cenários ainda sem resultado no README e tire prints.
- O teste do gateway já foi executado e documentado; isso não substitui os testes visuais do circuito.
- Archi: abra `alagalerta-arquitetura/AlagAlerta.archi`, confira as cinco visões, valide o modelo e exporte o PDF do diagrama em alta resolução.
- O PDF descritivo já está preenchido. O PDF do diagrama ainda depende da exportação no Archi.
- Monte o ZIP de arquitetura com documento descritivo, `.archi` e PDF do diagrama.

## 5. Android, vídeos e envio

Esta máquina tem Flutter, mas não tem Android SDK instalado nem emulador Android disponível.

1. Em uma máquina com Android SDK e emulador/celular, rode `flutter doctor` e `flutter devices`.
2. Inicie a API com `INICIAR-API.ps1` (porta 18080).
3. No emulador, use `INICIAR-APP.ps1 -Dispositivo emulator-5554`; troque o identificador pelo exibido em `flutter devices`.
4. Para celular físico/nuvem, use `-ApiUrl https://ENDERECO-REAL -Dispositivo ID-DO-CELULAR`.
5. Para o vídeo Mobile independente, pode usar `-Demo`. Para demonstrar integração Java, use o modo conectado.
6. Se a API estiver no HTTP da VM, configure HTTPS ou ajuste explicitamente o domínio/IP permitido em `android/app/src/main/res/xml/network_security_config.xml` antes de gerar o APK conectado.
7. Grave Mobile em emulador/celular, até 5 minutos. A versão web serve para conferência e não atende ao vídeo Mobile.
8. Gere/publice o APK conforme a orientação do professor. Os comandos estão no README do app.
9. Grave o pitch Java usando `PITCH.md`, até 5 minutos; DevOps deve ter narração e resolução de pelo menos 720p.
10. Preencha links reais nos READMEs e arquivos de `entregas`, confira em aba anônima e envie no portal.

## Como começar uma demonstração local

Terminal 1, na raiz do pacote:

```powershell
.\INICIAR-API.ps1
```

Terminal 2, com emulador Android já iniciado:

```powershell
.\INICIAR-APP.ps1 -Dispositivo emulator-5554
```

Login do cidadão de demonstração: `cidadao@alagalerta.com`, senha `Teste@2026`.
Para conferir no navegador: `INICIAR-APP.ps1 -Dispositivo chrome -ApiUrl http://127.0.0.1:18080`.

## Limites da verificação realizada

Não foram executados Azure/Docker, Oracle, Android, nem a validação visual no Archi. Não foram publicados repositórios, vídeos ou APK e não houve envio ao portal.
Nenhuma captura ou registro de execução externa foi inventado. Logs locais comprovam apenas a execução local descrita.
