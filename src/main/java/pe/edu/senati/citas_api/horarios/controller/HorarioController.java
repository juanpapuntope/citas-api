package pe.edu.senati.citas_api.horarios.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import pe.edu.senati.citas_api.horarios.dto.HorarioDTO;
import pe.edu.senati.citas_api.horarios.service.HorarioService;

/** Web services REST de horarios: /api/horarios */
@RestController
@RequestMapping("/api/horarios")
public class HorarioController {

    private final HorarioService service;

    public HorarioController(HorarioService service) {
        this.service = service;
    }

    // GET /api/horarios -> 200
    @GetMapping
    public List<HorarioDTO> listar() {
        return service.listar();
    }

    // GET /api/horarios/terapista/1 -> 200 (lista vacía si no tiene)
    @GetMapping("/terapista/{terapistaId}")
    public List<HorarioDTO> listarPorTerapista(@PathVariable Long terapistaId) {
        return service.listarPorTerapista(terapistaId);
    }

    // GET /api/horarios/dia/1 -> 200 (quién atiende el lunes)
    @GetMapping("/dia/{dia}")
    public List<HorarioDTO> listarPorDia(@PathVariable Integer dia) {
        return service.listarPorDia(dia);
    }

    // GET /api/horarios/1 -> 200 o 404
    @GetMapping("/{id}")
    public ResponseEntity<HorarioDTO> obtener(@PathVariable Long id) {
        return service.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/horarios -> 201, 400 o 409
    @PostMapping
    public ResponseEntity<HorarioDTO> crear(@Valid @RequestBody HorarioDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.crear(dto));
    }

    // PUT /api/horarios/1 -> 200, 400, 404 o 409
    @PutMapping("/{id}")
    public ResponseEntity<HorarioDTO> actualizar(@PathVariable Long id, @Valid @RequestBody HorarioDTO dto) {
        return service.actualizar(id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // DELETE /api/horarios/1 -> 204 o 404
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (service.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
