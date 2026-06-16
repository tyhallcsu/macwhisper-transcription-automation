# Contributing

This repo is public and privacy-sensitive. Keep changes small, reviewable, and free of customer data.

## Workflow

1. Branch per change (`feat/short-description`, `fix/short-description`, `docs/...`).
2. Make a small, focused diff.
3. Commit with a conventional-style subject:
   - `feat: add watch-folder mode`
   - `fix: handle filenames with colons`
   - `docs: clarify Shortcut wiring`
4. Push to GitHub and open a PR (or squash-merge directly if you're the only contributor).
5. Update `README.md` and the relevant `docs/*.md` whenever behavior changes.
6. Bump `CHANGELOG.md` for anything user-visible.

## Privacy rules — non-negotiable

The following must **never** be committed:

- Audio recordings (`*.m4a`, `*.mp3`, `*.wav`, etc.)
- Transcript files (`*.txt` produced by the script, `*.transcript`)
- Customer or job names, addresses, phone numbers, email addresses
- Tokens, API keys, passwords, OAuth secrets
- Absolute home paths (`/Users/<your-name>/...`) — use `$HOME` or generic placeholders in examples
- Anything inside a `Call Transcripts/`, `exports/`, `private/`, or `local/` folder

Before every commit:

```bash
git status
git diff --cached
./scripts/privacy_guard.sh
```

If something private slipped in:

```bash
git rm --cached <file>
echo '<pattern>' >> .gitignore
git commit -m "fix: stop tracking private file"
```

For history rewriting (only if a secret was committed): use `git filter-repo` and rotate the secret immediately.

## Style

- zsh scripts: `set -euo pipefail`, quote every variable, use `command -v` over hardcoded paths.
- Shell errors go to stderr, transcripts go to stdout, exit codes are meaningful.
- Markdown: one sentence per line is fine; wrap at ~100 chars.
