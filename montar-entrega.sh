#!/usr/bin/env bash
# Monta os ZIPs por disciplina em output/ e o PDF do DevOps.
# Uso: bash montar-entrega.sh   (na raiz do pacote AlagAlerta)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/output"; mkdir -p "$OUT"
cd "$ROOT"

zipdir() { # $1 = zip, demais = caminhos
  local z="$OUT/$1"; shift; rm -f "$z"
  zip -q -r "$z" "$@" -x '*/.git/*' '*/bin/*' '*/obj/*' '*/build/*' '*/target/*' \
      '*/node_modules/*' '*/.dart_tool/*' '*.env' '*/.env' '*.jks' '*.keystore' '*/.gitkeep'
  echo "OK  $z"
}

# Banco de dados: scripts + README + prints + identificação
zipdir AlagAlerta-PLSQL.zip alagalerta-plsql/*.sql alagalerta-plsql/README.md \
  alagalerta-plsql/evidencias entregas/plsql-identificacao.txt
ls alagalerta-plsql/evidencias/*.png >/dev/null 2>&1 || echo "AVISO: ainda não há prints em alagalerta-plsql/evidencias"

# Compliance/QA: documento descritivo + .archi + PDF do diagrama
ARQ=(alagalerta-arquitetura/Documento-Descritivo-AlagAlerta.pdf alagalerta-arquitetura/AlagAlerta.archi)
[ -f alagalerta-arquitetura/AlagAlerta-Diagrama.pdf ] && ARQ+=(alagalerta-arquitetura/AlagAlerta-Diagrama.pdf) \
  || echo "AVISO: falta alagalerta-arquitetura/AlagAlerta-Diagrama.pdf (exportar no Archi)"
zipdir AlagAlerta-Arquitetura.zip "${ARQ[@]}"

# Demais disciplinas: .txt com links
for f in java-advanced dotnet mobile iot; do cp "entregas/$f.txt" "$OUT/"; done

# DevOps: PDF a partir do devops.md
if command -v pandoc >/dev/null; then
  pandoc entregas/devops.md -s -o "$OUT/AlagAlerta-DevOps.html" --metadata title="AlagAlerta - DevOps"
  CHROME=$(command -v chromium || command -v google-chrome || ls /opt/pw-browsers/chromium-*/chrome-linux64/chrome 2>/dev/null | head -1 || true)
  if [ -n "$CHROME" ]; then
    "$CHROME" --headless --no-sandbox --print-to-pdf="$OUT/AlagAlerta-DevOps.pdf" "$OUT/AlagAlerta-DevOps.html" 2>/dev/null
  fi
  echo "OK  $OUT/AlagAlerta-DevOps.pdf (ou abra o .html e imprima em PDF)"
fi

echo "--- placeholders restantes:"
grep -rn -E '<usuario>|<id>|<nome do grupo>|SEU-USUARIO|cole o link' entregas/*.txt entregas/devops.md alagalerta-*/README.md || echo "nenhum"
