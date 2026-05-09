#!/bin/zsh
# install.sh — make scripts executable, sanity-check the host, and print next steps.
# No sudo required.

set -euo pipefail

repo_root="${0:A:h:h}"
cd -- "$repo_root"

print -- "==> Setting executable bits on scripts/"
chmod +x scripts/transcribe_call.zsh scripts/install.sh scripts/doctor.sh

print -- ""
print -- "==> Running doctor"
"$repo_root/scripts/doctor.sh" || true

print -- ""
print -- "==> Recommended next steps"
print -- "  1. Symlink the script onto your PATH so the macOS Shortcut can invoke it cleanly:"
print -- "       mkdir -p ~/bin"
print -- "       ln -sfn \"$repo_root/scripts/transcribe_call.zsh\" ~/bin/transcribe_call.zsh"
print -- "       (ensure ~/bin is on your PATH; add to ~/.zprofile if not already)"
print -- ""
print -- "  2. Build the macOS Shortcut following docs/shortcut-workflow.md."
print -- ""
print -- "  3. (Optional) Set defaults at ~/.config/macwhisper-automation/config.env"
print -- "     using examples/config.example.env as a template."
