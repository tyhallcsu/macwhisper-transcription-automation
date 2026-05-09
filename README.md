# MacWhisper Transcription Automation

A small macOS toolkit that turns Apple Notes call recordings into searchable text — saved into the right job folder and appended back into the original Note — via a single Share Sheet click.

## Why

Recording calls in Apple Notes is easy. Doing anything *useful* with those recordings is not: the audio sits buried inside a Note, with no project context, no full-text search, and no way to skim. Manually opening MacWhisper, picking a model, exporting, renaming, filing, and pasting back into Notes is several minutes of friction per call.

This repo collapses that into: **right-click the recording → Share → done.**

## What it does

1. You share the call recording from Apple Notes (or Finder) into a macOS Shortcut.
2. The Shortcut prompts for the job folder.
3. A zsh script invokes the **MacWhisper CLI** (`mw transcribe`).
4. The transcript is saved as a timestamped `.txt` under `<job_folder>/Call Transcripts/`.
5. The same plaintext is returned to the Shortcut, which appends it directly under the original recording in the Note.

No Notes-database scraping, no AppleScript reverse-engineering, no third-party services.

## Features

- One-click Share Sheet integration via macOS Shortcuts.
- Per-call job-folder routing — never lose track of which call goes where.
- Header block on every transcript: source audio, timestamp, model, script version.
- Robust filename sanitisation for tricky recording names.
- Optional model override via `MW_MODEL` env / config file.
- Built-in `doctor.sh` to surface install/version issues fast.
- Strict zsh, strict-mode, error-to-stderr — safe to chain in Shortcuts.

## Requirements

- macOS (tested on 15+).
- **MacWhisper Pro** with the Command-Line Tool installed (Settings → Advanced → Command-Line Tool).
- Apple Shortcuts.app (preinstalled).
- zsh (default macOS shell).

## Quick start

```sh
git clone git@github.com:tyhallcsu/macwhisper-transcription-automation.git
cd macwhisper-transcription-automation
./scripts/install.sh

# Put the script on your PATH for the Shortcut to find:
mkdir -p ~/bin
ln -sfn "$(pwd)/scripts/transcribe_call.zsh" ~/bin/transcribe_call.zsh
```

Then build the Shortcut: see **[docs/shortcut-workflow.md](docs/shortcut-workflow.md)**.

## Smoke test

```sh
mkdir -p /tmp/mw-smoke
cp ~/some-recording.m4a /tmp/mw-smoke/sample.m4a
~/bin/transcribe_call.zsh /tmp/mw-smoke/sample.m4a /tmp/mw-smoke
ls "/tmp/mw-smoke/Call Transcripts/"
```

## File-naming convention

Recommended Note title:
```
JobName - Call with Person - Date
```

Example transcript output:
```
<job_folder>/Call Transcripts/2026-05-08 14.32.05 - Acme-Call-with-Vendor.txt
```

## Privacy & security

- The script never uploads audio anywhere — everything runs locally through MacWhisper.
- `.gitignore` blocks `*.m4a`, `*.mp3`, `*.wav`, `*.txt`-flavoured transcripts under `Call Transcripts/`, `*.env`, and any folder named `private/`, `local/`, `exports/`, or `transcripts/`.
- Customer/job names, addresses, phone numbers, and absolute home paths must not be committed. See [CONTRIBUTING.md](CONTRIBUTING.md).
- The optional config file lives at `~/.config/macwhisper-automation/config.env` and is never read from inside the repo.

## Limitations

- Notes append happens **via the Shortcut**, not by writing to the Apple Notes database. That's deliberate — see [docs/watch-folder.md](docs/watch-folder.md#why-we-dont-scrape-the-notes-database).
- The Shortcut runs on macOS only. iOS Shortcuts can't execute zsh.
- MacWhisper CLI is gated behind MacWhisper Pro.
- A MacWhisper build that targets a newer macOS than your host will fail to launch — see [docs/troubleshooting.md](docs/troubleshooting.md#mw-wont-launch--library-not-loaded--newer-than-running-os).

## Documentation

- **[Setup](docs/setup.md)** — install, symlink, smoke test.
- **[Shortcut workflow](docs/shortcut-workflow.md)** — wire up Shortcuts.app step-by-step.
- **[Watch folder](docs/watch-folder.md)** — optional drag-and-drop mode.
- **[Troubleshooting](docs/troubleshooting.md)** — common failure modes and fixes.
- **[Contributing](CONTRIBUTING.md)** — privacy rules, commit style.

## Roadmap

- [ ] `--model` shortcut flag pass-through (today only via env / config).
- [ ] Multi-language support via `MW_LANG`.
- [ ] Optional speaker-diarization in the header block.
- [ ] Bundled "presets" (e.g. `mw-fast`, `mw-accurate`) selectable per job.
- [ ] Pre-flight ffmpeg re-encoding for unusual codecs.

## License

MIT — see [LICENSE](LICENSE).
