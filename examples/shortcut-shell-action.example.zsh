#!/bin/zsh
# Drop-in body for the macOS Shortcut's "Run Shell Script" action.
#
# Shortcut wiring (see docs/shortcut-workflow.md):
#   * Pass input: as arguments        →  $1 receives the audio file path
#   * Replace JOB_FOLDER below with the magic variable from "Ask for Folder"
#
# Tip: keep this script on your PATH (e.g. ~/bin/transcribe_call.zsh) so the
# Shortcut doesn't break if you move the repo.

"$HOME/bin/transcribe_call.zsh" "$1" "$JOB_FOLDER"
