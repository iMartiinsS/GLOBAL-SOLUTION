namespace AlagAlerta.Api.Dtos;

/// <summary>Corpo JSON devolvido nos erros 404 e 409.</summary>
public record ErroResponse(int Status, string Mensagem);
