using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace AlagAlerta.Api.Data;

/// <summary>
/// Usada apenas pelo "dotnet ef". Permite gerar migrations sem conexão com o banco;
/// para aplicar (database update) a string real vem de ConnectionStrings__Oracle ou de user-secrets.
/// </summary>
public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: true)
            .AddUserSecrets<DesignTimeDbContextFactory>(optional: true)
            .AddEnvironmentVariables()
            .Build();

        var connectionString = config.GetConnectionString("Oracle");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            // valor fictício: suficiente para "migrations add", que não abre conexão
            connectionString = "User Id=design;Password=design;Data Source=localhost:1521/ORCL";
        }

        var options = new DbContextOptionsBuilder<AppDbContext>().UseOracle(connectionString).Options;
        return new AppDbContext(options);
    }
}
