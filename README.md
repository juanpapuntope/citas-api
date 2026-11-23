# citas-api

Web services del catálogo de un centro de terapias (Spring Boot · Java 21 · base `citas_db`).

> El login compara la contraseña en **texto plano** solo para aprender. La próxima clase se reemplaza por una versión segura.

## Ejecutar en la PC (perfil dev, MySQL de XAMPP)

1. XAMPP: **Start** en Apache y MySQL.
2. phpMyAdmin → **Importar** → `database/citas_db.sql`.
3. Terminal: `.\mvnw spring-boot:run` y abrir http://localhost:8080/

## Ejecutar en Codespaces (perfil demo, H2 en memoria)

**Code → Codespaces → Create codespace on <rama>**. Arranca solo. Poner el puerto 8080 en **Public**.

## Web services

| Etapa | Método | Ruta |
|---|---|---|
| main | GET | `/` |

Pruebas: `postman/citas-api.postman_collection.json` (variable `baseUrl`).
Usuarios de prueba: todos con la contraseña `Clave123` (ver `database/citas_db.sql`).
