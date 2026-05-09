# Changelog

All notable changes to this project will be documented in this file. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Reframed the `mw` dyld failure mode as a MacWhisper packaging bug (CLI built with `minos 26.4` while the GUI ships with `LSMinimumSystemVersion = 14.0`) rather than a user-side macOS issue. `doctor.sh` and `docs/troubleshooting.md` no longer recommend upgrading macOS or reinstalling MacWhisper; they recommend reporting the bug upstream and offer a `whisper.cpp` fallback path.

## [0.1.0] — 2026-05-08

### Added
- Initial scaffold: `transcribe_call.zsh` main script, `install.sh` and `doctor.sh` helpers.
- Shortcut workflow recipe documenting how to wire Apple Notes call recordings through the script and back into the original Note.
- Optional watch-folder mode documentation.
- `.gitignore` blocking audio, transcripts, env, and job/customer data folders.
- README, CONTRIBUTING, and troubleshooting docs (including the macOS-version dyld failure mode).
