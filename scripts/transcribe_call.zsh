#!/bin/zsh
# transcribe_call.zsh — transcribe an audio file and save the result as a
# timestamped .txt under <job_folder>/Call Transcripts/. The transcript is
# also echoed to stdout so a calling macOS Shortcut can append it back into
# the originating Apple Note.
#
# Usage:  transcribe_call.zsh <audio_file> <job_folder>
#
# Engine selection (auto):
#   1. MacWhisper CLI (`mw transcribe`) — preferred when available.
#   2. whisper.cpp (`whisper-cli`) — automatic fallback when `mw` cannot
#      load (e.g. the dyld failure shipped in MacWhisper 13.20).
#
# Force a specific engine with TRANSCRIBE_ENGINE=mw or =whisper-cpp.
#
# Optional environment overrides (also sourced from
# ~/.config/macwhisper-automation/config.env if present):
#   MW_MODEL          MacWhisper model spec, e.g. "apple:en-US"
#   WHISPER_MODEL     Path to a whisper.cpp ggml model
#                     (default: ~/.local/share/whisper-cpp/models/ggml-base.en.bin)
#   WHISPER_LANG      whisper.cpp language code (default: en)

set -euo pipefail

readonly SCRIPT_VERSION="0.2.0"
readonly DEFAULT_WHISPER_MODEL="$HOME/.local/share/whisper-cpp/models/ggml-base.en.bin"

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

config_file="$HOME/.config/macwhisper-automation/config.env"
if [[ -f "$config_file" ]]; then
  # shellcheck disable=SC1090
  source "$config_file"
fi

: "${TRANSCRIBE_ENGINE:=auto}"
: "${WHISPER_MODEL:=$DEFAULT_WHISPER_MODEL}"
: "${WHISPER_LANG:=en}"

# ---- engine probes ----

mw_works() {
  local mw_bin
  mw_bin="$(command -v mw || true)"
  [[ -z "$mw_bin" ]] && return 1
  # `mw version` exits 0 only if the binary loads on this host.
  "$mw_bin" version >/dev/null 2>&1
}

whisper_cli_works() {
  command -v whisper-cli >/dev/null 2>&1 && [[ -f "$WHISPER_MODEL" ]]
}

# ---- pick engine ----

engine=""
case "$TRANSCRIBE_ENGINE" in
  mw)
    if mw_works; then engine=mw
    else err "TRANSCRIBE_ENGINE=mw forced, but mw is not runnable"; exit 1
    fi
    ;;
  whisper-cpp|whispercpp|whisper)
    if whisper_cli_works; then engine=whisper-cpp
    else err "TRANSCRIBE_ENGINE=whisper-cpp forced, but whisper-cli or model file is missing"; exit 1
    fi
    ;;
  auto|"")
    if mw_works; then engine=mw
    elif whisper_cli_works; then engine=whisper-cpp
    else
      err "no working transcription engine. Install one of:"
      err "  - MacWhisper CLI: MacWhisper → Settings → Advanced → Command-Line Tool"
      err "  - whisper.cpp:   brew install whisper-cpp + download a ggml model"
      err "                   (default model path: $DEFAULT_WHISPER_MODEL)"
      exit 127
    fi
    ;;
  *)
    err "unknown TRANSCRIBE_ENGINE: $TRANSCRIBE_ENGINE (use 'auto', 'mw', or 'whisper-cpp')"
    exit 64
    ;;
esac

# ---- filename + output path ----

base="$(basename -- "$audio_file")"
name="${base%.*}"
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

# ---- run engine ----

mw_stderr="$(mktemp -t mw_stderr.XXXXXX)"
tmp_wav=""
trap '[[ -n "$tmp_wav" ]] && rm -f -- "$tmp_wav"; rm -f -- "$mw_stderr"' EXIT INT TERM

transcript=""
engine_label=""

case "$engine" in
  mw)
    engine_label="MacWhisper CLI ($(command -v mw))"
    local_mw="$(command -v mw)"
    mw_args=(transcribe)
    [[ -n "${MW_MODEL:-}" ]] && mw_args+=(--model "$MW_MODEL")
    mw_args+=("$audio_file")
    if ! transcript="$("$local_mw" "${mw_args[@]}" 2>"$mw_stderr")"; then
      if grep -qiE 'library not loaded|newer than running OS|dyld' "$mw_stderr"; then
        err "MacWhisper CLI failed to launch (upstream packaging bug — see docs/troubleshooting.md)."
      else
        err "MacWhisper CLI failed:"
        while IFS= read -r line; do print -u2 -- "  $line"; done < "$mw_stderr"
      fi
      exit 1
    fi
    ;;

  whisper-cpp)
    engine_label="whisper.cpp ($(command -v whisper-cli)) using $(basename -- "$WHISPER_MODEL")"
    if ! command -v afconvert >/dev/null 2>&1; then
      err "afconvert not found — required for audio format conversion"
      exit 127
    fi
    tmp_wav="$(mktemp -t whisper_audio.XXXXXX).wav"
    if ! afconvert -f WAVE -d LEI16@16000 -c 1 "$audio_file" "$tmp_wav" 2>"$mw_stderr"; then
      err "afconvert failed to normalise audio:"
      while IFS= read -r line; do print -u2 -- "  $line"; done < "$mw_stderr"
      exit 1
    fi
    if ! transcript="$(whisper-cli -m "$WHISPER_MODEL" -f "$tmp_wav" -nt -np -l "$WHISPER_LANG" 2>"$mw_stderr")"; then
      err "whisper-cli failed:"
      while IFS= read -r line; do print -u2 -- "  $line"; done < "$mw_stderr"
      exit 1
    fi
    # whisper-cli prefixes a leading space + newline; trim once.
    transcript="${transcript#$'\n'}"
    transcript="${transcript# }"
    ;;
esac

if [[ -z "${transcript//[[:space:]]/}" ]]; then
  err "engine produced an empty transcript for: $audio_file"
  exit 1
fi

{
  print -- "Call Transcript"
  print -- "Source Audio:   $base"
  print -- "Transcribed:    $(date '+%Y-%m-%d %H:%M:%S')"
  print -- "Engine:         $engine_label"
  if [[ "$engine" == mw && -n "${MW_MODEL:-}" ]]; then
    print -- "Model:          $MW_MODEL"
  fi
  print -- "Script Version: $SCRIPT_VERSION"
  print -- ""
  print -- "$transcript"
} > "$out_file"

print -- "$transcript"
print -u2 -- "transcribe_call: saved $out_file"
