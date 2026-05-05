# Chronicle and Browser-Use Linux Decisions

Date: 2026-05-05

Related issues: #3, #4, and follow-up #14.

## Decision Summary

- `codex_chronicle` is treated as a macOS-only Chronicle screen-memory helper. The
  Linux build should omit or stub it until a cross-platform Chronicle
  implementation is available.
- `browser-use-peer-authorization.node` is treated as a macOS-only trusted-peer
  authorization addon. No public source or npm package was found, but the
  Electron app does not need it on Linux.
- Browser-use should remain a Linux goal. The Linux package should remove the
  copied macOS addon and validate the native pipe / in-app-browser path on
  `ssh codex-test`.
- The next blocker for Linux browser-use is `node_repl`, not peer
  authorization. Replacing Codex's `node_repl` with stock Node removes the
  `import.meta.__codexNativePipe` bridge required by `browser-client.mjs`.
  Follow-up #14 tracks that implementation and smoke test.

## Evidence

The macOS app payload on `ssh main` ships `codex_chronicle` as a Mach-O arm64
binary. Its dynamic libraries include macOS capture and UI frameworks such as
ScreenCaptureKit, AppKit, CoreImage, Vision, AVFoundation, and CoreML. Its
embedded symbols and strings point to Chronicle-specific capture, privacy
filtering, and memory-pipeline code rather than any public crate name in
`openai/codex`.

The public `openai/codex` repository has a `chronicle` feature flag, but the
public tree does not contain a `codex_chronicle` crate or binary target. Nearby
public crates such as rollout tracing and thread storage do not match the
screen-memory helper responsibilities.

The macOS app payload ships `native/browser-use-peer-authorization.node` as a
Mach-O arm64 Node addon. Its linked frameworks include LocalAuthentication and
Security, and its strings indicate peer socket authorization based on macOS code
signing identity. Exact public searches for the addon name in `openai/codex`,
OpenAI/browser-use repositories, and npm did not identify a rebuildable source.

The extracted Electron main bundle wraps this addon behind a platform check:
non-macOS platforms get an authorizer that returns authorized without loading
the addon. The same code path creates the browser-use native pipe with a JS
`net.createServer`, using Unix socket paths under `/tmp/codex-browser-use*` on
Linux. That makes the macOS addon unnecessary for Linux browser-use work.

The bundled browser client does still require a privileged native pipe bridge:
`browser-client.mjs` calls `import.meta.__codexNativePipe.createConnection(...)`
to reach those sockets. The macOS `node_repl` binary contains native-pipe bridge
strings and an allowlist knob for Unix sockets. On `ssh codex-test`, the current
Linux build swaps `node_repl` to a Linux Node executable, and a direct ESM check
reports no `__codexNativePipe` bridge. That is the real browser-use blocker to
port or replace on Linux.

On `ssh codex-test`, the current Linux build already installs
`codex_chronicle` as a shell stub. The current build still carries the macOS
`browser-use-peer-authorization.node` artifact into `build/resources/native`,
and Node reports `ERR_DLOPEN_FAILED` with an invalid ELF header when asked to
load it directly. That artifact should be removed from Linux packages; it is
not evidence that browser-use itself must be disabled.

## Reviewer Notes

Reviewers should not ask for a Linux rebuild command for either helper unless
new upstream source appears. For now:

- Chronicle is intentionally disabled on Linux.
- Do not request a Linux build of `browser-use-peer-authorization.node`; the app
  only needs that addon on macOS.
- Browser-use should be made to work on Linux by providing a Linux-compatible
  `node_repl` native-pipe bridge, then testing through the in-app-browser native
  pipe.
- The Linux bridge should only allow Codex-owned browser-use socket paths and
  should use same-user socket restrictions such as `$XDG_RUNTIME_DIR` or a
  mode-0700 per-user runtime directory.
