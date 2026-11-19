namespace AlagAlerta.Api.Models;

/// <summary>
/// Estação IoT instalada em um córrego: mede o nível da água e a chuva.
/// Pertence a uma única região (lado N da relação 1:N).
/// </summary>
public class Sensor
{
    public int Id { get; set; }

    /// <summary>Código gravado no firmware do dispositivo (ex.: SNS-PANT-01).</summary>
    public string Codigo { get; set; } = string.Empty;

    public string Localizacao { get; set; } = string.Empty;

    /// <summary>Nível da água (cm) a partir do qual o bairro entra em ALERTA.</summary>
    public int NivelAlertaCm { get; set; }

    /// <summary>Nível da água (cm) a partir do qual a situação é de EMERGÊNCIA.</summary>
    public int NivelCriticoCm { get; set; }

    /// <summary>Última medição recebida (cm). Nulo enquanto o sensor não enviou dados.</summary>
    public decimal? UltimoNivelCm { get; set; }

    public StatusSensor Status { get; set; } = StatusSensor.Ativo;

    public DateTime InstaladoEm { get; set; }

    public int RegiaoId { get; set; }

    public Regiao? Regiao { get; set; }
}

public enum StatusSensor
{
    Ativo,
    Manutencao,
    Inativo
}
