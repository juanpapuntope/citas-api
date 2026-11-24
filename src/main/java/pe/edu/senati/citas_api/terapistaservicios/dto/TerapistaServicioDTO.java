package pe.edu.senati.citas_api.terapistaservicios.dto;

import jakarta.validation.constraints.NotNull;

/**
 * JSON de /api/terapista-servicios.
 * Al crear solo se envían terapistaId y servicioId. Al responder se agregan los nombres
 * para que el frontend no tenga que hacer otra petición.
 */
public record TerapistaServicioDTO(

        Long id,

        @NotNull(message = "La terapista es obligatoria")
        Long terapistaId,

        @NotNull(message = "El servicio es obligatorio")
        Long servicioId,

        String terapista,   // solo respuesta: "María Gutiérrez León"
        String servicio     // solo respuesta: "Fisioterapia"
) { }
