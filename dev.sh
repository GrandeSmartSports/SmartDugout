#!/bin/bash
# ============================================================
# dev.sh — SmartDugout development helper
# ============================================================
# Usage:
#   ./dev.sh serve     Start local dev server (port 8080)
#   ./dev.sh deploy    Deploy to surge.sh (softball-eval.surge.sh)
#   ./dev.sh sync      Run hub sync from Alex's files
#   ./dev.sh status    Show git status + last 5 commits
#   ./dev.sh open      Open the app in default browser
# ============================================================

set -e

REPO_DIR="$HOME/Projects/SmartDugout"
DEPLOY_DIR="$HOME/Desktop/softball-deploy"
SURGE_DOMAIN="softball-eval.surge.sh"
PORT=8080

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

cd "$REPO_DIR"

case "${1:-help}" in

  serve)
    echo -e "${BLUE}Starting local dev server on port $PORT...${NC}"
    echo -e "Open: ${GREEN}http://localhost:$PORT${NC}"
    echo -e "Press Ctrl+C to stop"
    echo ""
    python3 -m http.server "$PORT"
    ;;

  deploy)
    echo -e "${BLUE}Deploying to $SURGE_DOMAIN...${NC}"
    echo ""

    # Copy latest files to deploy folder
    cp "$REPO_DIR/index.html" "$DEPLOY_DIR/index.html"
    cp "$REPO_DIR/sw.js" "$DEPLOY_DIR/sw.js"

    echo -e "${GREEN}Files copied to deploy folder.${NC}"
    echo ""
    echo -e "${YELLOW}Run this in a separate terminal:${NC}"
    echo ""
    echo "  cd ~/Desktop/softball-deploy && npx surge . $SURGE_DOMAIN"
    echo ""
    echo -e "(Surge requires interactive login — can't run from Claude Code)"
    ;;

  sync)
    echo -e "${BLUE}Running hub sync...${NC}"
    "$REPO_DIR/sync-hub.sh" "${@:2}"
    ;;

  status)
    echo -e "${BLUE}SmartDugout — Status${NC}"
    echo ""
    echo -e "${YELLOW}Branch:${NC}"
    git branch --show-current
    echo ""
    echo -e "${YELLOW}Last 5 commits:${NC}"
    git log --oneline -5
    echo ""
    echo -e "${YELLOW}Working tree:${NC}"
    git status --short
    if [ -z "$(git status --porcelain)" ]; then
      echo -e "  ${GREEN}Clean${NC}"
    fi
    echo ""
    echo -e "${YELLOW}Live app:${NC} https://$SURGE_DOMAIN"
    echo -e "${YELLOW}Repo:${NC}     https://github.com/GrandeSmartSports/SmartDugout"
    ;;

  open)
    echo -e "${BLUE}Opening SmartDugout in browser...${NC}"
    open "http://localhost:$PORT"
    ;;

  help|*)
    echo ""
    echo -e "${BLUE}SmartDugout Dev Helper${NC}"
    echo ""
    echo "  ./dev.sh serve     Start local dev server (port 8080)"
    echo "  ./dev.sh deploy    Prep files for surge.sh deploy"
    echo "  ./dev.sh sync      Run hub sync from Alex's files"
    echo "  ./dev.sh status    Show git status + recent commits"
    echo "  ./dev.sh open      Open app in browser"
    echo ""
    ;;

esac
