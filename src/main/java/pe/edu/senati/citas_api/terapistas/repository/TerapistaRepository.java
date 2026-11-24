package pe.edu.senati.citas_api.terapistas.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.senati.citas_api.terapistas.entity.Terapista;

public interface TerapistaRepository extends JpaRepository<Terapista, Long> {

    List<Terapista> findByActivoTrue();

    // Búsqueda por nombres o apellidos (?texto=gut)
    List<Terapista> findByNombresContainingIgnoreCaseOrApellidosContainingIgnoreCase(String nombres, String apellidos);

    boolean existsByDni(String dni);

    boolean existsByDniAndIdNot(String dni, Long id);

    boolean existsByUsuarioId(Long usuarioId);

    boolean existsByUsuarioIdAndIdNot(Long usuarioId, Long id);
}
