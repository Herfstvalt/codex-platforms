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

echo "==> [3/6] Bring over plugin tree + native/ + helper bin slots"
cp -a "$SRC/plugins" "$OUT/resources/plugins"
cp -a "$SRC/native" "$OUT/resources/native"
# Decision #4: browser-use-peer-authorization.node is a macOS trusted-peer
# authorization addon. The Electron main bundle authorizes non-macOS peers
# without loading it, so remove the copied Mach-O artifact and validate
# browser-use through the Linux native pipe instead.
rm -f "$OUT/resources/native/browser-use-peer-authorization.node"
# Helper binary slots (we'll overwrite Mac binaries with Linux equivs in step 4).
# Copying first preserves any non-binary sidecar files alongside them.
for b in codex codex_chronicle node node_repl rg; do
  cp -a "$SRC/$b" "$OUT/resources/$b"
done
# Replace Mac tectonic with Linux tectonic if present in apt path
if command -v tectonic >/dev/null 2>&1; then
  cp "$(command -v tectonic)" "$OUT/resources/plugins/openai-bundled/plugins/latex-tectonic/bin/tectonic"
fi

echo "==> [4/6] Linux helper binaries (Mac → Linux swap & stubs)"
# rg → system ripgrep
cp "$(command -v rg)" "$OUT/resources/rg"
# node -> system node 22 (matches Electron 41 internal Node)
cp "$(command -v node)" "$OUT/resources/node"
# TODO(#14): stock Node does not provide Codex's node_repl native pipe bridge
# (`import.meta.__codexNativePipe`), so browser-use remains blocked until this
# is replaced with a Linux-compatible node_repl implementation.
cp "$(command -v node)" "$OUT/resources/node_repl"
# Mac-only helpers → no-op stub
install -m755 "$STUBS/noop-helper" "$OUT/resources/native/bare-modifier-monitor"
install -m755 "$STUBS/noop-helper" "$OUT/resources/native/launch-services-helper"
# codex: no Linux build yet, install a recognizable stub until the agent
# runtime is built from public source or obtained from an upstream Linux payload.
install -m755 "$STUBS/noop-helper" "$OUT/resources/codex"
# Decision #3: codex_chronicle is macOS Chronicle screen-memory infrastructure.
# Chronicle is optional for the Linux MVP, so keep it stubbed until upstream
# ships a cross-platform helper or publishes the source needed to build it.
install -m755 "$STUBS/noop-helper" "$OUT/resources/codex_chronicle"
echo "    NOTE: codex is stubbed. Agent functionality will not work until we obtain"
echo "    a Linux build. Chronicle is also stubbed because it is macOS-only today."

echo "==> [5/6] Native node module rebuild against Electron 41.2.0 ABI"
# app.asar unpacks ONLY the .node files; full module trees (with package.json)
# live inside the asar. So rebuild fresh in a scratch dir, then drop the
# resulting .node binaries into the unpacked tree where Electron will load them.
SCRATCH=$ROOT/native-build
rm -rf "$SCRATCH"
mkdir -p "$SCRATCH"
cd "$SCRATCH"
npm init -y >/dev/null
npm install --no-audit --no-fund --silent better-sqlite3@12.8.0 node-pty@1.1.0
npx -y --package=@electron/rebuild@latest -- electron-rebuild -v 41.2.0 -f -m .

# Drop the rebuilt .node binaries into Codex's unpacked tree
mkdir -p "$OUT/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release"
mkdir -p "$OUT/resources/app.asar.unpacked/node_modules/node-pty/build/Release"
cp "$SCRATCH/node_modules/better-sqlite3/build/Release/better_sqlite3.node" \
   "$OUT/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release/"
cp "$SCRATCH/node_modules/node-pty/build/Release/pty.node" \
   "$OUT/resources/app.asar.unpacked/node_modules/node-pty/build/Release/"
# node-pty also ships a small spawn helper binary
if [ -f "$SCRATCH/node_modules/node-pty/build/Release/spawn-helper" ]; then
  cp "$SCRATCH/node_modules/node-pty/build/Release/spawn-helper" \
     "$OUT/resources/app.asar.unpacked/node_modules/node-pty/build/Release/"
fi
echo "    Verifying ELF + symbols on rebuilt .node files:"
file "$OUT/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release/better_sqlite3.node"
file "$OUT/resources/app.asar.unpacked/node_modules/node-pty/build/Release/pty.node"

echo "==> [6/6] Sparkle stub patch (TODO: actually patch app.asar)"
echo "    For now, sparkle.node is left as Mac binary; first launch will surface"
echo "    the real failure mode and we'll know if a stub is needed."

echo
echo "Build assembled at: $OUT"
echo "Run with:  xvfb-run -a $OUT/codex-electron --no-sandbox $OUT/resources/app.asar"
