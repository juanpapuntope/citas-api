package pe.edu.senati.citas_api.comun.controller;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

/** La raíz "/" muestra en JSON de quién es el web service y la URL de cada uno. */
@RestController
public class InicioController {

    @GetMapping("/")
    public Map<String, String> inicio() {
        // http://localhost:8080 en la PC, https://...-8080.app.github.dev en Codespaces
        String base = ServletUriComponentsBuilder.fromCurrentContextPath().toUriString();

        Map<String, String> urls = new LinkedHashMap<>();

        // Estas variables las pone GitHub dentro de cada codespace (no se escriben a mano)
        urls.put("repositorio", "https://github.com/" + variable("GITHUB_REPOSITORY"));
        urls.put("usuario", variable("GITHUB_USER"));
        urls.put("codespace", variable("CODESPACE_NAME"));

        urls.put("hola", base + "/api/hola");
        urls.put("especialidades", base + "/api/especialidades");
        urls.put("especialidad 1", base + "/api/especialidades/1");
        urls.put("buscar especialidades", base + "/api/especialidades/buscar?nombre=terapia");
        // Cada equipo agrega aquí las URLs de su módulo (pacientes, terapeutas...)
        return urls;
    }

    // En la PC estas variables no existen: se muestra "local"
    private String variable(String nombre) {
        String valor = System.getenv(nombre);
        return valor != null ? valor : "local";
    }
}