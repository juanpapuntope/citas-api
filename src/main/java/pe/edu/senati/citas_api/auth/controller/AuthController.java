package pe.edu.senati.citas_api.auth.controller;

import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import pe.edu.senati.citas_api.auth.dto.LoginDTO;
import pe.edu.senati.citas_api.auth.dto.SesionDTO;
import pe.edu.senati.citas_api.auth.service.AuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService service;

    public AuthController(AuthService service) {
        this.service = service;
    }

    // POST /api/auth/login -> 200, 400 (faltan datos), 401 (incorrecto) o 403 (inactivo o rol no permitido)
    @PostMapping("/login")
    public SesionDTO login(@Valid @RequestBody LoginDTO dto) {
        return service.login(dto);
    }
}
