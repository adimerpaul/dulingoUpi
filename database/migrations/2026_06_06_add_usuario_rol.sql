ALTER TABLE usuario
  ADD COLUMN rol VARCHAR(30) NOT NULL DEFAULT 'Estudiante' AFTER password;

UPDATE usuario
SET rol = 'Administrador'
WHERE id = 1;
