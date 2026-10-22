# Especificación de Cambios: Paginación Frontend

## Observación / Problema detectado
- El listado en el frontend cargaba todos los registros de golpe en una sola petición.
- Al aumentar el volumen de datos, la carga de la vista se volvía lenta y afectaba la usabilidad.
- Faltaba un control visual para navegar entre páginas de resultados.

## Corrección / Solución aplicada
- Se añadieron controles de navegación (botones Anterior / Siguiente y número de página).
- Se actualizó el cliente de API (`api/`) para enviar los parámetros `page` y `limit` en las peticiones GET.
- Se actualizaron los tipos de TypeScript (`types/`) para soportar la respuesta paginada del backend.

## Archivos modificados
- `frontend/src/modules/<modulo>/views/<Vista>.vue`
- `frontend/src/modules/<modulo>/api/<servicioApi>.ts`
- `frontend/src/modules/<modulo>/types/<modelo>.ts`