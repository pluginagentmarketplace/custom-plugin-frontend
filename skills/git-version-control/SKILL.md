---
name: git-version-control
description: Master Git version control - branching, merging, rebasing, and collaborative workflows.
sasmp_version: "1.3.0"
bonded_agent: 01-fundamentals-agent
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  commit_validation: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  audit_trail: true
---

# Git Version Control

> **Purpose:** Master version control for collaborative, traceable frontend development.

## Input/Output Schema

```typescript
interface GitSkillInput {
  operation: 'branch' | 'merge' | 'rebase' | 'conflict' | 'workflow';
  currentState?: string;
  targetBranch?: string;
}

interface GitSkillOutput {
  commands: string[];
  explanation: string;
  warnings: string[];
  rollbackPlan: string[];
}
```

## MANDATORY
- Git initialization and configuration
- Staging, committing, and viewing history
- Branching strategies (feature, develop, main)
- Merging and conflict resolution
- Remote repositories (push, pull, fetch)
- Pull requests and code review workflow

## OPTIONAL
- Git rebasing and interactive rebase
- Git stash for work in progress
- Git hooks for automation
- Git bisect for debugging
- Cherry-picking commits
- Git submodules

## ADVANCED
- Git flow vs trunk-based development
- Monorepo strategies (Nx, Turborepo)
- Git LFS for large files
- Advanced merge strategies
- Git internals (objects, refs)
- CI/CD integration

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Merge conflict` | Concurrent changes | Resolve manually, use mergetool |
| `Detached HEAD` | Checkout to commit | Create branch or checkout branch |
| `Push rejected` | Remote has changes | Pull first, then push |
| `Cannot rebase` | Uncommitted changes | Stash or commit first |

## Test Template

```bash
# Pre-commit hook test
#!/bin/sh
npm run lint || exit 1
npm test || exit 1
```

## Best Practices
- Write descriptive commit messages (conventional commits)
- Keep commits atomic and focused
- Use feature branches
- Review code before merging
- Never force push to shared branches

## Common Commands

```bash
# Feature branch workflow
git checkout -b feature/my-feature
git add .
git commit -m "feat: add new feature"
git push -u origin feature/my-feature

# Sync with main
git fetch origin
git rebase origin/main
```

## Resources
- [Pro Git Book](https://git-scm.com/book)
- [Conventional Commits](https://www.conventionalcommits.org/)

---
**Status:** Active | **Version:** 2.0.0
