#!/bin/zsh
# Fail if git is tracking or staging files that are likely to contain private
# call recordings, transcripts, credentials, or customer/job data.

set -euo pipefail

repo_root="${0:A:h:h}"
cd -- "$repo_root"

tmp_paths="$(mktemp -t mw_privacy_paths.XXXXXX)"
tmp_bad="$(mktemp -t mw_privacy_bad.XXXXXX)"
tmp_secret_hits="$(mktemp -t mw_privacy_secret_hits.XXXXXX)"
trap 'rm -f -- "$tmp_paths" "$tmp_bad" "$tmp_secret_hits"' EXIT INT TERM

{
  git ls-files
  git diff --cached --name-only --diff-filter=ACMRT
} | sort -u > "$tmp_paths"

is_allowed_path() {
  case "$1" in
    examples/config.example.env) return 0 ;;
    *) return 1 ;;
  esac
}

is_forbidden_path() {
  local filepath="$1"

  is_allowed_path "$filepath" && return 1

  case "$filepath" in
    *.m4a|*.mp3|*.wav|*.aiff|*.aac|*.flac|*.ogg|*.mp4|*.mov|*.transcript|*.log) return 0 ;;
    *.env|*.env.*) return 0 ;;
    *.key|*.pem|*.p12|*.pfx|*.jks|*.keystore|*.ppk|*.mobileconfig|*.gpg|*.asc|*.htpasswd) return 0 ;;
    id_rsa|id_rsa.pub|id_ed25519|id_ed25519.pub|id_dsa|id_dsa.pub|id_ecdsa|id_ecdsa.pub) return 0 ;;
    */id_rsa|*/id_rsa.pub|*/id_ed25519|*/id_ed25519.pub|*/id_dsa|*/id_dsa.pub|*/id_ecdsa|*/id_ecdsa.pub) return 0 ;;
    private/*|*/private/*|exports/*|*/exports/*|transcripts/*|*/transcripts/*) return 0 ;;
    "Call Transcripts"/*|*/"Call Transcripts"/*) return 0 ;;
    secrets/*|*/secrets/*|credentials/*|*/credentials/*|passwords/*|*/passwords/*) return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r filepath; do
  [[ -z "$filepath" ]] && continue
  if is_forbidden_path "$filepath"; then
    print -- "$filepath" >> "$tmp_bad"
  fi
done < "$tmp_paths"

if [[ -s "$tmp_bad" ]]; then
  print -u2 -- "privacy_guard: forbidden private/sensitive paths are tracked or staged:"
  sed 's/^/  - /' "$tmp_bad" >&2
  exit 1
fi

# A narrow high-confidence content scan for secrets. This intentionally avoids
# broad "password" matching so docs can discuss security without false alarms.
while IFS= read -r filepath; do
  [[ -z "$filepath" || ! -f "$filepath" ]] && continue
  is_allowed_path "$filepath" && continue

  if LC_ALL=C grep -Iq . "$filepath"; then
    LC_ALL=C grep -nE \
      'gh[opsu]_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|DSA|EC|PRIVATE) KEY' \
      "$filepath" >> "$tmp_secret_hits" || true
  fi
done < "$tmp_paths"

if [[ -s "$tmp_secret_hits" ]]; then
  print -u2 -- "privacy_guard: high-confidence secret-looking content found:"
  sed 's/^/  /' "$tmp_secret_hits" >&2
  exit 1
fi

print -- "privacy_guard: OK - no forbidden private paths or high-confidence secrets tracked/staged"
