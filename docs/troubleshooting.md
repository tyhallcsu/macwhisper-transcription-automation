# Troubleshooting

## `mw` won't launch — "Library not loaded" / "newer than running OS"

Symptom (running `mw version` or `doctor.sh`):

```
dyld[…]: Library not loaded: /usr/lib/swift/libswift_DarwinFoundation1.dylib
  Referenced from: /Applications/MacWhisper.app/Contents/MacOS/mw
                   (built for macOS 26.4 which is newer than running OS)
```

**This is a MacWhisper packaging bug, not a problem with your setup.** Verify with:

```sh
otool -l /Applications/MacWhisper.app/Contents/MacOS/mw | grep -A2 LC_BUILD_VERSION | head -6
defaults read /Applications/MacWhisper.app/Contents/Info LSMinimumSystemVersion
```

In MacWhisper 13.20 (build 1410), the GUI binary advertises `LSMinimumSystemVersion = 14.0`, while the CLI binary inside the same bundle is compiled with `minos 26.4`. dyld correctly refuses to load a binary that asks for a newer macOS than the host. The GUI runs fine; only the CLI is broken.

You cannot work around this with `DYLD_FRAMEWORK_PATH`, library shimming, or env tweaks — `libswift_DarwinFoundation1.dylib` was renamed in the macOS 26 SDK and no equivalent file exists on macOS 14/15.

**What to do:**

1. **Report it to MacWhisper support** (`support@macwhisper.com`). The fix is for them to rebuild `mw` with the same `-mmacosx-version-min` flag the GUI uses (14.0).
2. **Until then**, transcribe via the MacWhisper GUI's Watch Folders feature (see [watch-folder.md](watch-folder.md)) and use this repo's Shortcut only for the file-routing/Notes-append part.
3. **Or**, install an alternative engine like `whisper.cpp` (`brew install whisper-cpp`) and run the Shortcut against that. Ask in this repo and we can wire `transcribe_call.zsh` to fall back to it.

After MacWhisper ships a corrected `mw`, re-run **Settings → Advanced → Command-Line Tool → Install** and then `./scripts/doctor.sh`.

## Shortcut runs but the transcript is empty

- Open MacWhisper at least once and select a model (Settings → Models).
- In Terminal: `mw transcribe /path/to/sample.m4a` should print a transcript.
- If `mw` prints a model-download prompt, complete it once before re-running the Shortcut.

## "MacWhisper produced an empty transcript"

The script intentionally fails when `mw` returns nothing. Causes:
- Audio is silent or unsupported codec — re-encode with `ffmpeg -i in.xxx -c:a aac out.m4a`.
- Selected model isn't loaded yet — open MacWhisper.app once.

## "Append to Note" pastes nothing

The Run Shell Script action's output is what gets appended. If you see nothing in the Note:
- In the Shortcut, click the Run Shell Script action and verify **Pass input: as arguments** (not "to stdin").
- Add a temporary **Show Result** action wired to **Shell Script Result** to confirm the text exists.
- Make sure your script body is exactly:
  ```zsh
  "$HOME/bin/transcribe_call.zsh" "$1" "$JOB_FOLDER"
  ```
  with `$JOB_FOLDER` replaced by the folder magic variable.

## `command not found: mw` from inside the Shortcut

Shortcuts uses a minimal PATH. The script uses `command -v mw`, which works as long as `mw` is in `/usr/local/bin` or `/opt/homebrew/bin`. If you installed MacWhisper to a non-standard location, prepend it:

```zsh
PATH="/path/to/MacWhisper.app/Contents/MacOS:$PATH" "$HOME/bin/transcribe_call.zsh" "$1" "$JOB_FOLDER"
```

## Shortcut errors with "Operation not permitted"

Grant Shortcuts (and the script's parent terminal) **Full Disk Access** in System Settings → Privacy & Security if your job folders live in protected locations (Desktop, Documents, iCloud Drive). For Notes append, ensure Shortcuts has Notes access (System Settings → Privacy & Security → Automation).

## Filename has weird characters

The script strips `/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|` and control characters from the audio file's base name. If you see leftover artifacts, rename the source file before sharing.

## Where to file issues

This is a private repo. Capture issues in `CHANGELOG.md` under an `### Unreleased` heading or open an internal issue on GitHub.
