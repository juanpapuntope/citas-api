package pe.edu.senati.citas_api.servicios.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.senati.citas_api.servicios.entity.Servicio;

/** JpaRepository ya trae findAll, findById, save, existsById y deleteById. */
public interface ServicioRepository extends JpaRepository<Servicio, Long> {

    // WHERE LOWER(titulo) LIKE LOWER('%texto%')
    List<Servicio> findByTituloContainingIgnoreCase(String texto);

    // WHERE activo = true
    List<Servicio> findByActivoTrue();

    // ¿Ya existe otro servicio con ese título? (para no repetir títulos)
    boolean existsByTituloIgnoreCase(String titulo);

    boolean existsByTituloIgnoreCaseAndIdNot(String titulo, Long id);
}
