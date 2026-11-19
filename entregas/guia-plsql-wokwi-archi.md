# Guias rápidos: PL/SQL, Wokwi e Archi

## 1. PL/SQL no Oracle da FIAP (15 min)

> Testado em 19/11 num **Oracle 23 Free local** (não é o da FIAP): os 8 scripts rodaram sem erro. Saíram 5 tabelas
> (`GS_REGIAO` 10, `GS_SENSOR` 12, `GS_LEITURA` 33, `GS_ALERTA` 11, `GS_OCORRENCIA` 10) e as 2 procedures
> `VALID`. O `01_ddl.sql` só apaga tabelas `GS_*` (filtro por nome na `user_tables`), então não mexe em outras
> tabelas do seu usuário.

1. Abra o **SQL Developer** e conecte em `oracle.fiap.com.br`, porta `1521`, SID `ORCL`, usuário `RM568381`.
2. **Arquivo → Abrir** → `alagalerta-plsql/00_executar_tudo.sql`. Tem que abrir pelo disco, para o `@@` achar os
   outros arquivos.
3. Aperte **F5** (Executar Script). Se o SQL Developer pedir pasta de trabalho ou o SPOOL der `SP2-0606`, pode
   ignorar: o SPOOL é só log extra. Os prints são o que vale.
4. Role a aba **Saída do Script** e tire estes prints (Win + Shift + S), salvando em `alagalerta-plsql/evidencias/`:

| Arquivo | O que aparece no print |
|---|---|
| `01-ddl.png` | "Tabela criada" das 5 tabelas `GS_*` |
| `02-carga.png` | inserts / "linhas inseridas" e a contagem por tabela |
| `03-bloco-anonimo.png` | saída "ANÁLISE DE RISCO - JARDIM PANTANAL" (IF/decisão) |
| `04-repeticao.png` | saída dos laços FOR/WHILE |
| `05-cursor.png` | saída do cursor explícito |
| `06-procedures.png` | "Procedimento criado" para `PRC_REGISTRAR_LEITURA` e `PRC_PRIORIZAR_REGIOES` |
| `07-execucao.png` | cenários das procedures, incluindo os erros esperados ORA-20011/20012 |
| `08-verificacao.png` | tabela final com as 5 contagens + as 2 procedures `VALID` |

5. Me mande os prints (ou só me fale "prints ok") que eu monto o ZIP.

## 2. Wokwi (10 min). O circuito é **Arduino Uno**

1. Entre em **wokwi.com** logado → **+ New Project** → **Arduino Uno**.
2. Na aba `sketch.ino`, apague tudo e cole o conteúdo de `alagalerta-iot/estacao/estacao.ino`.
3. Na aba `diagram.json`, apague tudo e cole `alagalerta-iot/estacao/diagram.json`.
4. Aba **Library Manager** (ícone de livros) → **+** → procure **LiquidCrystal I2C** → adicione.
5. **Save** (dê o nome "AlagAlerta - Estação") e copie o link `https://wokwi.com/projects/...`.
6. Clique em ▶ e teste. Clique no **HC-SR04** para mudar a distância e gire o **potenciômetro** (chuva, 0 a 100 mm/h,
   proporcional ao giro). Tire um print de cada cenário (`evidencias/cenario-N.png`):

| # | Ajuste | Esperado (LCD / LED / buzzer) |
|---|---|---|
| 1 | distância **200**, chuva ~5% | nível 50 cm, **NORMAL**, LED verde |
| 2 | distância **200**, chuva ~35% | **ATENÇÃO**, LED amarelo |
| 3 | distância **160**, chuva ~10% | nível 90, **ATENÇÃO** (pré-alerta) |
| 4 | distância **160**, chuva ~55% | **ALERTA** antes de chegar em 120 cm |
| 5 | distância **130** | ALERTA ≥ 120,0 (já verificado) |
| 6 | distância **60** | nível 190, **EMERGÊNCIA**, LED vermelho, **sirene** |
| 7 | apague o fio do **ECHO** no diagrama e rode | "FALHA SENSOR" no LCD |

7. Me mande o link e o resultado de cada um ("1 ok, 2 ok, …" ou o que apareceu diferente). Eu atualizo a tabela
   do README com o que de fato aconteceu.

## 3. Archi (15 min)

1. Instale o **Archi** (archimatetool.com, grátis) e abra `alagalerta-arquitetura/AlagAlerta.archi`
   (Arquivo → Abrir).
2. Na árvore **Models → Views**, abra cada uma das 5 visões. Se algum elemento estiver sobreposto, arraste para
   arrumar.
3. **Tools → Validate Model**. Erros (vermelho) têm que ser corrigidos. Avisos de "elemento não usado em
   nenhuma view" podem ficar.
4. Para cada visão: abra a view → **File → Export → View As Image…** → formato **PDF** (ou PNG com escala
   **200%**) → salve como `visao-1.pdf` … `visao-5.pdf`.
5. Junte num PDF só: **ilovepdf.com → Juntar PDF**, ou me mande os 5 arquivos que eu junto. Nome final:
   `AlagAlerta-Diagrama.pdf`.
6. Alternativa em um passo: **File → Report → HTML…**, abrir no navegador e imprimir em PDF.
