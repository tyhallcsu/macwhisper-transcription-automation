#!/bin/zsh
# Idempotent local setup for this macOS workflow.
# It installs the script symlink, verifies local dependencies, and prints the
# manual Shortcuts.app wiring that macOS cannot create from the CLI.

set -euo pipefail

repo_root="${0:A:h:h}"
cd -- "$repo_root"

ok()   { print -- "  [ OK ]   $*"; }
warn() { print -- "  [WARN]   $*"; }

print -- "==> Preparing local MacWhisper Transcription Automation install"

print -- ""
print -- "==> Setting executable bits"
chmod +x scripts/*.sh scripts/*.zsh
ok "scripts/*.sh and scripts/*.zsh are executable"

print -- ""
print -- "==> Installing command symlink"
mkdir -p "$HOME/bin"
ln -sfn "$repo_root/scripts/transcribe_call.zsh" "$HOME/bin/transcribe_call.zsh"
ok "$HOME/bin/transcribe_call.zsh -> $repo_root/scripts/transcribe_call.zsh"

case ":$PATH:" in
  *":$HOME/bin:"*) ok "$HOME/bin is on PATH" ;;
  *) warn "$HOME/bin is not on PATH for this shell; Shortcuts still uses the absolute $HOME/bin path" ;;
esac

print -- ""
print -- "==> Verifying local dependencies"
if command -v afconvert >/dev/null 2>&1; then
  ok "afconvert available"
else
  warn "afconvert missing"
fi
if command -v whisper-cli >/dev/null 2>&1; then
  ok "whisper-cli available at $(command -v whisper-cli)"
else
  warn "whisper-cli missing (install with: brew install whisper-cpp)"
fi

model_path="${WHISPER_MODEL:-$HOME/.local/share/whisper-cpp/models/ggml-base.en.bin}"
if [[ -f "$model_path" ]]; then
  ok "whisper.cpp model found: $model_path"
else
  warn "whisper.cpp model missing: $model_path"
fi

if [[ -d "/System/Applications/Shortcuts.app" || -d "/Applications/Shortcuts.app" ]]; then
  ok "Shortcuts.app installed"
else
  warn "Shortcuts.app not found"
fi

print -- ""
print -- "==> Running doctor"
"$repo_root/scripts/doctor.sh"

print -- ""
print -- "==> Shortcut setup (manual)"
print -- "macOS can run/list/view/sign shortcuts from the CLI, but it cannot create or edit them."
print -- "Create a new Shortcut named: Transcribe Call Recording"
print -- ""
print -- "Required Run Shell Script action:"
# shellcheck disable=SC2016
print -- '  "$HOME/bin/transcribe_call.zsh" "$1" "$JOB_FOLDER"'
print -- ""
print -- "Replace literal JOB_FOLDER with the folder magic variable from the Shortcut's Ask for Folder action."
print -- "Full walkthrough: docs/shortcut-workflow.md"
