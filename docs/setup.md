# Setup

Tested on macOS 15+ with MacWhisper Pro and Apple's Shortcuts.app.

## 1. Install at least one transcription engine

You need either MacWhisper's CLI or whisper.cpp. The script auto-prefers `mw`; if it can't load, it falls back to `whisper-cli`.

### Option A — MacWhisper CLI

1. Install **MacWhisper** from [https://goodsnooze.gumroad.com/l/macwhisper](https://goodsnooze.gumroad.com/l/macwhisper) or the Mac App Store. The CLI requires **MacWhisper Pro**.
2. Open MacWhisper → **Settings** → **Advanced** → **Command-Line Tool** → **Install**. This creates `/usr/local/bin/mw`.
3. Verify in Terminal:
   ```sh
   mw version
   ```
   If you see `Library not loaded` / `newer than running OS`, you've hit the upstream packaging mismatch documented in [troubleshooting.md](troubleshooting.md). Use Option B for now.

### Option B — whisper.cpp (recommended fallback today)

```sh
brew install whisper-cpp
mkdir -p ~/.local/share/whisper-cpp/models
curl -L -o ~/.local/share/whisper-cpp/models/ggml-base.en.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin
```

(`base.en` is ~150 MB. For different size/quality trade-offs, replace `base.en` with `tiny.en`, `small.en`, `medium.en`, or `large-v3` in both the filename and the URL. Override at runtime with `WHISPER_MODEL=/path/to/your/model.bin`.)

Verify:
```sh
whisper-cli --help | head -5
ls ~/.local/share/whisper-cpp/models/
```

## 2. Clone and install this repo

```sh
git clone git@github.com:tyhallcsu/macwhisper-transcription-automation.git
cd macwhisper-transcription-automation
./scripts/install-local.sh
```

The local installer sets executable bits, creates or refreshes `~/bin/transcribe_call.zsh`, runs `doctor.sh`, and prints the manual Shortcuts.app setup step.
Expect a clean `Summary: N passing, 0 failing` from `doctor.sh` (warnings are okay when a fallback engine is ready).

## 3. Optional shell PATH setup

The Shortcut invokes the script by absolute path via `$HOME/bin/transcribe_call.zsh`.
If you also want to run `transcribe_call.zsh` directly by name in interactive shells, add `~/bin` to your PATH:

```sh
print 'export PATH="$HOME/bin:$PATH"' >> ~/.zprofile
exec zsh -l
```

## 4. (Optional) defaults file

```sh
mkdir -p ~/.config/macwhisper-automation
cp examples/config.example.env ~/.config/macwhisper-automation/config.env
$EDITOR ~/.config/macwhisper-automation/config.env
```

Uncomment a `MW_MODEL=…` line to force a specific transcription model.

## 5. Smoke test

```sh
./scripts/smoke_test_local.sh
```

You should see a disposable `.txt` file with a header and transcript body under `/tmp/test-job/Call Transcripts/`.

## 6. Build the Shortcut

Continue with [shortcut-workflow.md](shortcut-workflow.md).
