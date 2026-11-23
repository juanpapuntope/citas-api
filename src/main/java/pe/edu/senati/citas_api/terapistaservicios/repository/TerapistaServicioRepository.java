package pe.edu.senati.citas_api.terapistaservicios.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.senati.citas_api.terapistaservicios.entity.TerapistaServicio;

public interface TerapistaServicioRepository extends JpaRepository<TerapistaServicio, Long> {

    List<TerapistaServicio> findByTerapistaId(Long terapistaId);

    List<TerapistaServicio> findByServicioId(Long servicioId);

    boolean existsByTerapistaIdAndServicioId(Long terapistaId, Long servicioId);
}
