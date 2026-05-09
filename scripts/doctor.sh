#!/bin/zsh
# doctor.sh — verify the host can actually run the workflow.
# Prints a PASS/FAIL summary and exits non-zero if anything is broken.

set -uo pipefail

passes=0
fails=0

ok()   { print -- "  [ OK ]  $*"; passes=$((passes+1)); }
fail() { print -- "  [FAIL]  $*"; fails=$((fails+1)); }

print -- "MacWhisper Automation — doctor"
print -- ""

# 1. macOS check
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

# 3. mw binary present
mw_bin="$(command -v mw || true)"
if [[ -n "$mw_bin" ]]; then
  ok "mw on PATH: $mw_bin"

  # 4. mw actually runnable
  mw_err="$(mktemp -t mw_doctor.XXXXXX)"
  if "$mw_bin" version >/dev/null 2>"$mw_err"; then
    ok "mw responds to 'mw version'"
  else
    if grep -qiE 'library not loaded|newer than running OS|dyld' "$mw_err"; then
      fail "mw is installed but won't launch on this macOS version. Install a MacWhisper build matching your macOS, or upgrade macOS. See docs/troubleshooting.md"
    else
      fail "mw failed: $(head -n1 "$mw_err")"
    fi
  fi
  rm -f -- "$mw_err"
else
  fail "mw not on PATH — enable via MacWhisper → Settings → Advanced → Command-Line Tool"
fi

# 5. Shortcuts.app
if [[ -d "/System/Applications/Shortcuts.app" || -d "/Applications/Shortcuts.app" ]]; then
  ok "Shortcuts.app installed"
else
  fail "Shortcuts.app not found"
fi

# 6. ~/bin
if [[ -d "$HOME/bin" ]]; then
  ok "~/bin exists"
else
  print -- "  [INFO]  ~/bin not present — run install.sh to create a symlink target"
fi

print -- ""
print -- "Summary: $passes passing, $fails failing"

[[ $fails -eq 0 ]]
