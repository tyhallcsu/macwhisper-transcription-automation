#!/bin/zsh
# End-to-end local smoke test. Generates disposable audio with `say`, runs the
# transcription script, and confirms a .txt transcript lands in /tmp/test-job.

set -euo pipefail
setopt null_glob

repo_root="${0:A:h:h}"
cd -- "$repo_root"

audio_file="/tmp/macwhisper-transcription-smoke.aiff"
job_dir="${SMOKE_JOB_DIR:-/tmp/test-job}"

print -- "==> Creating disposable test audio"
rm -f -- "$audio_file"
rm -rf -- "$job_dir"
mkdir -p "$job_dir"
say -o "$audio_file" "this is a local smoke test for call transcription automation"

print -- "==> Running transcribe_call.zsh"
out="$("$repo_root/scripts/transcribe_call.zsh" "$audio_file" "$job_dir")"
print -- "$out"

if [[ -z "${out//[[:space:]]/}" ]]; then
  print -u2 -- "smoke_test_local: transcribe_call.zsh produced empty stdout"
  exit 1
fi

files=( "$job_dir/Call Transcripts"/*.txt )
if [[ ${#files[@]} -eq 0 ]]; then
  print -u2 -- "smoke_test_local: no transcript file written under $job_dir/Call Transcripts"
  exit 1
fi

print -- ""
print -- "==> Transcript file"
print -- "${files[1]}"
sed -n '1,12p' "${files[1]}"

rm -f -- "$audio_file"
print -- ""
print -- "smoke_test_local: OK"
