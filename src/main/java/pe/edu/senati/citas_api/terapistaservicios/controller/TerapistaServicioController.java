package pe.edu.senati.citas_api.terapistaservicios.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import pe.edu.senati.citas_api.terapistaservicios.dto.TerapistaServicioDTO;
import pe.edu.senati.citas_api.terapistaservicios.service.TerapistaServicioService;

/** Web services REST de terapista_servicios: /api/terapista-servicios */
@RestController
@RequestMapping("/api/terapista-servicios")
public class TerapistaServicioController {

    private final TerapistaServicioService service;

    public TerapistaServicioController(TerapistaServicioService service) {
        this.service = service;
    }

    // GET /api/terapista-servicios -> 200
    @GetMapping
    public List<TerapistaServicioDTO> listar() {
        return service.listar();
    }

    // GET /api/terapista-servicios/terapista/1 -> 200 (servicios que atiende la terapista 1)
    @GetMapping("/terapista/{terapistaId}")
    public List<TerapistaServicioDTO> listarPorTerapista(@PathVariable Long terapistaId) {
        return service.listarPorTerapista(terapistaId);
    }

    // GET /api/terapista-servicios/servicio/1 -> 200 (terapistas que atienden el servicio 1)
    @GetMapping("/servicio/{servicioId}")
    public List<TerapistaServicioDTO> listarPorServicio(@PathVariable Long servicioId) {
        return service.listarPorServicio(servicioId);
    }

    // GET /api/terapista-servicios/1 -> 200 o 404
    @GetMapping("/{id}")
    public ResponseEntity<TerapistaServicioDTO> obtener(@PathVariable Long id) {
        return service.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/terapista-servicios -> 201, 400 o 409
    @PostMapping
    public ResponseEntity<TerapistaServicioDTO> crear(@Valid @RequestBody TerapistaServicioDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.crear(dto));
    }

    // DELETE /api/terapista-servicios/1 -> 204 o 404
    // (no hay PUT: para cambiar una asignación se elimina y se crea otra)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (service.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
