using System.ComponentModel.DataAnnotations;
using AlagAlerta.Api.Models;

namespace AlagAlerta.Api.Dtos;

public class SensorRequest : IValidatableObject
{
    [Required(ErrorMessage = "codigo é obrigatório")]
    [RegularExpression("^[A-Z0-9-]{3,30}$", ErrorMessage = "codigo deve ter de 3 a 30 caracteres A-Z, 0-9 ou hífen")]
    public string Codigo { get; set; } = string.Empty;

    [Required(ErrorMessage = "localizacao é obrigatória")]
    [StringLength(150, MinimumLength = 5, ErrorMessage = "localizacao deve ter entre 5 e 150 caracteres")]
    public string Localizacao { get; set; } = string.Empty;

    [Range(1, 2000, ErrorMessage = "nivelAlertaCm deve estar entre 1 e 2000")]
    public int NivelAlertaCm { get; set; }

    [Range(1, 2000, ErrorMessage = "nivelCriticoCm deve estar entre 1 e 2000")]
    public int NivelCriticoCm { get; set; }

    [Range(0, 2000, ErrorMessage = "ultimoNivelCm deve estar entre 0 e 2000")]
    public decimal? UltimoNivelCm { get; set; }

    [EnumDataType(typeof(StatusSensor), ErrorMessage = "status deve ser Ativo, Manutencao ou Inativo")]
    public StatusSensor Status { get; set; } = StatusSensor.Ativo;

    [Range(1, int.MaxValue, ErrorMessage = "regiaoId é obrigatório")]
    public int RegiaoId { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (NivelCriticoCm <= NivelAlertaCm)
        {
            yield return new ValidationResult(
                "nivelCriticoCm deve ser maior que nivelAlertaCm",
                new[] { nameof(NivelCriticoCm) });
        }
    }
}

public record SensorResponse(int Id, string Codigo, string Localizacao, int NivelAlertaCm, int NivelCriticoCm,
    decimal? UltimoNivelCm, string Status, string SituacaoAtual, DateTime InstaladoEm, int RegiaoId, string? RegiaoNome)
{
    public static SensorResponse De(Sensor s) =>
        new(s.Id, s.Codigo, s.Localizacao, s.NivelAlertaCm, s.NivelCriticoCm, s.UltimoNivelCm, s.Status.ToString(),
            Situacao(s), s.InstaladoEm, s.RegiaoId, s.Regiao?.Nome);

    /// <summary>Classifica o último nível lido com os limites do próprio sensor.</summary>
    private static string Situacao(Sensor s)
    {
        if (s.UltimoNivelCm is null) return "SEM_DADOS";
        var nivel = s.UltimoNivelCm.Value;
        if (nivel >= s.NivelCriticoCm) return "EMERGENCIA";
        if (nivel >= s.NivelAlertaCm) return "ALERTA";
        if (nivel >= s.NivelAlertaCm * 0.7m) return "ATENCAO";
        return "NORMAL";
    }
}
