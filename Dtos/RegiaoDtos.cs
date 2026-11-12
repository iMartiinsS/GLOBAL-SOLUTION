using System.ComponentModel.DataAnnotations;
using AlagAlerta.Api.Models;

namespace AlagAlerta.Api.Dtos;

public class RegiaoRequest
{
    [Required(ErrorMessage = "nome é obrigatório")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "nome deve ter entre 2 e 100 caracteres")]
    public string Nome { get; set; } = string.Empty;

    [Required(ErrorMessage = "cidade é obrigatória")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "cidade deve ter entre 2 e 100 caracteres")]
    public string Cidade { get; set; } = string.Empty;

    [Required(ErrorMessage = "uf é obrigatória")]
    [RegularExpression("^[A-Z]{2}$", ErrorMessage = "uf deve ter 2 letras maiúsculas (ex.: SP)")]
    public string Uf { get; set; } = string.Empty;

    [Range(0, 10_000_000, ErrorMessage = "populacaoRisco deve estar entre 0 e 10.000.000")]
    public int PopulacaoRisco { get; set; }
}

public record RegiaoResponse(int Id, string Nome, string Cidade, string Uf, int PopulacaoRisco,
    DateTime CriadaEm, int TotalSensores)
{
    public static RegiaoResponse De(Regiao r) =>
        new(r.Id, r.Nome, r.Cidade, r.Uf, r.PopulacaoRisco, r.CriadaEm, r.Sensores.Count);
}

/// <summary>Região com a lista de sensores (GET por id).</summary>
public record RegiaoDetalheResponse(int Id, string Nome, string Cidade, string Uf, int PopulacaoRisco,
    DateTime CriadaEm, List<SensorResumo> Sensores)
{
    public static RegiaoDetalheResponse De(Regiao r) =>
        new(r.Id, r.Nome, r.Cidade, r.Uf, r.PopulacaoRisco, r.CriadaEm,
            r.Sensores.OrderBy(s => s.Codigo).Select(SensorResumo.De).ToList());
}

public record SensorResumo(int Id, string Codigo, string Localizacao, string Status, decimal? UltimoNivelCm)
{
    public static SensorResumo De(Sensor s) =>
        new(s.Id, s.Codigo, s.Localizacao, s.Status.ToString(), s.UltimoNivelCm);
}
