package br.com.fiap.alagalerta.repository.spec;

import br.com.fiap.alagalerta.domain.Alerta;
import br.com.fiap.alagalerta.domain.NivelRisco;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public final class AlertaSpecs {

    private AlertaSpecs() {
    }

    public static Specification<Alerta> comFiltro(Long regiaoId, NivelRisco nivelMinimo, Boolean ativo) {
        List<Specification<Alerta>> specs = new ArrayList<>();
        if (regiaoId != null) {
            specs.add((root, q, cb) -> cb.equal(root.get("regiao").get("id"), regiaoId));
        }
        if (nivelMinimo != null) {
            List<NivelRisco> aceitos = new ArrayList<>();
            for (NivelRisco n : NivelRisco.values()) {
                if (n.ordinal() >= nivelMinimo.ordinal()) aceitos.add(n);
            }
            specs.add((root, q, cb) -> root.get("nivel").in(aceitos));
        }
        if (ativo != null) {
            specs.add((root, q, cb) -> cb.equal(root.get("ativo"), ativo));
        }
        return Specification.allOf(specs);
    }
}
