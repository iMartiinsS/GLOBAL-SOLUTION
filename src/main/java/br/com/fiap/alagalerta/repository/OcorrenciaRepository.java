package br.com.fiap.alagalerta.repository;

import br.com.fiap.alagalerta.domain.Ocorrencia;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface OcorrenciaRepository extends JpaRepository<Ocorrencia, Long>, JpaSpecificationExecutor<Ocorrencia> {

    @Override
    @EntityGraph(attributePaths = {"regiao", "autor"})
    Page<Ocorrencia> findAll(Specification<Ocorrencia> spec, Pageable pageable);

    boolean existsByRegiaoId(Long regiaoId);
}
