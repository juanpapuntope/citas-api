package pe.edu.senati.citas_api.especialidades.entity;

import java.math.BigDecimal;
import jakarta.persistence.*;

/** HO-03: cada objeto es una fila de la tabla "especialidades". */
@Entity
@Table(name = "especialidades")
public class Especialidad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)   // AUTO_INCREMENT
    private Long id;

    @Column(nullable = false, unique = true, length = 80)
    private String nombre;

    @Column(length = 255)
    private String descripcion;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal precio;

    private Boolean activa = true;

    // Getters y setters (en VS Code: clic derecho → Source Action → Generate Getters and Setters)
    public Long getId() { return id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    public Boolean getActiva() { return activa; }
    public void setActiva(Boolean activa) { this.activa = activa; }
}