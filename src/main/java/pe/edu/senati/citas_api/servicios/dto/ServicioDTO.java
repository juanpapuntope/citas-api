package pe.edu.senati.citas_api.servicios.dto;

import java.math.BigDecimal;
import jakarta.validation.constraints.*;

/** Datos que entran y salen en el JSON de /api/servicios. */
public record ServicioDTO(

        Long id,

        @NotBlank(message = "El título es obligatorio")
        @Size(max = 80, message = "Máximo 80 caracteres")
        String titulo,

        @Size(max = 255, message = "Máximo 255 caracteres")
        String descripcion,

        @NotNull(message = "El costo es obligatorio")
        @PositiveOrZero(message = "El costo no puede ser negativo")
        BigDecimal costo,

        @NotNull(message = "La duración es obligatoria")
        @Min(value = 15, message = "Mínimo 15 minutos")
        @Max(value = 180, message = "Máximo 180 minutos")
        Integer duracion,

        @Size(max = 255, message = "Máximo 255 caracteres")
        String foto,

        Boolean activo
) { }
