# Development Workflows

This repo is public, local-first, and privacy-sensitive. Future work should keep the automation useful without letting recordings, transcripts, customer names, or local paths drift into git.

## Useful Local ESS Skills

### `notes-calls-project-sync`

Use as the v0.4 roadmap reference, not as code to port wholesale yet.

Relevant ideas:

- Read Notes call recordings only through explicit, opt-in project sync.
- Maintain per-project state so sync is incremental.
- Prefer existing iOS auto-transcripts when present.
- Fall back to local transcribers when audio lacks a transcript.
- Write curated markdown under project docs, never raw audio.
- Keep `.notes-calls-sync/` and any raw exports out of git.

For this repo, the v0.4 shape should be an optional project-sync mode that is clearly separate from the current Share Sheet workflow.

### `github-readme-polisher`

Use when changing README presentation. Its most important rule applies here: every badge, command, image, compatibility claim, and feature statement must be verifiable from repo files or GitHub state.

### `github-repo-bootstrap`

Use as a standards reference for public-repo hygiene: issue templates, security policy, CODEOWNERS, release workflow, CI, privacy guardrails, and careful defaults.

## Development Loop

Before committing a meaningful change:

```sh
./scripts/check_readme_assets.sh
./scripts/privacy_guard.sh
./scripts/doctor.sh
zsh -n scripts/*.sh scripts/*.zsh
```

For local behavior changes, also run:

```sh
./scripts/smoke_test_local.sh
```

## Privacy Rules

- Do not commit audio recordings.
- Do not commit generated transcript `.txt` files.
- Do not commit customer names, addresses, phone numbers, or local job-folder paths.
- Do not add screenshots that contain real Notes content.
- Use fake data in docs and generated visuals.

