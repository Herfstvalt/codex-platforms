# Security Policy

This repository has not published a stable release yet. Security-sensitive
reports are still useful because the project handles release artifacts,
checksums, upstream payload provenance, native binaries, and future signing
infrastructure.

## Private Reports

Use GitHub private vulnerability reporting for issues involving:

- Release credentials, signing keys, GitHub Actions tokens, or maintainer
  secrets.
- Tampered release artifacts, checksum mismatches, or provenance concerns.
- Vulnerabilities in packaging scripts that could execute untrusted input.
- Accidental inclusion of private payloads, local paths, tokens, logs, or user
  data.
- Security defects in install, update, or artifact verification flows.

Do not include API keys, session tokens, private payload files, or proprietary
OpenAI app contents in public issues.

## Public Issues

Use the public bug template for ordinary crashes, build failures, missing
dependencies, packaging regressions, and documentation mistakes. If a report is
unclear, start privately when it could expose a secret or artifact-integrity
problem.

## Scope

This policy covers code, documentation, build scripts, release metadata, and
artifacts produced by this repository. Vulnerabilities in OpenAI services,
official OpenAI applications, Electron, or upstream `openai/codex` should also
be reported to the responsible upstream project.
