package pe.edu.senati.citas_api.servicios.entity;

import java.math.BigDecimal;
import jakarta.persistence.*;

/** Cada objeto es una fila de la tabla "servicios". */
@Entity
@Table(name = "servicios")
public class Servicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)   // AUTO_INCREMENT
    private Long id;

    @Column(nullable = false, unique = true, length = 80)
    private String titulo;

    @Column(length = 255)
    private String descripcion;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal costo;   // en soles, incluye IGV

    @Column(nullable = false)
    private Integer duracion;   // minutos

    @Column(length = 255)
    private String foto;        // URL o ruta de la imagen

    @Column(nullable = false)
    private Boolean activo = true;

    public Long getId() { return id; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public BigDecimal getCosto() { return costo; }
    public void setCosto(BigDecimal costo) { this.costo = costo; }
    public Integer getDuracion() { return duracion; }
    public void setDuracion(Integer duracion) { this.duracion = duracion; }
    public String getFoto() { return foto; }
    public void setFoto(String foto) { this.foto = foto; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}
