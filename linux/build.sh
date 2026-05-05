#!/usr/bin/env bash
# build.sh — assemble a Linux x86_64 Codex bundle from the Mac payload.
#
# Inputs (already on codex-test, populated by ../scripts/sync-mac-payload.sh):
#   /root/codex-port/mac-resources/   Mac Resources tree (asar + native + bins)
#   /root/codex-port/electron-linux/extracted/   Electron 41.2.0 Linux x64
#
# Output:
#   /root/codex-port/build/   self-contained Codex-Linux directory ready to run
#
# Run on codex-test (Ubuntu 24.04). Not idempotent in the rebuild step —
# delete /root/codex-port/build to start clean.

set -euo pipefail

ROOT=/root/codex-port
SRC=$ROOT/mac-resources
ELEC=$ROOT/electron-linux/extracted
OUT=$ROOT/build
STUBS=$(cd "$(dirname "$0")/stubs" && pwd)

echo "==> [1/6] Stage Linux Electron"
rm -rf "$OUT"
cp -a "$ELEC" "$OUT"
# Rename the binary so spawning works the same way
mv "$OUT/electron" "$OUT/codex-electron"

echo "==> [2/6] Drop Codex app.asar in"
mkdir -p "$OUT/resources"
cp "$SRC/app.asar" "$OUT/resources/app.asar"
cp -a "$SRC/app.asar.unpacked" "$OUT/resources/app.asar.unpacked"

echo "==> [3/6] Bring over plugin tree (with Linux tectonic swap)"
cp -a "$SRC/plugins" "$OUT/resources/plugins"
# Replace Mac tectonic with Linux tectonic if present in apt path
if command -v tectonic >/dev/null 2>&1; then
  cp "$(command -v tectonic)" "$OUT/resources/plugins/openai-bundled/plugins/latex-tectonic/bin/tectonic"
fi

echo "==> [4/6] Linux helper binaries (Mac → Linux swap & stubs)"
# rg → system ripgrep
cp "$(command -v rg)" "$OUT/resources/rg"
# node / node_repl → system node 22 (matches Electron 41 internal Node)
cp "$(command -v node)" "$OUT/resources/node"
cp "$(command -v node)" "$OUT/resources/node_repl"
# Mac-only helpers → no-op stub
install -m755 "$STUBS/noop-helper" "$OUT/resources/native/bare-modifier-monitor"
install -m755 "$STUBS/noop-helper" "$OUT/resources/native/launch-services-helper"
# codex / codex_chronicle → ❌ no Linux build yet, install stub that exits with
# a recognizable code so the JS errors are obvious in logs
install -m755 "$STUBS/noop-helper" "$OUT/resources/codex"
install -m755 "$STUBS/noop-helper" "$OUT/resources/codex_chronicle"
echo "    NOTE: codex / codex_chronicle are stubbed. Agent functionality will not work"
echo "    until we obtain Linux builds (Rust source from openai/codex-cli, or extract"
echo "    from any internal Linux build OpenAI ships)."

echo "==> [5/6] Native node module rebuild against Electron 41.2.0 ABI"
cd "$OUT/resources/app.asar.unpacked/node_modules/better-sqlite3"
npx -y --package=@electron/rebuild@latest -- electron-rebuild -v 41.2.0 -m .
cd "$OUT/resources/app.asar.unpacked/node_modules/node-pty"
npx -y --package=@electron/rebuild@latest -- electron-rebuild -v 41.2.0 -m .

echo "==> [6/6] Sparkle stub patch (TODO: actually patch app.asar)"
echo "    For now, sparkle.node is left as Mac binary; first launch will surface"
echo "    the real failure mode and we'll know if a stub is needed."

echo
echo "Build assembled at: $OUT"
echo "Run with:  xvfb-run -a $OUT/codex-electron --no-sandbox $OUT/resources/app.asar"
