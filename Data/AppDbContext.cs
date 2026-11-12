using AlagAlerta.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AlagAlerta.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Regiao> Regioes => Set<Regiao>();

    public DbSet<Sensor> Sensores => Set<Sensor>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Regiao>(e =>
        {
            e.ToTable("TB_NET_REGIAO");
            e.HasKey(r => r.Id);
            e.Property(r => r.Id).HasColumnName("ID_REGIAO");
            e.Property(r => r.Nome).HasColumnName("NM_REGIAO").HasMaxLength(100).IsRequired();
            e.Property(r => r.Cidade).HasColumnName("NM_CIDADE").HasMaxLength(100).IsRequired();
            e.Property(r => r.Uf).HasColumnName("SG_UF").HasMaxLength(2).IsRequired();
            e.Property(r => r.PopulacaoRisco).HasColumnName("QT_POPULACAO_RISCO");
            e.Property(r => r.CriadaEm).HasColumnName("DT_CRIACAO");
            e.HasIndex(r => new { r.Nome, r.Cidade }).IsUnique().HasDatabaseName("UK_NET_REGIAO_NOME_CIDADE");

            // 1:N — uma região possui vários sensores.
            // Restrict: o banco impede apagar região que ainda tenha sensores (a API devolve 409).
            e.HasMany(r => r.Sensores)
                .WithOne(s => s.Regiao)
                .HasForeignKey(s => s.RegiaoId)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("FK_NET_SENSOR_REGIAO");
        });

        modelBuilder.Entity<Sensor>(e =>
        {
            e.ToTable("TB_NET_SENSOR");
            e.HasKey(s => s.Id);
            e.Property(s => s.Id).HasColumnName("ID_SENSOR");
            e.Property(s => s.Codigo).HasColumnName("CD_SENSOR").HasMaxLength(30).IsRequired();
            e.Property(s => s.Localizacao).HasColumnName("DS_LOCALIZACAO").HasMaxLength(150).IsRequired();
            e.Property(s => s.NivelAlertaCm).HasColumnName("NR_NIVEL_ALERTA_CM");
            e.Property(s => s.NivelCriticoCm).HasColumnName("NR_NIVEL_CRITICO_CM");
            e.Property(s => s.UltimoNivelCm).HasColumnName("NR_ULTIMO_NIVEL_CM").HasPrecision(7, 2);
            // enum gravado como texto para a tabela ficar legível em um SELECT
            e.Property(s => s.Status).HasColumnName("ST_SENSOR").HasConversion<string>().HasMaxLength(20);
            e.Property(s => s.InstaladoEm).HasColumnName("DT_INSTALACAO");
            e.Property(s => s.RegiaoId).HasColumnName("ID_REGIAO");
            e.HasIndex(s => s.Codigo).IsUnique().HasDatabaseName("UK_NET_SENSOR_CODIGO");
        });
    }
}
