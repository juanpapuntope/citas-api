package pe.edu.senati.citas_api.servicios.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import pe.edu.senati.citas_api.servicios.dto.ServicioDTO;
import pe.edu.senati.citas_api.servicios.service.ServicioService;

/** Web services REST de servicios: /api/servicios */
@RestController
@RequestMapping("/api/servicios")
public class ServicioController {

    private final ServicioService service;

    public ServicioController(ServicioService service) {
        this.service = service;
    }

    // GET /api/servicios -> 200
    @GetMapping
    public List<ServicioDTO> listar() {
        return service.listar();
    }

    // GET /api/servicios/activos -> 200
    @GetMapping("/activos")
    public List<ServicioDTO> listarActivos() {
        return service.listarActivos();
    }

    // GET /api/servicios/buscar?titulo=tera -> 200
    @GetMapping("/buscar")
    public List<ServicioDTO> buscar(@RequestParam String titulo) {
        return service.buscarPorTitulo(titulo);
    }

    // GET /api/servicios/1 -> 200 o 404
    @GetMapping("/{id}")
    public ResponseEntity<ServicioDTO> obtener(@PathVariable Long id) {
        return service.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/servicios -> 201, 400 (validación) o 409 (título repetido)
    @PostMapping
    public ResponseEntity<ServicioDTO> crear(@Valid @RequestBody ServicioDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.crear(dto));
    }

    // PUT /api/servicios/1 -> 200, 400, 404 o 409
    @PutMapping("/{id}")
    public ResponseEntity<ServicioDTO> actualizar(@PathVariable Long id, @Valid @RequestBody ServicioDTO dto) {
        return service.actualizar(id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // DELETE /api/servicios/1 -> 204, 404 o 409 (está en uso)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (service.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
