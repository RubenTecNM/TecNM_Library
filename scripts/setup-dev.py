#!/usr/bin/env python3
"""Build and start the isolated TecNM Compose stack, checking host ports first."""
import argparse
import errno
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import socket
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
ENV_FILE = ROOT / '.env'
KEYS = ('COMPOSE_PROJECT_NAME', 'TECNM_FRONTEND_PORT', 'TECNM_BACKEND_PORT',
        'TECNM_DB_PASSWORD')


def read_settings():
    settings = {}
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            match = re.fullmatch(r'\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*', line)
            if match:
                value = match[2]
                if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
                    value = value[1:-1]
                settings[match[1]] = value
    return settings


def port_number(value):
    if not str(value).isascii() or not str(value).isdigit() or not 1 <= int(value) <= 65535:
        raise argparse.ArgumentTypeError('El puerto debe ser un entero entre 1 y 65535.')
    return int(value)


def project_name(value):
    if not re.fullmatch(r'tecnm-[a-z0-9][a-z0-9_-]{0,40}', value):
        raise argparse.ArgumentTypeError('Usa un nombre como tecnm-servicio: minúsculas, números y guiones.')
    return value


def run(command, *, capture=False, env=None):
    return subprocess.run(command, cwd=ROOT, env=env, text=True,
                          stdout=subprocess.PIPE if capture else None,
                          stderr=subprocess.PIPE if capture else None, check=True)


def own_bindings(project, service):
    ids = run(['docker', 'ps', '-q', '--filter', f'label=com.docker.compose.project={project}',
               '--filter', f'label=com.docker.compose.service={service}'], capture=True).stdout.split()
    bindings = set()
    for container_id in ids:
        ports = json.loads(run(['docker', 'inspect', '--format', '{{json .NetworkSettings.Ports}}',
                               container_id], capture=True).stdout) or {}
        for entries in ports.values():
            for entry in entries or []:
                bindings.add((entry['HostIp'], int(entry['HostPort'])))
    return bindings


def port_conflicts(port, owned=()):
    conflicts = []
    for family, address in [(socket.AF_INET, '127.0.0.1'), (socket.AF_INET6, '::1')]:
        if (address, port) in owned or ('0.0.0.0' if family == socket.AF_INET else '::', port) in owned:
            continue
        try:
            with socket.socket(family, socket.SOCK_STREAM) as probe:
                if family == socket.AF_INET6:
                    probe.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
                probe.bind((address, port))
        except OSError as error:
            if error.errno in (errno.EAFNOSUPPORT, errno.EADDRNOTAVAIL):
                continue
            conflicts.append(address)
    return conflicts


def available_port(start, excluded):
    for offset in range(1, 1001):
        candidate = (start + offset - 1) % 65535 + 1
        if candidate not in excluded and not port_conflicts(candidate):
            return candidate
    return None


def check_ports(ports, project, *, interactive):
    if len(set(ports.values())) != len(ports):
        print('Frontend y backend necesitan puertos distintos. No se inició ningún contenedor.', file=sys.stderr)
        return False
    for service, selected in list(ports.items()):
        owned = own_bindings(project, service)
        while port_conflicts(selected, owned):
            alternative = available_port(selected, set(ports.values()))
            flag = f'--{service}-port'
            print(f'Puerto {selected} ocupado o no disponible para {service}.', file=sys.stderr)
            if alternative:
                print(f'Alternativa comprobada: {flag} {alternative}.', file=sys.stderr)
            if not interactive:
                print('No se cambiaron contenedores. Elige otro puerto y vuelve a ejecutar el script.', file=sys.stderr)
                return False
            answer = input(f'Nuevo puerto para {service} (Enter para cancelar): ').strip()
            if not answer:
                return False
            try:
                selected = port_number(answer)
            except argparse.ArgumentTypeError as error:
                print(error, file=sys.stderr)
                continue
            if selected in [value for key, value in ports.items() if key != service]:
                print('Ese puerto ya está seleccionado para el otro servicio.', file=sys.stderr)
                selected = ports[service]
        ports[service] = selected
    return True


def write_settings(settings):
    lines = ENV_FILE.read_text().splitlines() if ENV_FILE.exists() else []
    lines = [line for line in lines if not any(re.match(rf'^\s*{key}\s*=', line) for key in KEYS)]
    # Generated credentials use hex; quoting preserves their literal dotenv values.
    for key in KEYS:
        value = str(settings[key]).replace('\\', '\\\\').replace("'", "\\'")
        lines.append(f"{key}='{value}'")
    descriptor = os.open(ENV_FILE, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(descriptor, 'w') as output:
        output.write('\n'.join(lines) + '\n')
    ENV_FILE.chmod(0o600)


def certificates():
    directory = ROOT / '.docker' / 'certs'
    directory.mkdir(parents=True, exist_ok=True)
    directory.parent.chmod(0o700)
    directory.chmod(0o755)
    certificate = directory / 'localhost.crt'
    key = directory / 'localhost.key'
    valid = certificate.exists() and key.exists() and subprocess.run(
        ['openssl', 'x509', '-checkend', '86400', '-noout', '-in', str(certificate)],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    if not valid:
        run(['openssl', 'req', '-x509', '-nodes', '-newkey', 'rsa:2048', '-days', '365',
             '-subj', '/CN=localhost', '-addext', 'subjectAltName=DNS:localhost,IP:127.0.0.1',
             '-keyout', str(key), '-out', str(certificate)], capture=True)
    # The parent .docker is private on the host; the runtime user can read the mounted files.
    certificate.chmod(0o644)
    key.chmod(0o644)


def main():
    settings = read_settings()
    parser = argparse.ArgumentParser(description='Levanta frontend, backend y PostgreSQL privados con Docker Compose.')
    parser.add_argument('--frontend-port', type=port_number, default=settings.get('TECNM_FRONTEND_PORT', '5173'))
    parser.add_argument('--backend-port', type=port_number, default=settings.get('TECNM_BACKEND_PORT', '7001'))
    parser.add_argument('--project-name', type=project_name, default=settings.get('COMPOSE_PROJECT_NAME', 'tecnm-template'))
    parser.add_argument('--check-ports', action='store_true', help='Solo comprueba puertos; no modifica archivos ni contenedores.')
    args = parser.parse_args()
    if not args.check_ports and not (ROOT / 'database.sql').is_file():
        print('Falta database.sql en la raíz o no es un archivo regular. Crea el SQL de tu microservicio antes de iniciar.', file=sys.stderr)
        return 2
    for executable in ['docker', 'openssl']:
        if not shutil.which(executable):
            print(f'Falta {executable}. Instálalo antes de ejecutar este script.', file=sys.stderr)
            return 1
    try:
        run(['docker', 'compose', 'version'], capture=True)
        run(['docker', 'info', '--format', '{{.ServerVersion}}'], capture=True)
    except subprocess.CalledProcessError:
        print('Docker Compose no está disponible o el daemon Docker está detenido. Revisa Docker y vuelve a intentar.', file=sys.stderr)
        return 1

    ports = {'frontend': args.frontend_port, 'backend': args.backend_port}
    if not check_ports(ports, args.project_name, interactive=sys.stdin.isatty() and not args.check_ports):
        return 2
    print(f"Puertos disponibles: frontend {ports['frontend']}, backend {ports['backend']}. PostgreSQL sin puerto publicado.", flush=True)
    if args.check_ports:
        return 0

    settings.update(COMPOSE_PROJECT_NAME=args.project_name, TECNM_FRONTEND_PORT=str(ports['frontend']),
                    TECNM_BACKEND_PORT=str(ports['backend']))
    settings['TECNM_DB_PASSWORD'] = settings.get('TECNM_DB_PASSWORD') or secrets.token_hex(24)
    write_settings(settings)
    certificates()
    environment = dict(os.environ, **{key: settings[key] for key in KEYS})
    compose = ['docker', 'compose']

    def execute(*arguments):
        return run(compose + list(arguments), env=environment)

    try:
        execute('build')
        if not check_ports(ports, args.project_name, interactive=False):
            return 2
        execute('up', '-d', '--wait', '--wait-timeout', '120', 'db')
        execute('up', '-d', '--wait', '--wait-timeout', '120', 'backend', 'frontend')
    except subprocess.CalledProcessError:
        print('No se pudo completar el arranque Docker. Los datos del volumen se conservan.', file=sys.stderr)
        check_ports(ports, args.project_name, interactive=False)
        print('Consulta el motivo con: docker compose logs --tail 80', file=sys.stderr)
        return 1

    print(f"\nTecNM listo:\n  Frontend: https://localhost:{ports['frontend']}\n  Backend:  https://localhost:{ports['backend']}/api/health\n"
          f"  Contenedores: {args.project_name}-frontend, {args.project_name}-backend, {args.project_name}-postgres\n"
          '  PostgreSQL: db:5432, accesible solo desde la red de datos del backend.\n'
          '  database.sql: se ejecuta solo al inicializar un volumen nuevo.\n'
          '  Detener: docker compose stop\n  Logs: docker compose logs -f\n'
          '  HTTPS local usa un certificado autofirmado.')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (KeyboardInterrupt, EOFError):
        print('\nArranque cancelado. No se eliminaron datos.', file=sys.stderr)
        sys.exit(130)
    except (OSError, subprocess.CalledProcessError) as error:
        print(f'No se pudo preparar el entorno: {error}. Revisa permisos, Docker y OpenSSL.', file=sys.stderr)
        sys.exit(1)
