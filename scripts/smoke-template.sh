#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-https://localhost:7001}"
API_URL="${API_URL%/}"
smoke_directory=$(mktemp -d)
trap 'rm -rf "$smoke_directory"' EXIT

request() {
  curl --insecure --silent --show-error --connect-timeout 5 --max-time 15 \
    --request "$1" \
    --output "$smoke_directory/body" --write-out '%{http_code}' "$API_URL$2"
}

status=$(request GET /api/health)
test "$status" = 200 || { printf 'Health check devolvió %s.\n' "$status" >&2; exit 1; }
python3 - "$smoke_directory/body" <<'PY'
import json
from pathlib import Path
import sys
assert json.loads(Path(sys.argv[1]).read_text()) == {'status': 'ok'}
PY

status=$(request GET /api/__template_unknown_route__)
test "$status" = 404 || { printf 'Ruta no registrada devolvió %s; se esperaba 404.\n' "$status" >&2; exit 1; }

printf 'OK: health check disponible y ruta no registrada devuelve 404.\n'
