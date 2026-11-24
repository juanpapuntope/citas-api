package pe.edu.senati.citas_api.terapistas.dto;

import jakarta.validation.constraints.*;

/** Datos que entran y salen en el JSON de /api/terapistas. */
public record TerapistaDTO(

        Long id,

        @NotNull(message = "El usuario es obligatorio")
        Long usuarioId,

        @NotBlank(message = "Los nombres son obligatorios")
        @Size(max = 60, message = "Máximo 60 caracteres")
        String nombres,

        @NotBlank(message = "Los apellidos son obligatorios")
        @Size(max = 60, message = "Máximo 60 caracteres")
        String apellidos,

        @NotBlank(message = "El DNI es obligatorio")
        @Pattern(regexp = "\\d{8}", message = "El DNI tiene 8 dígitos")
        String dni,

        @Pattern(regexp = "9\\d{8}", message = "El celular tiene 9 dígitos y empieza con 9")
        String telefono,

        Boolean activo
) { }
