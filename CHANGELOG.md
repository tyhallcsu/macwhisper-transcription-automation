# Changelog

All notable changes to this project will be documented in this file. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] — 2026-05-09

### Added
- Repo went **public** under `tyhallcsu/macwhisper-transcription-automation` (MIT licensed).
- **CI pipeline** (`.github/workflows/ci.yml`): `zsh -n` syntax check, ShellCheck (best-effort), markdownlint, actionlint, link check, privacy-guard (no audio/transcript files tracked, README image refs resolve), and a macOS smoke test that installs `whisper-cpp`, generates audio with `say`, and runs `transcribe_call.zsh` end-to-end against the `tiny.en` ggml model.
- **Release pipeline** (`.github/workflows/release.yml`): tag-driven, extracts the matching CHANGELOG section as release notes, builds a versioned source tarball plus `SHA256SUMS.txt`, and publishes the GitHub release.
- **Public-repo standards**: `SECURITY.md` (private vulnerability reporting), `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1), `.github/CODEOWNERS`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/{bug_report,feature_request,config}.{yml}`, and `.github/dependabot.yml` (weekly GitHub Actions version updates).
- README badge row for CI status, latest release, license, and platform.
- `.markdownlint-cli2.jsonc` to keep markdownlint scoped to meaningful rules.
- Real generated raster image assets for README presentation: hero image, app icon, feature icons, and social preview candidate.
- `docs/assets.md` and `assets/prompts/image-generation-prompts.md` for asset inventory, privacy rules, and regeneration prompts.
- `scripts/check_readme_assets.sh` to verify local README image references exist.

### Changed
- README redesigned into a polished GitHub project page with centered visual hero, feature grid, workflow diagram, privacy guardrails, and asset documentation links.
- Renamed the example Shortcut from `ESS Transcribe Call Recording` → `Transcribe Call Recording` in public-facing docs (you can name the Shortcut on your own machine whatever you like).

## [0.2.0] — 2026-05-08

### Added
- **Two-engine auto-failover.** `transcribe_call.zsh` now prefers MacWhisper's `mw` CLI but transparently falls back to `whisper.cpp` (`whisper-cli`) when `mw` can't load. Force a specific engine with `TRANSCRIBE_ENGINE=mw|whisper-cpp`.
- whisper.cpp install path documented in `docs/setup.md`. Default model location: `~/.local/share/whisper-cpp/models/ggml-base.en.bin`. Override with `WHISPER_MODEL` / `WHISPER_LANG` env vars.
- `doctor.sh` rewritten to surface the *engine* picture: which CLIs are present, whether their models are downloaded, and which engine the auto path will pick.
- Header block in transcripts now records the actual engine + model used.

### Changed
- Reframed the `mw` dyld failure mode as a MacWhisper packaging bug (CLI built with `minos 26.4` while the GUI ships with `LSMinimumSystemVersion = 14.0`) rather than a user-side macOS issue. `doctor.sh` and `docs/troubleshooting.md` no longer recommend upgrading macOS or reinstalling MacWhisper; they point users at the whisper.cpp fallback and the upstream-bug-report path.

## [0.1.0] — 2026-05-08

### Added
- Initial scaffold: `transcribe_call.zsh` main script, `install.sh` and `doctor.sh` helpers.
- Shortcut workflow recipe documenting how to wire Apple Notes call recordings through the script and back into the original Note.
- Optional watch-folder mode documentation.
- `.gitignore` blocking audio, transcripts, env, and job/customer data folders.
- README, CONTRIBUTING, and troubleshooting docs (including the macOS-version dyld failure mode).
