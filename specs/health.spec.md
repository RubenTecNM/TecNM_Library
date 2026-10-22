# Health check del backend

## API

| Método y ruta | Acceso | Éxito |
| --- | --- | --- |
| `GET /api/health` | Público | `200 { "status": "ok" }` |

El endpoint confirma que el proceso de la API está disponible. No valida dependencias externas.
