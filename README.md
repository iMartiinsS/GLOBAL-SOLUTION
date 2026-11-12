# AlagAlerta — App Mobile (Flutter)

> Global Solution 2026/2 · **CitizenTech** · FIAP 2TDS · Mobile Application Development

**AlagAlerta** avisa moradores de bairros às margens de córregos **antes** da água chegar. Sensores IoT medem o nível
do córrego e a chuva; quando o risco sobe, o app mostra o alerta do bairro, orienta como se preparar e permite que o
próprio morador **relate alagamentos** onde ainda não há sensor.

- **Cidadão beneficiado:** famílias que vivem em áreas de risco de enchente (ex.: Jardim Pantanal e Jardim Romano,
  em São Paulo, onde mais de 60 mil pessoas convivem com alagamentos todo verão).
- **Problema resolvido:** hoje o aviso chega tarde ou não chega. O app transforma dados do córrego em alertas
  simples, com cor e instrução clara, e devolve à Defesa Civil a informação que vem da rua.
- **ODS relacionados:** **11** (Cidades e comunidades sustentáveis, meta 11.5: reduzir mortes e pessoas afetadas
  por desastres) e **13** (Ação contra a mudança global do clima, meta 13.1: resiliência a desastres naturais).

## Integrantes

| Nome | RM |
|---|---|
| _Nome completo_ | RM00000 |
| _Nome completo_ | RM00000 |
| _Nome completo_ | RM00000 |

**Vídeo de demonstração:** _cole aqui o link do YouTube (não listado)_

## Telas

| # | Tela | O que demonstra |
|---|---|---|
| 1 | **Login** | `Form` + `GlobalKey<FormState>`, `TextFormField` com validação, `AlertDialog` de erro, `SnackBar` de boas-vindas, mostrar/ocultar senha com `setState` |
| 2 | **Início** | situação do bairro, atalhos em `GridView`, alertas ativos em `ListView`, `Image` (logo) |
| 3 | **Detalhe do alerta** | recebe o `Alerta` por parâmetro; checklist "Itens preparados: 3/6" com `setState` e barra de progresso |
| 4 | **Sensores** | `GridView` com nível de cada córrego; filtro por bairro (`ChoiceChip` + `setState`) |
| 5 | **Detalhe do sensor** | recebe o `Sensor` por parâmetro; gráfico de barras com `Container` e histórico em `ListView` |
| 6 | **Reportar alagamento** | formulário completo com validação, `DropdownButtonFormField`, `Switch`, confirmação em `AlertDialog`; devolve a ocorrência criada com `Navigator.pop` |
| 7 | **Ocorrências** | lista com filtro por status, contador "Ocorrências abertas: N", inclusão e remoção (com desfazer) via `setState` |
| 8 | **Como se proteger** | orientações em `Card` e telefones de emergência em `GridView` |
| 9 | **Perfil** | preferências de notificação com `SwitchListTile`/`DropdownButton` e `setState`; logout |

### Navegação e passagem de parâmetros

- Rotas nomeadas em `main.dart` (`/`, `/home`, `/dicas`).
- Login → Início: `Navigator.pushReplacementNamed(context, '/home', arguments: usuario)`, lido com `ModalRoute.of(context)!.settings.arguments`.
- Alerta e sensor: `Navigator.push(MaterialPageRoute(builder: (_) => AlertaDetalheScreen(alerta: alerta)))`.
- Formulário → lista: `Navigator.pop(context, ocorrencia)` devolve o objeto criado, e a tela anterior faz `setState`.
- Barra inferior (`NavigationBar`) com 4 abas controladas por `setState` no `HomeShell`.

### Identidade visual

Paleta definida em `lib/theme/app_theme.dart`: azul institucional `#0B3D91` (confiança/Defesa Civil), ciano
`#4DD0E1` (água) e uma **escala de risco** fixa usada em todo o app (verde Normal, amarelo Atenção, laranja Alerta,
vermelho Emergência). Cards com cantos de 14 px, espaçamentos de 4/8/16/24 px e o mesmo logotipo em todas as telas.

## Como executar

Pré-requisitos: Flutter 3.x (stable) e um emulador Android/iOS ou dispositivo físico.

```bash
flutter pub get
flutter run
```

Login de teste: **cidadao@alagalerta.com** / **Teste@2026**

Testes de widget:

```bash
flutter test
```

Gerar o APK de release:

```bash
flutter build apk --release
```

O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk`.

Os dados são **mockados** (`lib/data/mock_data.dart`) e espelham a carga de demonstração da API AlagAlerta.
Esta entrega não depende de backend.

## Estrutura

```
lib/
├── main.dart              # MaterialApp, tema e rotas nomeadas
├── theme/app_theme.dart   # cores, espaçamentos e ThemeData
├── models/models.dart     # NivelRisco, Regiao, Sensor, Leitura, Alerta, Ocorrencia, Usuario
├── data/mock_data.dart    # dados mockados
├── utils/formatos.dart    # formatação de datas
├── widgets/               # NivelBadge, NivelAguaBar, AlertaCard
└── screens/               # 9 telas
```

## Uso de IA generativa

Usamos o assistente **Claude (Anthropic)** para gerar a estrutura inicial das telas, sugerir a paleta de cores e
redigir este README. O grupo revisou, executou e ajustou todo o código e é capaz de explicar cada widget e decisão.
