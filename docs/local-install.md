# Local Install

Use this path when you want the repo installed on your Mac for daily use with Apple Notes, Shortcuts, and local transcription.

## Install

```sh
./scripts/install-local.sh
```

The installer is idempotent. It:

- Makes every script in `scripts/` executable.
- Creates or refreshes `~/bin/transcribe_call.zsh`.
- Verifies `afconvert`, `whisper-cli`, the default whisper.cpp model, Shortcuts.app, and `doctor.sh`.
- Prints the exact Shortcuts.app setup needed for the Share Sheet workflow.

## Smoke Test

```sh
./scripts/smoke_test_local.sh
```

The smoke test creates a disposable audio file with `say`, runs the transcription script, and verifies a `.txt` transcript lands under:

```text
/tmp/test-job/Call Transcripts/
```

The test does not write anything inside the repo and does not use real customer or call data.

## Shortcut Setup

Create a Shortcut named:

```text
Transcribe Call Recording
```

Configure it as a Share Sheet / Quick Action workflow that accepts `Audio` and `Files`.

The **Run Shell Script** action should use `/bin/zsh`, pass input **as arguments**, and contain:

```zsh
"$HOME/bin/transcribe_call.zsh" "$1" "$JOB_FOLDER"
```

Replace literal `$JOB_FOLDER` with the folder magic variable from the Shortcut's **Ask for Folder** action.

Then add **Append to Note** using **Shell Script Result** as the text.

See [shortcut-workflow.md](shortcut-workflow.md) for the full step-by-step version.

## Why Shortcut Creation Is Manual

macOS ships a `shortcuts` CLI, but it can only run, list, view, and sign shortcuts:

```sh
shortcuts list
shortcuts run "Transcribe Call Recording"
shortcuts view "Transcribe Call Recording"
shortcuts sign --mode people-who-know-me --input input.shortcut --output output.shortcut
```

It cannot create or edit Shortcut actions. The Shortcut must be created in Shortcuts.app so the Share Sheet input, folder picker magic variable, shell action, and Notes append action are wired correctly.

