package pe.edu.senati.citas_api.comun;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** GET / : sirve para comprobar que la API está viva y con qué perfil arrancó. */
@RestController
public class InicioController {

    private final Environment env;

    public InicioController(Environment env) {
        this.env = env;
    }

    @GetMapping("/")
    public Map<String, String> inicio() {
        Map<String, String> datos = new LinkedHashMap<>();
        datos.put("proyecto", "citas-api");
        datos.put("perfil", String.join(",", env.getActiveProfiles()));   // dev o demo
        datos.put("estado", "OK");
        return datos;
    }
}
