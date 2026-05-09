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
./scripts/install.sh
```

The installer sets executable bits and runs `doctor.sh`. Expect a clean `Summary: N passing, 0 failing`.

## 3. Symlink the script onto your PATH

The macOS Shortcut will invoke the script by absolute path. Putting it in `~/bin` makes the Shortcut survive moves of the repo:

```sh
mkdir -p ~/bin
ln -sfn "$(pwd)/scripts/transcribe_call.zsh" ~/bin/transcribe_call.zsh
```

If `~/bin` is not on your PATH yet:

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
mkdir -p /tmp/mw-smoke
cp /path/to/some-recording.m4a /tmp/mw-smoke/sample.m4a
~/bin/transcribe_call.zsh /tmp/mw-smoke/sample.m4a /tmp/mw-smoke
ls "/tmp/mw-smoke/Call Transcripts/"
```

You should see a single `.txt` file with a header and the transcript body.

## 6. Build the Shortcut

Continue with [shortcut-workflow.md](shortcut-workflow.md).
