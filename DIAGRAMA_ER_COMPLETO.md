# Diagrama Entidad-Relación Completo (85 Tablas)

Este documento contiene el modelo Entidad-Relación unificado con las **85 tablas** de la base de datos y todas sus interconexiones relacionales, en el formato visual solicitado.

```mermaid
erDiagram
    AccesosLog {
        varchar Usuario
        datetime FechaIn
        varchar Tipo
    }
    ActividadesComplementarias {
        varchar Matricula FK
        int PeriodoID FK
        int Folio
        int Actividad_ID
        varchar Actividad
        int Creditos
        varchar Nota
    }
    ActividadesDocentes {
        varchar CveAct
        varchar Actividad
    }
    Adeudos {
        int FolioAD PK
        varchar Matricula FK
        datetime Fecha
        varchar Adeudo
        varchar Estatus
        varchar Usuario
    }
    AlumnoDetalle {
        varchar Matricula PK
        varchar EstadoID FK
        varchar MunicipioID FK
        int EscuelaID FK
        varchar CP
        varchar Colonia
        varchar Calle
    }
    Alumnos {
        varchar Matricula PK
        int CarreraID FK
        int PlanEstID FK
        int EspecialidadID FK
        varchar EstatusID FK
        int TurnoID FK
        varchar BajaID FK
        varchar Apellidos
        varchar Nombre
    }
    AsignaturaDetalle {
        varchar ClaveOficial PK
        varchar Caracterizacion
        varchar IntencionDidactica
        varchar Competencia
        varchar FuenteInformacion
    }
    AsignaturaEspecialidad {
        int id PK
        varchar ClaveMateria FK
        int idCarrera
    }
    Asignaturas {
        varchar ClaveMateria PK
        varchar ClaveOficial FK
        varchar Asignatura
        varchar NombreCorto
        int Creditos
        varchar Promediar
        varchar ExtraEscolar
    }
    AsignaturasD {
        varchar ClaveMateria FK
        nchar CarreraID FK
        int EspecialidadID FK
        int Semestre
        int Linea
        int Columna
        varchar Antecedente
    }
    AsistenciaDocentes {
        varchar ClaveDocente FK
        varchar ClaveMateria FK
        int PeriodoID FK
        int TurnoID FK
        bigint Folio
        smalldatetime Fecha
        varchar Docente
    }
    Aulas {
        int EdificioID FK
        int AulaID
        varchar Descripcion
    }
    Bajas {
        int BajaID PK
        varchar Baja
    }
    BajasRep {
        nvarchar matricula FK
        nvarchar nombre
        nvarchar motivo
    }
    BecasInscripcion {
        int PeriodoID PK
        int Ano PK
        varchar Matricula PK
        int FolioSB
        date Fecha
        varchar TipoBeca
        varchar Actividad
    }
    BecasInscripcionNI {
        int PeriodoID PK
        int Ano PK
        varchar CURP PK
        varchar Matricula FK
        int FolioSBNI
        date Fecha
        varchar TipoBeca
    }
    CalendarioEvaluacion {
        varchar PeriodoID PK
        varchar Ano PK
        varchar ClaveOficial PK
        varchar ClaveDocente PK
        varchar Horario PK
        varchar Semanas
    }
    Carreras {
        int CarreraID PK
        varchar Carrera
        varchar NombreCorto
        varchar Modalidad
        varchar Apertura
        varchar Cierre
        bit Vigente
    }
    Categorias {
        varchar CveCategoria PK
        varchar Categoria
    }
    Colonias {
        varchar EstadoID FK
        varchar MunicipioID FK
        varchar ColoniaID
        varchar CP
        varchar Colonia
        varchar Tipo
        varchar Codigo
    }
    ColoniasCP {
        varchar Codigo PK
        varchar EstadoID FK
        varchar MunicipioID FK
        varchar ColoniaID
        varchar CP
        varchar Colonia
        varchar Tipo
    }
    Competencias {
        varchar ClaveOficial PK
        int Unidad PK
        varchar Tema
        varchar Competencia
        varchar Genericas
        varchar Actividades
        varchar SubTemas
    }
    Configuracion {
        varchar EstadoID FK
        int PeriodoID FK
        varchar Dependencia
        varchar ClaveEscolar
        varchar Direccion
        varchar Ciudad
        varchar CP
    }
    CorreosClaves {
        varchar Matricula PK
        varchar Clave
    }
    CreacionGrupos {
        bigint Folio PK
        int PeriodoID FK
        varchar ClaveMateria FK
        varchar ClaveDocente FK
        int CarreraID FK
        int Ano
        varchar Grupo
    }
    CursoEspecial {
        varchar Matricula PK
        varchar ClaveMateria PK
        int PeriodoID PK
        int Ano PK
    }
    Departamentos {
        int CveDepto PK
        varchar Departamento
        varchar Encargado
        varchar Puesto
    }
    DisponibilidadMaterias {
        int PeriodoID FK
        varchar ClaveDocente FK
        varchar ClaveMateria FK
        int TurnoID FK
        bigint Conse
        int Ano
        varchar Grupo
    }
    Docente {
        int idDocente PK
        date fecha
    }
    Docentes {
        varchar Clave PK
        int CveDepto FK
        varchar CveCategoria FK
        varchar Nombre
        varchar Apellidos
        varchar EscuelaPro
        varchar Sexo
    }
    DocentesActividades {
        int PeriodoID FK
        varchar ClaveDocente FK
        int Ano
        varchar CveAct
        varchar Actividad
        int Horas
        varchar Lugar
    }
    DocentesDP {
        varchar Clave PK
        varchar MunicipioID FK
        varchar EstadoID FK
        date FechaNac
        varchar Direccion
        varchar Colonia
        varchar CP
    }
    DocentesExtra {
        varchar Clave
        date Fecha
        varchar Tipo
        varchar Descripcion
        int Horas
    }
    DocentesFormacion {
        int Folio PK
        varchar Clave
        int AnoInicio
        int AnoTermino
        varchar Titulo
        varchar Escuela
        varchar Cedula
    }
    DocentesNotas {
        varchar Clave
        date Fecha
        varchar Asunto
        varchar Detalles
        varchar CreadoPor
        bigint Conse
    }
    DocentesOtros {
        nchar Clave PK
        varchar Experiencia
        varchar Reconocimientos
        varchar CursosRecibidos
        varchar CursosImpartidos
    }
    DocentesTitulos {
        int CveTitu
        varchar Titulo
        varchar Abrev
    }
    Documentacion {
        varchar Matricula FK
        bit Acta
        bit CerSec
        bit CerPre
        bit Fotos
        bit Otro
        varchar ObservacionesActa
    }
    Edificios {
        int EdificioID PK
        varchar Edificio
    }
    Empresas {
        int EmpresaID PK
        varchar EstadoID FK
        varchar Empresa
        varchar RFC
        varchar Calle
        varchar Numero
        varchar Colonia
    }
    Escuelas {
        int EscuelaID PK
        varchar EstadoID FK
        varchar MunicipioID FK
        varchar Escuela
    }
    Especialidades {
        int EspecialidadID PK
        int CarreraID FK
        varchar Especialidad
        bit Vigente
    }
    Estados {
        varchar EstadoID PK
        varchar Estado
        varchar Abreviatura
    }
    Estatus {
        varchar EstatusID PK
        varchar Estatus
    }
    EvaluacionDocente {
        int PeriodoID FK
        varchar ClaveDocente FK
        varchar ClaveMateria FK
        varchar Matricula FK
        bigint Folio
        int Ano
        varchar Grupo
    }
    FichaCanalizacion {
        bigint FolioFC PK
        int PeriodoID FK
        varchar ClaveMateria FK
        int Ano
        varchar Grupo
        varchar Especialidad
        varchar Tutor
    }
    FichaContraReferencia {
        bigint FolioFC PK
        int PeriodoID FK
        varchar Matricula FK
        varchar ClaveMateria FK
        int Ano
        varchar Tipo
        varchar Nombre
    }
    Fichas {
        int PeriodoID PK
        int Ano PK
        varchar CURP PK
        varchar EstadoID FK
        varchar MunicipioID FK
        int EscuelaID FK
        int TurnoID FK
        varchar Matricula FK
        bigint Folio
        date Fecha
    }
    Files {
        int PeriodoID FK
        varchar ClaveMateria FK
        varchar ClaveDocente FK
        int ID
        nvarchar Name
        varchar ContentType
        bigint Size
    }
    FilesInscripciones {
        int PeriodoID PK
        int Ano PK
        varchar Matricula PK
        image PagoInscripcion
        varchar RFC
        varchar Razon
        varchar Domicilio
    }
    GruposExamenAdmision {
        int Folio PK
        varchar Edificio
        varchar Grupo
        varchar Aula
        int Cantidad
        varchar Horario
        varchar Liberado
    }
    GruposRegulares {
        int Folio PK
        int CarreraID FK
        int Semestre
        varchar Matutino
        varchar Nocturno
        int TotalM
        int ToTalN
    }
    HorariosDocentes {
        int PeriodoID FK
        varchar ClaveMateria FK
        varchar ClaveDocente FK
        int TurnoID FK
        bigint Folio
        int Ano
        varchar Grupo
    }
    ITSMLG {
        int PeriodoID FK
        varchar Matricula FK
        varchar ClaveMateria FK
        int Ano
        varchar Grupo
        int Calificacion
        int Oportunidad
    }
    Ingles {
        varchar Matricula FK
        varchar Nombre
        bit M1
        int CM1
        bit M2
        int CM2
        bit M3
    }
    InscritoHistorial {
        int PeriodoID PK
        int Ano PK
        varchar Matricula PK
        int TurnoID FK
        int Semestre
    }
    Instrumentacion {
        bigint FolioI PK
        int PeriodoID FK
        varchar ClaveMateria FK
        varchar Ano
        varchar Caracterizacion
        varchar Intencion
        varchar Competencia
    }
    IntrumentacionAna {
        bigint FolioI
        varchar Competencia
        varchar Descripcion
    }
    Kardex {
        varchar Matricula PK
        varchar ClaveMateria PK
        int Calificacion
        int Oportunidad
        int SemestrePrimera
        int PeriodoPrimera
        int AnoPrimera
    }
    ListaGrupos {
        int PeriodoID PK
        int Ano PK
        varchar Matricula PK
        varchar ClaveMateria PK
        varchar Grupo PK
        int Calificacion
        int Oportunidad
    }
    Menu {
        varchar CveMenu PK
        varchar Descripcion
        varchar Nivel
    }
    MenuPermisos {
        varchar CveMenu FK
        varchar Usuario
        varchar Menu
        bit Permiso
        bit Lectura
    }
    Municipios {
        varchar MunicipioID FK
        varchar EstadoID FK
        varchar Municipio
        int ID
    }
    NivelCarreras {
        int Nivel PK
        varchar Descripcion
    }
    Oportunidades {
        int OportunidadID
        varchar Descripcion
    }
    OportunidadesC {
        int OportunidadID
        varchar Oportunidad
    }
    Paso {
        varchar Matricula PK
        int Espe
    }
    Paso2 {
        varchar Matricula PK
        varchar Tipo
        varchar dos
        varchar tres
    }
    Pasos {
        varchar matricula FK
        varchar Letra
        varchar clavemateria
    }
    PeriodoVigente {
        int idPer PK
        int idPeriodo
        int year
        bit status
    }
    Periodos {
        int PeriodoID PK
        varchar Periodo
        varchar NombreCorto
    }
    PlanEstudios {
        int PlanEstID PK
        int CarreraID PK
        varchar PlanEst
        bit Vigente
        varchar LetraPlan
        varchar Modalidad
        int TotalCreditos
    }
    Posiciones {
        int TurnoID FK
        int Posicion
        varchar Descripcion
        varchar Dia
        int DiaNum
    }
    RegistroCertificados {
        int No PK
        varchar Matricula FK
        date Fecha
        varchar Tipo
        varchar FolioCertificado
        varchar Num
        varchar Libro
    }
    Residencias {
        bigint FolioRP PK
        varchar Matricula FK
        int EmpresaID FK
        varchar Empresa
        varchar Proyecto
        varchar FechaInicio
        varchar FechaTermino
    }
    Scaneados {
        varchar Matricula FK
        varbinary Ingreso
        datetime Fecha
        varbinary ServicioSocial
        varbinary Residencia
        varbinary Ingles
        varbinary ActividadesC
    }
    ServicioSocial {
        nchar FolioSS PK
        varchar Matricula FK
        int EmpresaID FK
        varchar Empresa
        varchar Departamento
        varchar Programa
        varchar Area
    }
    ServicioSocialDoc {
        varchar Matricula PK
        varchar DescripcionDoc PK
        varbinary Documento
        int Orden
    }
    Titulacion {
        varchar Matricula PK
        int PeriodoID FK
        varchar Nombre
        int Ano
        varchar Estatus
        varchar Remesa
        date Fecha
    }
    TurnoH {
        int TurnoID PK
        varchar Turno
        varchar Letra
    }
    Turnos {
        int TurnoID PK
        varchar Turno
    }
    Usuarios {
        int UsuarioID PK
        int PeriodoID FK
        int CveDepto FK
        varchar Nombre
        varchar Puesto
        varchar Usuario
        varchar Clave
    }
    dkar {
        nvarchar Matricula FK
        nvarchar ClaveMeria
        float Calificacion
        float Oportuniad
        float Semestre
        float Periodo1
        float Ano1
    }
    enec {
        nvarchar idMateria
        nvarchar nombre
    }
    verano {
        nvarchar MATRICULA PK
    }
    Carreras ||--o{ PlanEstudios : "tiene_planes"
    Carreras ||--o{ Especialidades : "ofrece_especialidades"
    NivelCarreras ||--o{ Carreras : "clasifica_nivel"
    Turnos ||--o{ TurnoH : "desglose_turnos"
    Asignaturas ||--|| AsignaturaDetalle : "detalle_materia"
    Asignaturas ||--o{ Competencias : "evalua_competencias"
    Asignaturas ||--o{ AsignaturaEspecialidad : "materia_especialidad"
    Asignaturas ||--o{ AsignaturasD : "docente_materia"
    Asignaturas ||--o{ DisponibilidadMaterias : "disponibilidad_periodo"
    Categorias ||--o{ Docentes : "categoria_salarial"
    Docentes ||--o{ DocentesDP : "datos_personales"
    Docentes ||--o{ DocentesExtra : "horas_extra"
    Docentes ||--o{ DocentesNotas : "bitacora_notas"
    Docentes ||--o{ DocentesOtros : "datos_adicionales"
    Docentes ||--o{ DocentesTitulos : "grados_titulos"
    Docentes ||--o{ DocentesFormacion : "capacitacion"
    Docentes ||--o{ DocentesActividades : "actividades_docente"
    Docentes ||--o{ HorariosDocentes : "horario_clases"
    Docentes ||--o{ AsistenciaDocentes : "registro_asistencia"
    Docentes ||--o{ ActividadesDocentes : "actividades_apoyo"
    Docentes ||--o{ Docente : "catalogo_auxiliar"
    Carreras ||--o{ Alumnos : "carrera_alumno"
    PlanEstudios ||--o{ Alumnos : "plan_alumno"
    Especialidades ||--o{ Alumnos : "especialidad_alumno"
    Turnos ||--o{ Alumnos : "turno_alumno"
    Estatus ||--o{ Alumnos : "estatus_alumno"
    Periodos ||--o{ Alumnos : "periodo_ingreso"
    Bajas ||--o{ Alumnos : "motivo_baja"
    Alumnos ||--|| AlumnoDetalle : "detalle_personal"
    Alumnos ||--o{ InscritoHistorial : "historial_periodos"
    Alumnos ||--o{ BecasInscripcion : "solicita_beca"
    Alumnos ||--o{ CorreosClaves : "cuenta_correo"
    Alumnos ||--o{ Documentacion : "expediente_fisico"
    Alumnos ||--o{ Scaneados : "expediente_digital"
    Alumnos ||--o{ BajasRep : "reporte_baja"
    Alumnos ||--o{ Adeudos : "adeudos_alumno"
    Alumnos ||--o{ ActividadesComplementarias : "actividades_alumno"
    Alumnos ||--o{ Ingles : "acreditacion_ingles"
    Alumnos ||--o{ CursoEspecial : "cursos_especiales"
    Alumnos ||--o{ verano : "cursos_verano"
    Alumnos ||--o{ Kardex : "historial_academico"
    Alumnos ||--o{ Paso : "paso_reinscripcion"
    Alumnos ||--o{ Paso2 : "paso2_reinscripcion"
    Pasos ||--o{ Paso : "etapa_flujo"
    Fichas ||--o{ FilesInscripciones : "archivos_ingreso"
    Fichas ||--o{ BecasInscripcionNI : "beca_nuevo_ingreso"
    Alumnos ||--o{ FichaCanalizacion : "canalizacion_tutor"
    FichaCanalizacion ||--o{ FichaContraReferencia : "resolucion_caso"
    Alumnos ||--o{ Files : "archivos_generales"
    Edificios ||--o{ Aulas : "alberga_aulas"
    Aulas ||--o{ CreacionGrupos : "aula_asignada"
    Asignaturas ||--o{ CreacionGrupos : "materia_grupo"
    Docentes ||--o{ CreacionGrupos : "docente_titular"
    Periodos ||--o{ CreacionGrupos : "periodo_grupo"
    CreacionGrupos ||--o{ ListaGrupos : "alumnos_inscritos"
    Alumnos ||--o{ ListaGrupos : "cursa_grupo"
    CreacionGrupos ||--o{ GruposRegulares : "grupo_regular"
    CreacionGrupos ||--o{ GruposExamenAdmision : "grupo_admision"
    CreacionGrupos ||--o{ CalendarioEvaluacion : "fechas_examenes"
    CreacionGrupos ||--o{ EvaluacionDocente : "evaluaciones_alumnos"
    Instrumentacion ||--o{ IntrumentacionAna : "analisis_instrumentacion"
    CreacionGrupos ||--o{ Instrumentacion : "instrumentacion_didactica"
    ListaGrupos ||--o{ Kardex : "acredita_kardex"
    Asignaturas ||--o{ Kardex : "asignatura_kardex"
    Kardex ||--o{ dkar : "detalle_kardex"
    ListaGrupos ||--o{ ITSMLG : "calificaciones_lista"
    Oportunidades ||--o{ OportunidadesC : "tipo_oportunidad"
    Alumnos ||--o{ Residencias : "residencia_profesional"
    Alumnos ||--o{ ServicioSocial : "servicio_social"
    ServicioSocial ||--o{ ServicioSocialDoc : "reportes_servicio"
    Empresas ||--o{ Residencias : "sede_residencia"
    Empresas ||--o{ ServicioSocial : "sede_servicio"
    Alumnos ||--o{ Titulacion : "tramite_titulacion"
    Alumnos ||--o{ RegistroCertificados : "libro_certificados"
    Estados ||--o{ Municipios : "municipios_estado"
    Municipios ||--o{ Colonias : "colonias_municipio"
    Estados ||--o{ ColoniasCP : "cp_estado"
    Estados ||--o{ Escuelas : "escuelas_estado"
    Periodos ||--o{ PeriodoVigente : "vigencia_periodo"
    Departamentos ||--o{ Docentes : "adscripcion_docente"
    Departamentos ||--o{ Usuarios : "departamento_usuario"
    Periodos ||--o{ Usuarios : "periodo_trabajo"
    Usuarios ||--o{ AccesosLog : "bitacora_login"
    Menu ||--o{ MenuPermisos : "permisos_perfil"
```
