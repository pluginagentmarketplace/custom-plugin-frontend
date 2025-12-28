# Git Workflow Patterns

## Feature Branch Workflow

Standard workflow for team development:

```bash
# 1. Start from updated main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/user-auth

# 3. Make changes and commit
git add .
git commit -m "feat(auth): add login form"
git commit -m "feat(auth): add validation"
git commit -m "test(auth): add login tests"

# 4. Push feature branch
git push -u origin feature/user-auth

# 5. Create Pull Request (GitHub/GitLab)

# 6. After approval, merge
git checkout main
git pull origin main
git merge feature/user-auth
git push origin main

# 7. Cleanup
git branch -d feature/user-auth
git push origin --delete feature/user-auth
```

## Rebase Workflow

Keep linear history:

```bash
# 1. Work on feature
git checkout -b feature/new-api
# ... commits ...

# 2. Before merging, rebase on main
git fetch origin
git rebase origin/main

# 3. If conflicts, resolve and continue
git add <resolved-files>
git rebase --continue

# 4. Force push (if already pushed)
git push --force-with-lease

# 5. Merge (fast-forward)
git checkout main
git merge feature/new-api  # Fast-forward
```

## Squash Merge Pattern

Clean up messy history:

```bash
# Interactive rebase to squash
git rebase -i HEAD~5

# In editor:
pick abc1234 feat: start feature
squash def5678 WIP
squash ghi9012 fix typo
squash jkl3456 more work
squash mno7890 final touches

# Rewrite combined commit message
# Save and exit

# Or use merge --squash
git checkout main
git merge --squash feature/messy-branch
git commit -m "feat: complete feature implementation"
```

## Hotfix Pattern

Emergency production fixes:

```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# 2. Fix and commit
git add .
git commit -m "fix: resolve critical security issue"

# 3. Merge to main immediately
git checkout main
git merge hotfix/critical-bug
git tag -a v1.2.1 -m "Hotfix release"
git push origin main --tags

# 4. Also merge to develop (if using git-flow)
git checkout develop
git merge hotfix/critical-bug
git push origin develop

# 5. Cleanup
git branch -d hotfix/critical-bug
```

## Cherry-Pick Pattern

Apply specific commits:

```bash
# Find commit hash
git log --oneline feature/other-branch

# Cherry-pick single commit
git cherry-pick abc1234

# Cherry-pick range
git cherry-pick abc1234..def5678

# Cherry-pick without committing
git cherry-pick -n abc1234
git cherry-pick -n def5678
git commit -m "feat: combine multiple improvements"

# If conflict
git cherry-pick --continue  # after resolving
git cherry-pick --abort     # cancel
```

## Bisect Pattern

Find bug-introducing commit:

```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark known good commit
git bisect good v1.0.0

# Git checks out middle commit
# Test and mark
git bisect bad   # if bug exists
git bisect good  # if bug doesn't exist

# Repeat until found
# "abc1234 is the first bad commit"

# End bisect
git bisect reset

# Automated bisect
git bisect start HEAD v1.0.0
git bisect run npm test
```

## Stash Workflow Pattern

Save work in progress:

```bash
# Save current work
git stash push -m "WIP: user dashboard"

# Switch to urgent fix
git checkout -b hotfix/urgent
# ... fix ...
git commit -m "fix: urgent issue"
git checkout main
git merge hotfix/urgent

# Return to original work
git checkout feature/dashboard
git stash pop

# Stash specific files
git stash push -m "partial work" -- src/component.js

# Create branch from stash
git stash branch new-feature stash@{0}
```

## Submodule Pattern

Include external repositories:

```bash
# Add submodule
git submodule add https://github.com/lib/shared.git libs/shared

# Clone with submodules
git clone --recursive <url>

# Update submodules
git submodule update --init --recursive

# Update to latest
git submodule update --remote

# Remove submodule
git submodule deinit libs/shared
git rm libs/shared
rm -rf .git/modules/libs/shared
```

## Worktree Pattern

Multiple working directories:

```bash
# Create worktree for branch
git worktree add ../project-hotfix hotfix/urgent

# Work in separate directory
cd ../project-hotfix
# ... make changes ...
git commit -m "fix: urgent issue"

# Return to main worktree
cd ../project

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../project-hotfix
```

## Clean History Rewrite

Fix historical mistakes (use with caution):

```bash
# Change author of last commit
git commit --amend --author="New Name <new@email.com>"

# Change all commits by author
git filter-branch --env-filter '
if [ "$GIT_AUTHOR_EMAIL" = "old@email.com" ]; then
    export GIT_AUTHOR_EMAIL="new@email.com"
    export GIT_AUTHOR_NAME="New Name"
fi
' --tag-name-filter cat -- --all

# Remove sensitive file from history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch secrets.txt' \
  --prune-empty --tag-name-filter cat -- --all

# Modern alternative: git-filter-repo
pip install git-filter-repo
git filter-repo --path secrets.txt --invert-paths
```

## Release Tagging Pattern

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Tag specific commit
git tag -a v1.0.0 abc1234 -m "Release version 1.0.0"

# Push tags
git push origin v1.0.0
git push origin --tags

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0

# List tags
git tag -l "v1.*"

# Show tag info
git show v1.0.0
```

## Hooks Pattern

Automate workflows:

```bash
# .git/hooks/pre-commit
#!/bin/sh
npm run lint
npm run test

# .git/hooks/commit-msg
#!/bin/sh
if ! grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+" "$1"; then
    echo "Invalid commit message format"
    exit 1
fi

# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
```

## Useful Aliases

```bash
# Add to ~/.gitconfig
[alias]
    # Status
    s = status -s

    # Logging
    lg = log --oneline --graph --decorate -20
    lga = log --oneline --graph --decorate --all

    # Branching
    co = checkout
    cob = checkout -b
    br = branch -vv

    # Committing
    ci = commit
    ca = commit --amend

    # Diffing
    d = diff
    ds = diff --staged

    # Undoing
    undo = reset --soft HEAD~1
    unstage = reset HEAD --

    # Cleanup
    cleanup = !git branch --merged | grep -v main | xargs git branch -d
```
