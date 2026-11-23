-- =====================================================================
--  citas_db - Sistema de citas de un centro de terapias
--  16 tablas compartidas por todos los repositorios del proyecto
--
--  Ejecutar en phpMyAdmin (pestaña Importar) o en la consola de MySQL/MariaDB.
--  ATENCIÓN: borra la base citas_db si ya existe y la crea de nuevo.
--  Las fechas de las citas se calculan a partir de HOY: siempre hay citas
--  pasadas (atendidas, canceladas), de hoy y futuras (reservadas).
--  Todos los usuarios tienen la contraseña: Clave123 (en texto plano, SOLO para aprender)
-- =====================================================================

DROP DATABASE IF EXISTS citas_db;
CREATE DATABASE citas_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE citas_db;

-- =====================================================================
--  TABLAS
-- =====================================================================

-- ----- Seguridad y configuración -----
CREATE TABLE roles (
  id      BIGINT       NOT NULL AUTO_INCREMENT,
  nombre  VARCHAR(20)  NOT NULL,           -- GERENTE, TERAPISTA, ADMIN, CLIENTE, RECEPCIONISTA
  PRIMARY KEY (id),
  UNIQUE KEY uk_roles_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id             BIGINT        NOT NULL AUTO_INCREMENT,
  email          VARCHAR(100)  NOT NULL,
  password       VARCHAR(60)   NOT NULL,   -- texto plano SOLO para aprender (la próxima clase se cifra)
  rol_id         BIGINT        NOT NULL,
  activo         BOOLEAN       NOT NULL DEFAULT TRUE,
  creado_en      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuarios_email (email),
  CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id) REFERENCES roles (id)
) ENGINE=InnoDB;

CREATE TABLE parametros (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  clave        VARCHAR(40)   NOT NULL,
  valor        VARCHAR(100)  NOT NULL,
  descripcion  VARCHAR(255)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_parametros_clave (clave)
) ENGINE=InnoDB;

CREATE TABLE auditoria (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  usuario_id   BIGINT       NOT NULL,
  accion       VARCHAR(20)  NOT NULL,      -- LOGIN, CREAR, ACTUALIZAR, ELIMINAR
  tabla        VARCHAR(40)  NULL,
  registro_id  BIGINT       NULL,
  fecha        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_auditoria_usuario_fecha (usuario_id, fecha),
  CONSTRAINT fk_auditoria_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

-- ----- Catálogo y personal -----
CREATE TABLE servicios (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  titulo       VARCHAR(80)   NOT NULL,
  descripcion  VARCHAR(255)  NULL,
  costo        DECIMAL(8,2)  NOT NULL,     -- incluye IGV
  duracion     INT           NOT NULL,     -- minutos
  foto         VARCHAR(255)  NULL,         -- URL o ruta de la imagen
  activo       BOOLEAN       NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uk_servicios_titulo (titulo),
  CONSTRAINT ck_servicios_costo CHECK (costo >= 0),
  CONSTRAINT ck_servicios_duracion CHECK (duracion BETWEEN 15 AND 180)
) ENGINE=InnoDB;

CREATE TABLE recepcionistas (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  usuario_id  BIGINT       NOT NULL,
  nombres     VARCHAR(60)  NOT NULL,
  apellidos   VARCHAR(60)  NOT NULL,
  dni         VARCHAR(8)   NOT NULL,
  telefono    VARCHAR(15)  NULL,
  turno       VARCHAR(10)  NOT NULL,       -- MANANA, TARDE
  PRIMARY KEY (id),
  UNIQUE KEY uk_recepcionistas_usuario (usuario_id),
  UNIQUE KEY uk_recepcionistas_dni (dni),
  CONSTRAINT fk_recepcionistas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

CREATE TABLE terapistas (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  usuario_id  BIGINT       NOT NULL,
  nombres     VARCHAR(60)  NOT NULL,
  apellidos   VARCHAR(60)  NOT NULL,
  dni         VARCHAR(8)   NOT NULL,
  telefono    VARCHAR(15)  NULL,
  activo      BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uk_terapistas_usuario (usuario_id),
  UNIQUE KEY uk_terapistas_dni (dni),
  CONSTRAINT fk_terapistas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

CREATE TABLE horarios (
  id            BIGINT   NOT NULL AUTO_INCREMENT,
  terapista_id  BIGINT   NOT NULL,
  dia_semana    TINYINT  NOT NULL,         -- 1 = lunes ... 7 = domingo
  hora_inicio   TIME     NOT NULL,
  hora_fin      TIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_horarios (terapista_id, dia_semana, hora_inicio),
  CONSTRAINT fk_horarios_terapista FOREIGN KEY (terapista_id) REFERENCES terapistas (id),
  CONSTRAINT ck_horarios_dia CHECK (dia_semana BETWEEN 1 AND 7),
  CONSTRAINT ck_horarios_horas CHECK (hora_inicio < hora_fin)
) ENGINE=InnoDB;

CREATE TABLE terapista_servicios (
  id            BIGINT  NOT NULL AUTO_INCREMENT,
  terapista_id  BIGINT  NOT NULL,
  servicio_id   BIGINT  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_terapista_servicio (terapista_id, servicio_id),
  CONSTRAINT fk_ts_terapista FOREIGN KEY (terapista_id) REFERENCES terapistas (id),
  CONSTRAINT fk_ts_servicio  FOREIGN KEY (servicio_id)  REFERENCES servicios (id)
) ENGINE=InnoDB;

-- ----- Clientes -----
CREATE TABLE clientes (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  usuario_id        BIGINT        NULL,    -- NULL: cliente sin cuenta en el sistema
  nombres           VARCHAR(60)   NOT NULL,
  apellidos         VARCHAR(60)   NOT NULL,
  dni               VARCHAR(8)    NOT NULL,
  fecha_nacimiento  DATE          NOT NULL,
  telefono          VARCHAR(15)   NULL,
  correo            VARCHAR(100)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_clientes_usuario (usuario_id),
  UNIQUE KEY uk_clientes_dni (dni),
  CONSTRAINT fk_clientes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

-- ----- Historia del cliente -----
CREATE TABLE antecedentes (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  cliente_id   BIGINT        NOT NULL,
  fecha        DATE          NOT NULL,     -- hasta hoy (si no se envía, el servidor pone la de hoy)
  descripcion  VARCHAR(2000) NOT NULL,     -- texto libre: alergias, enfermedades, cirugías, medicación...
  PRIMARY KEY (id),
  KEY ix_antecedentes_cliente_fecha (cliente_id, fecha),
  CONSTRAINT fk_antecedentes_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id)
) ENGINE=InnoDB;

CREATE TABLE consultas (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  cliente_id    BIGINT        NOT NULL,
  usuario_id    BIGINT        NOT NULL,    -- gerente que atendió la consulta
  fecha         DATE          NOT NULL,
  indicaciones  VARCHAR(500)  NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_consultas_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id),
  CONSTRAINT fk_consultas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

CREATE TABLE consulta_servicios (
  id           BIGINT  NOT NULL AUTO_INCREMENT,
  consulta_id  BIGINT  NOT NULL,
  servicio_id  BIGINT  NOT NULL,
  sesiones     INT     NOT NULL,           -- sesiones sugeridas de ese servicio
  PRIMARY KEY (id),
  UNIQUE KEY uk_consulta_servicio (consulta_id, servicio_id),
  CONSTRAINT fk_cs_consulta FOREIGN KEY (consulta_id) REFERENCES consultas (id),
  CONSTRAINT fk_cs_servicio FOREIGN KEY (servicio_id) REFERENCES servicios (id),
  CONSTRAINT ck_cs_sesiones CHECK (sesiones > 0)
) ENGINE=InnoDB;

-- ----- Citas (la Recepcionista registra inicio y fin, el Cliente valora) -----
CREATE TABLE citas (
  id                BIGINT       NOT NULL AUTO_INCREMENT,
  cliente_id        BIGINT       NOT NULL,
  terapista_id      BIGINT       NOT NULL,
  servicio_id       BIGINT       NOT NULL,
  recepcionista_id  BIGINT       NULL,     -- quién registró la atención
  hora_programada   DATETIME     NOT NULL,
  hora_inicio       DATETIME     NULL,     -- hora real de inicio
  hora_fin          DATETIME     NULL,     -- hora real de fin
  estado            VARCHAR(12)  NOT NULL DEFAULT 'RESERVADA',  -- RESERVADA, EN_ATENCION, ATENDIDA, CANCELADA
  valoracion        TINYINT      NULL,     -- 1 a 5, la da el cliente al terminar
  PRIMARY KEY (id),
  UNIQUE KEY uk_citas_terapista_hora (terapista_id, hora_programada),
  KEY ix_citas_cliente (cliente_id, hora_programada),
  CONSTRAINT fk_citas_cliente       FOREIGN KEY (cliente_id)       REFERENCES clientes (id),
  CONSTRAINT fk_citas_terapista     FOREIGN KEY (terapista_id)     REFERENCES terapistas (id),
  CONSTRAINT fk_citas_servicio      FOREIGN KEY (servicio_id)      REFERENCES servicios (id),
  CONSTRAINT fk_citas_recepcionista FOREIGN KEY (recepcionista_id) REFERENCES recepcionistas (id),
  CONSTRAINT ck_citas_valoracion CHECK (valoracion IS NULL OR valoracion BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- ----- Cobros -----
CREATE TABLE comprobantes (
  id          BIGINT        NOT NULL AUTO_INCREMENT,
  cita_id     BIGINT        NOT NULL,
  cliente_id  BIGINT        NOT NULL,
  tipo        VARCHAR(7)    NOT NULL,      -- BOLETA, FACTURA
  serie       VARCHAR(4)    NOT NULL,      -- B001, F001
  numero      INT           NOT NULL,
  fecha       DATETIME      NOT NULL,
  subtotal    DECIMAL(8,2)  NOT NULL,
  igv         DECIMAL(8,2)  NOT NULL,
  total       DECIMAL(8,2)  NOT NULL,
  estado      VARCHAR(10)   NOT NULL DEFAULT 'EMITIDO',  -- EMITIDO, ANULADO
  PRIMARY KEY (id),
  KEY ix_comprobantes_cita (cita_id),     -- una cita puede tener un comprobante ANULADO y otro EMITIDO
  UNIQUE KEY uk_comprobantes_serie_numero (serie, numero),
  CONSTRAINT fk_comprobantes_cita    FOREIGN KEY (cita_id)    REFERENCES citas (id),
  CONSTRAINT fk_comprobantes_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id)
) ENGINE=InnoDB;

CREATE TABLE pagos (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  comprobante_id  BIGINT        NOT NULL,
  metodo          VARCHAR(10)   NOT NULL,  -- EFECTIVO, TARJETA, YAPE, PLIN
  monto           DECIMAL(8,2)  NOT NULL,
  fecha           DATETIME      NOT NULL,
  nro_operacion   VARCHAR(30)   NULL,      -- obligatorio en TARJETA, YAPE y PLIN
  PRIMARY KEY (id),
  CONSTRAINT fk_pagos_comprobante FOREIGN KEY (comprobante_id) REFERENCES comprobantes (id),
  CONSTRAINT ck_pagos_monto CHECK (monto > 0)
) ENGINE=InnoDB;

-- =====================================================================
--  DATOS DE PRUEBA
-- =====================================================================

-- Roles (los 5 actores)
INSERT INTO roles (id, nombre) VALUES
(1, 'GERENTE'),
(2, 'TERAPISTA'),
(3, 'ADMIN'),
(4, 'CLIENTE'),
(5, 'RECEPCIONISTA');

-- Usuarios: todos con la contraseña Clave123
--   GERENTE        gerente@terapias.pe, gerente2@terapias.pe
--   ADMIN          admin@terapias.pe
--   TERAPISTA      maria.gutierrez@ ... sofia.vargas@terapias.pe (diego.ramirez@ inactivo)
--   RECEPCIONISTA  rosa.medina@, jorge.castro@, elena.ruiz@terapias.pe
--   CLIENTE        ana.quispe@correo.com ... (ricardo.vilchez@ inactivo; 2 clientes sin cuenta)
--   Sin perfil (para probar POST): nuevo.terapista@ (id 23), nueva.recepcionista@ (id 24), nuevo.cliente@correo.com (id 25)
INSERT INTO usuarios (id, email, password, rol_id, activo, creado_en) VALUES
(1, 'gerente@terapias.pe', 'Clave123', 1, TRUE, NOW() - INTERVAL 89 DAY),
(2, 'gerente2@terapias.pe', 'Clave123', 1, TRUE, NOW() - INTERVAL 88 DAY),
(3, 'admin@terapias.pe', 'Clave123', 3, TRUE, NOW() - INTERVAL 87 DAY),
(4, 'maria.gutierrez@terapias.pe', 'Clave123', 2, TRUE, NOW() - INTERVAL 86 DAY),
(5, 'carlos.paredes@terapias.pe', 'Clave123', 2, TRUE, NOW() - INTERVAL 85 DAY),
(6, 'lucia.herrera@terapias.pe', 'Clave123', 2, TRUE, NOW() - INTERVAL 84 DAY),
(7, 'pedro.sanchez@terapias.pe', 'Clave123', 2, TRUE, NOW() - INTERVAL 83 DAY),
(8, 'sofia.vargas@terapias.pe', 'Clave123', 2, TRUE, NOW() - INTERVAL 82 DAY),
(9, 'diego.ramirez@terapias.pe', 'Clave123', 2, FALSE, NOW() - INTERVAL 81 DAY),
(10, 'rosa.medina@terapias.pe', 'Clave123', 5, TRUE, NOW() - INTERVAL 80 DAY),
(11, 'jorge.castro@terapias.pe', 'Clave123', 5, TRUE, NOW() - INTERVAL 79 DAY),
(12, 'elena.ruiz@terapias.pe', 'Clave123', 5, TRUE, NOW() - INTERVAL 78 DAY),
(13, 'ana.quispe@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 77 DAY),
(14, 'luis.ramos@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 76 DAY),
(15, 'carmen.flores@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 75 DAY),
(16, 'jorge.mendoza@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 74 DAY),
(17, 'rosa.castillo@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 73 DAY),
(18, 'miguel.chavez@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 72 DAY),
(19, 'patricia.salazar@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 71 DAY),
(20, 'fernando.huaman@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 70 DAY),
(21, 'gabriela.lozano@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 69 DAY),
(22, 'ricardo.vilchez@correo.com', 'Clave123', 4, FALSE, NOW() - INTERVAL 68 DAY),
(23, 'nuevo.terapista@terapias.pe', 'Clave123', 2, TRUE, NOW() - INTERVAL 67 DAY),
(24, 'nueva.recepcionista@terapias.pe', 'Clave123', 5, TRUE, NOW() - INTERVAL 66 DAY),
(25, 'nuevo.cliente@correo.com', 'Clave123', 4, TRUE, NOW() - INTERVAL 65 DAY);

INSERT INTO parametros (id, clave, valor, descripcion) VALUES
(1, 'NOMBRE_EMPRESA', 'Centro de Terapias Bienestar', 'Nombre que aparece en los comprobantes'),
(2, 'RUC', '20999999991', 'RUC de prueba para las facturas'),
(3, 'IGV', '0.18', 'Tasa del IGV, el costo de los servicios ya lo incluye'),
(4, 'HORA_APERTURA', '08:00', 'Hora en que abre el centro'),
(5, 'HORA_CIERRE', '20:00', 'Hora en que cierra el centro'),
(6, 'DURACION_SESION_DEFECTO', '50', 'Minutos, si el servicio no indica duración'),
(7, 'SERIE_BOLETA', 'B001', 'Serie de las boletas'),
(8, 'SERIE_FACTURA', 'F001', 'Serie de las facturas');

-- Servicios: la foto es una ruta; la carpeta de imágenes la define el proyecto
INSERT INTO servicios (id, titulo, descripcion, costo, duracion, foto, activo) VALUES
(1, 'Fisioterapia', 'Rehabilitación física y manejo del dolor', 110.00, 50, '/img/servicios/fisioterapia.jpg', TRUE),
(2, 'Psicoterapia', 'Sesión individual de terapia psicológica', 130.00, 60, '/img/servicios/psicoterapia.jpg', TRUE),
(3, 'Masoterapia', 'Masaje terapéutico de relajación y descontracturante', 95.00, 45, '/img/servicios/masoterapia.jpg', TRUE),
(4, 'Terapia de lenguaje', 'Evaluación y terapia del habla y la comunicación', 100.00, 45, '/img/servicios/lenguaje.jpg', TRUE),
(5, 'Terapia ocupacional', 'Recuperación de habilidades para la vida diaria', 105.00, 50, '/img/servicios/ocupacional.jpg', TRUE),
(6, 'Drenaje linfático', 'Masaje para mejorar la circulación linfática', 120.00, 60, '/img/servicios/drenaje.jpg', TRUE),
(7, 'Electroterapia', 'Aplicación de corrientes para aliviar el dolor', 80.00, 30, '/img/servicios/electroterapia.jpg', TRUE),
(8, 'Acupuntura', 'Medicina tradicional con agujas finas', 90.00, 40, NULL, FALSE);

INSERT INTO recepcionistas (id, usuario_id, nombres, apellidos, dni, telefono, turno) VALUES
(1, 10, 'Rosa', 'Medina Torres', '47813459', '987200301', 'MANANA'),
(2, 11, 'Jorge', 'Castro Lima', '48924560', '987200302', 'TARDE'),
(3, 12, 'Elena', 'Ruiz Paz', '49035671', '987200303', 'MANANA');

INSERT INTO terapistas (id, usuario_id, nombres, apellidos, dni, telefono, activo) VALUES
(1, 4, 'María', 'Gutiérrez León', '41257893', '987100201', TRUE),
(2, 5, 'Carlos', 'Paredes Ríos', '42368904', '987100202', TRUE),
(3, 6, 'Lucía', 'Herrera Campos', '43479015', '987100203', TRUE),
(4, 7, 'Pedro', 'Sánchez Cruz', '44580126', '987100204', TRUE),
(5, 8, 'Sofía', 'Vargas Núñez', '45691237', '987100205', TRUE),
(6, 9, 'Diego', 'Ramírez Soto', '46702348', '987100206', FALSE);

-- Horarios: dia_semana 1 = lunes ... 7 = domingo (los pone el Gerente)
INSERT INTO horarios (id, terapista_id, dia_semana, hora_inicio, hora_fin) VALUES
(1, 1, 1, '08:00:00', '14:00:00'),
(2, 1, 2, '08:00:00', '14:00:00'),
(3, 1, 3, '08:00:00', '14:00:00'),
(4, 1, 4, '08:00:00', '14:00:00'),
(5, 1, 5, '08:00:00', '14:00:00'),
(6, 1, 6, '08:00:00', '14:00:00'),
(7, 2, 1, '14:00:00', '20:00:00'),
(8, 2, 2, '14:00:00', '20:00:00'),
(9, 2, 3, '14:00:00', '20:00:00'),
(10, 2, 4, '14:00:00', '20:00:00'),
(11, 2, 5, '14:00:00', '20:00:00'),
(12, 2, 6, '14:00:00', '20:00:00'),
(13, 3, 1, '08:00:00', '14:00:00'),
(14, 3, 2, '08:00:00', '14:00:00'),
(15, 3, 3, '08:00:00', '14:00:00'),
(16, 3, 4, '08:00:00', '14:00:00'),
(17, 3, 5, '08:00:00', '14:00:00'),
(18, 3, 6, '08:00:00', '14:00:00'),
(19, 4, 1, '10:00:00', '16:00:00'),
(20, 4, 2, '10:00:00', '16:00:00'),
(21, 4, 3, '10:00:00', '16:00:00'),
(22, 4, 4, '10:00:00', '16:00:00'),
(23, 4, 5, '10:00:00', '16:00:00'),
(24, 4, 6, '10:00:00', '16:00:00'),
(25, 5, 1, '14:00:00', '20:00:00'),
(26, 5, 2, '14:00:00', '20:00:00'),
(27, 5, 3, '14:00:00', '20:00:00'),
(28, 5, 4, '14:00:00', '20:00:00'),
(29, 5, 5, '14:00:00', '20:00:00'),
(30, 5, 6, '14:00:00', '20:00:00'),
(31, 6, 6, '08:00:00', '12:00:00');

-- Servicios que puede atender cada terapista
INSERT INTO terapista_servicios (id, terapista_id, servicio_id) VALUES
(1, 1, 1),
(2, 1, 5),
(3, 1, 7),
(4, 2, 2),
(5, 3, 3),
(6, 3, 6),
(7, 4, 1),
(8, 4, 4),
(9, 4, 5),
(10, 4, 7),
(11, 5, 3),
(12, 5, 6),
(13, 5, 8),
(14, 6, 1);

INSERT INTO clientes (id, usuario_id, nombres, apellidos, dni, fecha_nacimiento, telefono, correo) VALUES
(1, 13, 'Ana María', 'Quispe Huamán', '70123451', '1990-03-15', '951000001', 'ana.quispe@correo.com'),
(2, 14, 'Luis Alberto', 'Ramos Torres', '70234562', '1985-07-22', '951000002', 'luis.ramos@correo.com'),
(3, 15, 'Carmen Rosa', 'Flores Díaz', '70345673', '2001-11-05', NULL, 'carmen.flores@correo.com'),
(4, 16, 'Jorge Luis', 'Mendoza Salas', '70456784', '1978-01-30', '951000004', 'jorge.mendoza@correo.com'),
(5, 17, 'Rosa Elena', 'Castillo Vega', '70567895', '1995-09-12', '951000005', 'rosa.castillo@correo.com'),
(6, 18, 'Miguel Ángel', 'Chávez Rojas', '70678906', '1968-04-18', '951000006', 'miguel.chavez@correo.com'),
(7, 19, 'Patricia', 'Salazar Gómez', '70789017', '1999-12-01', '951000007', 'patricia.salazar@correo.com'),
(8, 20, 'Fernando', 'Huamán Ccori', '70890128', '1982-06-25', '951000008', 'fernando.huaman@correo.com'),
(9, 21, 'Gabriela', 'Lozano Pérez', '70901239', '2004-02-14', '951000009', 'gabriela.lozano@correo.com'),
(10, 22, 'Ricardo', 'Vílchez Arias', '71012340', '1975-10-09', '951000010', 'ricardo.vilchez@correo.com'),
(11, NULL, 'Teresa', 'Ponce Aguilar', '71123451', '1958-08-03', '951000011', NULL),
(12, NULL, 'Óscar', 'Navarro Silva', '71234562', '2006-05-20', '951000012', NULL);

INSERT INTO antecedentes (id, cliente_id, fecha, descripcion) VALUES
(1, 1, '2025-06-10', 'Contractura lumbar recurrente desde hace 2 años: empeora al cargar peso.'),
(2, 1, '2025-09-02', 'Alergia a la penicilina (reacción en la piel). No tomar antibióticos sin consultar.'),
(3, 2, '2025-07-15', 'Ansiedad generalizada en tratamiento con psicólogo. Duerme mal en épocas de estrés.'),
(4, 3, '2025-05-20', 'Operación de rodilla derecha (menisco) en 2025. Rehabilitación incompleta.'),
(5, 4, '2025-04-08', 'Hipertensión arterial controlada. Toma losartán 50 mg cada mañana.'),
(6, 4, '2025-10-01', 'Mareos al levantarse rápido. Medir la presión antes de cada sesión.'),
(7, 5, '2025-08-12', 'Tendinitis en hombro izquierdo por trabajo en computadora.'),
(8, 6, '2025-03-25', 'Artrosis de cadera. Prótesis de cadera derecha en 2024: evitar giros bruscos.'),
(9, 6, '2025-11-05', 'Dolor de rodilla izquierda al subir escaleras.'),
(10, 7, '2025-06-30', 'Alergia al látex: usar guantes de nitrilo.'),
(11, 8, '2025-09-18', 'Esguince de tobillo grado II (deporte). Ya camina sin dolor.'),
(12, 9, '2025-02-14', 'Retraso leve del lenguaje en la infancia: hoy solo seguimiento.'),
(13, 11, '2025-01-20', 'Diabetes tipo 2 con metformina 850 mg. Revisar los pies en cada sesión.'),
(14, 11, '2025-12-03', 'Hormigueo en las manos por las noches.'),
(15, 12, '2025-07-07', 'Fractura de muñeca derecha consolidada: falta fuerza al agarrar.');

-- Consultas: el Gerente da indicaciones y sugiere servicios con número de sesiones
INSERT INTO consultas (id, cliente_id, usuario_id, fecha, indicaciones) VALUES
(1, 1, 1, IF(DAYOFWEEK((CURDATE() - INTERVAL 40 DAY)) = 1, (CURDATE() - INTERVAL 40 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 40 DAY)), 'Dolor lumbar crónico. Evitar cargar peso y hacer los ejercicios en casa.'),
(2, 2, 2, IF(DAYOFWEEK((CURDATE() - INTERVAL 35 DAY)) = 1, (CURDATE() - INTERVAL 35 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 35 DAY)), 'Ansiedad por trabajo. Continuar con sesiones semanales de psicoterapia.'),
(3, 3, 1, IF(DAYOFWEEK((CURDATE() - INTERVAL 30 DAY)) = 1, (CURDATE() - INTERVAL 30 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 30 DAY)), 'Rehabilitación posoperatoria de rodilla. Fortalecer cuádriceps.'),
(4, 5, 1, IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), 'Tendinitis de hombro. Reposo relativo y terapia física.'),
(5, 6, 2, IF(DAYOFWEEK((CURDATE() - INTERVAL 20 DAY)) = 1, (CURDATE() - INTERVAL 20 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 20 DAY)), 'Artrosis de cadera. Mantener actividad suave y terapia ocupacional.'),
(6, 8, 1, IF(DAYOFWEEK((CURDATE() - INTERVAL 12 DAY)) = 1, (CURDATE() - INTERVAL 12 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 12 DAY)), 'Esguince de tobillo. Terapia física y vendaje funcional.'),
(7, 1, 2, IF(DAYOFWEEK((CURDATE() - INTERVAL 5 DAY)) = 1, (CURDATE() - INTERVAL 5 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 5 DAY)), 'Control: mejora del dolor lumbar. Agregar masoterapia.'),
(8, 9, 1, IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), 'Evaluación del habla. Iniciar terapia de lenguaje.');

INSERT INTO consulta_servicios (id, consulta_id, servicio_id, sesiones) VALUES
(1, 1, 1, 10),
(2, 1, 7, 5),
(3, 2, 2, 8),
(4, 3, 1, 12),
(5, 3, 5, 4),
(6, 4, 1, 6),
(7, 4, 7, 6),
(8, 5, 5, 8),
(9, 5, 3, 4),
(10, 6, 1, 6),
(11, 7, 3, 4),
(12, 8, 4, 10);

-- Citas: fechas relativas a HOY (pasadas, de hoy y futuras); un domingo se corre al lunes
INSERT INTO citas (id, cliente_id, terapista_id, servicio_id, recepcionista_id, hora_programada, hora_inicio, hora_fin, estado, valoracion) VALUES
(1, 1, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 30 DAY)) = 1, (CURDATE() - INTERVAL 30 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 30 DAY)), '08:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 30 DAY)) = 1, (CURDATE() - INTERVAL 30 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 30 DAY)), '08:00:00') + INTERVAL 3 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 30 DAY)) = 1, (CURDATE() - INTERVAL 30 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 30 DAY)), '08:00:00') + INTERVAL 53 MINUTE, 'ATENDIDA', 5),
(2, 1, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 27 DAY)) = 1, (CURDATE() - INTERVAL 27 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 27 DAY)), '09:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 27 DAY)) = 1, (CURDATE() - INTERVAL 27 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 27 DAY)), '09:00:00') + INTERVAL 5 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 27 DAY)) = 1, (CURDATE() - INTERVAL 27 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 27 DAY)), '09:00:00') + INTERVAL 50 MINUTE, 'ATENDIDA', 4),
(3, 1, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 23 DAY)) = 1, (CURDATE() - INTERVAL 23 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 23 DAY)), '10:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 23 DAY)) = 1, (CURDATE() - INTERVAL 23 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 23 DAY)), '10:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 23 DAY)) = 1, (CURDATE() - INTERVAL 23 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 23 DAY)), '10:00:00') + INTERVAL 45 MINUTE, 'ATENDIDA', 5),
(4, 1, 4, 7, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 20 DAY)) = 1, (CURDATE() - INTERVAL 20 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 20 DAY)), '10:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 20 DAY)) = 1, (CURDATE() - INTERVAL 20 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 20 DAY)), '10:00:00') + INTERVAL 3 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 20 DAY)) = 1, (CURDATE() - INTERVAL 20 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 20 DAY)), '10:00:00') + INTERVAL 28 MINUTE, 'ATENDIDA', 4),
(5, 3, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), '11:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), '11:00:00') + INTERVAL 10 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), '11:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', 5),
(6, 3, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 18 DAY)) = 1, (CURDATE() - INTERVAL 18 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 18 DAY)), '12:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 18 DAY)) = 1, (CURDATE() - INTERVAL 18 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 18 DAY)), '12:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 18 DAY)) = 1, (CURDATE() - INTERVAL 18 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 18 DAY)), '12:00:00') + INTERVAL 45 MINUTE, 'ATENDIDA', 3),
(7, 3, 4, 5, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 16 DAY)) = 1, (CURDATE() - INTERVAL 16 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 16 DAY)), '11:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 16 DAY)) = 1, (CURDATE() - INTERVAL 16 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 16 DAY)), '11:00:00') + INTERVAL 5 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 16 DAY)) = 1, (CURDATE() - INTERVAL 16 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 16 DAY)), '11:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', 4),
(8, 2, 2, 2, 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 28 DAY)) = 1, (CURDATE() - INTERVAL 28 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 28 DAY)), '14:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 28 DAY)) = 1, (CURDATE() - INTERVAL 28 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 28 DAY)), '14:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 28 DAY)) = 1, (CURDATE() - INTERVAL 28 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 28 DAY)), '14:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', 5),
(9, 2, 2, 2, 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 21 DAY)) = 1, (CURDATE() - INTERVAL 21 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 21 DAY)), '15:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 21 DAY)) = 1, (CURDATE() - INTERVAL 21 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 21 DAY)), '15:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 21 DAY)) = 1, (CURDATE() - INTERVAL 21 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 21 DAY)), '15:00:00') + INTERVAL 65 MINUTE, 'ATENDIDA', 5),
(10, 2, 2, 2, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 14 DAY)) = 1, (CURDATE() - INTERVAL 14 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 14 DAY)), '16:00:00'), NULL, NULL, 'CANCELADA', NULL),
(11, 5, 4, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 15 DAY)) = 1, (CURDATE() - INTERVAL 15 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 15 DAY)), '12:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 15 DAY)) = 1, (CURDATE() - INTERVAL 15 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 15 DAY)), '12:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 15 DAY)) = 1, (CURDATE() - INTERVAL 15 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 15 DAY)), '12:00:00') + INTERVAL 45 MINUTE, 'ATENDIDA', 4),
(12, 5, 4, 7, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 13 DAY)) = 1, (CURDATE() - INTERVAL 13 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 13 DAY)), '13:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 13 DAY)) = 1, (CURDATE() - INTERVAL 13 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 13 DAY)), '13:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 13 DAY)) = 1, (CURDATE() - INTERVAL 13 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 13 DAY)), '13:00:00') + INTERVAL 25 MINUTE, 'ATENDIDA', 5),
(13, 6, 3, 3, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 12 DAY)) = 1, (CURDATE() - INTERVAL 12 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 12 DAY)), '08:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 12 DAY)) = 1, (CURDATE() - INTERVAL 12 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 12 DAY)), '08:00:00') + INTERVAL 10 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 12 DAY)) = 1, (CURDATE() - INTERVAL 12 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 12 DAY)), '08:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', 5),
(14, 6, 5, 6, 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 10 DAY)) = 1, (CURDATE() - INTERVAL 10 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 10 DAY)), '14:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 10 DAY)) = 1, (CURDATE() - INTERVAL 10 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 10 DAY)), '14:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 10 DAY)) = 1, (CURDATE() - INTERVAL 10 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 10 DAY)), '14:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', 4),
(15, 8, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 8 DAY)) = 1, (CURDATE() - INTERVAL 8 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 8 DAY)), '13:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 8 DAY)) = 1, (CURDATE() - INTERVAL 8 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 8 DAY)), '13:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 8 DAY)) = 1, (CURDATE() - INTERVAL 8 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 8 DAY)), '13:00:00') + INTERVAL 50 MINUTE, 'ATENDIDA', 4),
(16, 4, 3, 6, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 7 DAY)) = 1, (CURDATE() - INTERVAL 7 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 7 DAY)), '09:00:00'), NULL, NULL, 'CANCELADA', NULL),
(17, 7, 5, 3, 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 6 DAY)) = 1, (CURDATE() - INTERVAL 6 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 6 DAY)), '15:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 6 DAY)) = 1, (CURDATE() - INTERVAL 6 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 6 DAY)), '15:00:00') + INTERVAL 3 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 6 DAY)) = 1, (CURDATE() - INTERVAL 6 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 6 DAY)), '15:00:00') + INTERVAL 53 MINUTE, 'ATENDIDA', 3),
(18, 1, 3, 3, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 4 DAY)) = 1, (CURDATE() - INTERVAL 4 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 4 DAY)), '10:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 4 DAY)) = 1, (CURDATE() - INTERVAL 4 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 4 DAY)), '10:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 4 DAY)) = 1, (CURDATE() - INTERVAL 4 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 4 DAY)), '10:00:00') + INTERVAL 40 MINUTE, 'ATENDIDA', NULL),
(19, 11, 4, 5, 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), '14:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), '14:00:00') + INTERVAL 10 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), '14:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', NULL),
(20, 12, 1, 7, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 2 DAY)) = 1, (CURDATE() - INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 2 DAY)), '08:30:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 2 DAY)) = 1, (CURDATE() - INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 2 DAY)), '08:30:00') + INTERVAL 10 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 2 DAY)) = 1, (CURDATE() - INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 2 DAY)), '08:30:00') + INTERVAL 40 MINUTE, 'ATENDIDA', 4),
(21, 2, 2, 2, 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '17:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '17:00:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '17:00:00') + INTERVAL 60 MINUTE, 'ATENDIDA', 5),
(22, 1, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '09:30:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '09:30:00') + INTERVAL 3 MINUTE, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '09:30:00') + INTERVAL 48 MINUTE, 'ATENDIDA', 5),
(23, 3, 1, 1, 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '11:30:00'), TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '11:30:00') + INTERVAL 10 MINUTE, NULL, 'EN_ATENCION', NULL),
(24, 8, 4, 1, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '10:30:00'), NULL, NULL, 'RESERVADA', NULL),
(25, 6, 5, 6, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '15:30:00'), NULL, NULL, 'RESERVADA', NULL),
(26, 9, 3, 6, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '12:00:00'), NULL, NULL, 'CANCELADA', NULL),
(27, 1, 3, 3, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 2 DAY)) = 1, (CURDATE() + INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 2 DAY)), '10:30:00'), NULL, NULL, 'RESERVADA', NULL),
(28, 2, 2, 2, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 2 DAY)) = 1, (CURDATE() + INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 2 DAY)), '18:00:00'), NULL, NULL, 'RESERVADA', NULL),
(29, 3, 1, 1, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 3 DAY)) = 1, (CURDATE() + INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 3 DAY)), '12:30:00'), NULL, NULL, 'RESERVADA', NULL),
(30, 5, 4, 1, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 3 DAY)) = 1, (CURDATE() + INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 3 DAY)), '11:30:00'), NULL, NULL, 'RESERVADA', NULL),
(31, 9, 5, 8, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 4 DAY)) = 1, (CURDATE() + INTERVAL 4 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 4 DAY)), '16:00:00'), NULL, NULL, 'RESERVADA', NULL),
(32, 4, 3, 3, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 5 DAY)) = 1, (CURDATE() + INTERVAL 5 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 5 DAY)), '08:30:00'), NULL, NULL, 'RESERVADA', NULL),
(33, 7, 5, 6, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 6 DAY)) = 1, (CURDATE() + INTERVAL 6 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 6 DAY)), '17:00:00'), NULL, NULL, 'RESERVADA', NULL),
(34, 11, 4, 5, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 7 DAY)) = 1, (CURDATE() + INTERVAL 7 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 7 DAY)), '15:00:00'), NULL, NULL, 'RESERVADA', NULL),
(35, 8, 1, 1, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 8 DAY)) = 1, (CURDATE() + INTERVAL 8 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 8 DAY)), '10:30:00'), NULL, NULL, 'RESERVADA', NULL),
(36, 12, 4, 7, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 9 DAY)) = 1, (CURDATE() + INTERVAL 9 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 9 DAY)), '12:30:00'), NULL, NULL, 'RESERVADA', NULL);

-- Comprobantes: el costo del servicio incluye IGV (subtotal = total / 1.18)
INSERT INTO comprobantes (id, cita_id, cliente_id, tipo, serie, numero, fecha, subtotal, igv, total, estado) VALUES
(1, 1, 1, 'BOLETA', 'B001', 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 30 DAY)) = 1, (CURDATE() - INTERVAL 30 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 30 DAY)), '08:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO'),
(2, 2, 1, 'BOLETA', 'B001', 2, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 27 DAY)) = 1, (CURDATE() - INTERVAL 27 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 27 DAY)), '09:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO'),
(3, 3, 1, 'BOLETA', 'B001', 3, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 23 DAY)) = 1, (CURDATE() - INTERVAL 23 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 23 DAY)), '10:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'ANULADO'),
(4, 4, 1, 'BOLETA', 'B001', 4, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 20 DAY)) = 1, (CURDATE() - INTERVAL 20 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 20 DAY)), '10:00:00') + INTERVAL 35 MINUTE, 67.80, 12.20, 80.00, 'EMITIDO'),
(5, 5, 3, 'BOLETA', 'B001', 5, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), '11:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO'),
(6, 6, 3, 'BOLETA', 'B001', 6, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 18 DAY)) = 1, (CURDATE() - INTERVAL 18 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 18 DAY)), '12:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO'),
(7, 7, 3, 'BOLETA', 'B001', 7, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 16 DAY)) = 1, (CURDATE() - INTERVAL 16 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 16 DAY)), '11:00:00') + INTERVAL 55 MINUTE, 88.98, 16.02, 105.00, 'EMITIDO'),
(8, 8, 2, 'BOLETA', 'B001', 8, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 28 DAY)) = 1, (CURDATE() - INTERVAL 28 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 28 DAY)), '14:00:00') + INTERVAL 65 MINUTE, 110.17, 19.83, 130.00, 'EMITIDO'),
(9, 9, 2, 'BOLETA', 'B001', 9, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 21 DAY)) = 1, (CURDATE() - INTERVAL 21 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 21 DAY)), '15:00:00') + INTERVAL 65 MINUTE, 110.17, 19.83, 130.00, 'EMITIDO'),
(10, 11, 5, 'BOLETA', 'B001', 10, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 15 DAY)) = 1, (CURDATE() - INTERVAL 15 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 15 DAY)), '12:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO'),
(11, 12, 5, 'BOLETA', 'B001', 11, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 13 DAY)) = 1, (CURDATE() - INTERVAL 13 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 13 DAY)), '13:00:00') + INTERVAL 35 MINUTE, 67.80, 12.20, 80.00, 'EMITIDO'),
(12, 13, 6, 'BOLETA', 'B001', 12, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 12 DAY)) = 1, (CURDATE() - INTERVAL 12 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 12 DAY)), '08:00:00') + INTERVAL 50 MINUTE, 80.51, 14.49, 95.00, 'EMITIDO'),
(13, 14, 6, 'BOLETA', 'B001', 13, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 10 DAY)) = 1, (CURDATE() - INTERVAL 10 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 10 DAY)), '14:00:00') + INTERVAL 65 MINUTE, 101.69, 18.31, 120.00, 'EMITIDO'),
(14, 15, 8, 'BOLETA', 'B001', 14, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 8 DAY)) = 1, (CURDATE() - INTERVAL 8 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 8 DAY)), '13:00:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO'),
(15, 17, 7, 'BOLETA', 'B001', 15, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 6 DAY)) = 1, (CURDATE() - INTERVAL 6 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 6 DAY)), '15:00:00') + INTERVAL 50 MINUTE, 80.51, 14.49, 95.00, 'EMITIDO'),
(16, 18, 1, 'BOLETA', 'B001', 16, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 4 DAY)) = 1, (CURDATE() - INTERVAL 4 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 4 DAY)), '10:00:00') + INTERVAL 50 MINUTE, 80.51, 14.49, 95.00, 'EMITIDO'),
(17, 19, 11, 'FACTURA', 'F001', 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), '14:00:00') + INTERVAL 55 MINUTE, 88.98, 16.02, 105.00, 'EMITIDO'),
(18, 20, 12, 'BOLETA', 'B001', 17, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 2 DAY)) = 1, (CURDATE() - INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 2 DAY)), '08:30:00') + INTERVAL 35 MINUTE, 67.80, 12.20, 80.00, 'EMITIDO'),
(19, 22, 1, 'BOLETA', 'B001', 18, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '09:30:00') + INTERVAL 55 MINUTE, 93.22, 16.78, 110.00, 'EMITIDO');

-- Pagos: EFECTIVO sin número de operación; TARJETA, YAPE y PLIN con número
INSERT INTO pagos (id, comprobante_id, metodo, monto, fecha, nro_operacion) VALUES
(1, 1, 'YAPE', 110.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 30 DAY)) = 1, (CURDATE() - INTERVAL 30 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 30 DAY)), '08:00:00') + INTERVAL 56 MINUTE, 'YP100001'),
(2, 2, 'TARJETA', 110.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 27 DAY)) = 1, (CURDATE() - INTERVAL 27 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 27 DAY)), '09:00:00') + INTERVAL 56 MINUTE, 'TJ100002'),
(3, 4, 'EFECTIVO', 80.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 20 DAY)) = 1, (CURDATE() - INTERVAL 20 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 20 DAY)), '10:00:00') + INTERVAL 36 MINUTE, NULL),
(4, 5, 'EFECTIVO', 55.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), '11:00:00') + INTERVAL 56 MINUTE, NULL),
(5, 5, 'YAPE', 55.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 25 DAY)) = 1, (CURDATE() - INTERVAL 25 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 25 DAY)), '11:00:00') + INTERVAL 56 MINUTE, 'YP100005'),
(6, 6, 'EFECTIVO', 110.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 18 DAY)) = 1, (CURDATE() - INTERVAL 18 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 18 DAY)), '12:00:00') + INTERVAL 56 MINUTE, NULL),
(7, 7, 'YAPE', 105.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 16 DAY)) = 1, (CURDATE() - INTERVAL 16 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 16 DAY)), '11:00:00') + INTERVAL 56 MINUTE, 'YP100007'),
(8, 8, 'TARJETA', 130.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 28 DAY)) = 1, (CURDATE() - INTERVAL 28 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 28 DAY)), '14:00:00') + INTERVAL 66 MINUTE, 'TJ100008'),
(9, 9, 'PLIN', 130.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 21 DAY)) = 1, (CURDATE() - INTERVAL 21 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 21 DAY)), '15:00:00') + INTERVAL 66 MINUTE, 'PL100009'),
(10, 10, 'EFECTIVO', 110.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 15 DAY)) = 1, (CURDATE() - INTERVAL 15 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 15 DAY)), '12:00:00') + INTERVAL 56 MINUTE, NULL),
(11, 11, 'YAPE', 80.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 13 DAY)) = 1, (CURDATE() - INTERVAL 13 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 13 DAY)), '13:00:00') + INTERVAL 36 MINUTE, 'YP100011'),
(12, 12, 'EFECTIVO', 95.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 12 DAY)) = 1, (CURDATE() - INTERVAL 12 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 12 DAY)), '08:00:00') + INTERVAL 51 MINUTE, NULL),
(13, 13, 'YAPE', 120.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 10 DAY)) = 1, (CURDATE() - INTERVAL 10 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 10 DAY)), '14:00:00') + INTERVAL 66 MINUTE, 'YP100013'),
(14, 14, 'TARJETA', 110.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 8 DAY)) = 1, (CURDATE() - INTERVAL 8 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 8 DAY)), '13:00:00') + INTERVAL 56 MINUTE, 'TJ100014'),
(15, 15, 'PLIN', 95.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 6 DAY)) = 1, (CURDATE() - INTERVAL 6 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 6 DAY)), '15:00:00') + INTERVAL 51 MINUTE, 'PL100015'),
(16, 16, 'EFECTIVO', 95.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 4 DAY)) = 1, (CURDATE() - INTERVAL 4 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 4 DAY)), '10:00:00') + INTERVAL 51 MINUTE, NULL),
(17, 17, 'YAPE', 105.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), '14:00:00') + INTERVAL 56 MINUTE, 'YP100017'),
(18, 18, 'EFECTIVO', 80.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 2 DAY)) = 1, (CURDATE() - INTERVAL 2 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 2 DAY)), '08:30:00') + INTERVAL 36 MINUTE, NULL),
(19, 19, 'YAPE', 110.00, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '09:30:00') + INTERVAL 56 MINUTE, 'YP100019');

-- Auditoría: quién hizo qué
INSERT INTO auditoria (id, usuario_id, accion, tabla, registro_id, fecha) VALUES
(1, 3, 'LOGIN', NULL, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '08:00:00')),
(2, 3, 'CREAR', 'usuarios', 9, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '08:10:00')),
(3, 1, 'LOGIN', NULL, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '08:30:00')),
(4, 1, 'CREAR', 'servicios', 7, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '08:40:00')),
(5, 1, 'ACTUALIZAR', 'horarios', 4, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 1 DAY)) = 1, (CURDATE() - INTERVAL 1 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 1 DAY)), '09:00:00')),
(6, 1, 'CREAR', 'consultas', 8, TIMESTAMP(IF(DAYOFWEEK((CURDATE() - INTERVAL 3 DAY)) = 1, (CURDATE() - INTERVAL 3 DAY) + INTERVAL 1 DAY, (CURDATE() - INTERVAL 3 DAY)), '10:00:00')),
(7, 10, 'LOGIN', NULL, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '07:55:00')),
(8, 10, 'ACTUALIZAR', 'citas', 22, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '10:30:00')),
(9, 10, 'CREAR', 'comprobantes', 19, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '10:35:00')),
(10, 4, 'LOGIN', NULL, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '08:05:00')),
(11, 4, 'ACTUALIZAR', 'terapistas', 1, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '08:07:00')),
(12, 13, 'LOGIN', NULL, NULL, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '07:30:00')),
(13, 3, 'ACTUALIZAR', 'usuarios', 22, TIMESTAMP(IF(DAYOFWEEK((CURDATE() + INTERVAL 0 DAY)) = 1, (CURDATE() + INTERVAL 0 DAY) + INTERVAL 1 DAY, (CURDATE() + INTERVAL 0 DAY)), '09:00:00'));
