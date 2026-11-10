-- Se ejecuta en cada arranque. INSERT IGNORE omite la fila si el nombre ya existe
-- (nombre es UNIQUE), así no se duplican los datos. Funciona en MySQL y en H2.
INSERT IGNORE INTO especialidades (nombre, descripcion, precio, activa) VALUES
('Fisioterapia', 'Rehabilitación de lesiones musculares y articulares', 110.00, true),
('Psicoterapia', 'Acompañamiento psicológico individual',               130.00, true),
('Masoterapia',  'Masaje terapéutico',                                   95.00, true),
('Ergoterapia',  'Terapia ocupacional para actividades diarias',        105.00, true),
('Acupuntura',   'Servicio suspendido temporalmente',                    90.00, false);