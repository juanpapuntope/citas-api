package pe.edu.senati.citas_api;

import java.util.TimeZone;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CitasApiApplication {

    public static void main(String[] args) {
        // La misma hora en tu PC, en Codespaces y en la base H2 (hora de Perú)
        TimeZone.setDefault(TimeZone.getTimeZone("America/Lima"));
        SpringApplication.run(CitasApiApplication.class, args);
    }
}
