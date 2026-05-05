# codex-platforms

Cross-platform porting work for OpenAI Codex desktop (officially Mac-only).

- `linux/` — Linux x86_64 port (active)
- `windows/` — Windows port (planned)
- `shared/` — inventory and findings that apply to all targets

## Test infra

- Source Mac install: SSH host `main` (`/Applications/Codex.app`)
- Linux test box: SSH host `codex-test` (Hetzner CX32, Ubuntu 24.04 LTS, 4 vCPU / 8 GB)
