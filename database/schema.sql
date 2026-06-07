-- ============================================================
--  Lumo — Schema + Seed Data
--  Ejecutar en MySQL/MariaDB con: CREATE DATABASE duolingo;
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------  TABLAS  -------------------

CREATE TABLE IF NOT EXISTS usuario (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100)  NOT NULL,
  email       VARCHAR(100)  NOT NULL UNIQUE,
  password    VARCHAR(255)  NOT NULL,
  created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  TIMESTAMP     NULL
);

CREATE TABLE IF NOT EXISTS seccion (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(150)  NOT NULL,
  created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  TIMESTAMP     NULL
);

CREATE TABLE IF NOT EXISTS seccion_detalle (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  seccion_id  INT           NOT NULL,
  nombre      VARCHAR(150)  NOT NULL,
  tipo        VARCHAR(20)   NOT NULL DEFAULT 'lesson',  -- lesson | review | chest | crown
  color       VARCHAR(20)   NOT NULL DEFAULT '#ff7a45',
  orden       INT           NOT NULL DEFAULT 0,
  created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  TIMESTAMP     NULL,
  FOREIGN KEY (seccion_id) REFERENCES seccion(id)
);

-- tipo_pregunta: multiple_choice | build | match
CREATE TABLE IF NOT EXISTS preguntas (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  seccion_detalle_id  INT           NOT NULL,
  nombre              TEXT          NOT NULL,
  tipo_pregunta       VARCHAR(20)   NOT NULL DEFAULT 'multiple_choice',
  config              TEXT          NULL,   -- JSON para build/match
  created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at          TIMESTAMP     NULL,
  FOREIGN KEY (seccion_detalle_id) REFERENCES seccion_detalle(id)
);

CREATE TABLE IF NOT EXISTS respuesta (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  pregunta_id  INT           NOT NULL,
  nombre       VARCHAR(255)  NOT NULL,
  es_correcta  TINYINT(1)    NOT NULL DEFAULT 0,
  created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   TIMESTAMP     NULL,
  FOREIGN KEY (pregunta_id) REFERENCES preguntas(id)
);

CREATE TABLE IF NOT EXISTS usuario_seccion_detalle (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id          INT           NOT NULL,
  seccion_detalle_id  INT           NOT NULL,
  realizado           TINYINT(1)    NOT NULL DEFAULT 0,
  fecha_creacion      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at          TIMESTAMP     NULL,
  UNIQUE KEY uq_user_detalle (usuario_id, seccion_detalle_id),
  FOREIGN KEY (usuario_id)         REFERENCES usuario(id),
  FOREIGN KEY (seccion_detalle_id) REFERENCES seccion_detalle(id)
);

SET FOREIGN_KEY_CHECKS = 1;

-- -------------------  SEED DATA  -------------------

INSERT INTO seccion (id, nombre) VALUES
(1, 'Etapa 1 · Saluda y despídete');

INSERT INTO seccion_detalle (id, seccion_id, nombre, tipo, color, orden) VALUES
(1, 1, 'Saludos básicos',         'lesson', '#ff7a45', 1),
(2, 1, 'Cómo estás',              'lesson', '#ff7a45', 2),
(3, 1, 'Repaso rápido',           'review', '#ffc53d', 3),
(4, 1, 'Presentarte',             'lesson', '#ff7a45', 4),
(5, 1, 'Cofre sorpresa',          'chest',  '#2dd4bf', 5),
(6, 1, 'Despedidas',              'lesson', '#ff7a45', 6),
(7, 1, 'Repaso de la sección',    'review', '#ffc53d', 7),
(8, 1, '¡Lección legendaria!',    'crown',  '#5fcf2f', 8);

-- ===== NODO 1 — Saludos básicos =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(1,  1, '¿Cómo se dice «Hola»?',                            'multiple_choice', NULL),
(2,  1, 'Selecciona el significado de «Good morning»',       'multiple_choice', NULL),
(3,  1, 'Empareja los pares',                                'match',           '{"pairs":[["Hello","Hola"],["Thanks","Gracias"],["Bye","Adiós"],["Please","Por favor"]]}'),
(4,  1, 'Hola, buenas tardes',                               'build',           '{"bank":["Hello","good","afternoon","morning","night","bye"],"answer":["Hello","good","afternoon"]}'),
(5,  1, '¿Qué significa «Welcome»?',                         'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(1, 'Goodbye', 0),(1, 'Hello',   1),(1, 'Please', 0),(1, 'Sorry',   0),
(2, 'Buenas noches', 0),(2, 'Buenos días', 1),(2, 'Hasta luego', 0),(2, 'Buenas tardes', 0),
(5, 'Bienvenido', 1),(5, 'Despedida', 0),(5, 'Buenas noches', 0),(5, 'Por favor', 0);

-- ===== NODO 2 — Cómo estás =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(6,  2, '¿Qué significa «How are you?»',                     'multiple_choice', NULL),
(7,  2, 'Estoy muy bien, gracias',                           'build',           '{"bank":["I","am","very","well","thanks","you","fine","good"],"answer":["I","am","very","well","thanks"]}'),
(8,  2, 'Selecciona el significado de «I''m fine»',          'multiple_choice', NULL),
(9,  2, 'Empareja los pares',                                'match',           '{"pairs":[["Good","Bien"],["Bad","Mal"],["Tired","Cansado"],["Happy","Feliz"]]}'),
(10, 2, '¿Cómo respondes a «How are you?»',                  'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(6,  '¿De dónde eres?',    0),(6,  '¿Cómo estás?',     1),(6,  '¿Cómo te llamas?', 0),(6,  '¿Cuántos años tienes?', 0),
(8,  'Estoy cansado',      0),(8,  'Estoy bien',        1),(8,  'Estoy ocupado',     0),(8,  'Estoy aquí',          0),
(10, 'My name is Ana',     0),(10, 'I''m fine, thanks', 1),(10, 'Goodbye',           0),(10, 'You''re welcome',     0);

-- ===== NODO 3 — Repaso rápido =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(11, 3, '¿Qué significa «Goodbye»?',                         'multiple_choice', NULL),
(12, 3, 'Empareja los pares',                                'match',           '{"pairs":[["Hello","Hola"],["How are you?","¿Cómo estás?"],["I''m fine","Estoy bien"],["Thanks","Gracias"]]}'),
(13, 3, 'Hola, ¿cómo estás?',                               'build',           '{"bank":["Hello","how","are","you","is","fine","good"],"answer":["Hello","how","are","you"]}'),
(14, 3, 'Selecciona el significado de «Please»',             'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(11, 'Hola',       0),(11, 'Gracias',  0),(11, 'Adiós',      1),(11, 'Por favor',  0),
(14, 'Gracias',    0),(14, 'Por favor',1),(14, 'Perdón',      0),(14, 'De nada',    0);

-- ===== NODO 4 — Presentarte =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(15, 4, 'Yo me llamo Ana',                                   'build',           '{"bank":["My","name","is","Ana","are","you","I''m"],"answer":["My","name","is","Ana"]}'),
(16, 4, '¿Qué significa «What''s your name?»',              'multiple_choice', NULL),
(17, 4, 'Empareja los pares',                                'match',           '{"pairs":[["Name","Nombre"],["I am","Yo soy"],["From","De"],["Nice","Encantado"]]}'),
(18, 4, 'Selecciona el significado de «Nice to meet you»',   'multiple_choice', NULL),
(19, 4, 'Soy de México',                                     'build',           '{"bank":["I","am","from","Mexico","to","is","name"],"answer":["I","am","from","Mexico"]}');

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(16, '¿Cuántos años tienes?',       0),(16, '¿Cómo te llamas?',         1),(16, '¿De dónde eres?',          0),(16, '¿Cómo estás?',              0),
(18, 'Hasta pronto',                0),(18, 'Encantado de conocerte',    1),(18, 'Buenos días',              0),(18, 'Muchas gracias',             0);

-- ===== NODO 5 — Cofre sorpresa =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(20, 5, '¿Qué significa «Thank you very much»?',             'multiple_choice', NULL),
(21, 5, '¿Cómo se dice «De nada»?',                          'multiple_choice', NULL),
(22, 5, '¿Qué significa «Excuse me»?',                       'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(20, 'Muchas gracias',    1),(20, 'De nada',          0),(20, 'Lo siento',        0),(20, 'Por favor',        0),
(21, 'Sorry',             0),(21, 'Please',           0),(21, 'You''re welcome',  1),(21, 'Excuse me',        0),
(22, 'Perdona / Con permiso', 1),(22, 'Gracias',      0),(22, 'Adiós',            0),(22, 'Bienvenido',       0);

-- ===== NODO 6 — Despedidas =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(23, 6, '¿Cómo se dice «Adiós»?',                            'multiple_choice', NULL),
(24, 6, 'Empareja los pares',                                'match',           '{"pairs":[["See you","Nos vemos"],["Later","Luego"],["Take care","Cuídate"],["Good night","Buenas noches"]]}'),
(25, 6, 'Nos vemos mañana',                                  'build',           '{"bank":["See","you","tomorrow","later","night","soon"],"answer":["See","you","tomorrow"]}'),
(26, 6, 'Selecciona el significado de «Take care»',          'multiple_choice', NULL),
(27, 6, '¿Qué significa «See you later»?',                   'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(23, 'Hello',         0),(23, 'Goodbye',        1),(23, 'Please',          0),(23, 'Welcome',         0),
(26, 'Cuídate',       1),(26, 'Apúrate',        0),(26, 'Buenos días',     0),(26, 'De nada',         0),
(27, 'Te veo ahora',  0),(27, 'Nos vemos luego',1),(27, 'Buenas noches',   0),(27, 'Encantado',       0);

-- ===== NODO 7 — Repaso de la sección =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(28, 7, 'Empareja los pares',                                'match',           '{"pairs":[["Hello","Hola"],["Goodbye","Adiós"],["Thanks","Gracias"],["Sorry","Perdón"]]}'),
(29, 7, 'Encantado, soy Ana',                                'build',           '{"bank":["Nice","to","meet","you","I''m","Ana","from","name"],"answer":["Nice","to","meet","you","I''m","Ana"]}'),
(30, 7, '¿Qué significa «How are you?»',                     'multiple_choice', NULL),
(31, 7, 'Selecciona el significado de «Take care»',          'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(30, '¿Cómo estás?',  1),(30, '¿Quién eres?',  0),(30, '¿Dónde estás?',  0),(30, '¿Qué hora es?', 0),
(31, 'Hasta luego',   0),(31, 'Cuídate',        1),(31, 'Por favor',      0),(31, 'Bienvenido',     0);

-- ===== NODO 8 — Lección legendaria =====

INSERT INTO preguntas (id, seccion_detalle_id, nombre, tipo_pregunta, config) VALUES
(32, 8, '¿Qué significa «See you soon»?',                    'multiple_choice', NULL),
(33, 8, 'Buenas noches, cuídate',                            'build',           '{"bank":["Good","night","take","care","morning","you","see"],"answer":["Good","night","take","care"]}'),
(34, 8, 'Empareja los pares',                                'match',           '{"pairs":[["Welcome","Bienvenido"],["Please","Por favor"],["Sorry","Perdón"],["Thanks","Gracias"]]}'),
(35, 8, '¿Cómo se dice «Encantado de conocerte»?',           'multiple_choice', NULL),
(36, 8, '¿Qué significa «Have a nice day»?',                 'multiple_choice', NULL);

INSERT INTO respuesta (pregunta_id, nombre, es_correcta) VALUES
(32, 'Hasta pronto',            1),(32, 'Buenas noches',        0),(32, 'Encantado',             0),(32, 'De nada',               0),
(35, 'See you later',           0),(35, 'Nice to meet you',     1),(35, 'How are you?',          0),(35, 'Take care',             0),
(36, 'Buen provecho',           0),(36, 'Que tengas un buen día',1),(36, 'Hasta mañana',         0),(36, 'Buenas tardes',         0);
