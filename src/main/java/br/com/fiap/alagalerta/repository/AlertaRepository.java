package br.com.fiap.alagalerta.repository;

import br.com.fiap.alagalerta.domain.Alerta;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.Optional;

public interface AlertaRepository extends JpaRepository<Alerta, Long>, JpaSpecificationExecutor<Alerta> {

    /** Query method derivado: alertas em vigor, mais recentes primeiro (tela inicial do app). */
    @EntityGraph(attributePaths = {"regiao", "sensor"})
    List<Alerta> findByAtivoTrueOrderByEmitidoEmDesc();

    /** Usado pela regra de negócio para não duplicar alerta na mesma região. */
    Optional<Alerta> findFirstByRegiaoIdAndAtivoTrueOrderByEmitidoEmDesc(Long regiaoId);

    @Override
    @EntityGraph(attributePaths = {"regiao", "sensor"})
    Page<Alerta> findAll(org.springframework.data.jpa.domain.Specification<Alerta> spec, Pageable pageable);

    boolean existsByRegiaoId(Long regiaoId);

    boolean existsBySensorId(Long sensorId);
}
