package br.com.fiap.alagalerta.repository;

import br.com.fiap.alagalerta.domain.Leitura;
import br.com.fiap.alagalerta.dto.ResumoRegiaoResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface LeituraRepository extends JpaRepository<Leitura, Long> {

    /** JPQL: histórico de um sensor em uma janela de tempo (gráfico do app). */
    @Query("""
            select l from Leitura l
            where l.sensor.id = :sensorId and l.dataHora >= :desde
            """)
    Page<Leitura> buscarHistorico(@Param("sensorId") Long sensorId,
                                  @Param("desde") LocalDateTime desde,
                                  Pageable pageable);

    /**
     * JPQL com agregação e projeção em DTO: nível máximo, média de chuva e quantidade de leituras
     * por região no período. Alimenta o painel da Defesa Civil.
     */
    @Query("""
            select new br.com.fiap.alagalerta.dto.ResumoRegiaoResponse(
                r.id, r.nome, r.cidade, max(l.nivelAguaCm), avg(l.chuvaMmHora), count(l))
            from Leitura l join l.sensor s join s.regiao r
            where l.dataHora >= :desde
            group by r.id, r.nome, r.cidade
            order by max(l.nivelAguaCm) desc
            """)
    List<ResumoRegiaoResponse> resumoPorRegiao(@Param("desde") LocalDateTime desde);

    boolean existsBySensorId(Long sensorId);
}
