#!/usr/bin/env bash
set -euo pipefail

api_url="${API_URL:-https://localhost:7001}"
cookie_jar="$(mktemp)"
response_body="$(mktemp)"
trap 'rm -f "$cookie_jar" "$response_body"' EXIT

expect_status() {
  local expected="$1"
  shift
  local actual
  actual="$(curl --insecure --silent --show-error --output "$response_body" --write-out '%{http_code}' "$@")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Esperado HTTP %s, recibido %s: %s\n' "$expected" "$actual" "$(<"$response_body")" >&2
    exit 1
  fi
}

expect_status 401 \
  --request POST \
  --header 'Content-Type: application/json' \
  --data '{"username":"admin","password":"incorrecta"}' \
  "$api_url/api/auth/login"

expect_status 400 \
  --request POST \
  --header 'Content-Type: application/json' \
  --data '{"username":"","password":""}' \
  "$api_url/api/auth/login"

expect_status 200 \
  --request POST \
  --header 'Content-Type: application/json' \
  --data '{"username":"admin","password":"TecNM-Demo-2026!"}' \
  --cookie-jar "$cookie_jar" \
  "$api_url/api/auth/login"

grep -q 'auth_token' "$cookie_jar"
grep -q 'session_exp' "$cookie_jar"

expect_status 200 --cookie "$cookie_jar" "$api_url/api/auth/me"
expect_status 204 --request POST --cookie "$cookie_jar" --cookie-jar "$cookie_jar" "$api_url/api/auth/logout"
expect_status 401 --cookie "$cookie_jar" "$api_url/api/auth/me"

printf 'Smoke auth OK\n'
