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

The issue flow is `needs-triage` -> labeled and scoped -> claimed or assigned
-> pull request.

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

## Local Build Loop

Run Linux build and packaging changes from a clean checkout on `codex-test`:

```sh
ssh codex-test
cd /root/codex
linux/build.sh
linux/package-appimage.sh
ls -lh /root/codex-port/dist/Codex-x86_64.AppImage
```

`linux/build.sh` assumes `/root/codex-port/mac-resources` contains the extracted
Mac `Contents/Resources` payload and
`/root/codex-port/electron-linux/extracted` contains the Linux Electron tree.
Do not commit either staged payload, generated build tree, or release artifact.

For documentation-only changes, do not run the remote build unless the docs
change a command, path, or build assumption that needs proof.

## Upstream Pins

Every build artifact must state the exact upstream `openai/codex` SHA used for
the Rust agent. Until a pin manifest is committed, record that SHA in the PR
description and release notes. When a branch adds or updates a pin manifest,
commit the manifest change with the build changes that depend on it.

Version-bump PRs should state:

- Old and new upstream `openai/codex` SHA.
- Why the bump is needed.
- What smoke or build evidence was collected.
- Whether any native module, Electron, payload, or protocol behavior changed.

Use the repository's pin helper when one exists; otherwise update the manifest
directly and keep the old/new SHA diff visible for reviewers.

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
- Skip issues labeled `claimed` and issues whose `Blocked by` section names an
  incomplete issue.
- To claim work, add the `claimed` label and leave a short issue comment stating
  the intended scope.
