# Dev Workflow Guide

Reference for all development processes on SmartDugout.

## Project Structure

```
~/Projects/SmartDugout/          <- Git repo (main project)
  index.html                     <- The app (single HTML file)
  sw.js                          <- Service worker for offline
  dashboard.html                 <- Dev command center (dark theme)
  DASHBOARD.html                 <- Alex's project management dashboard
  PROJECT_HUB.md                 <- Hub landing page
  VISION.md                      <- Strategy and goals
  TASKS.md                       <- Task tracking
  DECISIONS.md                   <- Decision log
  QUICK_START.md                 <- Quick reference
  OWNER_NOTES.md                 <- Owner scratchpad
  SETUP_DEV.md                   <- Dev onboarding
  SETUP_OPI.md                   <- Opi onboarding
  HUB_SYNC.md                    <- Hub sync documentation
  DEV_WORKFLOW.md                <- This file
  sync-hub.sh                    <- Script: sync hub from Alex
  dev.sh                         <- Script: dev helper commands
  research/                      <- Research docs (TBD)
  business-plan/                 <- Business plan (TBD)

~/Desktop/softball-deploy/       <- Surge.sh deploy folder
  index.html                     <- Copy of app for deploy
  sw.js                          <- Copy of service worker
  node_modules/                  <- Local surge installation

~/Desktop/softball.html          <- Legacy original (keep as backup)
~/Desktop/files/                 <- Alex's hub file drop zone
```

## Quick Commands

```bash
# Dev helper (run from repo root)
./dev.sh serve      # Start local server on port 8080
./dev.sh deploy     # Prep files for surge deploy
./dev.sh sync       # Sync hub files from Alex
./dev.sh status     # Git status + recent commits
./dev.sh open       # Open app in browser

# Hub sync (run from repo root)
./sync-hub.sh               # Sync Alex's files to repo
./sync-hub.sh --dry-run     # Preview changes only
./sync-hub.sh --force       # Also overwrite TASKS.md
```

## Development Flow

### Making Changes to the App

1. Edit `index.html` in the repo
2. Test locally: `./dev.sh serve` then open `http://localhost:8080`
3. Commit: `git add index.html && git commit -m "description"`
4. Push: `git push`
5. Deploy: `./dev.sh deploy` then run surge in a separate terminal

### Deploying to Production

The app is hosted at **https://softball-eval.surge.sh**

```bash
# 1. Copy latest files to deploy folder
./dev.sh deploy

# 2. In a separate terminal, run surge
cd ~/Desktop/softball-deploy
npx surge . softball-eval.surge.sh
```

Surge requires interactive login so it must be run from a real terminal, not from Claude Code.

### Syncing Hub Files from Alex

When Alex (Claude Chat) updates hub documentation:

1. Alex saves files to `~/Desktop/files/`
2. Run `./sync-hub.sh` (or `./dev.sh sync`)
3. Script copies, commits, and pushes automatically

See `HUB_SYNC.md` for full details.

## Key Technical Details

- **Single-file app**: All HTML, CSS, and JS in `index.html`
- **Data storage**: localStorage with key `sdb3`
- **Offline**: Service worker (`sw.js`) with network-first caching
- **PWA**: iOS "Add to Home Screen" supported via meta tags
- **HTTPS required**: Service workers only work over HTTPS (surge.sh)
- **Font**: Inter from Google Fonts
- **No build tools**: No webpack, no npm for the app itself

## Git Conventions

- Commit messages: short, descriptive, present tense
- Hub syncs get automatic message: "Sync hub files from Alex — [date]"
- Push to `main` branch (no branching needed yet)
- Never force push

## Important Paths

| What | Where |
|------|-------|
| App source | `~/Projects/SmartDugout/index.html` |
| Live app | https://softball-eval.surge.sh |
| GitHub repo | https://github.com/GrandeSmartSports/SmartDugout |
| Alex's files | `~/Desktop/files/` |
| Deploy folder | `~/Desktop/softball-deploy/` |
| Legacy backup | `~/Desktop/softball.html` |

## Resume Notes for Future Dev

If you're picking up where the last Dev session left off:

1. Read TASKS.md for assigned work
2. Run `./dev.sh status` to see where things stand
3. Run `./dev.sh sync` to get latest hub files from Alex
4. Check this file and HUB_SYNC.md for process info
5. Commit early, commit often, leave breadcrumbs
