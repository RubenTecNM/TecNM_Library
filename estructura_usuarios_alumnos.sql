-- =============================================================================
-- Estructura de Usuarios, Alumnos y sus tablas de dependencia (catálogos)
-- Extraído y simplificado de scriptAlumnosTEC.sql
-- =============================================================================
-- Relación de dependencias:
--   - Periodos        (catálogo independiente)
--   - Departamentos   (catálogo independiente)
--   - Turnos          (catálogo independiente)
--   - Estatus         (catálogo independiente)
--   - Bajas           (catálogo independiente)
--   - Carreras        (catálogo independiente)
--   - PlanEstudios    -> depende de Carreras
--   - Especialidades  -> depende de Carreras
--   - Usuarios        -> depende de Periodos, Departamentos
--   - Alumnos         -> depende de Carreras, PlanEstudios, Especialidades,
--                                Turnos, Periodos, Estatus, Bajas
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Catálogos base independientes
-- -----------------------------------------------------------------------------

CREATE TABLE Periodos (
    PeriodoID    INT         NOT NULL,
    Periodo      VARCHAR(20) NOT NULL,
    NombreCorto  VARCHAR(20) NOT NULL,
    PRIMARY KEY (PeriodoID)
);

CREATE TABLE Departamentos (
    CveDepto      INT         NOT NULL,
    Departamento  VARCHAR(70) NOT NULL,
    Encargado     VARCHAR(50) NULL DEFAULT '-',
    Puesto        VARCHAR(50) NULL DEFAULT '-',
    PRIMARY KEY (CveDepto)
);

CREATE TABLE Turnos (
    TurnoID  INT         NOT NULL,
    Turno    VARCHAR(20) NOT NULL,
    PRIMARY KEY (TurnoID)
);

CREATE TABLE Estatus (
    EstatusID  VARCHAR(3)  NOT NULL,
    Estatus    VARCHAR(40) NOT NULL,
    PRIMARY KEY (EstatusID)
);

CREATE TABLE Bajas (
    BajaID  INT         NOT NULL,
    Baja    VARCHAR(50) NOT NULL,
    PRIMARY KEY (BajaID)
);

CREATE TABLE Carreras (
    CarreraID    INT         NOT NULL,
    Carrera      VARCHAR(90) NOT NULL,
    NombreCorto  VARCHAR(50) NOT NULL,
    Modalidad    VARCHAR(20) NOT NULL,
    Apertura     VARCHAR(4)  NOT NULL,
    Cierre       VARCHAR(4)  NOT NULL,
    Vigente      BIT         NOT NULL,
    Nivel        VARCHAR(20) NOT NULL,
    Situacion    VARCHAR(10) NOT NULL,
    TotalM       INT         NULL,
    TotalN       INT         NULL,
    Letra        VARCHAR(2)  NULL,
    Clave        VARCHAR(30) NULL,
    PRIMARY KEY (CarreraID)
);

-- -----------------------------------------------------------------------------
-- 2. Catálogos dependientes de Carreras
-- -----------------------------------------------------------------------------

CREATE TABLE PlanEstudios (
    PlanEstID             INT            NOT NULL,
    CarreraID             INT            NOT NULL,
    PlanEst               VARCHAR(20)    NOT NULL,
    Vigente               BIT            NOT NULL,
    LetraPlan             VARCHAR(2)     NOT NULL,
    Modalidad             VARCHAR(20)    NOT NULL,
    TotalCreditos         INT            NOT NULL,
    CargaMaxima           INT            NOT NULL,
    CargaMinima           INT            NOT NULL,
    CantidadMaterias      INT            NULL,
    CreditosEspecialidad  INT            NULL,
    PDF                   VARBINARY(MAX) NULL,
    Competencia           BIT            NULL,
    PRIMARY KEY (PlanEstID, CarreraID),
    FOREIGN KEY (CarreraID) REFERENCES Carreras(CarreraID)
);

CREATE TABLE Especialidades (
    EspecialidadID  INT          NOT NULL,
    CarreraID       INT          NOT NULL,
    Especialidad    VARCHAR(100) NOT NULL,
    Vigente         BIT          NOT NULL DEFAULT 0,
    PRIMARY KEY (EspecialidadID),
    FOREIGN KEY (CarreraID) REFERENCES Carreras(CarreraID)
);

-- -----------------------------------------------------------------------------
-- 3. Entidades principales
-- -----------------------------------------------------------------------------

CREATE TABLE Usuarios (
    UsuarioID  INT          NOT NULL,
    Nombre     VARCHAR(80)  NOT NULL,
    Puesto     VARCHAR(70)  NOT NULL,
    Usuario    VARCHAR(30)  NOT NULL,
    Clave      VARCHAR(250) NOT NULL,
    Tipo       VARCHAR(50)  NOT NULL,
    PeriodoID  INT          NOT NULL,
    Ano        INT          NOT NULL,
    Activo     BIT          NOT NULL,
    CveDepto   INT          NULL,
    PRIMARY KEY (UsuarioID),
    FOREIGN KEY (PeriodoID) REFERENCES Periodos(PeriodoID),
    FOREIGN KEY (CveDepto) REFERENCES Departamentos(CveDepto)
);

CREATE TABLE Alumnos (
    Matricula       VARCHAR(12)  NOT NULL,
    Apellidos       VARCHAR(50)  NOT NULL,
    Nombre          VARCHAR(50)  NOT NULL,
    Sexo            VARCHAR(1)   NOT NULL,
    Semestre        INT          NOT NULL,
    CarreraID       INT          NOT NULL,
    Modalidad       VARCHAR(20)  NOT NULL,
    PlanEstID       INT          NOT NULL,
    EspecialidadID  INT          NOT NULL,
    EstatusID       VARCHAR(3)   NOT NULL,
    Generacion      VARCHAR(4)   NOT NULL,
    Inscrito        BIT          NOT NULL,
    TotalCreditos   INT          NOT NULL DEFAULT 0,
    TurnoID         INT          NOT NULL DEFAULT 0,
    PeriodoIngreso  INT          NOT NULL,
    AnoIngreso      VARCHAR(4)   NOT NULL,
    PeriodoTermino  INT          NOT NULL,
    AnoTermino      VARCHAR(4)   NULL,
    BajaID          VARCHAR(4)   NOT NULL,
    PeriodoBaja     INT          NOT NULL,
    AnoBaja         VARCHAR(4)   NULL,
    FolioCert       VARCHAR(15)  NOT NULL DEFAULT '-',
    LibroCert       VARCHAR(15)  NOT NULL DEFAULT '-',
    Revalidacion    BIT          NOT NULL DEFAULT 0,
    Foto            IMAGE        NULL,
    Foja            VARCHAR(5)   NULL,
    Titulado        BIT          NULL,
    Clave           VARCHAR(250) NULL DEFAULT 'ITSM5000',
    ApellidoP       VARCHAR(50)  NULL DEFAULT '-',
    ApellidoM       VARCHAR(50)  NULL DEFAULT '-',
    correo          VARCHAR(50)  NULL DEFAULT '-',
    seccion         VARCHAR(2)   NULL DEFAULT '-',
    PRIMARY KEY (Matricula),
    FOREIGN KEY (CarreraID) REFERENCES Carreras(CarreraID),
    FOREIGN KEY (PlanEstID, CarreraID) REFERENCES PlanEstudios(PlanEstID, CarreraID),
    FOREIGN KEY (EspecialidadID) REFERENCES Especialidades(EspecialidadID),
    FOREIGN KEY (EstatusID) REFERENCES Estatus(EstatusID),
    FOREIGN KEY (TurnoID) REFERENCES Turnos(TurnoID),
    FOREIGN KEY (PeriodoIngreso) REFERENCES Periodos(PeriodoID),
    FOREIGN KEY (PeriodoTermino) REFERENCES Periodos(PeriodoID),
    FOREIGN KEY (PeriodoBaja) REFERENCES Periodos(PeriodoID),
    FOREIGN KEY (BajaID) REFERENCES Bajas(BajaID)
);
