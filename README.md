# codex-platforms

Unofficial Linux and Windows packaging work for OpenAI Codex desktop, which
OpenAI currently publishes only for macOS. This repo assembles platform-native
Electron bundles from the official Mac `app.asar` payload, rebuilt native node
modules, and the upstream Apache-2.0 `openai/codex` Rust agent without forking
OpenAI's UI payload or Rust workspace.

## User Quick Start

No public AppImage release is published yet. Once releases start, Linux users
will download `Codex-x86_64.AppImage` from GitHub Releases:

```text
https://github.com/Herfstvalt/codex-platforms/releases/latest
```

After downloading an AppImage, run:

```sh
chmod +x Codex-x86_64.AppImage
./Codex-x86_64.AppImage
```

Until release CI exists, AppImages are maintainer-built artifacts produced on
`codex-test`.

Troubleshooting:

- If the shell reports `Permission denied`, rerun `chmod +x` on the AppImage.
- If AppImage startup fails because FUSE is missing on Ubuntu 24.04, install
  `libfuse2t64` or run with `APPIMAGE_EXTRACT_AND_RUN=1`.
- If the window opens but the agent does not connect, launch the AppImage from a
  terminal and include stdout/stderr, the artifact filename, and the upstream
  `openai/codex` SHA in the bug report.
- If login or network access fails behind a proxy, start the AppImage with the
  expected `HTTP_PROXY` and `HTTPS_PROXY` environment variables set.

## Contributor Quick Start

Linux build work runs on the Ubuntu 24.04 test host:

- Source Mac install: SSH host `main` at `/Applications/Codex.app`.
- Linux test box: SSH host `codex-test` (Hetzner CX32, Ubuntu 24.04 LTS,
  4 vCPU / 8 GB).
- Linux assembly path: `/root/codex-port` on `codex-test`.

From a clean checkout with maintainer-staged Mac resources and Linux Electron
under `/root/codex-port`:

```sh
ssh codex-test
cd /root/codex
linux/build.sh
linux/package-appimage.sh
ls -lh /root/codex-port/dist/Codex-x86_64.AppImage
```

`linux/build.sh` expects `/root/codex-port/mac-resources` to contain the Mac
`Contents/Resources` payload and `/root/codex-port/electron-linux/extracted` to
contain the Linux Electron tree. It produces `/root/codex-port/build`, and
`linux/package-appimage.sh` wraps that build tree into
`/root/codex-port/dist/Codex-x86_64.AppImage`.

The build must record the upstream `openai/codex` commit used for the Rust
agent. When a branch includes a pin manifest, keep the AppImage build, README
notes, and recorded SHA in the same PR so reviewers can reproduce the artifact.

## What's Where

- `linux/` - Linux assembly and packaging scripts.
- `linux/build.sh` - assembles the Linux Electron tree from staged Mac resources,
  rebuilt native modules, helper binaries, and the Rust agent.
- `linux/package-appimage.sh` - wraps `/root/codex-port/build` into the AppImage.
- `linux/stubs/` - no-op replacements for Mac-only helpers while Linux behavior
  is being validated.
- `windows/` - planned Windows packaging area.
- `shared/` - cross-platform inventory and findings that apply to all targets.
- `docs/` - maintainer notes that are not part of the user quick start.
- `.github/` - issue templates, pull request template, and review ownership.
