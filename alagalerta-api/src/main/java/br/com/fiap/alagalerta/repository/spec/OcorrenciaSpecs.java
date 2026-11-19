package br.com.fiap.alagalerta.repository.spec;

import br.com.fiap.alagalerta.domain.Ocorrencia;
import br.com.fiap.alagalerta.domain.StatusOcorrencia;
import br.com.fiap.alagalerta.dto.OcorrenciaFiltro;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Filtros dinâmicos com Specification: cada parâmetro preenchido vira um predicado,
 * os vazios são ignorados. Evita escrever uma query para cada combinação de filtros.
 */
public final class OcorrenciaSpecs {

    private OcorrenciaSpecs() {
    }

    public static Specification<Ocorrencia> comFiltro(OcorrenciaFiltro f) {
        List<Specification<Ocorrencia>> specs = new ArrayList<>();
        if (f.status() != null) specs.add(status(f.status()));
        if (f.regiaoId() != null) specs.add(regiao(f.regiaoId()));
        if (f.desde() != null) specs.add(registradaApos(f.desde()));
        if (f.ate() != null) specs.add(registradaAntes(f.ate()));
        if (f.alturaMinimaCm() != null) specs.add(alturaMinima(f.alturaMinimaCm()));
        if (f.texto() != null && !f.texto().isBlank()) specs.add(contemTexto(f.texto()));
        return Specification.allOf(specs);
    }

    static Specification<Ocorrencia> status(StatusOcorrencia status) {
        return (root, query, cb) -> cb.equal(root.get("status"), status);
    }

    static Specification<Ocorrencia> regiao(Long regiaoId) {
        return (root, query, cb) -> cb.equal(root.get("regiao").get("id"), regiaoId);
    }

    static Specification<Ocorrencia> registradaApos(LocalDateTime desde) {
        return (root, query, cb) -> cb.greaterThanOrEqualTo(root.get("registradaEm"), desde);
    }

    static Specification<Ocorrencia> registradaAntes(LocalDateTime ate) {
        return (root, query, cb) -> cb.lessThanOrEqualTo(root.get("registradaEm"), ate);
    }

    static Specification<Ocorrencia> alturaMinima(Integer cm) {
        return (root, query, cb) -> cb.greaterThanOrEqualTo(root.get("alturaAguaCm"), cm);
    }

    static Specification<Ocorrencia> contemTexto(String texto) {
        String like = "%" + texto.toLowerCase() + "%";
        return (root, query, cb) -> cb.or(
                cb.like(cb.lower(root.get("descricao")), like),
                cb.like(cb.lower(root.get("endereco")), like));
    }
}
