#!/bin/zsh
# install.sh — make scripts executable, sanity-check the host, and print next steps.
# No sudo required.

set -euo pipefail

repo_root="${0:A:h:h}"
cd -- "$repo_root"

print -- "==> Setting executable bits on scripts/"
chmod +x scripts/*.zsh scripts/*.sh

print -- ""
print -- "==> Running doctor"
"$repo_root/scripts/doctor.sh" || true

print -- ""
print -- "==> Recommended next steps"
print -- "  1. For a full local install, including the ~/bin symlink, run:"
print -- "       ./scripts/install-local.sh"
print -- ""
print -- "  2. Build the macOS Shortcut following docs/shortcut-workflow.md."
print -- ""
print -- "  3. Smoke-test the local workflow:"
print -- "       ./scripts/smoke_test_local.sh"
print -- ""
print -- "  4. (Optional) Set defaults at ~/.config/macwhisper-automation/config.env"
print -- "     using examples/config.example.env as a template."
