package br.com.fiap.alagalerta.repository;

import br.com.fiap.alagalerta.domain.Sensor;
import br.com.fiap.alagalerta.domain.StatusSensor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface SensorRepository extends JpaRepository<Sensor, Long> {

    /** Query method derivado: usado pelo gateway IoT, que se identifica pelo código gravado no firmware. */
    @EntityGraph(attributePaths = "regiao")
    Optional<Sensor> findByCodigo(String codigo);

    boolean existsByCodigo(String codigo);

    boolean existsByRegiaoId(Long regiaoId);

    @EntityGraph(attributePaths = "regiao")
    Page<Sensor> findByRegiaoIdAndStatus(Long regiaoId, StatusSensor status, Pageable pageable);

    @EntityGraph(attributePaths = "regiao")
    Page<Sensor> findByRegiaoId(Long regiaoId, Pageable pageable);

    /**
     * JPQL: sensores ativos que estão sem enviar dados desde um instante — indica falha de energia,
     * de rede ou dispositivo danificado pela enchente. A Defesa Civil usa para manutenção.
     */
    @Query("""
            select s from Sensor s join fetch s.regiao
            where s.status = br.com.fiap.alagalerta.domain.StatusSensor.ATIVO
              and (s.ultimaLeituraEm is null or s.ultimaLeituraEm < :limite)
            order by s.ultimaLeituraEm asc nulls first
            """)
    List<Sensor> buscarSensoresSilenciosos(@Param("limite") LocalDateTime limite);
}
