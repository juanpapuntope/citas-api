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
| rama-1-login-servicios | POST | `/api/auth/login` |
| rama-1-login-servicios | GET | `/api/servicios` |
| rama-1-login-servicios | GET | `/api/servicios/activos` |
| rama-1-login-servicios | GET | `/api/servicios/buscar?titulo=` |
| rama-1-login-servicios | GET | `/api/servicios/{id}` |
| rama-1-login-servicios | POST | `/api/servicios` |
| rama-1-login-servicios | PUT | `/api/servicios/{id}` |
| rama-1-login-servicios | DELETE | `/api/servicios/{id}` |
| rama-2-terapistas | GET | `/api/terapistas` |
| rama-2-terapistas | GET | `/api/terapistas/activos` |
| rama-2-terapistas | GET | `/api/terapistas/buscar?texto=` |
| rama-2-terapistas | GET | `/api/terapistas/{id}` |
| rama-2-terapistas | POST | `/api/terapistas` |
| rama-2-terapistas | PUT | `/api/terapistas/{id}` |
| rama-2-terapistas | DELETE | `/api/terapistas/{id}` |

Pruebas: `postman/citas-api.postman_collection.json` (variable `baseUrl`).
Usuarios de prueba: todos con la contraseña `Clave123` (ver `database/citas_db.sql`).
