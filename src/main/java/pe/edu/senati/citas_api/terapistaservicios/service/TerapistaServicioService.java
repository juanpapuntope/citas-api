package pe.edu.senati.citas_api.terapistaservicios.service;

import java.util.List;
import java.util.Optional;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import pe.edu.senati.citas_api.servicios.repository.ServicioRepository;
import pe.edu.senati.citas_api.terapistas.repository.TerapistaRepository;
import pe.edu.senati.citas_api.terapistaservicios.dto.TerapistaServicioDTO;
import pe.edu.senati.citas_api.terapistaservicios.entity.TerapistaServicio;
import pe.edu.senati.citas_api.terapistaservicios.repository.TerapistaServicioRepository;

@Service
public class TerapistaServicioService {

    private final TerapistaServicioRepository repository;
    private final TerapistaRepository terapistas;   // rama 2
    private final ServicioRepository servicios;     // rama 1

    public TerapistaServicioService(TerapistaServicioRepository repository,
                                    TerapistaRepository terapistas, ServicioRepository servicios) {
        this.repository = repository;
        this.terapistas = terapistas;
        this.servicios = servicios;
    }

    public List<TerapistaServicioDTO> listar() {
        return repository.findAll().stream().map(this::aDTO).toList();
    }

    public Optional<TerapistaServicioDTO> buscarPorId(Long id) {
        return repository.findById(id).map(this::aDTO);
    }

    public List<TerapistaServicioDTO> listarPorTerapista(Long terapistaId) {
        return repository.findByTerapistaId(terapistaId).stream().map(this::aDTO).toList();
    }

    public List<TerapistaServicioDTO> listarPorServicio(Long servicioId) {
        return repository.findByServicioId(servicioId).stream().map(this::aDTO).toList();
    }

    public TerapistaServicioDTO crear(TerapistaServicioDTO dto) {
        // 400: la terapista o el servicio no existen
        if (!terapistas.existsById(dto.terapistaId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La terapista " + dto.terapistaId() + " no existe");
        }
        if (!servicios.existsById(dto.servicioId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El servicio " + dto.servicioId() + " no existe");
        }
        // 409: no asignar dos veces el mismo servicio a la misma terapista
        if (repository.existsByTerapistaIdAndServicioId(dto.terapistaId(), dto.servicioId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "La terapista ya tiene asignado ese servicio");
        }
        TerapistaServicio nuevo = new TerapistaServicio();
        nuevo.setTerapistaId(dto.terapistaId());
        nuevo.setServicioId(dto.servicioId());
        return aDTO(repository.save(nuevo));
    }

    public boolean eliminar(Long id) {
        if (!repository.existsById(id)) {
            return false;
        }
        repository.deleteById(id);
        return true;
    }

    // Entidad -> DTO, agregando los nombres de la terapista y del servicio
    private TerapistaServicioDTO aDTO(TerapistaServicio e) {
        String terapista = terapistas.findById(e.getTerapistaId())
                .map(t -> t.getNombres() + " " + t.getApellidos()).orElse(null);
        String servicio = servicios.findById(e.getServicioId())
                .map(s -> s.getTitulo()).orElse(null);
        return new TerapistaServicioDTO(e.getId(), e.getTerapistaId(), e.getServicioId(), terapista, servicio);
    }
}
