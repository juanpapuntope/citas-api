package pe.edu.senati.citas_api.especialidades.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.senati.citas_api.especialidades.entity.Especialidad;

/** HO-05: save, findAll, findById, deleteById... sin escribir SQL. */
public interface EspecialidadRepository extends JpaRepository<Especialidad, Long> {

    // Spring arma la consulta a partir del nombre del método:
    // SELECT * FROM especialidades WHERE nombre LIKE '%texto%'
    List<Especialidad> findByNombreContainingIgnoreCase(String texto);
}