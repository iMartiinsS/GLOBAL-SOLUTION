# Roteiro: .NET no Oracle da FIAP + vídeo (até 5 min)

> Validado em 19/11 num Oracle 23 Free local: `dotnet ef database update` aplicou a migration `CriacaoInicial`
> e as 17 requisições do `AlagAlerta.Api.http` voltaram exatamente com o código esperado
> (201, 200, 204, 400, 404, 409). Falta rodar no Oracle da FIAP.

## Preparação (no seu PC, PowerShell, pasta `alagalerta-dotnet`)

1. Confira o SDK: `dotnet --list-sdks`. Precisa aparecer uma linha `8.0.x`.
   Se não aparecer: `winget install Microsoft.DotNet.SDK.8` e **abra um novo terminal**.
2. Configure a conexão (troque RM e senha; a senha fica só no seu PC, fora do Git):

   ```powershell
   dotnet user-secrets set "ConnectionStrings:Oracle" "User Id=rm568381;Password=SUA_SENHA;Data Source=oracle.fiap.com.br:1521/ORCL"
   dotnet tool restore
   dotnet ef database update
   dotnet run
   ```

   O `database update` deve terminar com `Done.` e o `run` com `Now listening on: http://localhost:5080`.
3. Abra o projeto no **VS Code** com a extensão **REST Client** (ou no Visual Studio/Rider) e abra
   `AlagAlerta.Api.http`. Cada bloco tem um "Send Request" em cima.
4. No **SQL Developer**, conecte no mesmo usuário e deixe aberta a árvore **Tabelas**.

> Se já rodou antes e quer começar limpo: no SQL Developer,
> `DELETE FROM TB_NET_SENSOR; DELETE FROM TB_NET_REGIAO; COMMIT;`. Os IDs não voltam para 1, então ajuste os
> IDs nas requisições 3 a 17 se for preciso.

## Gravação

| Tempo | Tela | O que fazer | Fala (Luigi) |
|---|---|---|---|
| 0:00–0:25 | VS Code | Mostrar `Program.cs`, `Models/Regiao.cs` e `Sensor.cs` | "Essa é a API .NET do AlagAlerta, em ASP.NET Core 8 com Entity Framework e Oracle. Uma região tem vários sensores, uma relação 1 para N." |
| 0:25–0:50 | Terminal | Mostrar a saída do `dotnet ef database update` e o `dotnet run` rodando | "A migration CriacaoInicial criou as tabelas no Oracle da FIAP, e a API tá rodando na 5080." |
| 0:50–1:10 | SQL Developer | Tabelas `TB_NET_REGIAO` e `TB_NET_SENSOR` (aba Colunas) | "Aqui as duas tabelas criadas pela migration, com a chave estrangeira do sensor pra região." |
| 1:10–2:10 | `.http` | Requisições **1 a 4** (POST, 201) e **5 a 8** (GET, 200) | "Cadastro duas regiões e dois sensores, tudo 201 Created. Agora consulto a lista, a região com os sensores dela e o sensor por id, 200 OK." |
| 2:10–2:40 | `.http` | Requisições **9 e 10** (PUT, 204) | "Atualizo o sensor: a água subiu pra 185 centímetros. Retorna 204 No Content." |
| 2:40–3:00 | SQL Developer | `SELECT * FROM TB_NET_SENSOR;` | "E no Oracle o valor já tá lá, 185." |
| 3:00–3:50 | `.http` | Requisições **11 e 12** (400), **13 e 14** (404), **15** (409) | "Agora os erros: dado inválido volta 400 com a mensagem de cada campo; id que não existe, 404; e não dá pra apagar região que ainda tem sensor, 409 Conflict." |
| 3:50–4:20 | `.http` | Requisições **16 e 17** (DELETE, 204) | "Apago o sensor e a região sem sensores, 204." |
| 4:20–4:45 | SQL Developer | `SELECT * FROM TB_NET_REGIAO; SELECT * FROM TB_NET_SENSOR;` | "No banco sobrou só o que não foi excluído. CRUD completo funcionando no Oracle." |
| 4:45–5:00 | — | — | "Esse foi o .NET do AlagAlerta. Valeu!" |

Depois: YouTube **Não listado** e me mande o link (vai no `entregas/dotnet.txt`).
