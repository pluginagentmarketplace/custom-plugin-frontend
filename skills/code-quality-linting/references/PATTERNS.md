# Code Quality & Linting Patterns - Best Practices & Real-World Examples

## Table of Contents
1. [ESLint Rule Customization](#eslint-rule-customization)
2. [Prettier Plugin Patterns](#prettier-plugin-patterns)
3. [Husky + Lint-Staged Workflow](#husky--lint-staged-workflow)
4. [Custom ESLint Rules](#custom-eslint-rules)
5. [IDE Configuration Patterns](#ide-configuration-patterns)
6. [CI/CD Automation](#cicd-automation)
7. [Monorepo Strategies](#monorepo-strategies)
8. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

## ESLint Rule Customization

### Pattern: Progressive Rule Strictness

Gradually enforce stricter rules across your project:

```json
{
  "rules": {
    // Phase 1: Safety (prevent bugs)
    "no-var": "error",
    "eqeqeq": ["error", "always"],
    "no-implicit-coercion": "error",

    // Phase 2: Quality (improve readability)
    "prefer-const": "error",
    "no-console": "warn",

    // Phase 3: Style (consistency)
    "semi": ["error", "always"],
    "quotes": ["error", "single"],

    // Phase 4: Advanced (best practices)
    "no-shadow": "error",
    "no-nested-ternary": "warn"
  }
}
```

### Pattern: Environment-Specific Rules

Different rules for different environments:

```json
{
  "env": {
    "browser": true,
    "node": true,
    "jest": true
  },
  "overrides": [
    {
      "files": ["**/__tests__/**"],
      "env": {
        "jest": true
      },
      "rules": {
        "no-console": "off"
      }
    },
    {
      "files": ["**/*.config.js"],
      "env": {
        "node": true
      },
      "rules": {
        "@typescript-eslint/no-var-requires": "off"
      }
    }
  ]
}
```

### Pattern: Rule Inheritance

Extend community configurations and override selectively:

```json
{
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    // Override inherited rule
    "react/prop-types": "off",

    // Make stricter
    "@typescript-eslint/no-explicit-any": "error"
  }
}
```

## Prettier Plugin Patterns

### Pattern: Plugin Configuration

Extend Prettier with plugins:

```javascript
// prettier.config.js
module.exports = {
  plugins: [
    require('prettier-plugin-tailwindcss'),
    require('prettier-plugin-organize-imports'),
  ],
  // Plugin-specific options
  tailwindConfig: './tailwind.config.js',
};
```

### Pattern: Multiple Config Files

Different formatting for different file types:

```bash
# .prettierrc.json for general
# .prettierrc.json.overrides for specific patterns
```

```json
{
  "overrides": [
    {
      "files": "*.md",
      "options": {
        "proseWrap": "always",
        "printWidth": 80
      }
    },
    {
      "files": "*.json",
      "options": {
        "tabWidth": 4
      }
    }
  ]
}
```

## Husky + Lint-Staged Workflow

### Pattern: Complete Workflow Setup

Real-world: Comprehensive pre-commit workflow

```bash
# 1. Pre-commit: Run linting on staged files
.husky/pre-commit:
npx lint-staged

# 2. Commit-msg: Validate commit message format
.husky/commit-msg:
npx commitlint --edit $1

# 3. Post-merge: Install new dependencies
.husky/post-merge:
npm ci
```

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --bail --findRelatedTests"
    ],
    "*.{json,md,css}": [
      "prettier --write"
    ]
  }
}
```

### Pattern: Skip Hooks When Needed

```bash
# Skip pre-commit hook for quick fixes
git commit --no-verify -m "Quick fix"

# Or set environment variable
HUSKY=0 git commit -m "Message"
```

### Pattern: Selective Testing

Only test changed files:

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "jest --bail --findRelatedTests"
    ]
  }
}
```

## Custom ESLint Rules

### Pattern: Simple Custom Rule

Create `rules/no-hardcoded-colors.js`:

```javascript
module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description: 'Disallow hardcoded CSS colors',
      category: 'Best Practices',
      recommended: false,
    },
    fixable: null,
  },
  create(context) {
    return {
      Literal(node) {
        if (typeof node.value === 'string' && /^#[0-9a-f]{6}$/i.test(node.value)) {
          context.report({
            node,
            message: 'Use CSS variables instead of hardcoded colors',
          });
        }
      },
    };
  },
};
```

Use in `.eslintrc.json`:

```json
{
  "plugins": ["./rules/custom-rules.js"],
  "rules": {
    "custom-rules/no-hardcoded-colors": "warn"
  }
}
```

## IDE Configuration Patterns

### Pattern: Team-Wide VSCode Setup

Shared settings in `.vscode/settings.json`:

```json
{
  // Editor defaults
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,

  // Language-specific
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[python]": {
    "editor.defaultFormatter": "ms-python.python"
  },

  // Linting
  "eslint.enable": true,
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "eslint.lintTask.enable": true,

  // Auto-fix on save
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  }
}
```

## CI/CD Automation

### Pattern: Multi-Stage Quality Gate

GitHub Actions with multiple quality checks:

```yaml
name: Quality Gate

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Format check
        run: npm run format:check

      - name: Type check
        run: npm run type-check

      - name: Test
        run: npm test -- --coverage

      - name: Build
        run: npm run build

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  # Separate job for linting commits
  commitlint:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Validate commits
        uses: wagoid/commitlint-github-action@v5
```

### Pattern: Quality Badges

Add to README.md:

```markdown
[![Tests](https://github.com/user/repo/workflows/Tests/badge.svg)](https://github.com/user/repo/actions)
[![Coverage](https://codecov.io/gh/user/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/user/repo)
[![Code Quality](https://img.shields.io/codefactor/grade/github/user/repo/main)](https://www.codefactor.io/repository/github/user/repo)
```

## Monorepo Strategies

### Pattern: Shared ESLint Config in Monorepo

Create `packages/eslint-config`:

```javascript
// packages/eslint-config/index.js
module.exports = {
  extends: ['eslint:recommended', 'prettier'],
  env: {
    node: true,
    es2021: true,
    browser: true,
  },
  rules: {
    // Shared rules
  },
};
```

Use in apps:

```json
{
  "extends": ["@myorg/eslint-config"],
  "rules": {
    // App-specific overrides
  }
}
```

### Pattern: Root-Level Quality Script

Root `package.json`:

```json
{
  "scripts": {
    "lint": "lerna run lint",
    "format": "prettier --write .",
    "type-check": "lerna run type-check",
    "quality": "npm run lint && npm run format && npm run type-check"
  }
}
```

## Common Pitfalls & Solutions

### Pitfall: ESLint + Prettier Conflicts

```json
// ❌ WRONG: ESLint formatting rules conflict with Prettier
{
  "extends": ["eslint:recommended"],
  "rules": {
    "semi": ["error", "always"],      // Conflicts
    "quotes": ["error", "single"]     // Conflicts
  }
}

// ✅ CORRECT: Let Prettier handle formatting
{
  "extends": ["eslint:recommended", "prettier"],
  "rules": {
    // No formatting rules here
    "no-var": "error",                // Logic rules only
    "eqeqeq": "error"
  }
}
```

### Pitfall: Overly Strict Rules

```json
// ❌ WRONG: Team can't work productively
{
  "rules": {
    "no-console": "error",            // Blocks debugging
    "no-empty-function": "error",     // Too strict
    "max-lines": ["error", 100]       // Unrealistic
  }
}

// ✅ CORRECT: Balanced strictness
{
  "rules": {
    "no-console": "warn",             // Allows debugging
    "no-empty-function": "warn",      // Suggests improvement
    "max-lines": ["warn", 300]        // Reasonable limit
  }
}
```

### Pitfall: Broken CI Due to Strict Rules

```bash
# ❌ WRONG: New strict rule breaks main branch
npm run lint  # Hundreds of errors in existing code

# ✅ CORRECT: Phased rule introduction
# 1. Add rule as "off"
# 2. Run in report mode
# 3. Fix violations in batches
# 4. Change to "warn"
# 5. Eventually "error"
```

### Pitfall: Not Automating Formatting

```bash
# ❌ WRONG: Manual formatting leads to inconsistency
git add .
git commit  # Hope files are formatted right

# ✅ CORRECT: Automation ensures consistency
git add .
# Pre-commit hook runs prettier
# Files auto-formatted before commit
```

---

**Total Content: 1000+ words of production patterns**

These patterns represent enterprise solutions for maintaining code quality at scale. Master them to build quality-conscious teams and projects.
