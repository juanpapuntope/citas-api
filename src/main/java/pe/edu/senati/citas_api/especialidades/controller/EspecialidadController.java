package pe.edu.senati.citas_api.especialidades.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import pe.edu.senati.citas_api.especialidades.dto.EspecialidadDTO;
import pe.edu.senati.citas_api.especialidades.service.EspecialidadService;

/** HO-02: CRUD REST de especialidades. */
@RestController
@RequestMapping("/api/especialidades")
public class EspecialidadController {

    private final EspecialidadService service;

    public EspecialidadController(EspecialidadService service) {
        this.service = service;
    }

    // GET /api/especialidades -> 200
    @GetMapping
    public List<EspecialidadDTO> listar() {
        return service.listar();
    }

    // GET /api/especialidades/1 -> 200 o 404
    @GetMapping("/{id}")
    public ResponseEntity<EspecialidadDTO> obtener(@PathVariable Long id) {
        return service.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // GET /api/especialidades/buscar?nombre=terapia -> 200
    @GetMapping("/buscar")
    public List<EspecialidadDTO> buscar(@RequestParam String nombre) {
        return service.buscarPorNombre(nombre);
    }

    // POST /api/especialidades -> 201 (400 si falla una validación)
    @PostMapping
    public ResponseEntity<EspecialidadDTO> crear(@Valid @RequestBody EspecialidadDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.crear(dto));
    }

    // PUT /api/especialidades/1 -> 200, 400 o 404
    @PutMapping("/{id}")
    public ResponseEntity<EspecialidadDTO> actualizar(@PathVariable Long id,
                                                      @Valid @RequestBody EspecialidadDTO dto) {
        return service.actualizar(id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // DELETE /api/especialidades/1 -> 204 o 404
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (service.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}