# Maintainer Future Work

This is a reviewer- and maintainer-focused backlog collected from the open
GitHub issues on 2026-05-05. It intentionally avoids direct Linux port
implementation work.

## Maintainer Issue Context

- #5: Add `README.md`, `CONTRIBUTING.md`, `LICENSE`, and `NOTICE` so reviewers
  have a documented contribution path and a defensible redistribution story.
  `CONTRIBUTING.md`, `LICENSE`, and `NOTICE` are covered by the first
  maintainer scaffolding pass; the README overhaul remains follow-up work.
- #6: Add `CODEOWNERS`, PR templates, and issue templates so branch protection
  and review routing behave predictably. This is covered by the first
  maintainer scaffolding pass.

## Issue Scan Summary

- #1 is the umbrella PRD for Linux and Windows distributions.
- #2, #3, #4, #7, #8, #9, #10, #11, and #12 are Linux or Linux-adjacent build,
  packaging, CI, research, reproducibility, and release-integrity work.
- #5 and #6 are reviewer/maintainer hygiene issues that can move independently
  of the Linux MVP.
- #1 also implies non-Linux maintainer work for Windows packaging, Windows code
  signing, future update channels, release policy, and eventual ownership split.

## Future Work To File Or Expand

- Document the issue triage flow from `needs-triage` to labeled, scoped, and
  assigned, including when to split research issues from implementation issues.
- Add a reviewer checklist for packaging and release PRs once CI exists:
  artifact provenance, smoke-test evidence, checksum evidence, and rollback
  notes.
- Add release checklist documentation that maps a tag to the exact source commit,
  upstream Codex SHA, payload version, artifact names, and checksum files.
- Add a repository label guide so maintainers apply platform, packaging, CI,
  security, and documentation labels consistently.
- Add dependency and payload update guidance after #8 lands, including where the
  pinned versions live and what reviewers should verify in a version-bump PR.
- Add a security-reporting policy before publishing release artifacts, especially
  for signing keys, release tokens, checksum integrity, and payload provenance.

## Non-Linux Future Work From #1

- Create Windows maintainer/reviewer guidance before the NSIS installer work
  starts: expected artifact names, Start Menu entry checks, uninstaller checks,
  and `codex://` URL handler verification.
- Capture the Authenticode signing decision as a maintainer issue before public
  Windows releases, including certificate ownership, renewal, and SmartScreen
  expectations.
- Track the v1.1 update-channel decision separately from the Linux port: whether
  the app should show a GitHub Releases update banner and what reviewers need to
  verify before enabling it.
- Record explicitly deferred release channels such as winget, Chocolatey, Snap,
  Flatpak, and distro repositories so contributors do not mix them into the
  initial packaging PRs.
- Add an ownership-expansion issue for splitting `CODEOWNERS` when Windows,
  release, or security maintainers join.
