# Codex Mac App Inventory

Source: `/Applications/Codex.app/Contents/Resources/` on `main` (host).
Codex version: v26.429.30905. Electron 41.2.0. electron-forge built.

## App bundle

- `app.asar` (140 MB) — Vite-bundled minified JS, **not encrypted, not V8 bytecode**. Extracts cleanly with `@electron/asar`.
  - `.vite/build/bootstrap.js`
  - `.vite/build/main-DlFGMsC6.js`
  - `.vite/build/preload.js`
  - `.vite/build/app-session-DB19JxBs.js`
  - `.vite/build/worker.js`
  - `.vite/build/sandbox-preload.js`
  - `.vite/build/comment-preload.js`
  - `.vite/build/trace-recording-sentry-upload-Cd19KbWC.js`
  - `.vite/build/workspace-root-drop-handler-B4gQVO2J.js`
  - `package.json` — `name: openai-codex-electron`, electron-forge devDeps include `@electron-forge/maker-deb` and `maker-rpm` (OpenAI builds Linux internally).

## Native node modules (in `app.asar.unpacked/node_modules/`)

| Module | Purpose | Linux port |
|---|---|---|
| `better-sqlite3` | SQLite for sessions/inbox/automations | rebuild from npm against Electron 41 ABI |
| `node-pty` | terminal pty | rebuild from npm against Electron 41 ABI |

## Bundled helper binaries (Mac-only Mach-O arm64)

| Binary | Size | Purpose | Linux strategy |
|---|---|---|---|
| `codex` | 189 MB | Codex CLI / agent runtime (Rust) | needs OpenAI's Linux build OR cargo build from source — **biggest unknown** |
| `codex_chronicle` | 3.9 MB | Chronicle screen-memory capture helper | omit/stub on Linux; macOS-only until upstream source or cross-platform Chronicle support exists |
| `node` | 113 MB | bundled Node.js | swap with Linux Node 22 (matches Electron 41) |
| `node_repl` | 8.9 MB | REPL sandbox for browser-use plugin, including native pipe bridge | needs Linux-compatible bridge; stock Node does not expose `import.meta.__codexNativePipe` |
| `rg` | 3.9 MB | ripgrep | Ubuntu `apt install ripgrep` |

## `native/` (helper binaries used at runtime)

| File | Purpose | Linux strategy |
|---|---|---|
| `bare-modifier-monitor` | Mac kbd modifier polling | stub (no-op binary) |
| `browser-use-peer-authorization.node` | macOS Node addon for browser plugin peer authorization | not needed on Linux; remove copied Mach-O and validate native pipe |
| `launch-services-helper` | LaunchServices integration | stub — Mac-only concept |
| `sparkle.node` | Sparkle auto-update bindings | stub — replace with no-op module |

## `plugins/openai-bundled/plugins/`

| Plugin | Linux concerns |
|---|---|
| `latex-tectonic` | ships a Mac `tectonic` binary — swap for Linux tectonic |
| `computer-use` | `.mcp.json` only, no native — should work as-is |
| `browser-use` | `browser-client.mjs` script + native pipe/IAB backend; macOS peer-auth addon is not loaded on Linux, but `node_repl` must provide `import.meta.__codexNativePipe` |

## Spawn references found in JS

Literal string references in `.vite/build/*.js`:

- `codex_chronicle` — referenced in `worker.js`, `workspace-root-drop-handler-B4gQVO2J.js`
- `node_repl` — referenced in `main-DlFGMsC6.js` with checks like `browser_use_node_repl_missing` and `x_cli_missing_for_node_repl_sandbox` (so missing binary = soft-fail, not hard-fail)
- `bare-modifier-monitor`, `launch-services-helper` — referenced in `main-DlFGMsC6.js`
- `browser-use-peer-authorization.node` — referenced in `main-DlFGMsC6.js`
- `tectonic` — referenced in `main-DlFGMsC6.js`
- `sparkle` (sparkleManager) — referenced in `bootstrap.js` and `main-DlFGMsC6.js` — initialized very early (`await i.initialize()` before app start)

The fact that some references are guarded with `_missing` error keys is encouraging — Codex was designed to soft-fail when helpers aren't available. `sparkleManager.initialize()` being awaited before app startup is the most worrying — if it throws on Linux, app won't start.

## Research decisions

- `codex_chronicle` is macOS Chronicle capture/memory infrastructure. Public
  `openai/codex` exposes a Chronicle feature flag but no public binary target
  for this helper. Linux should stub or omit it; see
  `docs/research/chronicle-and-browser-use.md`.
- `browser-use-peer-authorization.node` is a macOS code-signing peer
  authorization addon. No public source or npm package was found, but the
  Electron main bundle skips it on non-macOS platforms. Linux should remove the
  copied Mach-O addon.
- Browser-use still needs a Linux `node_repl` native-pipe bridge. The current
  stock-Node replacement does not expose `import.meta.__codexNativePipe`, so
  browser-use cannot connect to the in-app-browser socket yet. Follow-up #14
  tracks the implementation; see
  `docs/research/chronicle-and-browser-use.md`.

## Mac-only dependencies in package.json

- `@electron-forge/maker-dmg`
- `electron-osx-sign`
- scripts referencing `LaunchServicesHelper`
- `bare-modifier-monitor` script entry
