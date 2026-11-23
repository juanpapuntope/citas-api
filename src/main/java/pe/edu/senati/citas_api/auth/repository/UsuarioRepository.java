package pe.edu.senati.citas_api.auth.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.senati.citas_api.auth.entity.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    // Spring Data arma la consulta por el nombre: SELECT ... FROM usuarios WHERE email = ?
    Optional<Usuario> findByEmail(String email);
}
