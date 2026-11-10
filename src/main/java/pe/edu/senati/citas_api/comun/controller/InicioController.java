package pe.edu.senati.citas_api.comun.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import io.swagger.v3.oas.annotations.Hidden;

@Hidden
@Controller
public class InicioController {

    @GetMapping("/")
    public String inicio() {
        return "redirect:/swagger-ui.html";
    }
}