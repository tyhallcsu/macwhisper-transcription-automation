# Troubleshooting

## `mw` won't launch — "Library not loaded" / "newer than running OS"

Symptom (running `mw version` or `doctor.sh`):

```
dyld[…]: Library not loaded: /usr/lib/swift/libswift_DarwinFoundation1.dylib
  Referenced from: /Applications/MacWhisper.app/Contents/MacOS/mw
                   (built for macOS 26.4 which is newer than running OS)
```

**Cause.** The installed MacWhisper.app was built against a newer macOS SDK than the one your host is running. The bundled CLI links against system Swift libraries that don't exist on your macOS yet.

**Fix — pick one:**

1. **Install a MacWhisper build that matches your macOS.** From the developer site, look for the "Compatible with macOS X" download (or check the Mac App Store version, which Apple gates per OS). Replace `/Applications/MacWhisper.app`, then re-run **Settings → Advanced → Command-Line Tool → Install**.
2. **Upgrade macOS** to the version MacWhisper was built for. (Not always desirable — verify any other apps you depend on first.)

After fixing, re-run:
```sh
./scripts/doctor.sh
```

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
