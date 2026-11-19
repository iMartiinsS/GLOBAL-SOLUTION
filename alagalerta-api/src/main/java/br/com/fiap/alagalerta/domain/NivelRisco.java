package br.com.fiap.alagalerta.domain;

/**
 * Escala de risco usada nos alertas, do menor para o maior.
 */
public enum NivelRisco {
    NORMAL,
    ATENCAO,
    ALERTA,
    EMERGENCIA;

    public boolean maiorQue(NivelRisco outro) {
        return this.ordinal() > outro.ordinal();
    }
}
