package pe.edu.senati.citas_api.auth.entity;

import java.time.LocalDateTime;
import jakarta.persistence.*;

/** Cada objeto es una fila de la tabla "usuarios" (las cuentas para iniciar sesión). */
@Entity
@Table(name = "usuarios")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)   // AUTO_INCREMENT
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    // OJO: en esta clase la contraseña se guarda en TEXTO PLANO solo para aprender.
    // La próxima clase se reemplaza por una versión cifrada.
    @Column(nullable = false, length = 60)
    private String password;

    @Column(name = "rol_id", nullable = false)
    private Long rolId;

    @Column(nullable = false)
    private Boolean activo;

    @Column(name = "creado_en")
    private LocalDateTime creadoEn;

    public Long getId() { return id; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public Long getRolId() { return rolId; }
    public Boolean getActivo() { return activo; }
    public LocalDateTime getCreadoEn() { return creadoEn; }
}
