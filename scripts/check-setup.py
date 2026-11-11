#!/usr/bin/env python3
"""Exercise setup isolation and restart behavior with a simulated Docker CLI."""
import contextlib
import importlib.util
import io
from pathlib import Path
import subprocess
import tempfile
from unittest.mock import patch

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('setup_dev', ROOT / 'scripts/setup-dev.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    sql = root / 'database.sql'
    env_file = root / '.env'
    commands = []

    def docker(command, **kwargs):
        commands.append(command)
        return subprocess.CompletedProcess(command, 0, stdout='', stderr='')

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(setup, 'ROOT', root))
        stack.enter_context(patch.object(setup, 'ENV_FILE', env_file))
        runner = stack.enter_context(patch.object(setup, 'run', side_effect=docker))
        stack.enter_context(patch.object(setup.shutil, 'which', return_value='/mock/tool'))
        stack.enter_context(patch.object(setup, 'check_ports', return_value=True))
        certificates = stack.enter_context(patch.object(setup, 'certificates'))
        stack.enter_context(patch('sys.argv', ['setup-dev.py']))
        stack.enter_context(contextlib.redirect_stdout(io.StringIO()))
        errors = stack.enter_context(contextlib.redirect_stderr(io.StringIO()))

        # Missing SQL and a directory named database.sql fail before mutations.
        for as_directory in [False, True]:
            if as_directory:
                sql.mkdir()
            assert setup.main() == 2
            assert not env_file.exists()
            runner.assert_not_called()
            certificates.assert_not_called()
        assert 'database.sql' in errors.getvalue()
        sql.rmdir()

        # Port-only checks work without SQL and never create settings/certs.
        with patch('sys.argv', ['setup-dev.py', '--check-ports']):
            assert setup.main() == 0
        assert not env_file.exists()
        certificates.assert_not_called()

        # Both a comment-only template and arbitrary service SQL are accepted.
        for content in ['-- Sin tablas de aplicación.\n', 'CREATE TABLE widgets (id integer PRIMARY KEY);\n']:
            sql.write_text(content)
            commands.clear()
            assert setup.main() == 0
            first_settings = setup.read_settings()
            assert first_settings['COMPOSE_PROJECT_NAME'] == 'tecnm-template'
            password = first_settings['TECNM_DB_PASSWORD']
            assert password
            assert env_file.stat().st_mode & 0o777 == 0o600
            assert not any('exec' in command or 'down' in command for command in commands)

            # Repeating setup preserves credentials, custom settings and SQL.
            with env_file.open('a') as output:
                output.write('SERVICE_OPTION=preserved\n')
            assert setup.main() == 0
            repeated = setup.read_settings()
            assert repeated['TECNM_DB_PASSWORD'] == password
            assert repeated['SERVICE_OPTION'] == 'preserved'
            assert sql.read_text() == content

        # Failed database startup stops before starting application services.
        def failed_database(command, **kwargs):
            if command[-1] == 'db':
                raise subprocess.CalledProcessError(1, command)
            return docker(command, **kwargs)

        commands.clear()
        runner.side_effect = failed_database
        assert setup.main() == 1
        assert not any('backend' in command or 'down' in command for command in commands)
        assert setup.read_settings()['TECNM_DB_PASSWORD'] == password

print('OK: SQL requerido/genérico, modo de consulta sin cambios, reinicios conservan configuración y fallos no borran datos (Docker simulado).')
