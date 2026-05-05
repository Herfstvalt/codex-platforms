# Contributing

This repository is for packaging and portability work around OpenAI Codex
desktop. The repo's own code is packaging glue, scripts, metadata, and
documentation. Do not commit extracted OpenAI app payloads, generated release
artifacts, private keys, tokens, or local build directories.

## Contribution Flow

1. Find or open an issue before starting implementation work.
2. Keep the issue scoped to one reviewer-verifiable change.
3. Move `needs-triage` issues to a concrete label set before assigning work.
4. Open changes as a pull request against `main`.
5. Include the test or smoke evidence reviewers need in the PR description.

`main` is protected. Expect one approving review, resolved conversations, and
no force-push or direct-delete workflow for normal changes.

## Review Boundaries

- Changes under `linux/` should be reviewable as Linux packaging/runtime work.
- Changes under `windows/` should be reviewable as Windows packaging/runtime
  work.
- Changes under `shared/` affect more than one platform and should explain the
  cross-platform contract they introduce or change.
- Changes under `.github/`, `docs/`, root policy files, or release metadata are
  maintainer workflow changes and should describe their reviewer impact.

When a change crosses those boundaries, call that out in the PR's reviewer
focus section.

## Testing Expectations

Use the strongest useful evidence available for the change:

- Documentation-only changes should be checked for links, command accuracy, and
  reviewer clarity.
- Build-script changes should include the command run and the host/environment
  used.
- Packaging/runtime changes should include AppImage, installer, or boot-smoke
  evidence when available.
- If a test cannot be run yet, say exactly why in the PR template's "Not run"
  field.

Current Linux test infrastructure:

- Source Mac install: SSH host `main` at `/Applications/Codex.app`.
- Linux test box: SSH host `codex-test`, Ubuntu 24.04 LTS.
- Linux assembly path: `/root/codex-port` on `codex-test`.

## Upstream Pins

Pinned upstream Codex source is maintained in `shared/upstream.env`.
Version-bump PRs should state:

- Old and new upstream `openai/codex` SHA.
- Why the bump is needed.
- What smoke or build evidence was collected.
- Whether any native module, Electron, payload, or protocol behavior changed.

Use `shared/bump-upstream.sh` when available to update the pin, then commit the
resulting manifest change with the build changes that depend on it.

## Payload And Artifact Rules

- Do not commit `app.asar`, `app.asar.unpacked`, `mac-resources/`, AppImages,
  installers, native build outputs, generated archives, or real Codex icons.
- Do not patch OpenAI's `app.asar` JavaScript in this repository.
- Prefer documenting a missing upstream capability and filing a follow-up issue
  over carrying local forks of upstream code.
- Release artifacts must be produced from tagged commits once release CI exists.

## Issue Triage

Use labels to make reviewer routing explicit:

- `linux`, `windows`, or `shared` for platform scope.
- `packaging`, `ci`, `security`, or `documentation` for work area.
- `question` for research issues whose output may be a decision or follow-up
  issue.
- Keep `needs-triage` until the issue has enough scope, labels, and acceptance
  criteria for someone else to pick up.
