#!/usr/bin/env bash
# package-appimage.sh — wrap /root/codex-port/build into a single .AppImage.
#
# Pre-requisites:
#   - build.sh has run successfully → /root/codex-port/build exists
#   - codex (Linux Rust binary) has been dropped into resources/codex
#   - appimagetool is in PATH (we'll fetch it if missing)
#
# Output:
#   /root/codex-port/dist/Codex-x86_64.AppImage

set -euo pipefail

ROOT=/root/codex-port
BUILD=$ROOT/build
APPDIR=$ROOT/Codex.AppDir
DIST=$ROOT/dist
HERE=$(cd "$(dirname "$0")" && pwd)

[ -d "$BUILD" ] || { echo "ERROR: $BUILD does not exist — run build.sh first"; exit 1; }
[ -x "$BUILD/resources/codex" ] || { echo "ERROR: $BUILD/resources/codex missing or not exec"; exit 1; }
file "$BUILD/resources/codex" | grep -q ELF || { echo "ERROR: $BUILD/resources/codex is not an ELF binary"; exit 1; }

mkdir -p "$DIST"

echo "==> Bootstrap appimagetool"
if ! command -v appimagetool >/dev/null 2>&1; then
  AIT=$ROOT/appimagetool-x86_64.AppImage
  if [ ! -f "$AIT" ]; then
    wget -q -O "$AIT" \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$AIT"
  fi
  APPIMAGETOOL="$AIT --appimage-extract-and-run"
else
  APPIMAGETOOL=appimagetool
fi

echo "==> Stage AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/codex" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# Move Electron payload into AppDir
cp -a "$BUILD"/. "$APPDIR/usr/share/codex/"
mv "$APPDIR/usr/share/codex/codex-electron" "$APPDIR/usr/bin/codex-electron"

# AppRun launcher
install -m755 "$HERE/AppRun" "$APPDIR/AppRun"
install -m644 "$HERE/codex.desktop" "$APPDIR/codex.desktop"
install -m644 "$HERE/codex.desktop" "$APPDIR/usr/share/applications/codex.desktop"

# Icon — placeholder (replace later with a real Codex icon)
if [ -f "$HERE/codex.png" ]; then
  install -m644 "$HERE/codex.png" "$APPDIR/codex.png"
  install -m644 "$HERE/codex.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/codex.png"
else
  # Generate a 256x256 plain placeholder so appimagetool doesn't complain
  export APPDIR
  python3 - <<'PY'
import struct, zlib, os
w = h = 256
raw = bytearray()
for y in range(h):
    raw.append(0)
    for x in range(w):
        raw += bytes([16, 16, 16])  # dark grey
def chunk(typ, data):
    return struct.pack(">I", len(data)) + typ + data + struct.pack(">I", zlib.crc32(typ+data) & 0xffffffff)
out = b"\x89PNG\r\n\x1a\n"
out += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
out += chunk(b"IDAT", zlib.compress(bytes(raw)))
out += chunk(b"IEND", b"")
for p in [os.environ['APPDIR']+"/codex.png", os.environ['APPDIR']+"/usr/share/icons/hicolor/256x256/apps/codex.png"]:
    open(p, "wb").write(out)
PY
fi

echo "==> appimagetool"
ARCH=x86_64 $APPIMAGETOOL "$APPDIR" "$DIST/Codex-x86_64.AppImage"

echo
ls -lh "$DIST/Codex-x86_64.AppImage"
echo "Done. Distribute this single file to Linux users."
