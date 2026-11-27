-- ============================================================================
-- Sistema de Biblioteca del TecNM Campus Monclova
-- Script de Creación y Población de Base de Datos PostgreSQL
-- ============================================================================

-- Eliminar vistas, triggers y tablas en orden inverso si ya existen para evitar conflictos de FK
DROP VIEW IF EXISTS vw_attendance_summary_by_type CASCADE;
DROP VIEW IF EXISTS vw_active_loans_detail CASCADE;
DROP VIEW IF EXISTS vw_inventory_metrics CASCADE;
DROP TABLE IF EXISTS AuditLog CASCADE;
DROP TABLE IF EXISTS Visit CASCADE;
DROP TABLE IF EXISTS Service CASCADE;
DROP TABLE IF EXISTS Book_Topic CASCADE;
DROP TABLE IF EXISTS Book_Author CASCADE;
DROP TABLE IF EXISTS Loan CASCADE;
DROP TABLE IF EXISTS Book CASCADE;
DROP TABLE IF EXISTS Borrower CASCADE;
DROP TABLE IF EXISTS Role CASCADE;
DROP TABLE IF EXISTS Topic CASCADE;
DROP TABLE IF EXISTS Shelf CASCADE;
DROP TABLE IF EXISTS BookStatus CASCADE;
DROP TABLE IF EXISTS Author CASCADE;

-- ----------------------------------------------------------------------------
-- 1. Tabla: BookStatus (Catálogo de Estados de Libros)
-- ----------------------------------------------------------------------------
CREATE TABLE BookStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1'
);

-- ----------------------------------------------------------------------------
-- 2. Tabla: Shelf (Estantes / Ubicaciones Físicas)
-- ----------------------------------------------------------------------------
CREATE TABLE Shelf (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1'
);

-- ----------------------------------------------------------------------------
-- 3. Tabla: Topic (Temas / Áreas de Conocimiento)
-- ----------------------------------------------------------------------------
CREATE TABLE Topic (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1'
);

-- ----------------------------------------------------------------------------
-- 4. Tabla: Author (Autores)
-- ----------------------------------------------------------------------------
CREATE TABLE Author (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1'
);

-- ----------------------------------------------------------------------------
-- 5. Tabla: Book (Libros / Ejemplares del Acervo)
-- ----------------------------------------------------------------------------
CREATE TABLE Book (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    note TEXT NULL,
    author VARCHAR(255) NULL,
    folio VARCHAR(50) NOT NULL UNIQUE,
    dewey VARCHAR(50) NOT NULL,
    cutter VARCHAR(50) NOT NULL,
    status_id INT NOT NULL,
    shelf_id INT NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1',
    -- Llaves Foráneas
    CONSTRAINT fk_book_status FOREIGN KEY (status_id) REFERENCES BookStatus(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_book_shelf FOREIGN KEY (shelf_id) REFERENCES Shelf(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 6. Tabla: Role (Catálogo de Roles del Módulo de Biblioteca)
-- ----------------------------------------------------------------------------
CREATE TABLE Role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1'
);

-- ----------------------------------------------------------------------------
-- 7. Tabla: Borrower (Prestamistas / Usuarios de Biblioteca: Alumnos, Docentes y Administrativos)
--    Desacoplada de TecNM_LoginControl mediante Llaves Foráneas Lógicas:
--    - studentid: Número de Control (exclusivo para Alumnos)
--    - employeeid: Clave de Empleado / Nómina (exclusivo para Docentes y Administrativos)
--    - institutional_id: Columna generada que unifica el identificador institucional único
-- ----------------------------------------------------------------------------
CREATE TABLE Borrower (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    borrower_type VARCHAR(20) NOT NULL DEFAULT 'Alumno',
    studentid VARCHAR(30) NULL UNIQUE,
    employeeid VARCHAR(30) NULL UNIQUE,
    institutional_id VARCHAR(30) GENERATED ALWAYS AS (COALESCE(studentid, employeeid)) STORED UNIQUE,
    major VARCHAR(100) NOT NULL,
    semester VARCHAR(20) NULL,
    time VARCHAR(50) NULL,
    gender VARCHAR(20) NOT NULL,
    phoneNumber VARCHAR(25) NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    role_id INT NOT NULL DEFAULT 3,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1',
    -- Llaves Foráneas y Restricciones de Integridad (3FN)
    CONSTRAINT fk_borrower_role FOREIGN KEY (role_id) REFERENCES Role(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_borrower_gender
        CHECK (gender IN ('Masculino', 'Femenino')),
    CONSTRAINT chk_borrower_type
        CHECK (borrower_type IN ('Alumno', 'Docente', 'Administrativo', 'Otro')),
    CONSTRAINT chk_borrower_identifier_by_type
        CHECK (
            (borrower_type = 'Alumno' AND studentid IS NOT NULL AND employeeid IS NULL)
            OR
            (borrower_type IN ('Docente', 'Administrativo') AND employeeid IS NOT NULL AND studentid IS NULL AND semester IS NULL)
            OR
            (borrower_type = 'Otro' AND studentid IS NULL AND semester IS NULL)
        )
);
-- ----------------------------------------------------------------------------
-- 8. Tabla: Loan (Préstamos)
-- ----------------------------------------------------------------------------
CREATE TABLE Loan (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    borrower_id INT NOT NULL,
    startDate DATE NOT NULL DEFAULT CURRENT_DATE,
    dueDate DATE NOT NULL,
    returnDate DATE NULL,
    responsible VARCHAR(150) NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1',
    -- Llaves Foráneas
    CONSTRAINT fk_loan_book FOREIGN KEY (book_id) REFERENCES Book(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_loan_borrower FOREIGN KEY (borrower_id) REFERENCES Borrower(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 9. Tabla Intermedia N:M: Book_Author
-- ----------------------------------------------------------------------------
CREATE TABLE Book_Author (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1',
    -- Llaves Foráneas y Restricción de Unicidad
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES Book(id) ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES Author(id) ON DELETE CASCADE,
    CONSTRAINT uq_book_author UNIQUE (book_id, author_id)
);

-- ----------------------------------------------------------------------------
-- 10. Tabla Intermedia N:M: Book_Topic
-- ----------------------------------------------------------------------------
CREATE TABLE Book_Topic (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    topic_id INT NOT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1',
    -- Llaves Foráneas y Restricción de Unicidad
    CONSTRAINT fk_bt_book FOREIGN KEY (book_id) REFERENCES Book(id) ON DELETE CASCADE,
    CONSTRAINT fk_bt_topic FOREIGN KEY (topic_id) REFERENCES Topic(id) ON DELETE CASCADE,
    CONSTRAINT uq_book_topic UNIQUE (book_id, topic_id)
);

-- ----------------------------------------------------------------------------
-- 11. Tabla: Service (Catálogo de Servicios de Biblioteca)
-- ----------------------------------------------------------------------------
CREATE TABLE Service (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1'
);

-- ----------------------------------------------------------------------------
-- 12. Tabla: Visit (Registro de Visitas / Uso de Servicios)
-- ----------------------------------------------------------------------------
CREATE TABLE Visit (
    id SERIAL PRIMARY KEY,
    borrower_id INT NOT NULL,
    librarian_id INT NOT NULL,
    service_id INT NOT NULL,
    entryDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT NULL,
    -- Campos de Auditoría Obligatorios
    idUserCreate INT NOT NULL DEFAULT 1,
    dateCreate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUserUpdate INT NULL,
    dateUpdate TIMESTAMP NULL,
    idUserDelete INT NULL,
    dateDelete TIMESTAMP NULL,
    idStatus BIT(1) NOT NULL DEFAULT B'1',
    -- Llaves Foráneas
    CONSTRAINT fk_visit_borrower FOREIGN KEY (borrower_id) REFERENCES Borrower(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_visit_librarian FOREIGN KEY (librarian_id) REFERENCES Borrower(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_visit_service FOREIGN KEY (service_id) REFERENCES Service(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_visit_service_entry ON Visit (service_id, entryDate);
CREATE INDEX idx_visit_borrower_entry ON Visit (borrower_id, entryDate);

-- ============================================================================
-- POBLACIÓN DE DATOS INICIALES Y DE PRUEBA (INSERTS)
-- ============================================================================

-- 1. Catálogo obligatorio de BookStatus
INSERT INTO BookStatus (id, name, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Disponible', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Prestado', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'En reparación', 1, CURRENT_TIMESTAMP, B'1'),
(4, 'En proceso de baja', 1, CURRENT_TIMESTAMP, B'1'),
(5, 'En catálogo', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('BookStatus_id_seq', (SELECT MAX(id) FROM BookStatus));

-- 2. Estantes (Shelf)
INSERT INTO Shelf (id, name, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Estante A-1: Ingeniería de Software y Programación', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Estante A-2: Bases de Datos y Sistemas de Información', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Estante B-1: Redes, Telecomunicaciones y Ciberseguridad', 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Estante B-2: Sistemas Operativos y Arquitectura de Computadoras', 1, CURRENT_TIMESTAMP, B'1'),
(5, 'Estante C-1: Ciencias Básicas y Matemáticas Aplicadas', 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Estante D-1: Gestión Empresarial e Ingeniería Industrial', 1, CURRENT_TIMESTAMP, B'1'),
(7, 'Estante 1.1.1', 1, CURRENT_TIMESTAMP, B'1'),
(8, 'Estante 1.1.2', 1, CURRENT_TIMESTAMP, B'1'),
(9, 'Estante 1.1.3', 1, CURRENT_TIMESTAMP, B'1'),
(10, 'Estante 1.1.4', 1, CURRENT_TIMESTAMP, B'1'),
(11, 'Estante 1.1.5', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Shelf_id_seq', (SELECT MAX(id) FROM Shelf));

-- 3. Temas (Topic)
INSERT INTO Topic (id, name, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Ingeniería de Software', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Bases de Datos', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Redes de Computadoras', 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Sistemas Operativos', 1, CURRENT_TIMESTAMP, B'1'),
(5, 'Algoritmos y Estructuras de Datos', 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Cálculo Diferencial e Integral', 1, CURRENT_TIMESTAMP, B'1'),
(7, 'Inteligencia Artificial y Aprendizaje Automático', 1, CURRENT_TIMESTAMP, B'1'),
(8, 'Administración y Gestión de Proyectos', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Topic_id_seq', (SELECT MAX(id) FROM Topic));

-- 4. Autores (Author)
INSERT INTO Author (id, name, lastName, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Andrew S.', 'Tanenbaum', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Ian', 'Sommerville', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Robert C.', 'Martin', 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Abraham', 'Silberschatz', 1, CURRENT_TIMESTAMP, B'1'),
(5, 'James F.', 'Kurose', 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Keith W.', 'Ross', 1, CURRENT_TIMESTAMP, B'1'),
(7, 'James', 'Stewart', 1, CURRENT_TIMESTAMP, B'1'),
(8, 'Thomas H.', 'Cormen', 1, CURRENT_TIMESTAMP, B'1'),
(9, 'Roger S.', 'Pressman', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Author_id_seq', (SELECT MAX(id) FROM Author));

-- 5. Libros de acervo universitario (Book) - 8 títulos clásicos
INSERT INTO Book (title, note, author, folio, dewey, cutter, status_id, shelf_id, idUserCreate, dateCreate, idStatus) VALUES
('Diccionario de Informática', NULL, 'Cultural, S. A.', '69', 'C004', 'D545', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia Universal Diana', NULL, NULL, 'SIN-FOLIO-001', 'C030', 'E56', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario ilustrado de Computación para Inexpertos', NULL, 'Dan Gookin. Wally Wang. Chris Van Buren.', '74', 'C004', 'G659', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario Enciclopédico de Informática', 'Volumen 1', 'Héctor G. Tejera.', '1460', 'C004', 'T253d V.1', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario Enciclopédico de Informática', 'Volumen 2', 'Héctor G. Tejera.', '1461', 'C004', 'T253dV.2', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario para Usuarios de Computadoras', NULL, 'Bryan Pfaffenberger.', '71', 'C004', 'P523d', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionarios de redes', NULL, 'Peter Dyson', '72', 'C004.6', 'D994d', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionarios de redes', NULL, 'Peter Dyson', '73', 'C004.6', 'D994d', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario de la computación e internet', NULL, 'Editorial Trillas.', '76', 'C004.678', 'D545', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '3', 'C036', 'B862 V.1', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '4', 'C036', 'B862 V.2', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '5', 'C036', 'B862 V.3', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '6', 'C036', 'B862 V.4', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '7', 'C036', 'B862 V.5', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '8', 'C036', 'B862 V.6', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '9', 'C036', 'B862 V.7', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '10', 'C036', 'B862 V.8', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '11', 'C036', 'B862 V.9', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '12', 'C036', 'B862 V.10', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '13', 'C036', 'B862 V.11', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '14', 'C036', 'B862 V.12', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '15', 'C036', 'B862 V.13', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica', NULL, 'Encyclopaedia Britannica Publishers, inc.', '16', 'C036', 'B862 V.14', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '20', 'C036', 'H673 2000 V.1', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '21', 'C036', 'H673 2000 V.2', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '22', 'C036', 'H673 2000 V.3', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '23', 'C036', 'H673 2000 V.4', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '24', 'C036', 'H673 2000 V.5', 1, 7, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '25', 'C036', 'H673 2000 V.6', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '26', 'C036', 'H673 2000 V.7', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '27', 'C036', 'H673 2000 V.8', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '28', 'C036', 'H673 2000 V.9', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '29', 'C036', 'H673 2000 V.10', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '30', 'C036', 'H673 2000 V.11', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '31', 'C036', 'H673 2000 V.12', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '32', 'C036', 'H673 2000 V.13', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Millennium', NULL, 'Barsa International Publishers, inc.', '33', 'C036', 'H673 2000 V.14', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Encyclopaedia Britannica Publishers, inc.', '1', 'C036', 'H673  MICROPEDIA V.1', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Encyclopaedia Britannica Publishers, inc.', '2', 'C036', 'H673 MICROPEDIA V.2', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Barsa International Publishers, inc.', '18', 'C036', 'H673  2000  MICROPEDIA', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Barsa International Publishers, inc.', '19', 'C036', 'H673  2000  MICROPEDIA', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Encyclopaedia Britannica Publishers, inc.', '17', 'C036', 'H673  DATAPEDIA', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Barsa International Publishers, inc.', '34', 'C036', 'H673  2000 TEMAPEDIA', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Encyclopaedia Britannica Publishers, inc.', '35', 'C036', 'H673  TEMAPEDIA', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Hispánica Micropedia e Índice', NULL, 'Barsa International Publishers, inc.', '36', 'C036', 'H673 2000 DATAPEDIA', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '37', 'C036', 'M479 V.1', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '38', 'C036', 'M479 V.2', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '39', 'C036', 'M479 V.3', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '40', 'C036', 'M479 V.4', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '41', 'C036', 'M479 V.5', 1, 8, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '42', 'C036', 'M479 V.6', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '43', 'C036', 'M479 V.7', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '44', 'C036', 'M479 V.8', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '45', 'C036', 'M479 V.9', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '46', 'C036', 'M479 V.10', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '47', 'C036', 'M479 V.11', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '48', 'C036', 'M479 V.12', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '49', 'C036', 'M479 V.13', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de México', NULL, 'José Rogelio Alvarez', '50', 'C036', 'M479 V.14', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Milenios de México', NULL, 'Humberto Musacchio', '1375', 'C036', 'M642 T.1', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Milenios de México', NULL, 'Humberto Musacchio', '1376', 'C036', 'M642 T.2', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Milenios de México', NULL, 'Humberto Musacchio', '1377', 'C036', 'M642 T.3', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia Práctica del Estudiante', NULL, 'Promexa', '814', 'C300', 'E56', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario Económico, Contable, Comercial y Financiero', NULL, 'Carlos Javier Sanz', '2121', 'C330.3', 'S238D Ej. 1', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario Económico, Contable, Comercial y Financiero', NULL, 'Carlos Javier Sanz', '2122', 'C330.3', 'S238D Ej. 2', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario Económico, Contable, Comercial y Financiero', NULL, 'Carlos Javier Sanz', '2123', 'C330.3', 'S238D Ej. 3', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía, Tecnología del Carbón', NULL, 'Douglas M. Considine', '553', 'C333.79', 'E56 V.1', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía, Tecnología del Petróleo', NULL, 'Douglas M. Considine', '554', 'C333.79', 'E56 V.2', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía, Tecnología del Gas Natural', NULL, 'Douglas M. Considine', '555', 'C333.79', 'E56 V.3', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía, Tecnología de la Energía Nuclear', NULL, 'Douglas M. Considine', '556', 'C333.79', 'E56 V.4', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía Solar, Hidráulica, Geotérmica y Combustibles Químicos', NULL, 'Douglas M. Considine', '557', 'C333.79', 'E56 V.5', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía, Tendencias de las Tecnologías Energéticas', NULL, 'Douglas M. Considine', '558', 'C333.79', 'E56 V.6', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('Enciclopedia de Energía, Diccionario de Energía.', NULL, 'V. Daniel Hunt', '559', 'C333.79', 'E56 V.7', 1, 9, 1, CURRENT_TIMESTAMP, B'1'),
('La Guía Completas sobre Instalaciones Eléctricas', 'Segunda Edición.', 'Limusa', '4724', 'C333.7932', 'B627g', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Manual del Instalador Electricista', NULL, 'Enríquez Harper', '4730', 'C333.7932', 'E379', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Las 1000 empresas más importantes de México', NULL, NULL, '1875', 'C338.7', 'M479 V.1 2002', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Las 1000 empresas más importantes de México', NULL, NULL, '2928', 'C338.7', 'M479 ej.1 v.1 2003', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Mundo  Ejecutivo', NULL, NULL, '740', 'C338.7', 'M479 V.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Mundo  Ejecutivo', NULL, NULL, '739', 'C338.7', 'M479 V.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('32 Oportunidades de Inversión', 'Tomo 2', NULL, '2299', 'C338.7', 'M479 2003 EJ.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('32 Oportunidades de Inversión', NULL, NULL, '1876', 'C338.7', 'M479 2002 EJ.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Las 1000 empresas más importantes de México', NULL, NULL, '1873', 'C338.7', 'M479 2000 V.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Las 1000 empresas más importantes de México', NULL, NULL, '1874', 'C338.7', 'M479 2000 V.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Ley General de Sociedades Mercantiles', NULL, 'SISTA', '3552', 'C338.74', 'L681 2010 EJ.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Prontuario de Introducción al Estudio del Derecho y Nociones de Derecho Civil', '3a. Edición', 'Soto Álvarez.', '842', 'C340.56', 'S718p', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', 'Primera Edición', 'Ediciones Delma.', '834', 'C342.0272', 'C756 2001 EJ.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', 'Segunda Edición.', 'Ediciones Delma.', '835', 'C342.0272', 'C756 2001 EJ.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', 'Tercer Edición.', 'Ediciones Delma.', '836', 'C342.0272', 'C756 2001 EJ.3', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', NULL, 'Ediciones Fiscales ISEF.', '837', 'C342.0272', 'C756', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', NULL, 'Miguel Carbonell.', '3563', 'C342.0272', 'C756 2009', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Temas Selectos de Derecho  Laboral', NULL, 'Ana María Alvarado Larios.', '860', 'C344.01', 'A472t', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Temas Selectos de Derecho  Laboral', NULL, 'Ana María Alvarado Larios.', '861', 'C344.01', 'A472t EJ.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Instituto del Fondo Nacional De la Vivienda para los Trabajadores', NULL, 'Ediciones ALF.', '867', 'C344.063635', 'L681', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Ley Federal del Trabajo', NULL, 'Anaya Editores.', '862', 'C344.026', 'L681 EJ.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Ley Federal del Trabajo', NULL, 'Anaya Editores.', '863', 'C344.026', 'L681 EJ.3', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', NULL, 'Editores HORCASITAS.', '4885', 'C342.0727', 'C756 EJ.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Constitución Política de los Estados Unidos Mexicanos', NULL, 'Editores HORCASITAS.', '4886', 'C342.0727', 'C756 EJ.1', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Ley Federal del Trabajo', NULL, 'Alberto Trueba Urbina. Jorge Trueba Barrera.', '865', 'C344', 'T8651', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Ley ''98 Federal del Derecho del Autor', NULL, 'Ediciones Fiscales ISEF.', '925', 'C348', 'L681', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Prontuario Fiscal Correlacionado 1999 Cosas Prácticas', NULL, 'Gustavo Gasca Bretón.', '746', 'C348.02', 'G246p 1999', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Prontuario Fiscal Correlacionado 2000 Estudiantil', NULL, 'Gustavo Gasca Bretón.', '820', 'C348.02', 'P962 2000', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Prontuario Fiscal Correlacionado 2001 Estudiantil', NULL, 'Gustavo Gasca Bretón.', '824', 'C348.02', 'P962 2001', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Prontuario Fiscal Correlacionado 2001 Estudiantil', NULL, 'Gustavo Gasca Bretón.', '823', 'C348.02', 'P962 2001 EJ. 2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Fisco Agenda 2001', NULL, 'Ediciones Fiscales ISEF.', '822', 'C348.02', 'F528', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Fisco Agenda 2001', NULL, 'Ediciones Fiscales ISEF.', '825', 'C348.02', 'F528 EJ.2', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Código Fiscal de la Federación', NULL, 'Editorial Porrúa', '858', 'C348.023', 'L681', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Agenda Fiscal 2000', NULL, 'Ediciones Fiscales ISEF.', '859', 'C348.023', 'A265', 1, 10, 1, CURRENT_TIMESTAMP, B'1'),
('Código Civil', 'Trigesima Octava Edición', 'Ediciones Delma', '838', 'C348.02372', 'C669', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Código Fiscal de la Federación y su Reglamento', 'Primera Edición', 'Ediciones Delma', '852', 'C348.02372', 'C669 2001 EJ.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Código Fiscal de la Federación y su Reglamento', 'Primera Edición', 'Ediciones Delma', '853', 'C348.02372', 'C669 2001 EJ.2', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Código Fiscal de la Federación y su Reglamento', 'Primera Edición', 'Ediciones Delma', '854', 'C348.02372', 'C669 2001 EJ.3', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Código Civil Para el Estado de Coahuila de Zaragoza', NULL, 'Lazcano Garza Editores.', '840', 'C348.0237214', 'C669', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Código Civil Para el  Distrito Federal', NULL, 'Editorial Porrúa', '839', 'C348.0237253', 'L681', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley  del Impuesto Sobre la Renta y su Reglamento', NULL, 'Ediciones Delma', '855', 'C348.024', 'L681  EJ.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley  del Impuesto Sobre la Renta y su Reglamento', NULL, 'Ediciones Delma', '856', 'C348.024', 'L681 EJ.2', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley  del Impuesto Sobre la Renta y su Reglamento', NULL, 'Ediciones Delma', '857', 'C348.024', 'L681 EJ.3', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Impuesto Sobre la Renta 2010', NULL, 'Intituto Mexicano de Contadores Publicos.', '3555', 'C348.024', 'L681 2010 EJ.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Manual de Fórmulas Financieras', NULL, 'José de Jesús Gonzáles Serna.', '4731', 'C352.4', 'G643m', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Manual del Derecho Ambiental Mexicano', NULL, 'Raúl Brañes.', '3858', 'C352.3', 'B812 EJ.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Manual del Derecho Ambiental Mexicano', NULL, 'Raúl Brañes.', '3859', 'C352.3', 'B812 EJ.2', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '904', 'C354.64', 'D419 T.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '905', 'C354.64', 'D419 T.2', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '906', 'C354.64', 'D419 T.3', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '907', 'C354.64', 'D419 T.4', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '908', 'C354.64', 'D419 T.5', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '909', 'C354.64', 'D419 T.6', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '910', 'C354.64', 'D419 T.7', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Normas de Construcción', NULL, 'Coordinación Subsectorial de Normas.', '911', 'C354.64', 'D419 T.8', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Seguro Social', NULL, 'Editorial Berbera', '849', 'C368.3822', 'L681 2001', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Seguro Social', NULL, 'Editorial Berbera', '850', 'C368.3822', 'L681 2001 EJ.2', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Seguro Social', NULL, 'Editorial Berbera', '851', 'C368.3822', 'L681 2001 EJ.3', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Seguro Social', NULL, 'Editores Anaya', '3510', 'C368.3822', 'L681 2009 EJ. 1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Seguro Social  2010', NULL, 'Ediciones Fiscales ISEF.', '3479', 'C368.3822', 'L681 2010 EJ.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Ley del Seguro Social', NULL, 'Interpac.', '3499', 'C368.3822', 'N964 2010', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Programa Jóvenes destacados de Coahuila', NULL, 'Nazario S. Ortiz Garza. Lic. Francisco Lopez Serrano.', '736', 'C370.08427214', 'L8642p', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Palabras Frases y Hechos', NULL, 'Carlos Flores Revuelta', '2135', 'C401.4', 'F634p EJ.1', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Marco Juridico del Acuerdo Educativo Nacional', NULL, 'SEP', 'SIN-FOLIO-002', 'C004.6730', 'S/C', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Nuevos Escenarios Educativos', NULL, 'Ruth Harf, Delia Azzerboni, Sandra Sánchez y Néstor Zorzoli', 'SIN-FOLIO-003', 'C004.6731', 'S/C', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario de Sinónimos y Antónimos', NULL, 'Larousse', 'SIN-FOLIO-004', 'C004.6732', 'S/C', 1, 11, 1, CURRENT_TIMESTAMP, B'1'),
('Diccionario Enciclopédico', NULL, NULL, 'SIN-FOLIO-005', 'C004.6733', 'S/C', 1, 11, 1, CURRENT_TIMESTAMP, B'1');

INSERT INTO Book (title, note, author, folio, dewey, cutter, status_id, shelf_id, idUserCreate, dateCreate, idStatus) VALUES
('Lecciones de Electricidad', NULL, 'J. Ney / G. Louis', '1932', '333.7932', 'N568L', 2, 6, 1, CURRENT_TIMESTAMP, B'1'),
('Programación TRANSACT', NULL, 'Manuel Torres', '4346', '005.133', 'T636s', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Aprenda Programación Microsoft SQL', NULL, 'Rebeca M. Riordan', 'SIN-FOLIO-PRESTAMO-001', '005.74', 'R56', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Tecnología de las Máquinas Herramientas', NULL, 'Steve F. Krar / Arthur. Gill / Peter Smid', '4343', '621.902', 'K898t 2009', 2, 6, 1, CURRENT_TIMESTAMP, B'1'),
('C++ Como Programar', NULL, 'Daitel', '4075', '005.133', 'D324e Ej.1', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Ruta Interior', NULL, 'Hermann Hesse', '1611', '830.39', 'H586r', 2, 5, 1, CURRENT_TIMESTAMP, B'1'),
('La Inteligencia Emocional', NULL, 'Vergara', '3547', '153.9', 'G625I', 1, 5, 1, CURRENT_TIMESTAMP, B'1'),
('Programacion en algoritmos', NULL, 'Luis Joyanes Agilar', '1799', '005.13', 'E96XJ', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructuras de datos Básicas', NULL, 'Silvia Guardiati', '4812', '005.73', 'G914e', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructuras de datos', NULL, 'Luis Joyanes Aguilar', '1765', '005.73', 'J88E', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructuras de datos a objetos algoritmos', NULL, 'Silvia Guardiati', '4686', '005.73', 'G914e', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructuras de datos con CYC++', NULL, 'Luis Joyanes Aguilar', '263', '005.73', 'L585e', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de datos', NULL, 'Luis Joyanes Aguilar', '1764', '005.73', 'J88E', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('El Lenguaje de programación', NULL, 'Kernichan / Ritchie', '3542', '005.13', 'K399L', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de datos con CyC++', NULL, 'Yedidyah L.', '1536', '005.73', 'L265E', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de Datos Algoritmicos', NULL, 'Luis Joyanes Aguilar', '1766', '005.73', 'J88E Ej.3', 1, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de datos con CyC++', NULL, 'Yedidyah L.', '1535', '005.73', 'L285E', 1, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Programacion con C metodologia', NULL, 'Luis Joyanes Aguilar', '4536', '005.3', 'J88p', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de datos algorítmicos', NULL, 'Luis Joyanes Aguilar', '1767', '005.73', 'J88E Ej.4', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de datos con CyC++', NULL, 'Yedidyah L.', '1534', '005.73', 'L285E', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Estructura de Datos con Pascal', NULL, 'Aron M. Tenen baum', '1269', '005.133', 'T292e', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
('Libros Condensados', NULL, NULL, '3002', '810.6', 'L6979', 2, 5, 1, CURRENT_TIMESTAMP, B'1')
ON CONFLICT (folio) DO NOTHING;

-- 6. Relaciones N:M Book_Author
INSERT INTO Book_Author (book_id, author_id, idUserCreate, dateCreate, idStatus) VALUES
(1, 1, 1, CURRENT_TIMESTAMP, B'1'), -- Tanenbaum -> Sistemas Operativos Modernos
(2, 9, 1, CURRENT_TIMESTAMP, B'1'), -- Pressman -> Ing. de Software
(3, 3, 1, CURRENT_TIMESTAMP, B'1'), -- Martin -> Código Limpio
(4, 4, 1, CURRENT_TIMESTAMP, B'1'), -- Silberschatz -> Bases de Datos
(5, 5, 1, CURRENT_TIMESTAMP, B'1'), -- Kurose -> Redes
(5, 6, 1, CURRENT_TIMESTAMP, B'1'), -- Ross -> Redes (coautor)
(6, 7, 1, CURRENT_TIMESTAMP, B'1'), -- Stewart -> Cálculo
(7, 8, 1, CURRENT_TIMESTAMP, B'1'), -- Cormen -> Algoritmos
(8, 2, 1, CURRENT_TIMESTAMP, B'1'); -- Sommerville -> Ing. del Software

-- 7. Relaciones N:M Book_Topic
INSERT INTO Book_Topic (book_id, topic_id, idUserCreate, dateCreate, idStatus) VALUES
(1, 4, 1, CURRENT_TIMESTAMP, B'1'), -- Sistemas Operativos
(2, 1, 1, CURRENT_TIMESTAMP, B'1'), -- Ingeniería de Software
(3, 1, 1, CURRENT_TIMESTAMP, B'1'), -- Ingeniería de Software
(3, 5, 1, CURRENT_TIMESTAMP, B'1'), -- Algoritmos
(4, 2, 1, CURRENT_TIMESTAMP, B'1'), -- Bases de Datos
(5, 3, 1, CURRENT_TIMESTAMP, B'1'), -- Redes de Computadoras
(6, 6, 1, CURRENT_TIMESTAMP, B'1'), -- Cálculo
(7, 5, 1, CURRENT_TIMESTAMP, B'1'), -- Algoritmos y Estructuras de Datos
(8, 1, 1, CURRENT_TIMESTAMP, B'1'); -- Ingeniería de Software

-- 8. Catálogo de Roles del Módulo de Biblioteca (Role)
INSERT INTO Role (id, name, description, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Admin', 'Gestión total del sistema de biblioteca, catálogos, roles y reportes', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Bibliotecario', 'Gestión operativa de acervo, préstamos, devoluciones y registro de visitas', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Lector', 'Consulta de catálogo e historial propio de préstamos y visitas', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Role_id_seq', (SELECT MAX(id) FROM Role));

-- 9. Prestamistas / Usuarios (Borrower) con correos institucionales '@monclova.tecnm.mx'
--    Incluye Alumnos (con studentid y semester) y Docentes/Administrativos (con employeeid y semester NULL)
INSERT INTO Borrower (id, name, borrower_type, studentid, employeeid, major, semester, time, gender, phoneNumber, email, role_id, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Carlos Alberto Mendoza Rivas', 'Alumno', '21280541', NULL, 'Ingeniería en Sistemas Computacionales', '7mo Semestre', 'Matutino', 'Masculino', '8661234567', 'l21280541@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Ana Sofía Garza Villalobos', 'Alumno', '22280312', NULL, 'Ingeniería en Sistemas Computacionales', '5to Semestre', 'Matutino', 'Femenino', '8662345678', 'l22280312@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Luis Fernando Treviño Peña', 'Alumno', '20280199', NULL, 'Ingeniería Industrial', '9no Semestre', 'Vespertino', 'Masculino', '8663456789', 'l20280199@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Valeria Guadalupe Castillo Morales', 'Alumno', '23280820', NULL, 'Ingeniería en Gestión Empresarial', '3er Semestre', 'Matutino', 'Femenino', '8664567890', 'l23280820@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
(5, 'Ing. Roberto Hernández Dávila', 'Docente', NULL, 'DOC-ISC-014', 'Docente - Departamento de Sistemas', NULL, 'Tiempo Completo', 'Masculino', '8665678901', 'roberto.hernandez@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Lic. Martha Elena Vázquez Torres', 'Administrativo', NULL, 'ADM-BIB-003', 'Administrador de Biblioteca', NULL, 'Turno Completo', 'Femenino', '8666789012', 'martha.vazquez@monclova.tecnm.mx', 1, 1, CURRENT_TIMESTAMP, B'1'),
(7, 'Lic. Jorge Eduardo Morales Cruz', 'Administrativo', NULL, 'BIB-MON-005', 'Bibliotecario - Área de Circulación', NULL, 'Turno Vespertino', 'Masculino', '8667890123', 'jorge.morales@monclova.tecnm.mx', 2, 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Borrower_id_seq', (SELECT MAX(id) FROM Borrower));
INSERT INTO Borrower (name, borrower_type, studentid, employeeid, major, semester, time, gender, phoneNumber, email, role_id, idUserCreate, dateCreate, idStatus) VALUES
('Diego Verastegui Carrillo', 'Alumno', 'N24050251', NULL, 'Ingeniería Industrial', NULL, 'Matutino', 'Masculino', '8661470480', 'n24050251@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Christian Alonso Segovia Ambriz', 'Alumno', 'I21050385', NULL, 'Ingeniería Informática', NULL, 'Vespertino', 'Masculino', '8661616633', 'i21050385@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Kenia Aide Martinez Vallesteros', 'Alumno', 'I25050370', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Femenino', '8663886402', 'i25050370@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Oscar Uriel Soria', 'Alumno', 'INE-OSCAR', NULL, 'Sin especificar (INE)', NULL, 'Matutino', 'Masculino', '8662139499', 'oscar.soria@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Nery Eli Amador Facundo', 'Alumno', 'N25050276', NULL, 'Ingeniería Industrial', NULL, 'Matutino', 'Masculino', '8661503998', 'n25050276@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Raul de Jesus Berlanga. M', 'Alumno', 'I24050400', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Masculino', '8661625795', 'i24050400@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Xóchitl Mesta Alanis', 'Alumno', 'I24050387', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Femenino', '8661386510', 'i24050387@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Leslie Sofia Perez Romo', 'Alumno', 'I2505555', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Femenino', '8662000591', 'i2505555@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Mario Alejandro Mtz.', 'Alumno', 'I25050368', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Masculino', '8661345456', 'i25050368@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Stephanny Elizabeth Torres R.', 'Alumno', 'I25050386', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Femenino', '8662532849', 'i25050386@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Sebastian Ponce Carmona', 'Alumno', 'I25050377', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Masculino', '8662565888', 'i25050377@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Daniela Vianey Garcia', 'Alumno', 'I25050363', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Femenino', '8662124481', 'i25050363@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Elizabeth Anabely Garcia', 'Alumno', 'I25050364', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Femenino', '8666503851', 'i25050364@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Jesus Armando Sendejo', 'Alumno', 'I24050394', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Masculino', '8661854586', 'i24050394@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1'),
('Cesar Emmanuel Vallejo', 'Alumno', 'I23050364', NULL, 'Ingeniería Informática', NULL, 'Matutino', 'Masculino', '8661651892', 'i23050364@monclova.tecnm.mx', 3, 1, CURRENT_TIMESTAMP, B'1')
ON CONFLICT (studentid) DO NOTHING;

-- 10. Préstamos (Loan)
INSERT INTO Loan (book_id, borrower_id, startDate, dueDate, returnDate, responsible, idUserCreate, dateCreate, idStatus) VALUES
((SELECT id FROM Book WHERE folio = '1932'), (SELECT id FROM Borrower WHERE studentid = 'N24050251'), '2026-09-01', '2026-09-04', NULL, 'Araceli', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '4346'), (SELECT id FROM Borrower WHERE studentid = 'I21050385'), '2026-09-02', '2026-09-05', NULL, 'Araceli', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = 'SIN-FOLIO-PRESTAMO-001'), (SELECT id FROM Borrower WHERE studentid = 'I21050385'), '2026-09-02', '2026-09-05', NULL, 'Araceli', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '4343'), (SELECT id FROM Borrower WHERE studentid = 'I25050370'), '2026-09-04', '2026-09-08', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '4075'), (SELECT id FROM Borrower WHERE studentid = 'INE-OSCAR'), '2026-09-04', '2026-09-08', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1611'), (SELECT id FROM Borrower WHERE studentid = 'N25050276'), '2026-09-02', '2026-09-05', NULL, 'Araceli', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '3547'), (SELECT id FROM Borrower WHERE studentid = 'N25050276'), '2026-08-24', '2026-08-27', '2026-08-27', 'Araceli', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1799'), (SELECT id FROM Borrower WHERE studentid = 'I24050400'), '2026-08-31', '2026-09-04', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '4812'), (SELECT id FROM Borrower WHERE studentid = 'I24050400'), '2026-08-31', '2026-09-04', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1765'), (SELECT id FROM Borrower WHERE studentid = 'I24050400'), '2026-08-31', '2026-09-04', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '4686'), (SELECT id FROM Borrower WHERE studentid = 'I24050387'), '2026-08-31', '2026-09-04', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '263'), (SELECT id FROM Borrower WHERE studentid = 'I24050387'), '2026-08-31', '2026-09-04', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1764'), (SELECT id FROM Borrower WHERE studentid = 'I2505555'), '2026-08-26', '2026-08-31', NULL, 'Araceli', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '3542'), (SELECT id FROM Borrower WHERE studentid = 'I25050368'), '2026-08-27', '2026-08-31', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1536'), (SELECT id FROM Borrower WHERE studentid = 'I25050386'), '2026-08-27', '2026-08-31', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1766'), (SELECT id FROM Borrower WHERE studentid = 'I25050377'), '2026-08-27', '2026-08-31', '2026-08-31', 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1535'), (SELECT id FROM Borrower WHERE studentid = 'I25050363'), '2026-08-27', '2026-08-31', '2026-08-31', 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '4536'), (SELECT id FROM Borrower WHERE studentid = 'I25050364'), '2026-08-27', '2026-08-31', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1767'), (SELECT id FROM Borrower WHERE studentid = 'I25050364'), '2026-08-27', '2026-08-31', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1534'), (SELECT id FROM Borrower WHERE studentid = 'I24050394'), '2026-08-28', '2026-09-01', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '1269'), (SELECT id FROM Borrower WHERE studentid = 'I24050394'), '2026-08-28', '2026-09-01', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1'),
((SELECT id FROM Book WHERE folio = '3002'), (SELECT id FROM Borrower WHERE studentid = 'I23050364'), '2026-08-31', '2026-09-04', NULL, 'Oscar', 1, CURRENT_TIMESTAMP, B'1');


-- 11. Catálogo de Servicios de Biblioteca (Service)
INSERT INTO Service (id, name, description, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Presencial', 'Consulta o estudio presencial en sala de biblioteca', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Virtual', 'Uso de biblioteca digital o equipo de cómputo', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Reunión', 'Uso de espacio para reunión o trabajo en equipo', 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Clase', 'Sesión o clase impartida en instalaciones de biblioteca', 1, CURRENT_TIMESTAMP, B'1'),
(5, 'Mantenimiento', 'Soporte técnico o mantenimiento en instalaciones de biblioteca', 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Otra', 'Otro servicio o motivo de visita a biblioteca', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Service_id_seq', (SELECT MAX(id) FROM Service));

-- 12. Visitas de prueba (Visit)
INSERT INTO Visit (id, borrower_id, librarian_id, service_id, entryDate, notes, idUserCreate, dateCreate, idStatus) VALUES
(1, 1, 6, 1, CURRENT_TIMESTAMP - INTERVAL '2 days', 'Consulta de bibliografía para proyecto de Sistemas Operativos', 1, CURRENT_TIMESTAMP, B'1'),
(2, 2, 6, 2, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Acceso a base de datos digital IEEE', 1, CURRENT_TIMESTAMP, B'1'),
(3, 3, 7, 3, CURRENT_TIMESTAMP - INTERVAL '4 hours', 'Reunión de equipo para proyecto integrador', 1, CURRENT_TIMESTAMP, B'1'),
(4, 5, 7, 4, CURRENT_TIMESTAMP - INTERVAL '1 hour', 'Clase de Bases de Datos en sala audiovisual', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Visit_id_seq', (SELECT MAX(id) FROM Visit));

-- ============================================================================
-- TÓPICOS DE BASE DE DATOS (IFF-1026):
-- PARTICIONAMIENTO, BITÁCORA ACTIVA DE AUDITORÍA (TRIGGERS) Y VISTAS DE REPORTE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 13. Tabla Particionada: AuditLog (Bitácora Activa de Auditoría de Transacciones)
--     Cumple con:
--     - Particionamiento declarativo por rango de fechas (PARTITION BY RANGE)
--     - Registro automático de usuario, fecha/hora, operación y detalle JSONB
-- ----------------------------------------------------------------------------
CREATE TABLE AuditLog (
    id BIGSERIAL,
    table_name VARCHAR(60) NOT NULL,
    record_id INT NULL,
    operation VARCHAR(15) NOT NULL,
    institutional_user_id INT NOT NULL DEFAULT 1,
    db_user VARCHAR(60) NOT NULL DEFAULT CURRENT_USER,
    operation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB NULL,
    new_data JSONB NULL,
    PRIMARY KEY (id, operation_date),
    CONSTRAINT chk_audit_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
) PARTITION BY RANGE (operation_date);

-- Particiones Semestrales y Partición por Defecto para Continuidad Operativa
CREATE TABLE AuditLog_2026_H1 PARTITION OF AuditLog
    FOR VALUES FROM ('2026-01-01 00:00:00') TO ('2026-07-01 00:00:00');

CREATE TABLE AuditLog_2026_H2 PARTITION OF AuditLog
    FOR VALUES FROM ('2026-07-01 00:00:00') TO ('2027-01-01 00:00:00');

CREATE TABLE AuditLog_Default PARTITION OF AuditLog DEFAULT;

CREATE INDEX idx_auditlog_table_date ON AuditLog (table_name, operation_date DESC);

-- ----------------------------------------------------------------------------
-- 14. Función y Triggers Automáticos de Auditoría en Entidades Críticas
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_register_audit_log()
RETURNS TRIGGER AS $$
DECLARE
    v_record_id INT;
    v_user_id INT := 1;
    v_old_json JSONB := NULL;
    v_new_json JSONB := NULL;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        v_new_json := to_jsonb(NEW);
        v_record_id := (v_new_json->>'id')::INT;
        v_user_id := COALESCE((v_new_json->>'idusercreate')::INT, 1);
    ELSIF (TG_OP = 'UPDATE') THEN
        v_old_json := to_jsonb(OLD);
        v_new_json := to_jsonb(NEW);
        v_record_id := (v_new_json->>'id')::INT;
        v_user_id := COALESCE((v_new_json->>'iduserupdate')::INT, (v_new_json->>'idusercreate')::INT, 1);
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_json := to_jsonb(OLD);
        v_record_id := (v_old_json->>'id')::INT;
        v_user_id := COALESCE((v_old_json->>'iduserdelete')::INT, (v_old_json->>'idusercreate')::INT, 1);
    END IF;

    INSERT INTO AuditLog (
        table_name,
        record_id,
        operation,
        institutional_user_id,
        db_user,
        operation_date,
        old_data,
        new_data
    ) VALUES (
        TG_TABLE_NAME,
        v_record_id,
        TG_OP,
        v_user_id,
        CURRENT_USER,
        CURRENT_TIMESTAMP,
        v_old_json,
        v_new_json
    );

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers activos sobre las entidades críticas del módulo de Biblioteca
CREATE TRIGGER trg_audit_book
    AFTER INSERT OR UPDATE OR DELETE ON Book
    FOR EACH ROW EXECUTE FUNCTION fn_register_audit_log();

CREATE TRIGGER trg_audit_loan
    AFTER INSERT OR UPDATE OR DELETE ON Loan
    FOR EACH ROW EXECUTE FUNCTION fn_register_audit_log();

CREATE TRIGGER trg_audit_borrower
    AFTER INSERT OR UPDATE OR DELETE ON Borrower
    FOR EACH ROW EXECUTE FUNCTION fn_register_audit_log();

CREATE TRIGGER trg_audit_visit
    AFTER INSERT OR UPDATE OR DELETE ON Visit
    FOR EACH ROW EXECUTE FUNCTION fn_register_audit_log();

CREATE TRIGGER trg_audit_bookstatus
    AFTER INSERT OR UPDATE OR DELETE ON BookStatus
    FOR EACH ROW EXECUTE FUNCTION fn_register_audit_log();

-- ----------------------------------------------------------------------------
-- 15. Vistas SQL para Lectura de Reportes (Instancia Maestro / Réplica Esclavo)
-- ----------------------------------------------------------------------------

-- Vista 1: Resumen de Asistencia y Visitas por Tipo de Usuario (Alumno, Docente, Administrativo)
--          El turno (shift) se calcula a partir de la hora exacta de entrada en Visit.entryDate:
--          < 15:00 (antes de las 3:00 PM) -> 'Matutino' | >= 15:00 -> 'Vespertino'
CREATE OR REPLACE VIEW vw_attendance_summary_by_type AS
SELECT
    DATE(v.entryDate) AS visit_date,
    b.borrower_type,
    b.gender,
    CASE
        WHEN EXTRACT(HOUR FROM v.entryDate) < 15 THEN 'Matutino'
        ELSE 'Vespertino'
    END AS shift,
    b.major,
    s.name AS service_name,
    COUNT(v.id) AS total_visits
FROM Visit v
INNER JOIN Borrower b ON b.id = v.borrower_id
INNER JOIN Service s ON s.id = v.service_id
WHERE v.idStatus = B'1' AND b.idStatus = B'1'
GROUP BY
    DATE(v.entryDate),
    b.borrower_type,
    b.gender,
    CASE
        WHEN EXTRACT(HOUR FROM v.entryDate) < 15 THEN 'Matutino'
        ELSE 'Vespertino'
    END,
    b.major,
    s.name;

-- Vista 2: Detalle de Préstamos Activos y Vencidos con Identificador Institucional Único
CREATE OR REPLACE VIEW vw_active_loans_detail AS
SELECT
    l.id AS loan_id,
    bk.folio,
    bk.title AS book_title,
    b.name AS borrower_name,
    b.borrower_type,
    b.institutional_id,
    b.studentid,
    b.employeeid,
    b.major,
    b.semester,
    l.startDate,
    l.dueDate,
    l.returnDate,
    l.responsible,
    CASE
        WHEN l.returnDate IS NOT NULL THEN 'Devuelto'
        WHEN l.dueDate < CURRENT_DATE THEN 'Vencido'
        WHEN l.dueDate = CURRENT_DATE THEN 'Vence Hoy'
        ELSE 'En Tiempo'
    END AS loan_status
FROM Loan l
INNER JOIN Book bk ON bk.id = l.book_id
INNER JOIN Borrower b ON b.id = l.borrower_id
WHERE l.idStatus = B'1';

-- Vista 3: Métricas Consolidadas de Inventario Bibliotecario
CREATE OR REPLACE VIEW vw_inventory_metrics AS
SELECT
    COUNT(*) FILTER (WHERE idStatus = B'1') AS total_books,
    COUNT(*) FILTER (WHERE idStatus = B'1' AND status_id = 1) AS available_count,
    COUNT(*) FILTER (WHERE idStatus = B'1' AND status_id = 2) AS borrowed_count,
    COUNT(*) FILTER (WHERE idStatus = B'1' AND status_id = 3) AS repair_count,
    COUNT(*) FILTER (WHERE idStatus = B'1' AND status_id = 4) AS discard_count,
    COUNT(*) FILTER (WHERE idStatus = B'1' AND status_id = 5) AS catalog_count
FROM Book;
