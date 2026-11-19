using System.Text.Json.Serialization;
using AlagAlerta.Api.Data;
using AlagAlerta.Api.Dtos;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// A string de conexão NÃO fica no repositório: vem de user-secrets ou da variável de ambiente
// ConnectionStrings__Oracle (veja o README).
var connectionString = builder.Configuration.GetConnectionString("Oracle");
if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "Connection string 'Oracle' não configurada. Rode: " +
        "dotnet user-secrets set \"ConnectionStrings:Oracle\" \"User Id=RM...;Password=...;Data Source=oracle.fiap.com.br:1521/ORCL\"");
}

builder.Services.AddDbContext<AppDbContext>(options => options.UseOracle(connectionString));

builder.Services
    .AddControllers()
    .AddJsonOptions(o =>
    {
        // aceita e devolve enums como texto: "Ativo", "Manutencao", "Inativo"
        o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
    });

var app = builder.Build();

// Qualquer erro não tratado vira JSON 500, sem expor stack trace.
app.UseExceptionHandler(errorApp => errorApp.Run(async context =>
{
    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
    await context.Response.WriteAsJsonAsync(new ErroResponse(500, "Erro interno ao processar a requisição"));
}));

app.MapGet("/", () => Results.Ok(new
{
    api = "AlagAlerta .NET",
    descricao = "CitizenTech de alerta de enchentes - regiões monitoradas e sensores IoT",
    rotas = new[] { "/api/regioes", "/api/sensores" }
}));

app.MapControllers();

app.Run();
