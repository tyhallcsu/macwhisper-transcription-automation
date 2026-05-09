# Upstream bug report — MacWhisper `mw` CLI min-OS mismatch

Suggested email body to send to **support@macwhisper.com**. Subject and content are below — paste, fill in your version numbers, and send.

---

**Subject:** `mw` CLI in 13.20 (build 1410) compiled for macOS 26.4, fails to load on macOS 14/15

Hi MacWhisper team,

The `mw` command-line tool shipped with MacWhisper 13.20 (build 1410) won't dyld-load on macOS releases older than 26. The MacWhisper.app GUI works fine on the same install — it's only the bundled CLI that's broken.

**Repro on macOS 15.7.1 (Apple Silicon):**

```
$ /usr/local/bin/mw version
dyld[…]: Library not loaded: /usr/lib/swift/libswift_DarwinFoundation1.dylib
  Referenced from: /Applications/MacWhisper.app/Contents/MacOS/mw
                   (built for macOS 26.4 which is newer than running OS)
  Reason: tried: '/usr/lib/swift/libswift_DarwinFoundation1.dylib' (no such file),
                 '/System/Volumes/Preboot/Cryptexes/OS/usr/lib/swift/libswift_DarwinFoundation1.dylib' (no such file),
                 '/usr/lib/swift/libswift_DarwinFoundation1.dylib' (no such file, not in dyld cache)
```

**Diagnosis:**

```
$ otool -l /Applications/MacWhisper.app/Contents/MacOS/mw | grep -A2 LC_BUILD_VERSION
      cmd LC_BUILD_VERSION
  cmdsize 32
 platform 1
    minos 26.4

$ defaults read /Applications/MacWhisper.app/Contents/Info LSMinimumSystemVersion
14.0
```

The GUI binary advertises `LSMinimumSystemVersion = 14.0`, but the CLI inside the same bundle was compiled with `minos 26.4`. dyld correctly refuses to load it on anything older than macOS 26.

**Suggested fix:**

Rebuild `mw` with the same `-mmacosx-version-min` (or equivalent target) the GUI uses (14.0). Currently the CLI ships with a version-min that excludes most of your install base.

Happy to test a build.

Thanks,
Tyler

---

## Why this matters for the workflow

Without `mw`, this repo's `transcribe_call.zsh` falls back to `whisper.cpp` (already wired in v0.2.0). That works, but:

- `whisper.cpp` doesn't share MacWhisper's model selections, prompts, or history.
- Users who paid for MacWhisper Pro reasonably expect the CLI to run on the same OS the GUI runs on.

Once MacWhisper ships a fixed `mw`, the script automatically switches back — no changes needed on this end.
