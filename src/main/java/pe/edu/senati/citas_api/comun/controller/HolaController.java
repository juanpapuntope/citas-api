package pe.edu.senati.citas_api.comun.controller;

import java.time.LocalDateTime;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** HO-01: primer controlador REST. */
@RestController                 // esta clase responde peticiones HTTP con datos (texto o JSON)
@RequestMapping("/api/hola")    // todas sus rutas empiezan con /api/hola
public class HolaController {

    // GET http://localhost:8080/api/hola
    @GetMapping
    public String hola() {
        return "¡Hola mundo desde Spring Boot!";
    }

    // GET http://localhost:8080/api/hola/Juan  -> el dato viene en la ruta
    @GetMapping("/{nombre}")
    public Map<String, Object> saludar(@PathVariable String nombre) {
        return Map.of("mensaje", "Hola " + nombre, "fecha", LocalDateTime.now().toString());
    }

    // GET http://localhost:8080/api/hola/sumar?a=5&b=3  -> los datos vienen después de ?
    @GetMapping("/sumar")
    public Map<String, Integer> sumar(@RequestParam int a, @RequestParam int b) {
        return Map.of("a", a, "b", b, "resultado", a + b);
    }
}