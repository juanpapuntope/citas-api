package pe.edu.senati.citas_api.auth.dto;

/** JSON que devuelve un login correcto. Nunca se devuelve la contraseña. */
public record SesionDTO(Long usuarioId, String email, String rol) { }
