# AlagAlerta — Arquitetura de Soluções (TOGAF / ArchiMate)

> Global Solution 2026/2 · **CitizenTech** · FIAP 2TDS · Compliance, Quality Assurance & Tests

| Arquivo | Conteúdo |
|---|---|
| `AlagAlerta.archi` | modelo no **Archi** com 86 elementos, 112 relações e 5 visões |
| `Documento-Descritivo-AlagAlerta.pdf` / `.html` | nome do projeto, equipe, desafio, público-alvo com estimativas de impacto e fontes, descrição das 4 camadas e justificativas |
| `AlagAlerta-Arquitetura.pdf` | **gerado pelo grupo no Archi** (veja abaixo) |

## Visões do modelo

1. **Arquitetura de Solução AlagAlerta (visão completa)**: as 4 camadas e as relações entre elas
2. **Visão da Arquitetura (Motivação)**: stakeholders, drivers, avaliações, metas, resultados, princípios, restrições e requisitos
3. **Visão de Negócios**: atores, papel, evento, processos, serviços e objetos de negócio
4. **Visão de Sistemas (Aplicação)**: componentes, interfaces, serviços e objetos de dados
5. **Visão de Infraestrutura (Tecnologia)**: dispositivos, nós, software de sistema, redes, equipamentos e artefatos

## Antes de entregar (passo a passo no Archi)

1. Abra o Archi (https://www.archimatetool.com) → **File → Open** → `AlagAlerta.archi`.
2. Abra cada visão e ajuste a posição dos elementos/conexões se quiser melhorar a leitura
   (**Arrange → Layout** ou arrastando). Revise nomes e textos.
3. Rode **Tools → Validate Model** e corrija os avisos que aparecerem.
4. Exporte em alta resolução: **File → Report → HTML** (opcional) e, para o PDF, abra a visão 1 →
   **File → Export → View As Image** (formato **PDF**, escala 200%). Repita para as visões 2 a 5 se quiser uma
   página por camada. Salve como `AlagAlerta-Arquitetura.pdf`.
5. Preencha nomes e RMs no documento descritivo (`.html`), gere o PDF de novo (Ctrl+P → Salvar como PDF) e
   compacte em um `.zip`: documento + `.archi` + PDF do diagrama.

## Diagrama exportado

`AlagAlerta-Diagrama.pdf` reúne as 5 visões exportadas pelo **Archi 5.11** (relatório gerado pela linha de comando
do Archi a partir de `AlagAlerta.archi`). O layout foi ampliado para que todos os rótulos caibam nos elementos.
