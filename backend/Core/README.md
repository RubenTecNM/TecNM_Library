# Dominio compartido

Agregar en `Entities/` únicamente las entidades compartidas que requiera el microservicio. El template no predefine entidades de negocio.

Mapear persistencia desde `Data/` mediante configuraciones EF Core y mantener el esquema correspondiente en `database.sql` de la raíz o en la estrategia de migraciones elegida por el proyecto.
