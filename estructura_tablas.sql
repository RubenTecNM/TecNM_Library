-- =============================================================================
-- Estructura simplificada de tablas (extraída de scriptAlumnosTEC.sql)
-- Total de tablas: 85
-- =============================================================================

CREATE TABLE CreacionGrupos (
    Folio                BIGINT      NOT NULL,
    PeriodoID            INT         NOT NULL,
    Ano                  INT         NOT NULL,
    ClaveMateria         VARCHAR(15) NOT NULL,
    Grupo                VARCHAR(10) NOT NULL,
    ClaveDocente         VARCHAR(5)  NOT NULL,
    Limite               INT         NOT NULL,
    LunesHI              VARCHAR(8)  NOT NULL,
    LunesHF              VARCHAR(8)  NOT NULL,
    LunesAula            VARCHAR(8)  NOT NULL,
    MartesHI             VARCHAR(8)  NOT NULL,
    MartesHF             VARCHAR(8)  NOT NULL,
    MartesAula           VARCHAR(8)  NOT NULL,
    MiercolesHI          VARCHAR(8)  NOT NULL,
    MiercolesHF          VARCHAR(8)  NOT NULL,
    MiercolesAula        VARCHAR(8)  NOT NULL,
    JuevesHI             VARCHAR(8)  NOT NULL,
    JuevesHF             VARCHAR(8)  NOT NULL,
    JuevesAula           VARCHAR(8)  NOT NULL,
    ViernesHI            VARCHAR(8)  NOT NULL,
    ViernesHF            VARCHAR(8)  NOT NULL,
    ViernesAula          VARCHAR(8)  NOT NULL,
    SabadoHI             VARCHAR(8)  NOT NULL,
    SabadoHF             VARCHAR(8)  NOT NULL,
    SabadoAula           VARCHAR(8)  NOT NULL,
    LunesA               VARCHAR(15) NOT NULL,
    MartesA              VARCHAR(15) NOT NULL,
    MiercolesA           VARCHAR(15) NOT NULL,
    JuevesA              VARCHAR(15) NOT NULL,
    ViernesA             VARCHAR(15) NOT NULL,
    SabadoA              VARCHAR(15) NOT NULL,
    Inscritos            INT         NOT NULL,
    UsuarioCreacion      VARCHAR(30) NOT NULL,
    FechaCreacion        DATETIME    NOT NULL,
    UsuarioModificacion  VARCHAR(30) NOT NULL,
    FechaModificacion    DATETIME    NOT NULL,
    IP                   VARCHAR(16) NOT NULL,
    Base                 BIT         NOT NULL,
    Seccion              VARCHAR(5)  NULL,
    DomingoHI            VARCHAR(8)  NOT NULL,
    DomingoHF            VARCHAR(8)  NOT NULL,
    DomingoA             VARCHAR(15) NOT NULL,
    DomingoAula          VARCHAR(8)  NOT NULL,
    CveOfiCom            VARCHAR(15) NULL,
    CarreraID            INT         NULL,
    PRIMARY KEY (Folio)
);

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
    PRIMARY KEY (PlanEstID, CarreraID)
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

CREATE TABLE ListaGrupos (
    PeriodoID            INT           NOT NULL,
    Ano                  INT           NOT NULL,
    Matricula            VARCHAR(12)   NOT NULL,
    ClaveMateria         VARCHAR(15)   NOT NULL,
    Grupo                VARCHAR(12)   NOT NULL,
    Calificacion         INT           NOT NULL,
    Oportunidad          INT           NOT NULL,
    U1                   INT           NOT NULL,
    O1                   INT           NOT NULL,
    F1                   INT           NOT NULL,
    U2                   INT           NOT NULL,
    O2                   INT           NOT NULL,
    F2                   INT           NOT NULL,
    U3                   INT           NOT NULL,
    O3                   INT           NOT NULL,
    F3                   INT           NOT NULL,
    U4                   INT           NOT NULL,
    O4                   INT           NOT NULL,
    F4                   INT           NOT NULL,
    U5                   INT           NOT NULL,
    O5                   INT           NOT NULL,
    F5                   INT           NOT NULL,
    U6                   INT           NOT NULL,
    O6                   INT           NOT NULL,
    F6                   INT           NOT NULL,
    U7                   INT           NOT NULL,
    O7                   INT           NOT NULL,
    F7                   INT           NOT NULL,
    U8                   INT           NOT NULL,
    O8                   INT           NOT NULL,
    F8                   INT           NOT NULL,
    U9                   INT           NOT NULL,
    O9                   INT           NOT NULL,
    F9                   INT           NOT NULL,
    U10                  INT           NOT NULL,
    O10                  INT           NOT NULL,
    F10                  INT           NOT NULL,
    U11                  INT           NOT NULL,
    O11                  INT           NOT NULL,
    F11                  INT           NOT NULL,
    U12                  INT           NOT NULL,
    O12                  INT           NOT NULL,
    F12                  INT           NOT NULL,
    U13                  INT           NOT NULL,
    O13                  INT           NOT NULL,
    F13                  INT           NOT NULL,
    U14                  INT           NOT NULL,
    O14                  INT           NOT NULL,
    F14                  INT           NOT NULL,
    U15                  INT           NOT NULL,
    O15                  INT           NOT NULL DEFAULT 0,
    F15                  INT           NOT NULL DEFAULT 0,
    Cerrado              INT           NOT NULL,
    UsuarioCreacion      VARCHAR(30)   NOT NULL,
    FechaCreacion        SMALLDATETIME NOT NULL,
    UsuarioModificacion  VARCHAR(30)   NOT NULL,
    FechaModificacion    SMALLDATETIME NOT NULL,
    IP                   VARCHAR(16)   NOT NULL,
    Conse                BIGINT        IDENTITY NOT NULL,
    Global               BIT           NULL,
    Baja                 BIT           NULL,
    PRIMARY KEY (PeriodoID, Ano, Matricula, ClaveMateria, Grupo)
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
    PRIMARY KEY (Matricula)
);

CREATE TABLE Asignaturas (
    ClaveMateria  VARCHAR(15)    NOT NULL,
    ClaveOficial  VARCHAR(15)    NOT NULL,
    Asignatura    VARCHAR(100)   NOT NULL,
    NombreCorto   VARCHAR(50)    NULL,
    Creditos      INT            NOT NULL,
    Promediar     VARCHAR(2)     NOT NULL,
    ExtraEscolar  VARCHAR(2)     NOT NULL,
    HT            INT            NOT NULL,
    HP            INT            NOT NULL,
    Orden         INT            NULL,
    Unidades      INT            NULL,
    Pdf           VARBINARY(MAX) NULL,
    Ofertar       VARCHAR(2)     NULL,
    especialidad  INT            NULL,
    PRIMARY KEY (ClaveMateria)
);

CREATE TABLE Docentes (
    Clave            VARCHAR(5)   NOT NULL,
    Nombre           VARCHAR(60)  NOT NULL,
    Apellidos        VARCHAR(60)  NOT NULL,
    EscuelaPro       VARCHAR(100) NULL,
    Sexo             VARCHAR(1)   NOT NULL,
    Vigente          BIT          NOT NULL,
    Cedula           VARCHAR(12)  NOT NULL,
    Correo           VARCHAR(100) NOT NULL,
    CURP             VARCHAR(25)  NOT NULL,
    RFC              VARCHAR(20)  NOT NULL,
    TelefonoC        VARCHAR(15)  NOT NULL,
    TelefonoM        VARCHAR(15)  NOT NULL,
    Foto             IMAGE        NULL,
    FechaIngreso     DATE         NOT NULL,
    Nota             VARCHAR(MAX) NULL,
    Pass             VARCHAR(50)  NULL,
    Tipo             VARCHAR(20)  NULL,
    CveDepto         INT          NULL,
    CveCategoria     VARCHAR(10)  NULL,
    CveTitu          INT          NULL,
    CveLicenciatura  INT          NULL,
    Titulo           VARCHAR(100) NULL,
    TotalHoras       INT          NULL,
    Cedula2          VARCHAR(10)  NULL,
    PRIMARY KEY (Clave)
);

CREATE TABLE Fichas (
    Folio               BIGINT         NOT NULL,
    PeriodoID           INT            NOT NULL,
    Ano                 INT            NOT NULL,
    Fecha               DATE           NOT NULL,
    Apellidos           VARCHAR(50)    NOT NULL,
    Nombre              VARCHAR(50)    NOT NULL,
    Sexo                VARCHAR(1)     NOT NULL,
    Nacionalidad        VARCHAR(15)    NOT NULL,
    EstadoCivil         VARCHAR(15)    NOT NULL,
    EstadoID            VARCHAR(2)     NOT NULL,
    MunicipioID         VARCHAR(3)     NOT NULL,
    Localidad           VARCHAR(80)    NULL,
    Calle               VARCHAR(80)    NULL,
    Numero              VARCHAR(20)    NULL,
    ColoniaID           VARCHAR(12)    NULL,
    CP                  VARCHAR(5)     NULL,
    Telefono            VARCHAR(15)    NULL,
    Movil               VARCHAR(15)    NULL,
    Email               VARCHAR(50)    NULL,
    FechaNac            DATE           NOT NULL,
    EstadoNac           VARCHAR(2)     NOT NULL,
    LugarNac            VARCHAR(100)   NULL,
    CURP                VARCHAR(30)    NOT NULL,
    RFC                 VARCHAR(20)    NULL,
    EscuelaID           INT            NOT NULL,
    Promedio            DECIMAL(18, 2) NOT NULL,
    AnoEgreso           VARCHAR(4)     NULL,
    TurnoID             INT            NOT NULL,
    CarreraOp1          INT            NOT NULL,
    CarreraOp2          INT            NOT NULL,
    NumHijos            INT            NOT NULL,
    TipoSangre          VARCHAR(15)    NOT NULL,
    NombrePadre         VARCHAR(50)    NULL,
    TelefonoPadre       VARCHAR(15)    NULL,
    NombreMadre         VARCHAR(50)    NULL,
    TelefonoMadre       VARCHAR(15)    NULL,
    Tutor               VARCHAR(50)    NULL,
    TelefonoTutor       VARCHAR(15)    NULL,
    Trabaja             VARCHAR(2)     NULL,
    LugarTrabajo        VARCHAR(80)    NULL,
    HorarioTrabajo      VARCHAR(50)    NULL,
    ServicioMedico      VARCHAR(20)    NOT NULL,
    NSS                 VARCHAR(15)    NOT NULL,
    Discapacidad        VARCHAR(50)    NOT NULL,
    Consecutivo         INT            NOT NULL,
    Ciclo               VARCHAR(15)    NOT NULL,
    Liberado            BIT            NOT NULL,
    EspecialidadPrepa   VARCHAR(80)    NULL DEFAULT '-',
    Hora                VARCHAR(20)    NOT NULL DEFAULT '-',
    Edificio            VARCHAR(5)     NOT NULL DEFAULT '-',
    Aula                VARCHAR(5)     NOT NULL DEFAULT '-',
    Pago                VARBINARY(MAX) NULL,
    Internet            BIT            NULL,
    TelefonoMovil       BIT            NULL,
    PC                  BIT            NULL,
    Lap                 BIT            NULL,
    Tablet              BIT            NULL,
    ActaNacPDF          VARBINARY(MAX) NULL,
    CURPPDF             VARBINARY(MAX) NULL,
    CertificadoPDF      VARBINARY(MAX) NULL,
    PagoPDF             VARBINARY(MAX) NULL,
    LiberadoDocumentos  VARCHAR(2)     NULL,
    Matricula           VARCHAR(15)    NULL,
    Telnun              VARCHAR(20)    NULL,
    Modalidad           VARCHAR(20)    NULL,
    LenguaIndigena      VARCHAR(2)     NULL,
    PRIMARY KEY (PeriodoID, Ano, CURP)
);

CREATE TABLE EvaluacionDocente (
    Folio         BIGINT       NOT NULL,
    PeriodoID     INT          NOT NULL,
    Ano           INT          NOT NULL,
    ClaveDocente  VARCHAR(10)  NOT NULL,
    ClaveMateria  VARCHAR(10)  NOT NULL,
    Grupo         VARCHAR(8)   NOT NULL,
    Respuesta     VARCHAR(50)  NOT NULL,
    Fecha         DATETIME     NULL,
    Comentarios   VARCHAR(MAX) NULL,
    Matricula     VARCHAR(50)  NOT NULL
);

CREATE TABLE HorariosDocentes (
    Folio         BIGINT      NOT NULL,
    PeriodoID     INT         NOT NULL,
    Ano           INT         NOT NULL,
    ClaveMateria  VARCHAR(10) NOT NULL,
    ClaveDocente  VARCHAR(10) NOT NULL,
    TurnoID       INT         NOT NULL,
    Grupo         VARCHAR(3)  NOT NULL,
    Posicion      INT         NOT NULL,
    Edificio      VARCHAR(10) NULL,
    Aula          VARCHAR(10) NULL
);

CREATE TABLE InscritoHistorial (
    PeriodoID  INT         NOT NULL,
    Ano        INT         NOT NULL,
    Matricula  VARCHAR(50) NOT NULL,
    Semestre   INT         NOT NULL,
    TurnoID    INT         NOT NULL,
    PRIMARY KEY (PeriodoID, Ano, Matricula)
);

CREATE TABLE Municipios (
    MunicipioID  VARCHAR(3)   NOT NULL,
    Municipio    VARCHAR(250) NOT NULL,
    EstadoID     VARCHAR(2)   NOT NULL,
    ID           INT          IDENTITY NOT NULL
);

CREATE TABLE Periodos (
    PeriodoID    INT         NOT NULL,
    Periodo      VARCHAR(20) NOT NULL,
    NombreCorto  VARCHAR(20) NOT NULL,
    PRIMARY KEY (PeriodoID)
);

CREATE TABLE ColoniasCP (
    ColoniaID    VARCHAR(5)   NOT NULL,
    CP           VARCHAR(5)   NULL,
    Colonia      VARCHAR(200) NULL,
    Tipo         VARCHAR(25)  NULL,
    EstadoID     VARCHAR(3)   NULL,
    MunicipioID  VARCHAR(3)   NULL,
    Codigo       VARCHAR(20)  NOT NULL,
    MuniID       VARCHAR(3)   NULL,
    PRIMARY KEY (Codigo)
);

CREATE TABLE Turnos (
    TurnoID  INT         NOT NULL,
    Turno    VARCHAR(20) NOT NULL,
    PRIMARY KEY (TurnoID)
);

CREATE TABLE Escuelas (
    EscuelaID    INT          NOT NULL,
    Escuela      VARCHAR(240) NOT NULL,
    EstadoID     VARCHAR(2)   NOT NULL,
    MunicipioID  VARCHAR(3)   NOT NULL,
    PRIMARY KEY (EscuelaID)
);

CREATE TABLE Especialidades (
    EspecialidadID  INT          NOT NULL,
    CarreraID       INT          NOT NULL,
    Especialidad    VARCHAR(100) NOT NULL,
    Vigente         BIT          NOT NULL DEFAULT 0,
    PRIMARY KEY (EspecialidadID),
    FOREIGN KEY (CarreraID) REFERENCES Carreras(CarreraID)
);

CREATE TABLE Estados (
    EstadoID     VARCHAR(2)  NOT NULL,
    Estado       VARCHAR(50) NOT NULL,
    Abreviatura  VARCHAR(10) NOT NULL,
    PRIMARY KEY (EstadoID)
);

CREATE TABLE AlumnoDetalle (
    Matricula            VARCHAR(15)   NOT NULL,
    EstadoID             VARCHAR(2)    NOT NULL,
    MunicipioID          VARCHAR(3)    NOT NULL,
    CP                   VARCHAR(10)   NULL,
    Colonia              VARCHAR(60)   NOT NULL,
    Calle                VARCHAR(100)  NOT NULL,
    Numero               VARCHAR(20)   NOT NULL,
    CURP                 VARCHAR(30)   NULL,
    RFC                  VARCHAR(30)   NULL,
    Email                VARCHAR(80)   NULL,
    Telefono             VARCHAR(25)   NULL,
    Movil                VARCHAR(25)   NULL,
    LugarNacimiento      VARCHAR(100)  NOT NULL,
    EstadoNacID          VARCHAR(2)    NOT NULL,
    FechaNacimiento      SMALLDATETIME NOT NULL,
    EstadoCivil          VARCHAR(20)   NOT NULL,
    NumHijos             INT           NOT NULL,
    TipoSangre           VARCHAR(10)   NOT NULL,
    EscuelaID            INT           NOT NULL,
    AnoEgreso            VARCHAR(4)    NULL,
    Promedio             DECIMAL(5, 2) NOT NULL,
    NombrePadre          VARCHAR(100)  NULL,
    TelefonoPadre        VARCHAR(16)   NULL,
    NombreMadre          VARCHAR(100)  NULL,
    TelefonoMadre        VARCHAR(16)   NULL,
    Tutor                VARCHAR(100)  NULL,
    TelefonoTutor        VARCHAR(16)   NULL,
    Trabaja              VARCHAR(2)    NOT NULL,
    LugarTrabajo         VARCHAR(100)  NULL,
    HorarioTrabajo       VARCHAR(50)   NULL,
    ServicioMedico       VARCHAR(15)   NOT NULL,
    NSS                  VARCHAR(30)   NOT NULL,
    Nacionalidad         VARCHAR(50)   NULL,
    Discapacidad         VARCHAR(20)   NOT NULL,
    Observaciones        VARCHAR(200)  NULL,
    Emergencia           VARCHAR(200)  NULL,
    UsuarioCreacion      VARCHAR(30)   NOT NULL,
    FechaCreacion        SMALLDATETIME NOT NULL,
    UsuarioModificacion  VARCHAR(30)   NOT NULL,
    FechaModificacion    SMALLDATETIME NOT NULL,
    LenguaIndigena       VARCHAR(2)    NULL DEFAULT 'NO',
    PRIMARY KEY (Matricula)
);

CREATE TABLE Kardex (
    Matricula            VARCHAR(12)   NOT NULL,
    ClaveMateria         VARCHAR(15)   NOT NULL,
    Calificacion         INT           NOT NULL,
    Oportunidad          INT           NOT NULL,
    SemestrePrimera      INT           NULL,
    PeriodoPrimera       INT           NOT NULL,
    AnoPrimera           INT           NOT NULL,
    SemestreSegunda      INT           NULL,
    PeriodoSegunda       INT           NULL,
    AnoSegunda           INT           NULL,
    PeriodoTercera       INT           NULL,
    AnoTercera           INT           NULL,
    FechaEspecial        VARCHAR(30)   NULL,
    FechaEspecial2       VARCHAR(30)   NULL,
    UsuarioCreacion      VARCHAR(30)   NULL,
    FechaCreacion        SMALLDATETIME NULL,
    UsuarioModificacion  VARCHAR(30)   NULL,
    FechaModificacion    SMALLDATETIME NULL,
    IP                   VARCHAR(16)   NULL,
    SemestreTercera      INT           NULL,
    PRIMARY KEY (Matricula, ClaveMateria)
);

CREATE TABLE Categorias (
    CveCategoria  VARCHAR(10) NOT NULL,
    Categoria     VARCHAR(70) NOT NULL,
    PRIMARY KEY (CveCategoria)
);

CREATE TABLE AccesosLog (
    Usuario  VARCHAR(30) NOT NULL,
    FechaIn  DATETIME    NOT NULL,
    Tipo     VARCHAR(3)  NOT NULL
);

CREATE TABLE ActividadesComplementarias (
    Folio         INT           NOT NULL,
    Matricula     VARCHAR(12)   NOT NULL,
    Actividad_ID  INT           NOT NULL,
    Actividad     VARCHAR(80)   NOT NULL,
    Creditos      INT           NOT NULL,
    Nota          VARCHAR(MAX)  NULL,
    Fecha         SMALLDATETIME NOT NULL,
    PeriodoID     INT           NULL,
    Ano           INT           NULL,
    Usuario       VARCHAR(30)   NULL
);

CREATE TABLE ActividadesDocentes (
    CveAct     VARCHAR(5)  NOT NULL,
    Actividad  VARCHAR(70) NOT NULL
);

CREATE TABLE Adeudos (
    FolioAD    INT          NOT NULL,
    Fecha      DATETIME     NOT NULL,
    Matricula  VARCHAR(15)  NOT NULL,
    Adeudo     VARCHAR(300) NOT NULL,
    Estatus    VARCHAR(10)  NOT NULL,
    Usuario    VARCHAR(20)  NOT NULL,
    PRIMARY KEY (FolioAD)
);

CREATE TABLE AsignaturaDetalle (
    ClaveOficial        VARCHAR(15)  NOT NULL,
    Caracterizacion     VARCHAR(MAX) NOT NULL,
    IntencionDidactica  VARCHAR(MAX) NOT NULL,
    Competencia         VARCHAR(MAX) NOT NULL,
    FuenteInformacion   VARCHAR(MAX) NOT NULL,
    PRIMARY KEY (ClaveOficial)
);

CREATE TABLE AsignaturaEspecialidad (
    id            INT         IDENTITY NOT NULL,
    idCarrera     INT         NULL,
    ClaveMateria  VARCHAR(15) NULL,
    PRIMARY KEY (id)
);

CREATE TABLE AsignaturasD (
    ClaveMateria    VARCHAR(15) NOT NULL,
    Semestre        INT         NOT NULL,
    Linea           INT         NOT NULL,
    Columna         INT         NOT NULL,
    Antecedente     VARCHAR(20) NOT NULL,
    PlanEst         VARCHAR(30) NOT NULL,
    CarreraID       NCHAR(10)   NOT NULL,
    Orden           INT         NOT NULL,
    Antecedente2    VARCHAR(15) NULL,
    Conse           INT         IDENTITY NOT NULL,
    EspecialidadID  INT         NULL
);

CREATE TABLE AsistenciaDocentes (
    Folio                BIGINT        NOT NULL,
    Fecha                SMALLDATETIME NOT NULL,
    ClaveDocente         VARCHAR(10)   NOT NULL,
    Docente              VARCHAR(70)   NOT NULL,
    ClaveMateria         VARCHAR(4)    NOT NULL,
    Grupo                VARCHAR(2)    NOT NULL,
    Materia              VARCHAR(100)  NOT NULL,
    Horario              VARCHAR(20)   NOT NULL,
    Tipo                 VARCHAR(1)    NOT NULL,
    Retardo              BIT           NOT NULL,
    RetardoMin           INT           NOT NULL,
    Observaciones        VARCHAR(MAX)  NULL,
    UsuarioCreacion      VARCHAR(20)   NOT NULL,
    FechaCreacion        SMALLDATETIME NOT NULL,
    UsuarioModificacion  VARCHAR(20)   NOT NULL,
    FechaModificacion    SMALLDATETIME NOT NULL,
    IP                   VARCHAR(16)   NOT NULL,
    Cerrado              BIT           NOT NULL,
    PeriodoID            INT           NOT NULL,
    Ano                  INT           NOT NULL,
    Dia                  INT           NOT NULL,
    Edificio             VARCHAR(10)   NULL,
    Aula                 VARCHAR(10)   NULL,
    TurnoID              INT           NULL
);

CREATE TABLE Aulas (
    AulaID       INT         NOT NULL,
    Descripcion  VARCHAR(50) NOT NULL,
    EdificioID   INT         NOT NULL
);

CREATE TABLE Bajas (
    BajaID  INT         NOT NULL,
    Baja    VARCHAR(50) NOT NULL,
    PRIMARY KEY (BajaID)
);

CREATE TABLE BajasRep (
    matricula  NVARCHAR(50)  NULL,
    nombre     NVARCHAR(150) NULL,
    motivo     NVARCHAR(150) NULL
);

CREATE TABLE BecasInscripcion (
    FolioSB             INT            NOT NULL,
    PeriodoID           INT            NOT NULL,
    Ano                 INT            NOT NULL,
    Fecha               DATE           NOT NULL,
    TipoBeca            VARCHAR(50)    NOT NULL,
    Matricula           VARCHAR(12)    NOT NULL,
    Actividad           VARCHAR(MAX)   NULL,
    HermanosEstudiando  VARCHAR(2)     NOT NULL,
    Carrera             VARCHAR(50)    NULL,
    Semestre            INT            NULL,
    Motivo              VARCHAR(MAX)   NOT NULL,
    DependeMismo        BIT            NOT NULL,
    IngresoMismo        DECIMAL(18, 2) NOT NULL,
    DependePadre        BIT            NOT NULL,
    IngresoPadre        DECIMAL(18, 2) NOT NULL,
    DependeMadre        BIT            NOT NULL,
    IngresoMadre        DECIMAL(18, 2) NOT NULL,
    DependeTutor        BIT            NOT NULL,
    IngresoTutor        DECIMAL(18, 2) NOT NULL,
    DependeConyuge      BIT            NOT NULL,
    IngresoConyuge      DECIMAL(18, 2) NOT NULL,
    DependeOtro         BIT            NOT NULL,
    IngresoOtro         DECIMAL(18, 2) NOT NULL,
    NumPersonas         INT            NOT NULL,
    TipoCasa            VARCHAR(20)    NOT NULL,
    NumHab              VARCHAR(5)     NOT NULL,
    Sector              VARCHAR(20)    NOT NULL,
    MedioTransporte     VARCHAR(70)    NOT NULL,
    NumVehiculos        VARCHAR(8)     NOT NULL,
    Marca               VARCHAR(30)    NULL,
    Modelo              VARCHAR(30)    NULL,
    Trabajas            VARCHAR(2)     NOT NULL,
    Empresa             VARCHAR(100)   NULL,
    Puesto              VARCHAR(100)   NULL,
    Ayuda               VARCHAR(2)     NOT NULL,
    Institucion         VARCHAR(80)    NULL,
    IngresoMensual      DECIMAL(18, 2) NOT NULL,
    Porcentaje          INT            NOT NULL,
    Estatus             VARCHAR(10)    NOT NULL,
    MontoPagar          VARCHAR(15)    NOT NULL,
    NumPerEst           INT            NOT NULL DEFAULT 0,
    SemestreCursar      INT            NOT NULL,
    Observaciones       VARCHAR(250)   NULL,
    Promedio            INT            NULL,
    PRIMARY KEY (PeriodoID, Ano, Matricula)
);

CREATE TABLE BecasInscripcionNI (
    FolioSBNI           INT          NOT NULL,
    PeriodoID           INT          NOT NULL,
    Ano                 INT          NOT NULL,
    CURP                VARCHAR(30)  NOT NULL,
    Fecha               DATE         NOT NULL,
    TipoBeca            VARCHAR(50)  NOT NULL,
    Matricula           VARCHAR(12)  NOT NULL,
    Actividad           VARCHAR(MAX) NULL,
    HermanosEstudiando  VARCHAR(2)   NOT NULL,
    Carrera             VARCHAR(50)  NULL,
    Semestre            INT          NULL,
    Motivo              VARCHAR(MAX) NOT NULL,
    DependeMismo        BIT          NOT NULL,
    IngresoMismo        VARCHAR(20)  NOT NULL,
    DependePadre        BIT          NOT NULL,
    IngresoPadre        VARCHAR(20)  NOT NULL,
    DependeMadre        BIT          NOT NULL,
    IngresoMadre        VARCHAR(20)  NOT NULL,
    DependeTutor        BIT          NOT NULL,
    IngresoTutor        VARCHAR(20)  NOT NULL,
    DependeConyuge      BIT          NOT NULL,
    IngresoConyuge      VARCHAR(20)  NOT NULL,
    DependeOtro         BIT          NOT NULL,
    IngresoOtro         VARCHAR(20)  NOT NULL,
    NumPersonas         INT          NOT NULL,
    TipoCasa            VARCHAR(20)  NOT NULL,
    NumHab              VARCHAR(5)   NOT NULL,
    Sector              VARCHAR(20)  NOT NULL,
    MedioTransporte     VARCHAR(70)  NOT NULL,
    NumVehiculos        VARCHAR(8)   NOT NULL,
    Marca               VARCHAR(30)  NULL,
    Modelo              VARCHAR(30)  NULL,
    Trabajas            VARCHAR(2)   NOT NULL,
    Empresa             VARCHAR(100) NULL,
    Puesto              VARCHAR(100) NULL,
    Ayuda               VARCHAR(2)   NOT NULL,
    Institucion         VARCHAR(80)  NULL,
    IngresoMensual      VARCHAR(50)  NOT NULL,
    Porcentaje          INT          NOT NULL,
    Estatus             VARCHAR(10)  NOT NULL,
    MontoPagar          VARCHAR(15)  NOT NULL,
    NumPerEst           INT          NOT NULL,
    SemestreCursar      INT          NOT NULL,
    Promedio            VARCHAR(5)   NOT NULL,
    Calle               VARCHAR(100) NOT NULL,
    Numero              VARCHAR(30)  NOT NULL,
    Colonia             VARCHAR(50)  NOT NULL,
    Municipio           VARCHAR(50)  NOT NULL,
    Estado              VARCHAR(50)  NOT NULL,
    CP                  VARCHAR(5)   NOT NULL,
    Celular             VARCHAR(20)  NOT NULL,
    Telcasa             VARCHAR(20)  NOT NULL,
    Edad                VARCHAR(2)   NULL,
    EstadoCivil         VARCHAR(20)  NOT NULL,
    Nacionalidad        VARCHAR(20)  NOT NULL,
    Movil               VARCHAR(16)  NOT NULL,
    Email               VARCHAR(50)  NOT NULL,
    Apellidos           VARCHAR(50)  NOT NULL,
    Nombre              VARCHAR(50)  NOT NULL,
    Sexo                VARCHAR(1)   NOT NULL,
    Observaciones       VARCHAR(250) NULL,
    PRIMARY KEY (PeriodoID, Ano, CURP)
);

CREATE TABLE CalendarioEvaluacion (
    PeriodoID     VARCHAR(1)  NOT NULL,
    Ano           VARCHAR(4)  NOT NULL,
    ClaveOficial  VARCHAR(12) NOT NULL,
    ClaveDocente  VARCHAR(6)  NOT NULL,
    Horario       VARCHAR(80) NOT NULL,
    Semanas       VARCHAR(60) NOT NULL,
    PRIMARY KEY (PeriodoID, Ano, ClaveOficial, ClaveDocente, Horario)
);

CREATE TABLE Colonias (
    ColoniaID    VARCHAR(50) NULL,
    CP           VARCHAR(50) NULL,
    Colonia      VARCHAR(50) NULL,
    Tipo         VARCHAR(50) NULL,
    EstadoID     VARCHAR(50) NULL,
    MunicipioID  VARCHAR(50) NULL,
    Codigo       VARCHAR(50) NULL,
    MuniID       VARCHAR(50) NULL
);

CREATE TABLE Competencias (
    ClaveOficial  VARCHAR(15)  NOT NULL,
    Unidad        INT          NOT NULL,
    Tema          VARCHAR(200) NOT NULL,
    Competencia   VARCHAR(MAX) NOT NULL,
    Genericas     VARCHAR(MAX) NULL,
    Actividades   VARCHAR(MAX) NOT NULL,
    SubTemas      VARCHAR(MAX) NOT NULL,
    PRIMARY KEY (ClaveOficial, Unidad)
);

CREATE TABLE Configuracion (
    Dependencia           VARCHAR(150)   NOT NULL,
    ClaveEscolar          VARCHAR(30)    NULL,
    Direccion             VARCHAR(150)   NOT NULL,
    Ciudad                VARCHAR(80)    NULL,
    EstadoID              VARCHAR(2)     NULL,
    CP                    VARCHAR(50)    NOT NULL,
    Telefono              VARCHAR(15)    NULL,
    Telefono2             VARCHAR(15)    NULL,
    PeriodoID             INT            NOT NULL,
    Ano                   INT            NOT NULL,
    Ciclo                 VARCHAR(20)    NOT NULL,
    Director              VARCHAR(80)    NOT NULL,
    DirectorAcademico     VARCHAR(80)    NOT NULL,
    ControlEscolar        VARCHAR(80)    NOT NULL,
    ExamenAdmision        SMALLDATETIME  NOT NULL,
    HoraExamenAdmision    VARCHAR(40)    NOT NULL,
    EntregaDocumentacion  SMALLDATETIME  NOT NULL,
    Periodo               VARCHAR(100)   NOT NULL,
    Vacaciones            VARCHAR(100)   NOT NULL,
    FechaNivelacion       VARCHAR(80)    NOT NULL,
    HoraM                 VARCHAR(50)    NOT NULL,
    HoraN                 VARCHAR(50)    NOT NULL,
    Verano                VARCHAR(80)    NOT NULL,
    Conse                 INT            NULL,
    InicioMat             INT            NULL,
    CostoInscripcion      DECIMAL(18, 2) NULL,
    Link                  VARCHAR(50)    NULL,
    Calificaciones        BIT            NULL,
    Horario               BIT            NULL,
    Bloqueo               BIT            NULL,
    EntregaProgramacion   DATE           NULL,
    Seguimiento1          DATE           NULL,
    Seguimiento2          DATE           NULL,
    Seguimiento3          DATE           NULL,
    EntregaFinal          DATE           NULL,
    ConseCartaibre        INT            NULL
);

CREATE TABLE CorreosClaves (
    Matricula  VARCHAR(12) NOT NULL,
    Clave      VARCHAR(30) NOT NULL,
    PRIMARY KEY (Matricula)
);

CREATE TABLE CursoEspecial (
    Matricula     VARCHAR(15) NOT NULL,
    ClaveMateria  VARCHAR(20) NOT NULL,
    PeriodoID     INT         NOT NULL,
    Ano           INT         NOT NULL,
    PRIMARY KEY (Matricula, ClaveMateria, PeriodoID, Ano)
);

CREATE TABLE Departamentos (
    CveDepto      INT         NOT NULL,
    Departamento  VARCHAR(70) NOT NULL,
    Encargado     VARCHAR(50) NULL DEFAULT '-',
    Puesto        VARCHAR(50) NULL DEFAULT '-',
    PRIMARY KEY (CveDepto)
);

CREATE TABLE DisponibilidadMaterias (
    Conse         BIGINT     NOT NULL,
    PeriodoID     INT        NOT NULL,
    Ano           INT        NOT NULL,
    ClaveDocente  VARCHAR(6) NOT NULL,
    ClaveMateria  VARCHAR(5) NOT NULL,
    TurnoID       INT        NOT NULL,
    Grupo         VARCHAR(2) NOT NULL,
    Prioridad     INT        NULL
);

CREATE TABLE dkar (
    Matricula     NVARCHAR(255) NULL,
    ClaveMeria    NVARCHAR(255) NULL,
    Calificacion  FLOAT         NULL,
    Oportuniad    FLOAT         NULL,
    Semestre      FLOAT         NULL,
    Periodo1      FLOAT         NULL,
    Ano1          FLOAT         NULL,
    Semestre2     FLOAT         NULL,
    Periodo2      FLOAT         NULL,
    Ano2          NVARCHAR(255) NULL,
    Periodo3      NVARCHAR(255) NULL,
    Ano3          NVARCHAR(255) NULL,
    FechaEsp      NVARCHAR(255) NULL,
    FechaEsp2     NVARCHAR(255) NULL,
    UsuarioC      NVARCHAR(255) NULL,
    FechaC        DATETIME      NULL,
    usuarioM      NVARCHAR(255) NULL,
    FechaM        DATETIME      NULL,
    IP            NVARCHAR(255) NULL,
    Semestre3     FLOAT         NULL
);

CREATE TABLE Docente (
    idDocente  INT  NOT NULL,
    fecha      DATE NULL,
    PRIMARY KEY (idDocente)
);

CREATE TABLE DocentesActividades (
    PeriodoID     INT          NOT NULL,
    Ano           INT          NOT NULL,
    ClaveDocente  VARCHAR(5)   NOT NULL,
    CveAct        VARCHAR(5)   NOT NULL,
    Actividad     VARCHAR(70)  NOT NULL,
    Horas         INT          NOT NULL,
    Lugar         VARCHAR(100) NOT NULL,
    Lunes         VARCHAR(15)  NULL,
    Martes        VARCHAR(15)  NULL,
    Miercoles     VARCHAR(15)  NULL,
    Jueves        VARCHAR(15)  NULL,
    Viernes       VARCHAR(15)  NULL,
    Sabado        VARCHAR(15)  NULL,
    Domingo       VARCHAR(15)  NULL,
    Folio         INT          NOT NULL
);

CREATE TABLE DocentesDP (
    Clave        VARCHAR(5)   NOT NULL,
    FechaNac     DATE         NOT NULL,
    Direccion    VARCHAR(100) NOT NULL,
    Colonia      VARCHAR(100) NOT NULL,
    CP           VARCHAR(5)   NOT NULL,
    Ciudad       VARCHAR(80)  NOT NULL,
    MunicipioID  VARCHAR(3)   NOT NULL,
    EstadoID     VARCHAR(2)   NOT NULL,
    Hijos        INT          NOT NULL,
    NSS          VARCHAR(20)  NOT NULL,
    EstadoCivil  VARCHAR(20)  NOT NULL,
    PRIMARY KEY (Clave)
);

CREATE TABLE DocentesExtra (
    Clave        VARCHAR(5)  NOT NULL,
    Fecha        DATE        NOT NULL,
    Tipo         VARCHAR(10) NOT NULL,
    Descripcion  VARCHAR(10) NOT NULL,
    Horas        INT         NOT NULL,
    FOREIGN KEY (Clave) REFERENCES Docentes(Clave)
);

CREATE TABLE DocentesFormacion (
    Clave       VARCHAR(5)   NOT NULL,
    AnoInicio   INT          NOT NULL,
    AnoTermino  INT          NOT NULL,
    Titulo      VARCHAR(100) NOT NULL,
    Escuela     VARCHAR(100) NOT NULL,
    Cedula      VARCHAR(50)  NULL,
    Folio       INT          IDENTITY NOT NULL,
    PRIMARY KEY (Folio)
);

CREATE TABLE DocentesNotas (
    Clave      VARCHAR(5)   NOT NULL,
    Fecha      DATE         NOT NULL,
    Asunto     VARCHAR(400) NOT NULL,
    Detalles   VARCHAR(MAX) NOT NULL,
    CreadoPor  VARCHAR(30)  NOT NULL,
    Conse      BIGINT       NOT NULL,
    FOREIGN KEY (Clave) REFERENCES Docentes(Clave)
);

CREATE TABLE DocentesOtros (
    Clave             NCHAR(10)    NOT NULL,
    Experiencia       VARCHAR(MAX) NOT NULL,
    Reconocimientos   VARCHAR(MAX) NOT NULL,
    CursosRecibidos   VARCHAR(MAX) NOT NULL,
    CursosImpartidos  VARCHAR(MAX) NOT NULL,
    PRIMARY KEY (Clave)
);

CREATE TABLE DocentesTitulos (
    CveTitu  INT         NOT NULL,
    Titulo   VARCHAR(80) NOT NULL,
    Abrev    VARCHAR(10) NOT NULL
);

CREATE TABLE Documentacion (
    Matricula            VARCHAR(10)  NOT NULL,
    Acta                 BIT          NOT NULL,
    CerSec               BIT          NOT NULL,
    CerPre               BIT          NOT NULL,
    Fotos                BIT          NOT NULL,
    Otro                 BIT          NOT NULL,
    ObservacionesActa    VARCHAR(100) NOT NULL,
    ObservacionesCerSec  VARCHAR(100) NOT NULL,
    ObservacionesCerPre  VARCHAR(100) NOT NULL,
    ObservacionesFotos   VARCHAR(100) NOT NULL,
    ObservacionesOtro    VARCHAR(100) NOT NULL,
    UsuarioCreacion      VARCHAR(30)  NOT NULL,
    FechaCreacion        DATETIME     NOT NULL,
    UsuarioModificacion  VARCHAR(30)  NOT NULL,
    FechaModificacion    DATETIME     NOT NULL,
    IP                   VARCHAR(16)  NOT NULL,
    CartaAutenticidad    BIT          NULL,
    CURP                 BIT          NULL,
    ObservacionesCarta   VARCHAR(100) NULL,
    ObservacionesCURP    VARCHAR(100) NULL
);

CREATE TABLE Edificios (
    EdificioID  INT         NOT NULL,
    Edificio    VARCHAR(10) NOT NULL,
    PRIMARY KEY (EdificioID)
);

CREATE TABLE Empresas (
    EmpresaID      INT          NOT NULL,
    Empresa        VARCHAR(200) NOT NULL,
    RFC            VARCHAR(25)  NOT NULL,
    Calle          VARCHAR(100) NULL,
    Numero         VARCHAR(20)  NULL,
    Colonia        VARCHAR(80)  NULL,
    Ciudad         VARCHAR(80)  NULL,
    EstadoID       VARCHAR(2)   NULL,
    Telefono       VARCHAR(15)  NOT NULL,
    Telefono2      VARCHAR(15)  NOT NULL,
    Representante  VARCHAR(70)  NULL,
    Puesto         VARCHAR(70)  NULL,
    Contacto       VARCHAR(80)  NULL,
    Puesto2        VARCHAR(80)  NULL,
    Giro           VARCHAR(20)  NOT NULL,
    Sector         VARCHAR(20)  NOT NULL,
    PRIMARY KEY (EmpresaID)
);

CREATE TABLE enec (
    idMateria  NVARCHAR(10) NULL,
    nombre     NVARCHAR(50) NULL
);

CREATE TABLE Estatus (
    EstatusID  VARCHAR(3)  NOT NULL,
    Estatus    VARCHAR(40) NOT NULL,
    PRIMARY KEY (EstatusID)
);

CREATE TABLE FichaCanalizacion (
    FolioFC        BIGINT         NOT NULL,
    PeriodoID      INT            NOT NULL,
    Ano            INT            NOT NULL,
    ClaveMateria   VARCHAR(5)     NOT NULL,
    Grupo          VARCHAR(3)     NOT NULL,
    Especialidad   VARCHAR(100)   NOT NULL,
    Tutor          VARCHAR(100)   NULL,
    Problematica   VARCHAR(MAX)   NULL,
    Servicio       VARCHAR(MAX)   NULL,
    Observaciones  VARCHAR(MAX)   NULL,
    Fecha          DATE           NULL,
    Evidencia1     VARBINARY(MAX) NULL,
    Unidad         INT            NULL,
    Porcentaje     DECIMAL(18, 2) NULL,
    PRIMARY KEY (FolioFC)
);

CREATE TABLE FichaContraReferencia (
    FolioFC        BIGINT         NOT NULL,
    PeriodoID      INT            NOT NULL,
    Ano            INT            NOT NULL,
    Tipo           VARCHAR(10)    NOT NULL,
    Matricula      VARCHAR(10)    NOT NULL,
    Nombre         VARCHAR(100)   NOT NULL,
    ClaveMateria   VARCHAR(5)     NOT NULL,
    Grupo          VARCHAR(3)     NOT NULL,
    Especialidad   VARCHAR(100)   NOT NULL,
    Semestre       INT            NOT NULL,
    Turno          VARCHAR(10)    NOT NULL,
    Tutor          VARCHAR(100)   NULL,
    Servicio       VARCHAR(MAX)   NULL,
    Nota           VARCHAR(MAX)   NULL,
    Observaciones  VARCHAR(MAX)   NULL,
    Fecha          DATE           NULL,
    Evidencia1     VARBINARY(MAX) NULL,
    Evidencia2     VARBINARY(MAX) NULL,
    Evidencia3     VARBINARY(MAX) NULL,
    FolioFCana     BIGINT         NULL,
    Unidad         INT            NULL,
    Porcentaje     DECIMAL(18, 2) NULL,
    PRIMARY KEY (FolioFC)
);

CREATE TABLE Files (
    ID            INT            IDENTITY NOT NULL,
    Name          NVARCHAR(100)  NOT NULL,
    ContentType   VARCHAR(50)    NOT NULL,
    Size          BIGINT         NOT NULL,
    Data          VARBINARY(MAX) NOT NULL,
    PeriodoID     INT            NOT NULL,
    Ano           INT            NOT NULL,
    ClaveMateria  VARCHAR(5)     NOT NULL,
    ClaveDocente  VARCHAR(10)    NOT NULL,
    Grupo         VARCHAR(5)     NOT NULL
);

CREATE TABLE FilesInscripciones (
    PeriodoID        INT          NOT NULL,
    Ano              INT          NOT NULL,
    Matricula        VARCHAR(15)  NOT NULL,
    PagoInscripcion  IMAGE        NOT NULL,
    RFC              VARCHAR(20)  NULL,
    Razon            VARCHAR(200) NULL,
    Domicilio        VARCHAR(250) NULL,
    Correo           VARCHAR(150) NOT NULL,
    Telefono         VARCHAR(20)  NOT NULL,
    Observaciones    VARCHAR(250) NULL,
    Folio            INT          IDENTITY NOT NULL,
    fecha            DATE         NULL DEFAULT CURRENT_TIMESTAMP,
    estatus          VARCHAR(20)  NULL DEFAULT 'REVISION',
    PRIMARY KEY (PeriodoID, Ano, Matricula)
);

CREATE TABLE GruposExamenAdmision (
    Folio     INT         NOT NULL,
    Edificio  VARCHAR(2)  NOT NULL,
    Grupo     VARCHAR(2)  NOT NULL,
    Aula      VARCHAR(5)  NOT NULL,
    Cantidad  INT         NOT NULL,
    Horario   VARCHAR(50) NOT NULL,
    Liberado  VARCHAR(2)  NOT NULL,
    PRIMARY KEY (Folio)
);

CREATE TABLE GruposRegulares (
    Folio      INT         NOT NULL,
    CarreraID  INT         NOT NULL,
    Semestre   INT         NOT NULL,
    Matutino   VARCHAR(10) NOT NULL,
    Nocturno   VARCHAR(10) NOT NULL,
    TotalM     INT         NULL,
    ToTalN     INT         NULL,
    PRIMARY KEY (Folio)
);

CREATE TABLE Ingles (
    Matricula          VARCHAR(50)  NOT NULL,
    Nombre             VARCHAR(80)  NOT NULL,
    M1                 BIT          NOT NULL,
    CM1                INT          NOT NULL,
    M2                 BIT          NOT NULL,
    CM2                INT          NOT NULL,
    M3                 BIT          NOT NULL,
    CM3                INT          NOT NULL,
    M4                 BIT          NOT NULL,
    CM4                INT          NOT NULL,
    M5                 BIT          NOT NULL,
    CM5                INT          NOT NULL,
    M6                 BIT          NOT NULL,
    CM6                INT          NOT NULL,
    Comp               BIT          NULL,
    MB1                BIT          NULL,
    CB1                INT          NULL,
    MB2                BIT          NULL,
    CB2                INT          NULL,
    Liberado           BIT          NOT NULL,
    FechaModificacion  DATETIME     NULL,
    Observaciones      VARCHAR(MAX) NULL
);

CREATE TABLE Instrumentacion (
    FolioI           BIGINT       NOT NULL,
    PeriodoID        INT          NOT NULL,
    Ano              VARCHAR(4)   NOT NULL,
    ClaveMateria     VARCHAR(5)   NOT NULL,
    Caracterizacion  VARCHAR(MAX) NOT NULL,
    Intencion        VARCHAR(MAX) NOT NULL,
    Competencia      VARCHAR(MAX) NOT NULL,
    Docente          VARCHAR(6)   NOT NULL,
    PRIMARY KEY (FolioI)
);

CREATE TABLE IntrumentacionAna (
    FolioI       BIGINT       NOT NULL,
    Competencia  VARCHAR(200) NOT NULL,
    Descripcion  VARCHAR(250) NOT NULL
);

CREATE TABLE ITSMLG (
    PeriodoID            INT         NOT NULL,
    Ano                  INT         NOT NULL,
    Matricula            VARCHAR(50) NOT NULL,
    ClaveMateria         VARCHAR(50) NOT NULL,
    Grupo                VARCHAR(50) NOT NULL,
    Calificacion         INT         NOT NULL,
    Oportunidad          INT         NOT NULL,
    U1                   INT         NOT NULL,
    O1                   INT         NOT NULL,
    F1                   INT         NOT NULL,
    U2                   INT         NOT NULL,
    O2                   INT         NOT NULL,
    F2                   INT         NOT NULL,
    U3                   INT         NOT NULL,
    O3                   INT         NOT NULL,
    F3                   INT         NOT NULL,
    U4                   INT         NOT NULL,
    O4                   INT         NOT NULL,
    F4                   INT         NOT NULL,
    U5                   INT         NOT NULL,
    O5                   INT         NOT NULL,
    F5                   INT         NOT NULL,
    U6                   INT         NOT NULL,
    O6                   INT         NOT NULL,
    F6                   INT         NOT NULL,
    U7                   INT         NOT NULL,
    O7                   INT         NOT NULL,
    F7                   INT         NOT NULL,
    U8                   INT         NOT NULL,
    O8                   INT         NOT NULL,
    F8                   INT         NOT NULL,
    U9                   INT         NOT NULL,
    O9                   INT         NOT NULL,
    F9                   INT         NOT NULL,
    U10                  INT         NOT NULL,
    O10                  INT         NOT NULL,
    F10                  INT         NOT NULL,
    U11                  INT         NOT NULL,
    O11                  INT         NOT NULL,
    F11                  INT         NOT NULL,
    U12                  INT         NOT NULL,
    O12                  INT         NOT NULL,
    F12                  INT         NOT NULL,
    U13                  INT         NOT NULL,
    O13                  INT         NOT NULL,
    F13                  INT         NOT NULL,
    U14                  INT         NOT NULL,
    O14                  INT         NOT NULL,
    F14                  INT         NOT NULL,
    U15                  INT         NOT NULL,
    O15                  INT         NOT NULL,
    F15                  INT         NOT NULL,
    Cerrado              INT         NOT NULL,
    UsuarioCreacion      VARCHAR(50) NOT NULL,
    FechaCreacion        DATETIME    NOT NULL,
    UsuarioModificacion  VARCHAR(50) NOT NULL,
    FechaModificacion    DATETIME    NOT NULL,
    IP                   VARCHAR(50) NOT NULL,
    Conse                BIGINT      NOT NULL,
    Global               INT         NOT NULL,
    Baja                 INT         NOT NULL,
    Clave                VARCHAR(50) NOT NULL
);

CREATE TABLE Menu (
    CveMenu      VARCHAR(20) NOT NULL,
    Descripcion  VARCHAR(30) NOT NULL,
    Nivel        VARCHAR(1)  NOT NULL,
    PRIMARY KEY (CveMenu)
);

CREATE TABLE MenuPermisos (
    Usuario  VARCHAR(20) NOT NULL,
    CveMenu  VARCHAR(10) NOT NULL,
    Menu     VARCHAR(30) NOT NULL,
    Permiso  BIT         NOT NULL,
    Lectura  BIT         NULL
);

CREATE TABLE NivelCarreras (
    Nivel        INT         NOT NULL,
    Descripcion  VARCHAR(50) NOT NULL,
    PRIMARY KEY (Nivel)
);

CREATE TABLE Oportunidades (
    OportunidadID  INT         NOT NULL,
    Descripcion    VARCHAR(50) NOT NULL
);

CREATE TABLE OportunidadesC (
    OportunidadID  INT         NOT NULL,
    Oportunidad    VARCHAR(50) NOT NULL
);

CREATE TABLE Paso (
    Matricula  VARCHAR(12) NOT NULL,
    Espe       INT         NULL,
    PRIMARY KEY (Matricula)
);

CREATE TABLE Paso2 (
    Matricula  VARCHAR(12) NOT NULL,
    Tipo       VARCHAR(70) NOT NULL,
    dos        VARCHAR(50) NULL,
    tres       VARCHAR(50) NULL,
    PRIMARY KEY (Matricula)
);

CREATE TABLE Pasos (
    Letra         VARCHAR(50) NOT NULL,
    matricula     VARCHAR(20) NOT NULL,
    clavemateria  VARCHAR(15) NOT NULL
);

CREATE TABLE PeriodoVigente (
    idPer      INT IDENTITY NOT NULL,
    idPeriodo  INT NULL,
    year       INT NULL,
    status     BIT NULL,
    PRIMARY KEY (idPer)
);

CREATE TABLE Posiciones (
    Posicion     INT         NOT NULL,
    Descripcion  VARCHAR(50) NOT NULL,
    Dia          VARCHAR(20) NOT NULL,
    TurnoID      INT         NOT NULL,
    DiaNum       INT         NULL
);

CREATE TABLE RegistroCertificados (
    No                INT         IDENTITY NOT NULL,
    Fecha             DATE        NOT NULL,
    Matricula         VARCHAR(10) NOT NULL,
    Tipo              VARCHAR(15) NOT NULL,
    FolioCertificado  VARCHAR(10) NOT NULL,
    Num               VARCHAR(5)  NULL,
    Libro             VARCHAR(20) NULL,
    Foja              VARCHAR(50) NULL,
    PRIMARY KEY (No)
);

CREATE TABLE Residencias (
    FolioRP         BIGINT       NOT NULL,
    Matricula       VARCHAR(12)  NOT NULL,
    EmpresaID       INT          NOT NULL,
    Empresa         VARCHAR(250) NOT NULL,
    Proyecto        VARCHAR(250) NOT NULL,
    FechaInicio     VARCHAR(15)  NOT NULL,
    FechaTermino    VARCHAR(15)  NOT NULL,
    ClaveDoc        VARCHAR(50)  NOT NULL,
    AsesorExterno   VARCHAR(80)  NOT NULL,
    CargoAsesorExt  VARCHAR(150) NOT NULL,
    Estatus         VARCHAR(50)  NOT NULL,
    Observaciones   VARCHAR(250) NULL,
    PRIMARY KEY (FolioRP)
);

CREATE TABLE Scaneados (
    Matricula       VARCHAR(12)    NOT NULL,
    Ingreso         VARBINARY(MAX) NULL,
    Fecha           DATETIME       NOT NULL,
    ServicioSocial  VARBINARY(MAX) NULL,
    Residencia      VARBINARY(MAX) NULL,
    Ingles          VARBINARY(MAX) NULL,
    ActividadesC    VARBINARY(MAX) NULL
);

CREATE TABLE ServicioSocial (
    FolioSS           NCHAR(10)    NOT NULL,
    Matricula         VARCHAR(12)  NOT NULL,
    EmpresaID         INT          NOT NULL,
    Empresa           VARCHAR(250) NOT NULL,
    Departamento      VARCHAR(80)  NOT NULL,
    Programa          VARCHAR(100) NOT NULL,
    Area              VARCHAR(80)  NOT NULL,
    Responsable       VARCHAR(70)  NOT NULL,
    FechaInicio       VARCHAR(15)  NOT NULL,
    FechaTerminacion  VARCHAR(15)  NOT NULL,
    HoraInicio        VARCHAR(20)  NOT NULL,
    HoraTermino       VARCHAR(20)  NOT NULL,
    Situacion         VARCHAR(20)  NOT NULL,
    Estatus           VARCHAR(30)  NOT NULL,
    Nota              VARCHAR(MAX) NULL,
    Calificacion      INT          NULL,
    PRIMARY KEY (FolioSS)
);

CREATE TABLE ServicioSocialDoc (
    Matricula       VARCHAR(12)    NOT NULL,
    DescripcionDoc  VARCHAR(80)    NOT NULL,
    Documento       VARBINARY(MAX) NOT NULL,
    Orden           INT            NOT NULL,
    PRIMARY KEY (Matricula, DescripcionDoc)
);

CREATE TABLE Titulacion (
    Matricula  VARCHAR(12) NOT NULL,
    Nombre     VARCHAR(80) NOT NULL,
    PeriodoID  INT         NOT NULL,
    Ano        INT         NOT NULL,
    Estatus    VARCHAR(25) NOT NULL,
    Remesa     VARCHAR(10) NOT NULL,
    Fecha      DATE        NOT NULL,
    PRIMARY KEY (Matricula)
);

CREATE TABLE TurnoH (
    TurnoID  INT         NOT NULL,
    Turno    VARCHAR(50) NOT NULL,
    Letra    VARCHAR(1)  NOT NULL,
    PRIMARY KEY (TurnoID)
);

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
    PRIMARY KEY (UsuarioID)
);

CREATE TABLE verano (
    MATRICULA  NVARCHAR(50) NOT NULL,
    PRIMARY KEY (MATRICULA)
);
