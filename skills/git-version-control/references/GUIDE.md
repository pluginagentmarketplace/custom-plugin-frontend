# Git Version Control Guide

## Essential Commands

### Setup & Configuration

```bash
# Configure user
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Set default branch name
git config --global init.defaultBranch main

# Enable helpful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### Repository Operations

```bash
# Initialize new repo
git init

# Clone existing repo
git clone <url>
git clone <url> <directory>
git clone --depth 1 <url>  # Shallow clone

# Check status
git status
git status -s  # Short format
```

### Staging & Committing

```bash
# Stage files
git add <file>
git add .           # All files
git add -p          # Interactive staging

# Commit
git commit -m "message"
git commit -am "message"  # Add + commit (tracked files)
git commit --amend        # Modify last commit

# View changes
git diff              # Unstaged changes
git diff --staged     # Staged changes
git diff HEAD~1       # Last commit changes
```

### Branching

```bash
# List branches
git branch           # Local
git branch -r        # Remote
git branch -a        # All

# Create branch
git branch <name>
git checkout -b <name>      # Create and switch
git switch -c <name>        # Modern syntax

# Switch branch
git checkout <branch>
git switch <branch>         # Modern syntax

# Delete branch
git branch -d <branch>      # Safe delete
git branch -D <branch>      # Force delete
git push origin --delete <branch>  # Remote

# Rename branch
git branch -m <old> <new>
```

### Merging & Rebasing

```bash
# Merge
git merge <branch>
git merge --no-ff <branch>  # No fast-forward
git merge --squash <branch> # Squash commits

# Rebase
git rebase <branch>
git rebase -i HEAD~3       # Interactive rebase
git rebase --continue      # After conflict resolution
git rebase --abort         # Cancel rebase

# Cherry-pick
git cherry-pick <commit>
git cherry-pick <start>..<end>
```

### Remote Operations

```bash
# Manage remotes
git remote -v
git remote add <name> <url>
git remote remove <name>
git remote rename <old> <new>

# Fetch & Pull
git fetch origin
git fetch --all
git pull                # fetch + merge
git pull --rebase       # fetch + rebase

# Push
git push origin <branch>
git push -u origin <branch>  # Set upstream
git push --force-with-lease  # Safe force push
```

### History & Logs

```bash
# View log
git log
git log --oneline
git log --graph --decorate
git log -p              # With diff
git log --stat          # With stats
git log --author="name"
git log --since="2 weeks ago"
git log <file>          # File history

# Search
git log --grep="keyword"
git log -S "code"       # Search in changes

# Show commit
git show <commit>
git show HEAD~2
```

### Undoing Changes

```bash
# Unstage
git reset HEAD <file>
git restore --staged <file>  # Modern syntax

# Discard changes
git checkout -- <file>
git restore <file>           # Modern syntax

# Reset commits
git reset --soft HEAD~1   # Keep changes staged
git reset --mixed HEAD~1  # Keep changes unstaged (default)
git reset --hard HEAD~1   # Discard changes

# Revert (safe for shared history)
git revert <commit>
git revert HEAD~3..HEAD   # Range
```

### Stashing

```bash
# Stash changes
git stash
git stash push -m "message"
git stash -u              # Include untracked

# List stashes
git stash list

# Apply stash
git stash pop             # Apply and remove
git stash apply           # Apply and keep
git stash apply stash@{2} # Specific stash

# Delete stash
git stash drop stash@{0}
git stash clear           # All stashes
```

## Branching Strategies

### Git Flow

```
main ────────●──────────●─────────────►
              \        /
release        \──────●
                \    /
develop ────●────●──●────●────►
            \      /
feature      \────●
```

- `main`: Production code
- `develop`: Integration branch
- `feature/*`: New features
- `release/*`: Release preparation
- `hotfix/*`: Production fixes

### GitHub Flow

```
main ──────●───────●───────●────►
            \     /
feature      \───●
```

- `main`: Always deployable
- Feature branches for all changes
- Pull requests for code review
- Deploy immediately after merge

### Trunk-Based Development

```
main ────●───●───●───●───●───►
          \─●─/
```

- Single `main` branch
- Short-lived feature branches (<1 day)
- Feature flags for incomplete work
- Continuous integration

## Commit Message Convention

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting |
| refactor | Code restructuring |
| perf | Performance improvement |
| test | Adding tests |
| chore | Maintenance |
| ci | CI/CD changes |

### Examples

```bash
# Simple
feat: add user authentication

# With scope
fix(auth): resolve token expiration issue

# With body and footer
feat(api): implement pagination

Add cursor-based pagination to all list endpoints.
Includes:
- Forward/backward navigation
- Configurable page size
- Total count header

Closes #123
```

## Best Practices

1. **Commit often** - Small, focused commits
2. **Write good messages** - Clear, descriptive
3. **Branch strategically** - Feature branches
4. **Pull before push** - Stay updated
5. **Review before merge** - Code reviews
6. **Never force push main** - Protect shared branches
7. **Use .gitignore** - Exclude generated files
8. **Tag releases** - Semantic versioning
