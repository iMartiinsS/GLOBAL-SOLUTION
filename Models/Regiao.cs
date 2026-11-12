namespace AlagAlerta.Api.Models;

/// <summary>
/// Bairro ou área monitorada pelo AlagAlerta. Uma região tem vários sensores (1:N).
/// </summary>
public class Regiao
{
    public int Id { get; set; }

    public string Nome { get; set; } = string.Empty;

    public string Cidade { get; set; } = string.Empty;

    public string Uf { get; set; } = string.Empty;

    /// <summary>Moradores estimados em área de risco de enchente.</summary>
    public int PopulacaoRisco { get; set; }

    public DateTime CriadaEm { get; set; }

    public List<Sensor> Sensores { get; set; } = new();
}
