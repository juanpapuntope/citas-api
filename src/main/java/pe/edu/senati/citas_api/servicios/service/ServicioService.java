package pe.edu.senati.citas_api.servicios.service;

import java.util.List;
import java.util.Optional;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import pe.edu.senati.citas_api.servicios.dto.ServicioDTO;
import pe.edu.senati.citas_api.servicios.entity.Servicio;
import pe.edu.senati.citas_api.servicios.repository.ServicioRepository;

/** Lógica y reglas del CRUD de servicios. El controlador usa el servicio, no el repositorio. */
@Service
public class ServicioService {

    private final ServicioRepository repository;

    public ServicioService(ServicioRepository repository) {
        this.repository = repository;
    }

    public List<ServicioDTO> listar() {
        return repository.findAll().stream().map(this::aDTO).toList();
    }

    public Optional<ServicioDTO> buscarPorId(Long id) {
        return repository.findById(id).map(this::aDTO);
    }

    public List<ServicioDTO> buscarPorTitulo(String titulo) {
        return repository.findByTituloContainingIgnoreCase(titulo).stream().map(this::aDTO).toList();
    }

    public List<ServicioDTO> listarActivos() {
        return repository.findByActivoTrue().stream().map(this::aDTO).toList();
    }

    public ServicioDTO crear(ServicioDTO dto) {
        // Regla: el título no se repite -> 409 Conflict
        if (repository.existsByTituloIgnoreCase(dto.titulo())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe un servicio con ese título");
        }
        Servicio nuevo = new Servicio();
        copiar(dto, nuevo);
        return aDTO(repository.save(nuevo));   // INSERT
    }

    public Optional<ServicioDTO> actualizar(Long id, ServicioDTO dto) {
        if (repository.existsByTituloIgnoreCaseAndIdNot(dto.titulo(), id)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe otro servicio con ese título");
        }
        return repository.findById(id).map(existente -> {
            copiar(dto, existente);
            return aDTO(repository.save(existente));   // UPDATE (porque ya tiene id)
        });
    }

    public boolean eliminar(Long id) {
        if (!repository.existsById(id)) {
            return false;   // el controlador responde 404
        }
        try {
            repository.deleteById(id);   // DELETE
        } catch (DataIntegrityViolationException e) {
            // La base no deja borrar una fila que otra tabla usa (clave foránea)
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "No se puede eliminar: el servicio ya se usa en citas o terapistas. Desactívalo con activo=false");
        }
        return true;
    }

    // Entidad -> DTO (lo que sale en el JSON)
    private ServicioDTO aDTO(Servicio e) {
        return new ServicioDTO(e.getId(), e.getTitulo(), e.getDescripcion(), e.getCosto(),
                e.getDuracion(), e.getFoto(), e.getActivo());
    }

    // DTO -> Entidad (lo que se guarda en la tabla)
    private void copiar(ServicioDTO dto, Servicio e) {
        e.setTitulo(dto.titulo());
        e.setDescripcion(dto.descripcion());
        e.setCosto(dto.costo());
        e.setDuracion(dto.duracion());
        e.setFoto(dto.foto());
        e.setActivo(dto.activo() == null ? true : dto.activo());   // si no lo envían, queda activo
    }
}
