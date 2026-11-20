# Roteiro: vídeo Mobile (até 5 min, com narração, em emulador ou celular)

> **Não pode ser no navegador.** Use o emulador do Android Studio ou um celular Android.
> Validado em 19/11: `flutter analyze` sem nenhum problema, 4 testes ok e o teste integrado (login, alertas,
> sensores, envio e consulta de ocorrência) passou contra a API Java em Docker com PostgreSQL.

## Jeito mais rápido: instalar o APK pronto (sem Android Studio)

1. Pegue o `app-release.apk` na Release `v1.0` do repositório `alagalerta-app` (eu publico quando o repo existir)
   ou na pasta `output/` do backup.
2. **Celular Android:** mande o APK pro celular (Drive/WhatsApp), abra e permita "instalar apps desconhecidos".
3. Grave a tela do celular: Android tem gravador nativo (puxe a barra de cima → **Gravar tela**, com microfone),
   ou espelhe no PC com o **scrcpy** e grave com o OBS.

> O APK aponta para `http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080`. **A VM da Azure precisa
> estar no ar.** Se você criar a VM em outra região, me avise que eu gero o APK de novo.
> Sem a VM, ainda dá pra gravar no **modo demo** (dados locais): `flutter run --dart-define=DEMO_MODE=true`.

## Alternativa: emulador (precisa do Android Studio)

```powershell
flutter doctor
flutter emulators --launch <id>        # ou abra pelo Device Manager do Android Studio
flutter devices
.\INICIAR-APP.ps1 -Dispositivo emulator-5554 -ApiUrl http://alagalerta-rm568381.northcentralus.cloudapp.azure.com:8080
```

## Gravação

| Tempo | Tela | O que fazer | Fala (Luigi) |
|---|---|---|---|
| 0:00–0:20 | Ícone do app | Abrir o AlagAlerta | "Esse é o AlagAlerta, o app de alerta de enchentes da nossa Global Solution. Feito em Flutter e conectado na nossa API Java que tá rodando na Azure." |
| 0:20–0:50 | **Login** | Clicar em Entrar vazio (erros nos campos), errar a senha (AlertDialog), depois `cidadao@alagalerta.com` / `Teste@2026`, mostrar o olhinho da senha | "O login valida os campos. Se a senha tá errada aparece esse aviso. Com o usuário certo ele autentica na API com JWT e mostra o SnackBar de boas-vindas." |
| 0:50–1:30 | **Início** | Mostrar situação do bairro, atalhos e lista de alertas ativos | "Na tela inicial a pessoa vê a situação do bairro dela e os alertas ativos, que vêm direto da API." |
| 1:30–2:10 | **Detalhe do alerta** | Tocar num alerta, marcar itens do checklist (vai para 3/6) | "Quando toca no alerta ele abre o detalhe, recebido por parâmetro, com o que fazer. Esse checklist vai atualizando: documentos, remédios, ponto de encontro." |
| 2:10–2:50 | **Sensores** → **Detalhe** | Filtrar por bairro no ChoiceChip, abrir um sensor, mostrar gráfico e histórico | "Aqui os sensores dos córregos. Dá pra filtrar por bairro, e no detalhe tem o gráfico e o histórico das leituras." |
| 2:50–3:40 | **Reportar alagamento** | Preencher (tentar enviar vazio antes), escolher no dropdown, ligar o Switch, confirmar no AlertDialog | "O morador também pode relatar um alagamento. O formulário valida tudo, pede confirmação e manda pra API." |
| 3:40–4:10 | **Ocorrências** | Mostrar a ocorrência nova na lista, o contador e o filtro por status | "Olha ela aqui na lista, já salva no servidor. O contador mostra quantas ocorrências estão abertas." |
| 4:10–4:35 | **Como se proteger** | Rolar os cards e telefones | "Tem também as orientações de segurança e os telefones de emergência." |
| 4:35–4:55 | **Perfil** | Mexer nos switches, depois Sair | "E no perfil as preferências de notificação e o logout." |
| 4:55–5:00 | — | — | "Esse é o AlagAlerta. Valeu!" |

Depois: YouTube **Não listado** e me mande o link (vai no `entregas/mobile.txt`).
