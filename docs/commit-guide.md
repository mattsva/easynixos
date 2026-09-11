# Commit guide

This repository uses a short, consistent commit style.

## Message format

Use this pattern:

<area>: <summary>

Examples:

- `<installer>: <add hostname and keyboard prompts>`
- `<bindings>: <open launcher and clipboard history with Super keys>`
- `<hardening>: <fix security hardening configuration>`

Keep the subject short and specific. Prefer one sentence in the imperative mood.

## Typical workflow

1. Check the branch state:
   ```bash
   git status
   git --no-pager log --oneline --decorate -n 12
   ```
2. Stage only the files for this change:
   ```bash
   git add <files>
   ```
3. Commit with the repository style:
   ```bash
   git commit -m '<area>: <summary>'
   ```
4. Push when ready:
   ```bash
   git push origin main
   ```

## Good commit examples

- `<installer>: <add current version banner>`
- `<docs>: <document commit workflow>`
- `<system>: <fix rebuild permissions before switch>`

## Notes

- Keep commits focused on one topic.
- Do not mix unrelated fixes in a single commit.
- If a fix touches the installer, the rebuild flow, or config generation, explain the reason in the commit summary.
