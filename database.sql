-- ============================================================================
-- Sistema de Biblioteca del TecNM Campus Monclova
-- Script de Creación y Población de Base de Datos PostgreSQL
-- ============================================================================

-- Eliminar tablas en orden inverso si ya existen para evitar conflictos de FK
DROP TABLE IF EXISTS Book_Topic CASCADE;
DROP TABLE IF EXISTS Book_Author CASCADE;
DROP TABLE IF EXISTS Loan CASCADE;
DROP TABLE IF EXISTS Book CASCADE;
DROP TABLE IF EXISTS Borrower CASCADE;
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
-- 6. Tabla: Borrower (Prestamistas / Usuarios de Biblioteca)
-- ----------------------------------------------------------------------------
CREATE TABLE Borrower (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    studentid VARCHAR(30) NOT NULL UNIQUE,
    major VARCHAR(100) NOT NULL,
    time VARCHAR(50) NOT NULL,
    phoneNumber VARCHAR(25) NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
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
-- 7. Tabla: Loan (Préstamos)
-- ----------------------------------------------------------------------------
CREATE TABLE Loan (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    borrower_id INT NOT NULL,
    startDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dueDate TIMESTAMP NOT NULL,
    returnDate TIMESTAMP NULL,
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
-- 8. Tabla Intermedia N:M: Book_Author
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
-- 9. Tabla Intermedia N:M: Book_Topic
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
(6, 'Estante D-1: Gestión Empresarial e Ingeniería Industrial', 1, CURRENT_TIMESTAMP, B'1');
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
INSERT INTO Book (id, title, note, author, folio, dewey, cutter, status_id, shelf_id, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Sistemas Operativos Modernos', '4ta Edición, Pearson Educación', 'Andrew S. Tanenbaum', 'FOL-TECNM-001', '005.43', 'T164s', 1, 4, 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Ingeniería de Software: Un Enfoque Práctico', '7ma Edición, McGraw-Hill', 'Roger S. Pressman', 'FOL-TECNM-002', '005.1', 'P935i', 1, 1, 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Código Limpio: Manual de estilo para el desarrollo ágil', '1ra Edición, Anaya Multimedia', 'Robert C. Martin', 'FOL-TECNM-003', '005.13', 'M379c', 2, 1, 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Fundamentos de Bases de Datos', '6ta Edición, McGraw-Hill Interamericana', 'Abraham Silberschatz', 'FOL-TECNM-004', '005.74', 'S582f', 1, 2, 1, CURRENT_TIMESTAMP, B'1'),
(5, 'Redes de Computadoras: Un Enfoque Descendente', '7ma Edición, Pearson', 'James F. Kurose', 'FOL-TECNM-005', '004.6', 'K96r', 2, 3, 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Cálculo de una Variable: Trascendentes Tempranas', '8va Edición, Cengage Learning', 'James Stewart', 'FOL-TECNM-006', '515.3', 'S849c', 1, 5, 1, CURRENT_TIMESTAMP, B'1'),
(7, 'Introduction to Algorithms (CLRS)', '3rd Edition, MIT Press', 'Thomas H. Cormen', 'FOL-TECNM-007', '005.1', 'C811i', 3, 1, 1, CURRENT_TIMESTAMP, B'1'),
(8, 'Ingeniería del Software', '9na Edición, Pearson Addison Wesley', 'Ian Sommerville', 'FOL-TECNM-008', '005.1', 'S696i', 5, 1, 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Book_id_seq', (SELECT MAX(id) FROM Book));

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

-- 8. Prestamistas / Usuarios (Borrower) con correos institucionales '@monclova.tecnm.mx'
INSERT INTO Borrower (id, name, studentid, major, time, phoneNumber, email, idUserCreate, dateCreate, idStatus) VALUES
(1, 'Carlos Alberto Mendoza Rivas', '21280541', 'Ingeniería en Sistemas Computacionales', 'Matutino - 7mo Semestre', '8661234567', 'l21280541@monclova.tecnm.mx', 1, CURRENT_TIMESTAMP, B'1'),
(2, 'Ana Sofía Garza Villalobos', '22280312', 'Ingeniería en Sistemas Computacionales', 'Matutino - 5to Semestre', '8662345678', 'l22280312@monclova.tecnm.mx', 1, CURRENT_TIMESTAMP, B'1'),
(3, 'Luis Fernando Treviño Peña', '20280199', 'Ingeniería Industrial', 'Vespertino - 9no Semestre', '8663456789', 'l20280199@monclova.tecnm.mx', 1, CURRENT_TIMESTAMP, B'1'),
(4, 'Valeria Guadalupe Castillo Morales', '23280820', 'Ingeniería en Gestión Empresarial', 'Matutino - 3er Semestre', '8664567890', 'l23280820@monclova.tecnm.mx', 1, CURRENT_TIMESTAMP, B'1'),
(5, 'Ing. Roberto Hernández Dávila', 'DOC-ISC-014', 'Docente - Departamento de Sistemas', 'Tiempo Completo', '8665678901', 'roberto.hernandez@monclova.tecnm.mx', 1, CURRENT_TIMESTAMP, B'1'),
(6, 'Lic. Martha Elena Vázquez Torres', 'ADM-BIB-003', 'Administrador de Biblioteca', 'Turno Completo', '8666789012', 'martha.vazquez@monclova.tecnm.mx', 1, CURRENT_TIMESTAMP, B'1');
SELECT setval('Borrower_id_seq', (SELECT MAX(id) FROM Borrower));

-- 9. Préstamos de prueba (Loan)
INSERT INTO Loan (id, book_id, borrower_id, startDate, dueDate, returnDate, responsible, idUserCreate, dateCreate, idStatus) VALUES
(1, 3, 1, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP + INTERVAL '2 days', NULL, 'Lic. Martha Elena Vázquez Torres', 1, CURRENT_TIMESTAMP - INTERVAL '5 days', B'1'),
(2, 5, 2, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '4 days', NULL, 'Lic. Martha Elena Vázquez Torres', 1, CURRENT_TIMESTAMP - INTERVAL '3 days', B'1'),
(3, 1, 3, CURRENT_TIMESTAMP - INTERVAL '14 days', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '6 days', 'Lic. Martha Elena Vázquez Torres', 1, CURRENT_TIMESTAMP - INTERVAL '14 days', B'1');
SELECT setval('Loan_id_seq', (SELECT MAX(id) FROM Loan));
