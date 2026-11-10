package pe.edu.senati.citas_api.comun.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** Permite que un frontend en otra dirección llame a la API. */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")   // en clase: cualquier frontend
                .allowedMethods("GET", "POST", "PUT", "DELETE");
    }
}