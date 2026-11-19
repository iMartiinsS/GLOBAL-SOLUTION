# Verificação local - 17/11/2026

Equipe: Pedro Relich (RM567933) e Luigi Martins (RM568381), 2TDSPA.

Resultados observados nesta máquina:

| Componente | Verificação | Resultado |
|---|---|---|
| Java | `mvnw.cmd test -q` | 7 testes, 0 falhas e 0 erros |
| Flutter | Testes de widget | 2 aprovados: validação/login de demonstração e senha incorreta |
| Flutter | Cliente REST | 2 aprovados: paginação HAL/JWT e coleção vazia/erro 401 |
| Flutter + Java | Teste contra API HTTP local | 1 aprovado: login, regiões/sensores/alertas, criação e consulta de ocorrência, logout e rejeição de senha errada |
| Flutter | Build web conectado | Compilação aprovada; não equivale ao APK nem ao vídeo Mobile |
| .NET | `dotnet build --no-restore` | Compilação net8.0 aprovada, sem erros ou avisos |
| Gateway IoT | `node gateway.mjs --simular` contra API local | 8 leituras aceitas, classificação de NORMAL a EMERGENCIA |
| Interface web | Login pelo formulário e carregamento real da tela inicial | Requisições 200 para autenticação e dados; alerta EMERGENCIA exibido; nenhum erro JavaScript observado |

As capturas `app-login-web.png` e `app-inicio-web.png` foram produzidas na interface web local. Não são capturas Android e não substituem a gravação Mobile exigida.

Nos testes HTTP locais foi usada a porta 18080, com banco H2 em memória. A porta 8080 estava ocupada nesta máquina.
Não há comprovação de execução Oracle, PostgreSQL/Docker ou Azure neste relatório.
A máquina possui .NET 11 RC como SDK; a compilação do destino net8.0 passou, mas a execução no .NET 8 e no Oracle permanece pendente.

## Saída observada do gateway

```text
[gateway] autenticado como gateway@alagalerta.com
[gateway] SNS-PANT-01 60 cm / 5 mm/h => NORMAL
[gateway] SNS-PANT-01 78 cm / 18 mm/h => NORMAL
[gateway] SNS-PANT-01 95 cm / 34 mm/h => ATENCAO
[gateway] SNS-PANT-01 112 cm / 41 mm/h => ATENCAO
[gateway] SNS-PANT-01 128 cm / 47 mm/h => ALERTA
[gateway] SNS-PANT-01 150 cm / 55 mm/h => ALERTA
[gateway] SNS-PANT-01 172 cm / 62 mm/h => ALERTA
[gateway] SNS-PANT-01 185 cm / 64 mm/h => EMERGENCIA -> ALERTA #1
```

O teste cobre gateway HTTP + regra da API. Os testes físicos/visuais do circuito no Wokwi permanecem separados.

## Reproduzir a integração

Inicie `INICIAR-API.ps1` e, em outro terminal dentro de `alagalerta-app`, execute:

```powershell
flutter test --dart-define=RUN_LIVE_API=true --dart-define=TEST_API_URL=http://127.0.0.1:18080
```

O teste cria uma ocorrência de demonstração. Use o ambiente local com dados de teste.
Ao reiniciar a API no perfil padrão, o banco H2 em memória é recriado.

No caminho com acentos desta máquina, o servidor de análise do Flutter apresentou falha ao interpretar sua mensagem LSP inicial.
A análise foi executada em uma cópia temporária do mesmo código em caminho sem acentos. Consulte `flutter-analyze.txt`.
