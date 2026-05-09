#!/bin/zsh
# doctor.sh — verify the host can actually run the workflow.
# Reports which engine(s) are usable. Exits non-zero only if NO engine works.

set -uo pipefail

DEFAULT_WHISPER_MODEL="$HOME/.local/share/whisper-cpp/models/ggml-base.en.bin"
: "${WHISPER_MODEL:=$DEFAULT_WHISPER_MODEL}"

passes=0
fails=0
warns=0

ok()   { print -- "  [ OK ]   $*"; passes=$((passes+1)); }
warn() { print -- "  [WARN]   $*"; warns=$((warns+1)); }
fail() { print -- "  [FAIL]   $*"; fails=$((fails+1)); }
info() { print -- "  [INFO]   $*"; }

print -- "MacWhisper Automation — doctor"
print -- ""

# 1. macOS
if [[ "$(uname)" != "Darwin" ]]; then
  fail "not running on macOS — this workflow is macOS-only"
else
  ok "macOS detected ($(sw_vers -productVersion 2>/dev/null || echo unknown))"
fi

# 2. zsh
if command -v zsh >/dev/null 2>&1; then
  ok "zsh available at $(command -v zsh)"
else
  fail "zsh not found"
fi

# 3. Shortcuts.app
if [[ -d "/System/Applications/Shortcuts.app" || -d "/Applications/Shortcuts.app" ]]; then
  ok "Shortcuts.app installed"
else
  warn "Shortcuts.app not found (you can still run the script directly)"
fi

# 4. afconvert (needed for whisper.cpp fallback path)
if command -v afconvert >/dev/null 2>&1; then
  ok "afconvert available (built-in)"
else
  warn "afconvert not on PATH — whisper.cpp fallback won't work without it"
fi

print -- ""
print -- "Transcription engines:"

# 5. MacWhisper CLI (mw)
mw_bin="$(command -v mw || true)"
mw_runs=0
if [[ -n "$mw_bin" ]]; then
  mw_err="$(mktemp -t mw_doctor.XXXXXX)"
  if "$mw_bin" version >/dev/null 2>"$mw_err"; then
    ok "MacWhisper CLI ($mw_bin) — runs"
    mw_runs=1
  else
    if grep -qiE 'library not loaded|newer than running OS|dyld' "$mw_err"; then
      warn "MacWhisper CLI installed at $mw_bin but won't dyld-load — upstream packaging bug, see docs/troubleshooting.md"
    else
      warn "MacWhisper CLI failed: $(head -n1 "$mw_err")"
    fi
  fi
  rm -f -- "$mw_err"
else
  info "MacWhisper CLI not on PATH (optional if you'll use whisper.cpp instead)"
fi

# 6. whisper.cpp
whisper_runs=0
whisper_bin="$(command -v whisper-cli || true)"
if [[ -n "$whisper_bin" ]]; then
  if [[ -f "$WHISPER_MODEL" ]]; then
    ok "whisper.cpp ($whisper_bin) + model $(basename "$WHISPER_MODEL") — ready"
    whisper_runs=1
  else
    warn "whisper-cli installed but model file not found at $WHISPER_MODEL"
    info "       download with: curl -L -o \"$WHISPER_MODEL\" https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
    info "       (create the dir first: mkdir -p \"\$(dirname \"$WHISPER_MODEL\")\")"
  fi
else
  info "whisper-cli not on PATH (install with: brew install whisper-cpp)"
fi

# 7. ~/bin
if [[ -d "$HOME/bin" ]]; then
  ok "~/bin exists"
else
  info "~/bin not present — install.sh will guide you"
fi

print -- ""
if [[ $mw_runs -eq 1 ]]; then
  ok "Selected engine for auto mode: MacWhisper CLI"
elif [[ $whisper_runs -eq 1 ]]; then
  ok "Selected engine for auto mode: whisper.cpp (fallback)"
else
  fail "No working transcription engine — install MacWhisper CLI or whisper.cpp"
fi

print -- ""
print -- "Summary: $passes passing, $warns warning, $fails failing"

[[ $fails -eq 0 ]]
