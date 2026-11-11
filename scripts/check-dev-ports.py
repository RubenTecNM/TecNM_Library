#!/usr/bin/env python3
"""Check occupied ports and friendly CLI errors without starting containers."""
import argparse
import contextlib
import importlib.util
import io
from pathlib import Path
import socket
import subprocess
from unittest.mock import patch

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('setup_dev', ROOT / 'scripts/setup-dev.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)

for value in ['0', '-1', '65536', 'abc', '1.5']:
    try:
        setup.port_number(value)
    except argparse.ArgumentTypeError:
        pass
    else:
        raise AssertionError(f'Invalid port accepted: {value}')
assert setup.port_number('5173') == 5173

with socket.socket() as busy:
    busy.bind(('127.0.0.1', 0))
    busy.listen()
    port = busy.getsockname()[1]
    assert setup.port_conflicts(port) == ['127.0.0.1']
    assert not setup.port_conflicts(port, {('127.0.0.1', port)})
    alternative = setup.available_port(port, {port})
    assert alternative != port and not setup.port_conflicts(alternative)
    with patch.object(setup, 'own_bindings', return_value=set()), contextlib.redirect_stderr(io.StringIO()) as errors:
        assert not setup.check_ports({'frontend': port, 'backend': alternative}, 'tecnm-test', interactive=False)
        assert f'Puerto {port}' in errors.getvalue() and '--frontend-port' in errors.getvalue()
        assert 'No se cambiaron contenedores' in errors.getvalue()
        assert not setup.check_ports({'frontend': port, 'backend': port}, 'tecnm-test', interactive=False)
        next_port = setup.available_port(alternative, {port, alternative})
        with patch('builtins.input', return_value=str(next_port)):
            ports = {'frontend': port, 'backend': alternative}
            assert setup.check_ports(ports, 'tecnm-test', interactive=True)
            assert ports['frontend'] == next_port

try:
    ipv6 = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    ipv6.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
    ipv6.bind(('::1', 0))
except OSError:
    if 'ipv6' in locals(): ipv6.close()
else:
    with ipv6:
        ipv6.listen()
        assert '::1' in setup.port_conflicts(ipv6.getsockname()[1])

for flag, value in [('--frontend-port', '65536'), ('--project-name', 'bad/name')]:
    result = subprocess.run(['bash', 'scripts/setup-dev.sh', flag, value], cwd=ROOT, text=True, capture_output=True)
    assert result.returncode == 2 and 'Traceback' not in result.stderr

print('OK: puertos inválidos/duplicados, IPv4/IPv6 ocupado, alternativa, reutilización e interacción sin iniciar Docker.')
