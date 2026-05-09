# Security Policy

## Supported Versions

Only the latest release on `main` receives security fixes. The project is small and shell-based; there is no LTS branch.

| Version | Supported |
| --- | --- |
| Latest `main` | ✅ |
| Tagged release ≥ v0.2.0 | ✅ |
| Anything older | ❌ |

## Reporting a Vulnerability

**Please do not open a public issue for security problems.**

Use GitHub's private vulnerability reporting:

1. Open the **Security** tab on the repository.
2. Click **Report a vulnerability**.
3. Describe the issue, the affected file/line, and a reproduction recipe if you have one.

You can expect:

- Acknowledgement within 7 days.
- A triage decision (fix, won't-fix, out-of-scope) within 14 days.
- A fix or mitigation in the next minor release if accepted.

## Scope

In scope:

- Anything in `scripts/` that writes outside `<job_folder>/Call Transcripts/`.
- Path traversal or quoting bugs that could let an attacker-controlled audio filename clobber files.
- CI workflows in `.github/workflows/` (token misuse, untrusted-input handling, supply-chain risk).
- Insecure defaults documented in `docs/`.

Out of scope:

- Bugs in third-party engines (`mw`, `whisper-cli`, `afconvert`) — report those upstream.
- Issues that require already having root or full disk access on the user's machine.
- Anything in MacWhisper's app bundle or model files.

## What this project does NOT do

- It does not transmit audio, transcripts, or any user content over the network. Everything runs locally.
- It does not read the Apple Notes SQLite database.
- It does not collect telemetry.
- It does not require API keys or tokens.

If you observe behavior contrary to any of the above, treat it as a P0 security finding.
