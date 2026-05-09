#!/bin/zsh
# transcribe_call.zsh — transcribe an audio file with the MacWhisper CLI (`mw`)
# and save the result as a timestamped .txt under <job_folder>/Call Transcripts/.
# The transcript is also echoed to stdout so a calling macOS Shortcut can
# append it back into the originating Apple Note.
#
# Usage:  transcribe_call.zsh <audio_file> <job_folder>
#
# Optional environment overrides (or sourced from ~/.config/macwhisper-automation/config.env):
#   MW_MODEL  e.g. "apple:en-US"   passed as --model to mw
#   MW_LANG   reserved for future use
#
# Exits non-zero with a single-line stderr message on any failure so the
# Shortcut surfaces the error to the user.

set -euo pipefail

readonly SCRIPT_VERSION="0.1.0"

err() { print -u2 -- "transcribe_call: $*"; }

audio_file="${1:-}"
job_folder="${2:-}"

if [[ -z "$audio_file" || -z "$job_folder" ]]; then
  err "usage: transcribe_call.zsh <audio_file> <job_folder>"
  exit 64
fi

if [[ ! -f "$audio_file" ]]; then
  err "audio file not found: $audio_file"
  exit 66
fi

if [[ ! -d "$job_folder" ]]; then
  err "job folder not found: $job_folder"
  exit 66
fi

# Optional config file (never committed)
config_file="$HOME/.config/macwhisper-automation/config.env"
if [[ -f "$config_file" ]]; then
  # shellcheck disable=SC1090
  source "$config_file"
fi

mw_bin="$(command -v mw || true)"
if [[ -z "$mw_bin" ]]; then
  err "MacWhisper CLI 'mw' not found on PATH. Install via MacWhisper → Settings → Advanced → Command-Line Tool."
  exit 127
fi

# Build mw args
mw_args=(transcribe)
if [[ -n "${MW_MODEL:-}" ]]; then
  mw_args+=(--model "$MW_MODEL")
fi
mw_args+=("$audio_file")

# Filename sanitisation
base="$(basename -- "$audio_file")"
name="${base%.*}"
# Strip path-hostile chars and control chars; collapse whitespace runs.
safe_name="$(printf '%s' "$name" \
  | tr -d '\000-\037' \
  | sed -E 's#[/\\:*?"<>|]+#-#g' \
  | tr -s ' ' ' ' \
  | sed -E 's/^ +| +$//g')"
[[ -z "$safe_name" ]] && safe_name="call-recording"

stamp="$(date '+%Y-%m-%d %H.%M.%S')"
out_dir="$job_folder/Call Transcripts"
out_file="$out_dir/$stamp - $safe_name.txt"

mkdir -p -- "$out_dir"

# Run mw, capturing stderr separately so we can detect the macOS-version dyld failure.
mw_stderr="$(mktemp -t mw_stderr.XXXXXX)"
trap 'rm -f -- "$mw_stderr"' EXIT INT TERM

if ! mw_output="$("$mw_bin" "${mw_args[@]}" 2>"$mw_stderr")"; then
  if grep -qiE 'library not loaded|newer than running OS|dyld' "$mw_stderr"; then
    err "MacWhisper CLI failed to launch — installed MacWhisper appears built for a newer macOS than this host. See docs/troubleshooting.md."
  else
    err "MacWhisper CLI failed:"
    while IFS= read -r line; do print -u2 -- "  $line"; done < "$mw_stderr"
  fi
  exit 1
fi

if [[ -z "${mw_output//[[:space:]]/}" ]]; then
  err "MacWhisper produced an empty transcript for: $audio_file"
  exit 1
fi

{
  print -- "MacWhisper Transcript"
  print -- "Source Audio:  $base"
  print -- "Transcribed:   $(date '+%Y-%m-%d %H:%M:%S')"
  if [[ -n "${MW_MODEL:-}" ]]; then
    print -- "Model:         $MW_MODEL"
  fi
  print -- "Script Version: $SCRIPT_VERSION"
  print -- ""
  print -- "$mw_output"
} > "$out_file"

# Echo just the transcript text on stdout for the Shortcut to append into Notes.
print -- "$mw_output"

# Helpful for terminal users; ignored by Shortcuts when stdout is captured.
print -u2 -- "transcribe_call: saved $out_file"
