package pe.edu.senati.citas_api.terapistas.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import pe.edu.senati.citas_api.terapistas.dto.TerapistaDTO;
import pe.edu.senati.citas_api.terapistas.service.TerapistaService;

/** Web services REST de terapistas: /api/terapistas */
@RestController
@RequestMapping("/api/terapistas")
public class TerapistaController {

    private final TerapistaService service;

    public TerapistaController(TerapistaService service) {
        this.service = service;
    }

    // GET /api/terapistas -> 200
    @GetMapping
    public List<TerapistaDTO> listar() {
        return service.listar();
    }

    // GET /api/terapistas/activos -> 200
    @GetMapping("/activos")
    public List<TerapistaDTO> listarActivos() {
        return service.listarActivos();
    }

    // GET /api/terapistas/buscar?texto=gut -> 200
    @GetMapping("/buscar")
    public List<TerapistaDTO> buscar(@RequestParam String texto) {
        return service.buscar(texto);
    }

    // GET /api/terapistas/1 -> 200 o 404
    @GetMapping("/{id}")
    public ResponseEntity<TerapistaDTO> obtener(@PathVariable Long id) {
        return service.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/terapistas -> 201, 400 o 409
    @PostMapping
    public ResponseEntity<TerapistaDTO> crear(@Valid @RequestBody TerapistaDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.crear(dto));
    }

    // PUT /api/terapistas/1 -> 200, 400, 404 o 409
    @PutMapping("/{id}")
    public ResponseEntity<TerapistaDTO> actualizar(@PathVariable Long id, @Valid @RequestBody TerapistaDTO dto) {
        return service.actualizar(id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // DELETE /api/terapistas/1 -> 204, 404 o 409
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (service.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
