# Roteiro: vídeo pitch Java (até 5 min), Pedro + Luigi

> Baseado no `PITCH.md`, com as falas em tom de conversa. Lendo em ritmo normal dá uns 4 min 30 s.
> **Como gravar a dois:** chamada no Google Meet/Teams gravando a chamada, com quem estiver na demo
> compartilhando a tela. Ou cada um grava sua parte no OBS e vocês juntam no Clipchamp.
> Os dois têm que aparecer pelo menos uma vez (câmera na abertura e no fechamento).

---

### Bloco 1: Problema (0:00–0:45). **Pedro**

**Tela:** foto de rua alagada (com crédito) e depois o número "8,27 milhões" grande.

> "Fevereiro de 2025, Jardim Pantanal, zona leste de São Paulo. Teve família que ficou ilhada por dias. E muita
> gente só percebeu a enchente quando a água já tava dentro de casa.
>
> E não é só lá: pelo IBGE e pelo Cemaden, são mais de 8 milhões de brasileiros morando em área de risco.
>
> Alerta oficial existe, só que é genérico, tipo 'chuva forte na zona leste'. Não fala qual córrego tá subindo
> agora, nem quanto tempo você tem pra sair. E bem na hora da tempestade, cai a luz e a internet."

### Bloco 2: Solução (0:45–1:30). **Luigi**

**Tela:** diagrama da arquitetura (estação → gateway → API → app), do README da API ou do documento descritivo.

> "Por isso a gente criou o AlagAlerta. A ideia é simples: saber antes da água chegar.
>
> A gente coloca estações baratas embaixo das pontes. Um sensor ultrassônico mede o nível do córrego e um
> pluviômetro mede a chuva. A própria estação já calcula o risco e toca uma sirene ali na rua, mesmo sem
> internet.
>
> Ao mesmo tempo, a leitura vai pra nossa API em Java, com Spring Boot. Ela gera o alerta do bairro, e o morador
> recebe no app o nível do córrego e o que fazer. Quem mora num lugar sem sensor pode relatar o alagamento, e a
> Defesa Civil vê um ranking de qual região atender primeiro."

### Bloco 3: Demonstração (1:30–3:00). **Pedro conduz, tela compartilhada**

Deixe tudo aberto antes: Swagger da API (Azure ou local), Wokwi, terminal com o gateway e o app.

| Tempo | Tela | Fala |
|---|---|---|
| 1:30 | **Wokwi:** clicar no sensor ultrassônico e arrastar a distância de 200 para 60 cm | "Essa é a estação simulada. Vou fazer o córrego subir… pronto, emergência. LED vermelho e sirene." |
| 1:50 | **Terminal:** `node gateway.mjs --simular` | "O gateway manda cada leitura pra API, autenticado com JWT. Se a internet cair, ele guarda e reenvia depois." |
| 2:10 | **Swagger:** `GET /api/alertas/ativos` | "A API classificou o risco e subiu o alerta sozinha. Essa rota é pública e tem cache, porque quando começa a chover todo mundo abre o app ao mesmo tempo." |
| 2:30 | **App:** tela inicial → abrir alerta → checklist | "No app, a moradora vê a situação do bairro, abre o alerta e segue o checklist." |
| 2:45 | **App:** Reportar alagamento → enviar | "E ela consegue relatar o que tá vendo na rua. Vai direto pra Defesa Civil." |

> **Se faltar tempo para preparar tudo:** faça só Swagger + app. O Wokwi e o gateway podem virar um print de
> 5 segundos.

### Bloco 4: Modelo de negócio (3:00–4:00). **Luigi**

**Tela:** slide com três blocos: Quem paga · Quem participa · Como escala.

> "Quem paga são as prefeituras e as Defesas Civis, por assinatura: um valor por mês por estação, com plataforma,
> manutenção e o app de graça pro cidadão.
>
> O custo é baixo. Pela nossa estimativa, cada estação sai uns 400 reais de hardware. Um piloto com 10 estações
> cobre uns 11 mil moradores do Jardim Pantanal, menos de 50 centavos por pessoa.
>
> Quem participa: escolas e UBS hospedam os gateways, as lideranças do bairro ajudam a cadastrar os moradores e a
> Defesa Civil opera o painel.
>
> E escala fácil: pra entrar em outro bairro ou outra cidade é só cadastrar região e sensor. O mercado são os 872
> municípios que o Cemaden já monitora."

### Bloco 5: Impacto e fechamento (4:00–4:50). **Pedro, com os dois na câmera no final**

**Tela:** ícones dos ODS 11 e 13; no fim, os dois na câmera.

> "E como a gente mede se funciona? Três metas: no máximo 2 minutos entre o córrego passar do limite e o alerta
> chegar no celular, 80% dos moradores da área de risco cadastrados e 30% menos tempo de resposta da Defesa
> Civil.
>
> Na nossa simulação, a gente estima uns 90 minutos de antecedência antes do nível crítico. Ainda precisa
> validar em campo, mas é tempo pra tirar um idoso de casa e salvar os documentos.
>
> O AlagAlerta atende o ODS 11, cidades resilientes, e o ODS 13, ação climática."

**Luigi (fecha):**

> "A tecnologia que salva vida numa enchente não precisa ser cara. Ela só precisa chegar antes da água.
> Eu sou o Luigi…"

**Pedro:**

> "…e eu sou o Pedro. Valeu!"

---

**Checklist:** cronometre (≤ 5:00), áudio sem barulho, demo ao vivo, os dois aparecem, link **Não listado**
testado numa aba anônima. Os números de custo, cobertura e antecedência são **estimativas**; se perguntarem,
falem que são estimativas.
