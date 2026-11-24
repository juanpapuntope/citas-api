package pe.edu.senati.citas_api.auth.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.senati.citas_api.auth.entity.Rol;

public interface RolRepository extends JpaRepository<Rol, Long> {
}
