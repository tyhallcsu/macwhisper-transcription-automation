# Optional: watch-folder mode

MacWhisper Pro has a built-in **Watch Folders** feature ([docs](https://macwhisper.helpscoutdocs.com/article/35-automatically-transcribing-files-in-watch-folders)). It auto-transcribes any audio file dropped into a chosen folder. Use it when you want hands-free `.txt` generation but don't need the transcript appended back into Notes.

## How it works

1. In MacWhisper, open **Settings → Watch Folders**.
2. Add a folder (e.g. `~/Inbox/CallRecordings`).
3. Choose your export format(s) — at minimum `Plain Text (.txt)`.
4. Toggle **Auto-Transcribe** on.
5. Drop an audio file in. MacWhisper writes the `.txt` next to it.

## When to prefer the Shortcut workflow instead

- You want the transcript **appended back into the original Note**. Watch Folders has no awareness of which Apple Note an audio file came from.
- You want transcripts in a **specific job folder** (the Shortcut prompts for this; Watch Folders all share one output destination).
- You need a header block in the transcript file (`Source Audio`, `Transcribed`, etc.).

## Hybrid pattern

Keep both:

- **Watch Folder** = `~/Inbox/CallRecordings` → drag-and-drop quick path for ad-hoc audio.
- **Shortcut** = the in-place call-recording flow that pairs `.txt` to a job folder and appends to Notes.

Don't try to combine them — the Watch Folder will overwrite or duplicate output if the same file is also passed through `transcribe_call.zsh`.

## Why we don't scrape the Notes database

Apple Notes stores its data in a private SQLite/CloudKit format under `~/Library/Group Containers/group.com.apple.notes/`. Reading or writing it directly:
- Breaks across macOS updates without warning.
- Can corrupt notes during iCloud sync.
- Has no supported API.

Apple's public hooks (Share Sheet, AppleScript, the Shortcuts.app **Append to Note** action) are the only durable path. The Shortcut covers them all.
