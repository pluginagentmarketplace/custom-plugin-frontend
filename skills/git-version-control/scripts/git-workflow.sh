#!/bin/bash
# Git Workflow Helper Script
# Part of git-version-control skill - Golden Format E703 Compliant

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Git Workflow Helper"
    echo "==================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  status      - Show detailed status"
    echo "  feature     - Create feature branch"
    echo "  commit      - Interactive commit"
    echo "  sync        - Sync with remote"
    echo "  cleanup     - Clean merged branches"
    echo "  log         - Pretty git log"
    echo ""
}

# Show detailed status
git_status() {
    echo -e "${BLUE}=== Git Status ===${NC}"
    echo ""
    echo -e "${YELLOW}Branch:${NC} $(git branch --show-current)"
    echo -e "${YELLOW}Remote:${NC} $(git remote -v | head -1)"
    echo ""

    # Uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Changes:${NC}"
        git status --short
    else
        echo -e "${GREEN}✓ Working directory clean${NC}"
    fi

    # Ahead/behind
    echo ""
    LOCAL=$(git rev-parse @ 2>/dev/null)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")

    if [ -n "$REMOTE" ]; then
        if [ "$LOCAL" = "$REMOTE" ]; then
            echo -e "${GREEN}✓ Up to date with remote${NC}"
        else
            AHEAD=$(git rev-list --count @{u}..@ 2>/dev/null || echo 0)
            BEHIND=$(git rev-list --count @..@{u} 2>/dev/null || echo 0)
            [ "$AHEAD" -gt 0 ] && echo -e "${YELLOW}↑ $AHEAD commits ahead${NC}"
            [ "$BEHIND" -gt 0 ] && echo -e "${YELLOW}↓ $BEHIND commits behind${NC}"
        fi
    fi
}

# Create feature branch
create_feature() {
    local BRANCH_NAME="$1"
    if [ -z "$BRANCH_NAME" ]; then
        echo -e "${RED}Error: Branch name required${NC}"
        echo "Usage: $0 feature <branch-name>"
        exit 1
    fi

    # Prefix with feature/
    if [[ ! "$BRANCH_NAME" =~ ^feature/ ]]; then
        BRANCH_NAME="feature/$BRANCH_NAME"
    fi

    echo -e "${BLUE}Creating feature branch: $BRANCH_NAME${NC}"
    git checkout -b "$BRANCH_NAME"
    echo -e "${GREEN}✓ Created and switched to $BRANCH_NAME${NC}"
}

# Interactive commit
interactive_commit() {
    echo -e "${BLUE}=== Interactive Commit ===${NC}"

    # Show staged changes
    if [ -z "$(git diff --cached --name-only)" ]; then
        echo -e "${YELLOW}No staged changes. Stage files first.${NC}"
        echo ""
        echo "Unstaged changes:"
        git status --short
        echo ""
        read -p "Stage all changes? (y/n): " STAGE_ALL
        if [ "$STAGE_ALL" = "y" ]; then
            git add -A
        else
            exit 0
        fi
    fi

    echo ""
    echo "Staged changes:"
    git diff --cached --stat
    echo ""

    # Commit type
    echo "Select commit type:"
    echo "  1) feat     - New feature"
    echo "  2) fix      - Bug fix"
    echo "  3) docs     - Documentation"
    echo "  4) style    - Formatting"
    echo "  5) refactor - Code refactoring"
    echo "  6) test     - Adding tests"
    echo "  7) chore    - Maintenance"
    read -p "Type (1-7): " TYPE_NUM

    case $TYPE_NUM in
        1) TYPE="feat";;
        2) TYPE="fix";;
        3) TYPE="docs";;
        4) TYPE="style";;
        5) TYPE="refactor";;
        6) TYPE="test";;
        7) TYPE="chore";;
        *) TYPE="feat";;
    esac

    read -p "Scope (optional): " SCOPE
    read -p "Short description: " DESC

    if [ -n "$SCOPE" ]; then
        COMMIT_MSG="$TYPE($SCOPE): $DESC"
    else
        COMMIT_MSG="$TYPE: $DESC"
    fi

    echo ""
    echo -e "${YELLOW}Commit message: $COMMIT_MSG${NC}"
    read -p "Confirm? (y/n): " CONFIRM

    if [ "$CONFIRM" = "y" ]; then
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✓ Committed successfully${NC}"
    fi
}

# Sync with remote
sync_remote() {
    echo -e "${BLUE}=== Syncing with Remote ===${NC}"

    local BRANCH=$(git branch --show-current)

    echo "Fetching updates..."
    git fetch --all --prune

    echo "Pulling changes..."
    git pull --rebase origin "$BRANCH" || {
        echo -e "${RED}Rebase conflict! Resolve manually.${NC}"
        exit 1
    }

    echo -e "${GREEN}✓ Synced with remote${NC}"
}

# Cleanup merged branches
cleanup_branches() {
    echo -e "${BLUE}=== Cleaning Merged Branches ===${NC}"

    local MERGED=$(git branch --merged main 2>/dev/null | grep -v "main" | grep -v "\*")

    if [ -z "$MERGED" ]; then
        echo -e "${GREEN}✓ No merged branches to clean${NC}"
        return
    fi

    echo "Merged branches:"
    echo "$MERGED"
    echo ""
    read -p "Delete these branches? (y/n): " CONFIRM

    if [ "$CONFIRM" = "y" ]; then
        echo "$MERGED" | xargs git branch -d
        echo -e "${GREEN}✓ Branches deleted${NC}"
    fi
}

# Pretty log
pretty_log() {
    local COUNT="${1:-10}"
    git log --oneline --graph --decorate -n "$COUNT"
}

# Main
case "${1:-help}" in
    status)   git_status;;
    feature)  create_feature "$2";;
    commit)   interactive_commit;;
    sync)     sync_remote;;
    cleanup)  cleanup_branches;;
    log)      pretty_log "$2";;
    *)        show_help;;
esac
