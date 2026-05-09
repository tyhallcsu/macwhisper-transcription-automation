# Setup

Tested on macOS 15+ with MacWhisper Pro and Apple's Shortcuts.app.

## 1. Install MacWhisper and enable the CLI

1. Install **MacWhisper** from [https://goodsnooze.gumroad.com/l/macwhisper](https://goodsnooze.gumroad.com/l/macwhisper) or the Mac App Store. The CLI requires **MacWhisper Pro**.
2. Open MacWhisper → **Settings** → **Advanced** → **Command-Line Tool** → **Install**. This creates `/usr/local/bin/mw`.
3. Verify in Terminal:
   ```sh
   mw version
   ```
   You should see a version line. If you see a `Library not loaded` or `newer than running OS` error, see [troubleshooting.md](troubleshooting.md).

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
