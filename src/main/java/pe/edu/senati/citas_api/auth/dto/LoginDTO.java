package pe.edu.senati.citas_api.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/** JSON que envía el cliente para iniciar sesión. */
public record LoginDTO(

        @NotBlank(message = "El correo es obligatorio")
        @Email(message = "Correo no válido")
        String email,

        @NotBlank(message = "La contraseña es obligatoria")
        String password
) { }
