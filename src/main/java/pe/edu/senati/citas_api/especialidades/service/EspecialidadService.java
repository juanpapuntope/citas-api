package pe.edu.senati.citas_api.especialidades.service;

import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import pe.edu.senati.citas_api.especialidades.dto.EspecialidadDTO;
import pe.edu.senati.citas_api.especialidades.entity.Especialidad;
import pe.edu.senati.citas_api.especialidades.repository.EspecialidadRepository;

/** HO-06: lógica del CRUD. El controlador usa el servicio, no el repositorio. */
@Service
public class EspecialidadService {

    private final EspecialidadRepository repository;

    public EspecialidadService(EspecialidadRepository repository) {
        this.repository = repository;
    }

    public List<EspecialidadDTO> listar() {
        return repository.findAll().stream().map(this::aDTO).toList();
    }

    public Optional<EspecialidadDTO> buscarPorId(Long id) {
        return repository.findById(id).map(this::aDTO);
    }

    public List<EspecialidadDTO> buscarPorNombre(String texto) {
        return repository.findByNombreContainingIgnoreCase(texto).stream().map(this::aDTO).toList();
    }

    public EspecialidadDTO crear(EspecialidadDTO dto) {
        Especialidad nueva = new Especialidad();
        copiar(dto, nueva);
        return aDTO(repository.save(nueva));
    }

    public Optional<EspecialidadDTO> actualizar(Long id, EspecialidadDTO dto) {
        return repository.findById(id).map(existente -> {
            copiar(dto, existente);
            return aDTO(repository.save(existente));
        });
    }

    public boolean eliminar(Long id) {
        if (!repository.existsById(id)) {
            return false;
        }
        repository.deleteById(id);
        return true;
    }

    // Entidad -> DTO (lo que se devuelve en el JSON)
    private EspecialidadDTO aDTO(Especialidad e) {
        return new EspecialidadDTO(e.getId(), e.getNombre(), e.getDescripcion(), e.getPrecio(), e.getActiva());
    }

    // DTO -> Entidad (lo que se guarda en la base)
    private void copiar(EspecialidadDTO dto, Especialidad e) {
        e.setNombre(dto.nombre());
        e.setDescripcion(dto.descripcion());
        e.setPrecio(dto.precio());
        e.setActiva(dto.activa() == null ? true : dto.activa());
    }
}