package pe.edu.senati.citas_api.especialidades.dto;

import java.math.BigDecimal;
import jakarta.validation.constraints.*;

/** HO-07: datos que entran y salen de la API. */
public record EspecialidadDTO(

        Long id,   // al crear se ignora: lo genera la base de datos

        @NotBlank(message = "El nombre es obligatorio")
        @Size(max = 80, message = "Máximo 80 caracteres")
        String nombre,

        @Size(max = 255, message = "Máximo 255 caracteres")
        String descripcion,

        @NotNull(message = "El precio es obligatorio")
        @PositiveOrZero(message = "El precio no puede ser negativo")
        BigDecimal precio,

        Boolean activa
) { }