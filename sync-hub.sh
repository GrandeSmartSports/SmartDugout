#!/bin/bash
# ============================================================
# sync-hub.sh — Sync Project Hub files from Alex to GitHub repo
# ============================================================
# Usage: ./sync-hub.sh [--dry-run] [--force]
#
# Alex (Claude Chat) exports hub files to ~/Desktop/files/
# This script syncs them into the SmartDugout repo, commits,
# and pushes to GitHub.
#
# Files synced from Alex:
#   PROJECT_HUB.md, VISION.md, DECISIONS.md, QUICK_START.md,
#   OWNER_NOTES.md, SETUP_DEV.md, SETUP_OPI.md
#
# Special handling:
#   TASKS.md    — Both Alex and Dev update this. Script shows diff
#                 and asks before overwriting.
#   DASHBOARD.html — Repo has custom version. Alex's template is
#                    skipped unless --force is used.
# ============================================================

set -e

REPO_DIR="$HOME/Projects/SmartDugout"
SOURCE_DIR="$HOME/Desktop/files"
DRY_RUN=false
FORCE=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --force)   FORCE=true ;;
  esac
done

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  SmartDugout — Hub Sync${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo -e "${RED}ERROR: Source directory not found: $SOURCE_DIR${NC}"
  echo "Make sure Alex's files are saved to ~/Desktop/files/"
  exit 1
fi

# Check repo directory exists
if [ ! -d "$REPO_DIR/.git" ]; then
  echo -e "${RED}ERROR: Repo not found at: $REPO_DIR${NC}"
  exit 1
fi

cd "$REPO_DIR"

# Files that Alex owns (safe to overwrite)
ALEX_FILES=(
  "PROJECT_HUB.md"
  "VISION.md"
  "DECISIONS.md"
  "QUICK_START.md"
  "OWNER_NOTES.md"
  "SETUP_DEV.md"
  "SETUP_OPI.md"
)

# Track what changed
CHANGED=0
SKIPPED=0

echo -e "${YELLOW}Source:${NC} $SOURCE_DIR"
echo -e "${YELLOW}Repo:${NC}   $REPO_DIR"
echo ""

# Sync Alex-owned files
for file in "${ALEX_FILES[@]}"; do
  src="$SOURCE_DIR/$file"
  dest="$REPO_DIR/$file"

  if [ ! -f "$src" ]; then
    echo -e "  ${YELLOW}SKIP${NC} $file (not in source)"
    ((SKIPPED++))
    continue
  fi

  if [ -f "$dest" ] && diff -q "$src" "$dest" > /dev/null 2>&1; then
    echo -e "  ${GREEN}OK${NC}   $file (no changes)"
    continue
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${BLUE}WOULD COPY${NC} $file"
    if [ -f "$dest" ]; then
      diff --brief "$src" "$dest" 2>/dev/null || true
    fi
  else
    cp "$src" "$dest"
    echo -e "  ${GREEN}COPIED${NC} $file"
  fi
  ((CHANGED++))
done

# Handle TASKS.md specially (both Alex and Dev edit it)
echo ""
TASKS_SRC="$SOURCE_DIR/TASKS.md"
TASKS_DEST="$REPO_DIR/TASKS.md"

if [ -f "$TASKS_SRC" ]; then
  if [ -f "$TASKS_DEST" ] && diff -q "$TASKS_SRC" "$TASKS_DEST" > /dev/null 2>&1; then
    echo -e "  ${GREEN}OK${NC}   TASKS.md (no changes)"
  else
    echo -e "${YELLOW}  TASKS.md has differences (both Alex and Dev edit this):${NC}"
    if [ -f "$TASKS_DEST" ]; then
      echo "  --- Repo version vs Alex's version ---"
      diff "$TASKS_DEST" "$TASKS_SRC" | head -30 || true
      echo ""
    fi

    if [ "$FORCE" = true ]; then
      if [ "$DRY_RUN" = false ]; then
        cp "$TASKS_SRC" "$TASKS_DEST"
        echo -e "  ${GREEN}COPIED${NC} TASKS.md (--force)"
      else
        echo -e "  ${BLUE}WOULD COPY${NC} TASKS.md (--force)"
      fi
      ((CHANGED++))
    else
      echo -e "  ${YELLOW}SKIPPED${NC} TASKS.md — review manually or use --force"
      echo "  (Repo version may have Dev's updates that Alex doesn't have yet)"
      ((SKIPPED++))
    fi
  fi
fi

# Handle DASHBOARD.html (repo has custom version)
echo ""
DASH_SRC="$SOURCE_DIR/DASHBOARD.html"
DASH_DEST="$REPO_DIR/DASHBOARD.html"

if [ -f "$DASH_SRC" ]; then
  if [ "$FORCE" = true ]; then
    if [ "$DRY_RUN" = false ]; then
      cp "$DASH_SRC" "$DASH_DEST"
      echo -e "  ${GREEN}COPIED${NC} DASHBOARD.html (--force)"
    else
      echo -e "  ${BLUE}WOULD COPY${NC} DASHBOARD.html (--force)"
    fi
    ((CHANGED++))
  else
    echo -e "  ${YELLOW}SKIPPED${NC} DASHBOARD.html — repo has custom version"
    echo "  (Use --force to overwrite with Alex's template)"
    ((SKIPPED++))
  fi
fi

# Summary
echo ""
echo -e "${BLUE}────────────────────────────────────${NC}"
echo -e "  Changed: ${GREEN}$CHANGED${NC}  Skipped: ${YELLOW}$SKIPPED${NC}"
echo -e "${BLUE}────────────────────────────────────${NC}"

if [ "$DRY_RUN" = true ]; then
  echo ""
  echo -e "${YELLOW}DRY RUN — no files were changed. Remove --dry-run to apply.${NC}"
  exit 0
fi

# Git operations
if [ $CHANGED -gt 0 ]; then
  echo ""
  echo -e "${BLUE}Staging and committing...${NC}"

  git add -A
  git commit -m "Sync hub files from Alex — $(date '+%b %d, %Y')"
  git push

  echo ""
  echo -e "${GREEN}Done! Changes pushed to GitHub.${NC}"
else
  echo ""
  echo -e "${GREEN}Everything is already in sync. Nothing to commit.${NC}"
fi

echo ""
