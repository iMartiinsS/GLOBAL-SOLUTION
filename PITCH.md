# Roteiro do vídeo pitch — AlagAlerta (máx. 5 min)

> Java Advanced · Global Solution 2026/2 · vale para a nota e para a **premiação**.
> Estrutura do slide oficial: problema → solução → demonstração → modelo de negócio → impacto.
> Falado em ritmo natural, o texto dá cerca de **4 min 40 s**. Roteiro dividido entre Pedro Relich e Luigi Martins.

---

## 0:00 – 0:45 · O problema (Pedro Relich)

**Na tela:** fotos ou vídeos de ruas alagadas no Jardim Pantanal (use imagens de domínio público ou com crédito) e,
em seguida, o número **8,27 milhões** grande na tela.

> "Fevereiro de 2025. No Jardim Pantanal, zona leste de São Paulo, famílias ficaram ilhadas por dias.
> Muitas descobriram a enchente do mesmo jeito: quando a água já estava dentro de casa.
>
> E não é só lá. Segundo o IBGE e o Cemaden, **8 milhões e 270 mil brasileiros** vivem em áreas de risco de
> inundação e deslizamento.
>
> O alerta oficial existe, mas é genérico: 'chuva forte na zona leste'. Ele não diz **qual córrego está subindo
> agora**, nem **quanto tempo** você tem para sair. E, justamente na tempestade, a energia e a internet caem."

---

## 0:45 – 1:30 · A solução (Luigi Martins)

**Na tela:** o logo do AlagAlerta e, depois, o diagrama da arquitetura (estação → gateway → API → app).

> "Nós criamos o **AlagAlerta**: saiba antes da água chegar.
>
> Instalamos **estações de baixo custo** embaixo das pontes. Um sensor ultrassônico mede o nível do córrego e um
> pluviômetro mede a chuva. A estação classifica o risco na hora e **toca uma sirene no próprio local**, mesmo
> sem internet.
>
> Ao mesmo tempo, a leitura vai para a nossa **API em Java**. Ela gera o alerta **do seu bairro**, e o morador
> recebe no **app** o nível do córrego, o que fazer e quanto tempo tem. O morador também pode **relatar** um
> alagamento onde ainda não existe sensor, e a **Defesa Civil** vê em um ranking qual região atender primeiro."

---

## 1:30 – 3:00 · Demonstração (Pedro Relich conduz, tela gravada)

> Grave a tela **sem cortes**, com a API rodando (local ou na VM Azure). Ensaie antes: 90 segundos passam rápido.

| Tempo | O que mostrar | Fala |
|---|---|---|
| 1:30 | **Wokwi**: a estação rodando. Arraste a distância do HC-SR04 de 200 cm para 60 cm; LED vermelho e sirene acendem | "Esta é a estação. Vou simular o córrego subindo… pronto: **emergência**. Os LEDs e a sirene avisam quem está na rua." |
| 1:50 | **Terminal**: `node gateway.mjs --simular` imprimindo NORMAL → ATENÇÃO → ALERTA → EMERGÊNCIA | "O gateway envia cada leitura para a API, autenticado com **JWT**. Se a internet cair, ele guarda as leituras e reenvia depois." |
| 2:10 | **Swagger** → `GET /api/alertas/ativos`: alerta EMERGÊNCIA no Jardim Pantanal, com os links HATEOAS | "A API classificou o risco e **elevou o alerta automaticamente**. Esta rota é pública e fica em **cache**, porque todo mundo abre o app ao mesmo tempo quando começa a chover." |
| 2:30 | **App** (emulador): tela inicial com "Situação de alerta", toque no alerta e no checklist "Itens preparados: 3/6" | "No app, a Maria vê a situação do bairro dela, abre o alerta e segue o checklist: documentos, remédios, ponto de encontro." |
| 2:45 | **App**: "Reportar alagamento", preencher e enviar, a ocorrência aparece na lista | "E ela relata o que vê na rua. A Defesa Civil recebe o relato e prioriza o atendimento." |

---

## 3:00 – 4:00 · Modelo de negócio (Luigi Martins)

**Na tela:** um slide com três blocos: **Quem paga · Quem participa · Como escala**.

> "**Quem paga** são prefeituras e Defesas Civis, por assinatura: um valor mensal por estação, que inclui a
> plataforma, a manutenção e o app gratuito para o cidadão.
>
> O custo é baixo: cada estação sai por **cerca de 400 reais** em hardware, como estimativa inicial. Um piloto com 10 estações cobre cerca
> de **11 mil moradores** do Jardim Pantanal, com custo estimado de hardware inferior a **50 centavos por morador** da área coberta.
>
> **Quem participa:** escolas e UBS hospedam os gateways no alto do bairro, as lideranças comunitárias ajudam a
> cadastrar os moradores e a Defesa Civil opera o painel.
>
> **Como escala:** o sistema já separa região e sensores. Para entrar em outro bairro ou outra cidade basta
> cadastrar. O mercado são os **872 municípios** que o Cemaden já monitora. Os dados históricos também ajudam a
> prefeitura a decidir onde investir em drenagem."

---

## 4:00 – 5:00 · Impacto e fechamento (Pedro Relich, com os dois aparecendo no final)

**Na tela:** os indicadores e os ícones dos ODS 11 e 13; no fim, o grupo e o logo.

> "Como medimos o impacto? Com três números: **até 2 minutos** entre o córrego atingir o limite e o alerta no
> celular, **80% dos moradores** da área de risco cadastrados e **30% menos tempo** de resposta da Defesa Civil.
>
> Em um cenário simulado, a projeção da subida sugere cerca de **90 minutos de antecedência** antes do nível crítico. É uma estimativa que ainda precisa ser validada em campo.
> Isso é tempo para tirar uma pessoa idosa de casa, salvar documentos e subir os móveis.
>
> O AlagAlerta atende o **ODS 11**, cidades resilientes a desastres, e o **ODS 13**, adaptação à mudança do clima.
>
> A tecnologia que salva vidas numa enchente não precisa ser cara nem complicada. Ela precisa chegar
> **antes da água**. Por isso o AlagAlerta merece vencer."

---

## Checklist de gravação

- [ ] Duração **≤ 5:00**: o que passar disso não é avaliado. Cronometre o ensaio.
- [ ] **Áudio limpo** vale mais que edição: microfone de fone, ambiente silencioso.
- [ ] Demonstração **ao vivo**, não só prints. Deixe API, gateway, Wokwi e emulador abertos antes de gravar.
- [ ] Antes da gravação, reinicie a API (`../INICIAR-API.ps1`, na pasta da API, ou `./INICIAR-API.ps1`, na raiz) para os dados de demonstração voltarem ao estado inicial.
- [ ] Fale com **quem vai usar** a solução, não com o professor.
- [ ] Mostre **todos os integrantes** em algum momento.
- [ ] Use imagens de enchente com **crédito ou licença livre**.
- [ ] Publique no YouTube como **público ou não listado**, teste o link numa **aba anônima** e coloque o link
      no README da API e no `.txt` de entrega.

## Fontes citadas na fala

- IBGE/Cemaden: 8.270.127 pessoas em áreas de risco em 872 municípios (Censo 2010).
- Agência Pública e Jornal de Brasília: moradores ilhados no Jardim Pantanal em fevereiro de 2025.
- Prefeitura de São Paulo (noticiado em 2025): mais de 4.000 famílias em área de risco no Jardim Pantanal.
- Custo, cobertura e antecedência são **estimativas do projeto**; as premissas estão no documento descritivo da
  arquitetura. Se o professor perguntar, apresente-as como estimativas, não como medições.
