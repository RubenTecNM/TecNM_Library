#!/usr/bin/env bash
set -euo pipefail
if ! command -v python3 >/dev/null; then
  printf 'Falta Python 3 para comprobar puertos y preparar Docker.\n' >&2
  exit 1
fi
exec python3 "$(dirname "$0")/setup-dev.py" "$@"
