"""Gera o pacote para compartilhar, preservando fontes e históricos Git.

Exclui dependências, builds e arquivos locais de credenciais.
Execute: python EMPACOTAR.py
"""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / 'output'
OUTPUT.mkdir(exist_ok=True)
ARCHIVE = OUTPUT / 'AlagAlerta-para-Luigi.zip'
FOLDERS = [
    'alagalerta-api', 'alagalerta-app', 'alagalerta-dotnet',
    'alagalerta-plsql', 'alagalerta-iot', 'alagalerta-arquitetura',
    'entregas', 'evidencias-locais',
]
ROOT_FILES = [
    'BRIEFING.md', 'ENTREGAS.md', 'PITCH.md', 'COMECE-AQUI-LUIGI.md',
    'MENSAGEM-PARA-LUIGI.txt', 'INICIAR-API.ps1', 'INICIAR-APP.ps1',
    'EMPACOTAR.py',
]
EXCLUDED_DIRS = {
    'build', 'target', 'bin', 'obj', 'node_modules', '.dart_tool',
    '.gradle', '.idea', '.vscode', '__pycache__', '.pub-cache',
    '.pub', '.flutter-plugins-dependencies',
}


def include(path):
    rel = path.relative_to(ROOT)
    if any(part in EXCLUDED_DIRS for part in rel.parts):
        return False
    if path.name == '.env' or path.name.startswith('.env.') and path.name != '.env.example':
        return False
    if path.name in {'local.properties', 'key.properties', 'secrets.json'}:
        return False
    if path.suffix.lower() in {'.jks', '.keystore', '.pem', '.key'}:
        return False
    return True


paths = [ROOT / name for name in ROOT_FILES]
for folder in FOLDERS:
    paths.extend(path for path in (ROOT / folder).rglob('*') if path.is_file() and include(path))

with ZipFile(ARCHIVE, 'w', compression=ZIP_DEFLATED) as archive:
    for path in sorted(paths):
        archive.write(path, 'AlagAlerta/' + path.relative_to(ROOT).as_posix())

with ZipFile(ARCHIVE) as archive:
    assert archive.testzip() is None, 'Falha de integridade no ZIP'
    names = set(archive.namelist())
    for folder in FOLDERS[:6]:
        assert f'AlagAlerta/{folder}/.git/HEAD' in names, f'Histórico ausente: {folder}'
    for name in ROOT_FILES:
        assert f'AlagAlerta/{name}' in names, f'Arquivo ausente: {name}'
    assert not any(name.endswith('/.env') or name.endswith('/local.properties') for name in names)
    count = len(names)

digest = hashlib.sha256(ARCHIVE.read_bytes()).hexdigest()
ARCHIVE.with_suffix('.zip.sha256').write_text(f'{digest}  {ARCHIVE.name}\n', encoding='utf-8')
print(f'{ARCHIVE}\n{count} arquivos; {ARCHIVE.stat().st_size / 1024 / 1024:.2f} MB; integridade OK')
