package pe.edu.senati.citas_api.terapistaservicios.entity;

import jakarta.persistence.*;

/** Tabla intermedia "terapista_servicios": qué servicios atiende cada terapista (relación N a N). */
@Entity
@Table(name = "terapista_servicios")
public class TerapistaServicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "terapista_id", nullable = false)
    private Long terapistaId;

    @Column(name = "servicio_id", nullable = false)
    private Long servicioId;

    public Long getId() { return id; }
    public Long getTerapistaId() { return terapistaId; }
    public void setTerapistaId(Long terapistaId) { this.terapistaId = terapistaId; }
    public Long getServicioId() { return servicioId; }
    public void setServicioId(Long servicioId) { this.servicioId = servicioId; }
}
