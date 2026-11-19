package br.com.fiap.alagalerta.repository;

import br.com.fiap.alagalerta.domain.Regiao;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RegiaoRepository extends JpaRepository<Regiao, Long> {

    /** Query method derivado: regiões de uma cidade, ignorando maiúsculas/minúsculas. */
    Page<Regiao> findByCidadeIgnoreCase(String cidade, Pageable pageable);

    boolean existsByNomeIgnoreCaseAndCidadeIgnoreCase(String nome, String cidade);
}
