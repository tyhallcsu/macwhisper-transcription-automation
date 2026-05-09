# macOS Shortcut: Transcribe Call Recording

This Shortcut takes an audio file (typically a call recording shared from Apple Notes), prompts for a job folder, transcribes via MacWhisper, saves the `.txt`, and appends the transcript back into the originating Note.

## Prerequisites

- `~/bin/transcribe_call.zsh` exists and is executable (see [setup.md](setup.md)).
- MacWhisper CLI works (`mw version` succeeds).

## Build the Shortcut

1. Open **Shortcuts.app**.
2. Click **+** to create a new shortcut. Name it **`Transcribe Call Recording`** (or whatever fits your naming scheme — a prefix like `ACME Transcribe Call Recording` is fine, it's purely cosmetic).
3. Open the **Shortcut details** panel (top-right toggle):
   - Enable **Use as Quick Action**.
   - Enable **Use from Share Sheet**.
   - **Receive**: `Audio` and `Files`.
4. Add the actions in this order:

### Action 1 — Get Shortcut Input
- Action: **Receive Input from Share Sheet**.
- Type: `Audio Files, Files`.

### Action 2 — Ask for Folder
- Action: **Get Folder**, configured as **Ask Each Time**.
- Prompt: `Choose the job folder for this call`.
- This produces a `Folder` magic variable. Rename it to **`JOB_FOLDER`** to match the example below.

### Action 3 — Run Shell Script
- **Shell**: `/bin/zsh`.
- **Pass input**: `as arguments`.
- **Input**: the audio file from Action 1.
- **Script body** (paste exactly):
  ```zsh
  "$HOME/bin/transcribe_call.zsh" "$1" "$JOB_FOLDER"
  ```
  Then click **JOB_FOLDER** in the script and replace it with the magic variable produced by Action 2 (Shortcuts will display it as a chip — that's correct).

### Action 4 — Append Transcript to a Note
- Action: **Append to Note** (under Notes).
- **Text**: the **Shell Script Result** magic variable.
- **Note**: either:
  - **Ask Each Time** — pick the matching Note manually each run, or
  - A specific note if you keep one running call log.

### Action 5 (optional) — Show notification
- Action: **Show Notification**, body: `Transcript saved to JOB_FOLDER/Call Transcripts`.

## End-to-end

1. In Apple Notes, locate the call recording. Right-click → **Save Attachment…** to a known folder (e.g. `~/Downloads`), or use **Share Audio**.
2. From Finder/the Share Sheet, send the audio file to **Transcribe Call Recording**.
3. Pick the job folder.
4. Wait for MacWhisper to finish.
5. The `.txt` lands in `<job_folder>/Call Transcripts/`, and the same text appends below the original Note's audio attachment.

## Naming convention recommendation

Notes title:
```
JobName - Call with Person - Date
```
Example: `Acme HQ - Call with Vendor - 2026-05-08`

Resulting transcript filename:
```
2026-05-08 14.32.05 - JobName-Call-with-Person.txt
```

## Quick Action variant

You can run the same Shortcut as a Finder Quick Action:
1. Right-click the audio file in Finder → **Quick Actions** → **Transcribe Call Recording**.
2. Pick the job folder.
3. Open the Note manually and paste/append the result if you skipped Action 4 above.
