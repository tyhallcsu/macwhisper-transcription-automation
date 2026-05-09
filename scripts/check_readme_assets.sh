#!/bin/zsh
# Verify that local image references in README.md point to committed files.

set -euo pipefail

repo_root="${0:A:h:h}"
readme="$repo_root/README.md"

if [[ ! -f "$readme" ]]; then
  print -u2 -- "check_readme_assets: README.md not found"
  exit 1
fi

tmp_refs="$(mktemp -t readme_image_refs.XXXXXX)"
trap 'rm -f -- "$tmp_refs"' EXIT INT TERM

# Markdown images: ![alt](path)
grep -Eo '!\[[^]]*\]\([^)]+\)' "$readme" \
  | sed -E 's/^!\[[^]]*\]\(([^)]+)\)$/\1/' >> "$tmp_refs" || true

# HTML image/source tags: src="path" and srcset="path"
grep -Eo '(src|srcset)="[^"]+"' "$readme" \
  | sed -E 's/^(src|srcset)="([^"]+)".*$/\2/' \
  | awk '{print $1}' >> "$tmp_refs" || true

sort -u "$tmp_refs" -o "$tmp_refs"

missing=0
checked=0

while IFS= read -r ref; do
  [[ -z "$ref" ]] && continue
  case "$ref" in
    http://*|https://*|mailto:*|\#*) continue ;;
  esac

  # Strip an optional anchor/query if someone adds cache-busting later.
  clean_ref="${ref%%\#*}"
  clean_ref="${clean_ref%%\?*}"

  checked=$((checked + 1))
  if [[ -f "$repo_root/$clean_ref" ]]; then
    print -- "[ OK ] $clean_ref"
  else
    print -u2 -- "[MISS] $clean_ref"
    missing=$((missing + 1))
  fi
done < "$tmp_refs"

if [[ "$missing" -gt 0 ]]; then
  print -u2 -- "check_readme_assets: $missing missing README image asset(s)"
  exit 1
fi

print -- "check_readme_assets: checked $checked local README image asset(s); all present"

