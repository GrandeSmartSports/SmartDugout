# Hub Sync Process

How to sync Project Hub files from Alex (Claude Chat) to the GitHub repo.

## Quick Version

```bash
# Preview what would change (safe, changes nothing)
./sync-hub.sh --dry-run

# Sync Alex's files to repo, commit, and push
./sync-hub.sh
```

## How It Works

1. Alex exports hub files to `~/Desktop/files/`
2. Run `sync-hub.sh` from the repo
3. Script copies updated files, commits, and pushes

## File Ownership

| File | Owner | Notes |
|------|-------|-------|
| PROJECT_HUB.md | Alex | Always overwritten from source |
| VISION.md | Alex | Always overwritten from source |
| DECISIONS.md | Alex | Always overwritten from source |
| QUICK_START.md | Alex | Always overwritten from source |
| OWNER_NOTES.md | Alex | Always overwritten from source |
| SETUP_DEV.md | Alex | Always overwritten from source |
| SETUP_OPI.md | Alex | Always overwritten from source |
| TASKS.md | Both | Skipped by default — Dev and Alex both edit. Use `--force` to overwrite. |
| DASHBOARD.html | Dev | Repo has custom version. Alex's template is skipped. Use `--force` to overwrite. |

## Flags

- `--dry-run` — Show what would change without modifying anything
- `--force` — Also overwrite TASKS.md and DASHBOARD.html

## When to Run

Run this script whenever:
- Alex says hub files have been updated
- Starting a new Dev session and want latest docs
- Owner says "sync the hub"

## Handling TASKS.md Conflicts

Both Alex and Dev update TASKS.md. When they diverge:
1. Run `./sync-hub.sh --dry-run` to see the diff
2. Manually merge if needed, or use `--force` to take Alex's version
3. Dev's updates (task completion, progress notes) should generally be preserved
