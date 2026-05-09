# Visual Assets

The repo uses real AI-generated raster assets for the README and repository presentation.
Assets are intentionally generic: no Apple logos, MacWhisper branding, real transcripts, customer names, job addresses, phone numbers, or local machine paths.

## Inventory

| Asset | Size | Format | Used in | Purpose |
| --- | ---: | --- | --- | --- |
| `assets/images/hero-macwhisper-notes-transcription.png` | 1600x900 | PNG | `README.md` | Main hero image |
| `assets/images/hero-macwhisper-notes-transcription.webp` | 1600x900 | WebP | `README.md` | Lightweight hero source |
| `assets/images/social-preview.png` | 1280x640 | PNG | `README.md`, GitHub social preview candidate | Repo preview image |
| `assets/images/social-preview.webp` | 1280x640 | WebP | `README.md` | Lightweight social preview source |
| `assets/icons/app-icon.png` | 1024x1024 | PNG | `README.md` | Repo/app identity mark |
| `assets/icons/apple-notes-audio.png` | 512x512 | PNG | `README.md` | Audio export feature |
| `assets/icons/macwhisper-cli.png` | 512x512 | PNG | `README.md` | Transcription engine feature |
| `assets/icons/job-folder-transcript.png` | 512x512 | PNG | `README.md` | Job-folder transcript feature |
| `assets/icons/shortcut-automation.png` | 512x512 | PNG | `README.md` | Shortcut automation feature |
| `assets/prompts/image-generation-prompts.md` | n/a | Markdown | Asset source doc | Exact generation prompts |

## Generation Summary

The images were generated as premium macOS automation visuals: dark navy/charcoal background, subtle glassmorphism, warm amber and teal accents, generic notes/audio/transcript/folder concepts, and realistic UI mockup polish.

See [`assets/prompts/image-generation-prompts.md`](../assets/prompts/image-generation-prompts.md) for the exact prompts.

## Regeneration

1. Generate fresh raster PNGs using the prompts in `assets/prompts/image-generation-prompts.md`.
2. Copy the selected outputs into `assets/images/` and `assets/icons/`.
3. Normalize dimensions:
   ```sh
   magick input-hero.png -resize '1600x900^' -gravity center -extent 1600x900 -strip assets/images/hero-macwhisper-notes-transcription.png
   magick input-social.png -resize '1280x640^' -gravity center -extent 1280x640 -strip assets/images/social-preview.png
   magick input-app-icon.png -resize 1024x1024 -strip assets/icons/app-icon.png
   magick input-feature.png -resize 512x512 -strip assets/icons/<name>.png
   cwebp -quiet -q 88 assets/images/hero-macwhisper-notes-transcription.png -o assets/images/hero-macwhisper-notes-transcription.webp
   cwebp -quiet -q 88 assets/images/social-preview.png -o assets/images/social-preview.webp
   ```
4. Run:
   ```sh
   ./scripts/check_readme_assets.sh
   ```

## Privacy Rules

- Do not use screenshots containing real recordings, transcripts, Notes content, job folders, customer names, addresses, phone numbers, or local paths.
- Do not commit source recordings or generated transcript `.txt` files.
- Keep the visuals generic and synthetic.
- Avoid copyrighted logos and exact third-party branding.
- If a screenshot is ever needed, use a disposable mock account and fake text only.

