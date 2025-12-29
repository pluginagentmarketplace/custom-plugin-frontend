# Code Quality & Linting - Complete Technical Guide

## Table of Contents
1. [ESLint Configuration](#eslint-configuration)
2. [Prettier Code Formatting](#prettier-code-formatting)
3. [TypeScript Strict Mode](#typescript-strict-mode)
4. [Husky Pre-Commit Hooks](#husky-pre-commit-hooks)
5. [Lint-Staged Configuration](#lint-staged-configuration)
6. [IDE Integration](#ide-integration)
7. [CI/CD Integration](#cicd-integration)
8. [Debugging & Troubleshooting](#debugging--troubleshooting)

## ESLint Configuration

### Installation

```bash
npm install --save-dev eslint
npm install --save-dev @typescript-eslint/eslint-plugin @typescript-eslint/parser
npm install --save-dev eslint-plugin-react eslint-plugin-react-hooks
npm install --save-dev eslint-plugin-jsx-a11y eslint-plugin-import
```

### Basic Configuration

Create `.eslintrc.json`:

```json
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true,
    "jest": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "plugins": [
    "react",
    "react-hooks",
    "@typescript-eslint"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "no-console": "warn",
    "@typescript-eslint/no-explicit-any": "warn"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

### Rule Severity Levels

```javascript
// "off" or 0   - rule disabled
// "warn" or 1  - warning, won't fail CI
// "error" or 2 - error, will fail CI

{
  "rules": {
    "no-unused-vars": "error",      // Strict
    "no-console": "warn",            // Permissive
    "prefer-const": "error"
  }
}
```

### Common Rules

```javascript
{
  "rules": {
    // Variables
    "no-var": "error",                        // Use let/const
    "prefer-const": "error",                  // Use const when possible
    "no-unused-vars": "error",                // Catch unused variables

    // Styling
    "semi": ["error", "always"],              // Require semicolons
    "quotes": ["error", "single"],            // Single quotes
    "comma-dangle": ["error", "always-multiline"],

    // Functions
    "no-implicit-coercion": "error",
    "eqeqeq": ["error", "always"],            // === instead of ==

    // React-specific
    "react/prop-types": "off",
    "react/react-in-jsx-scope": "off",
    "react-hooks/rules-of-hooks": "error",

    // TypeScript-specific
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
```

### Running ESLint

```bash
# Check all files
npm run lint

# Fix auto-fixable issues
npm run lint:fix

# Check specific file
npm run lint src/app.js

# Check specific directory
npm run lint src/components/

# Output as JSON
npm run lint -- --format json
```

### .eslintignore File

```
node_modules
dist
build
coverage
*.min.js
.next
```

## Prettier Code Formatting

### Installation

```bash
npm install --save-dev prettier
```

### Configuration

Create `.prettierrc`:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "bracketSpacing": true,
  "endOfLine": "lf"
}
```

### Configuration Options

```javascript
{
  // Semicolons at end of statements
  "semi": true,

  // Trailing commas in multi-line
  // "es5" - where valid in ES5 (objects, arrays, params)
  // "none" - no trailing commas
  // "all" - trailing commas everywhere
  "trailingComma": "es5",

  // Single vs double quotes
  "singleQuote": true,

  // Line width before wrapping
  "printWidth": 100,

  // Spaces per indent level
  "tabWidth": 2,

  // Use tabs instead of spaces
  "useTabs": false,

  // Arrow function parens
  // "always" - (x) => x
  // "avoid" - x => x
  "arrowParens": "always",

  // Spaces in object literals
  // { x: 1 } vs {x: 1}
  "bracketSpacing": true,

  // Line endings
  // "lf" - Unix (LF)
  // "crlf" - Windows (CRLF)
  // "auto" - detect
  "endOfLine": "lf"
}
```

### Running Prettier

```bash
# Format all files
npm run format

# Check formatting without changing
npm run format:check

# Format specific file
npx prettier --write src/app.js

# Check formatting
npx prettier --check src/
```

### .prettierignore File

```
node_modules
dist
build
coverage
*.min.js
.next
yarn.lock
package-lock.json
```

### Prettier + ESLint Integration

```json
{
  "extends": [
    "eslint:recommended",
    "prettier"  // Disables ESLint formatting rules
  ]
}
```

## TypeScript Strict Mode

### Configuration

```json
{
  "compilerOptions": {
    "strict": true,

    // Individual strict checks:
    "noImplicitAny": true,              // Error on any
    "strictNullChecks": true,           // Null/undefined checking
    "strictFunctionTypes": true,        // Function parameter checking
    "strictBindCallApply": true,        // bind/call/apply checking
    "strictPropertyInitialization": true, // Property init checking
    "noImplicitThis": true,             // Error on implicit this
    "alwaysStrict": true,               // Use strict mode

    // Additional safety checks:
    "noUnusedLocals": true,             // Unused variables
    "noUnusedParameters": true,         // Unused parameters
    "noImplicitReturns": true,          // All code paths return
    "noFallthroughCasesInSwitch": true, // Switch fall-through
    "noUncheckedIndexedAccess": true    // Index access safety

    // Module resolution:
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true
  }
}
```

### Type Safety Benefits

```typescript
// ❌ Without strict mode (passes)
function process(data) {
  return data.value;  // data might be null
}

// ✅ With strict mode (error)
function process(data: { value: string } | null) {
  return data.value;  // Error: Object is possibly 'null'
}

// ✅ Fixed with strict mode
function process(data: { value: string } | null) {
  return data?.value || '';
}
```

## Husky Pre-Commit Hooks

### Installation

```bash
npm install --save-dev husky lint-staged
npx husky install
```

### Create Pre-Commit Hook

```bash
npx husky add .husky/pre-commit "npx lint-staged"
```

Or manually create `.husky/pre-commit`:

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx lint-staged
```

### Create Commit Message Hook

```bash
npx husky add .husky/commit-msg "npx commitlint --edit $1"
```

### Hook Examples

Pre-commit hook for running tests:

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm test
npm run lint
```

## Lint-Staged Configuration

### Installation

```bash
npm install --save-dev lint-staged
```

### Configuration

Create `.lintstagedrc`:

```json
{
  "*.{js,jsx,ts,tsx}": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{json,md,css,scss}": [
    "prettier --write"
  ]
}
```

### Or in package.json

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

### Benefits

- Runs checks only on **staged** files
- Fast (doesn't process entire project)
- Prevents bad commits
- Automatic fixes before commit

## IDE Integration

### VSCode Configuration

Create `.vscode/settings.json`:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "eslint.enable": true,
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  }
}
```

### Recommended Extensions

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next"
  ]
}
```

### VSCode Formatting Behavior

- **Format on save:** Auto-format file when saving
- **Format on paste:** Auto-format pasted code
- **Quote style:** Matches Prettier configuration
- **Semi-colons:** Enforced by Prettier

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/quality.yml`:

```yaml
name: Code Quality

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  quality:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Use Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check Prettier formatting
        run: npm run format:check

      - name: Run TypeScript check
        run: npm run type-check

      - name: Run tests
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Debugging & Troubleshooting

### Common Issues

**Issue:** ESLint and Prettier conflict

```bash
# Fix: Add eslint-config-prettier
npm install --save-dev eslint-config-prettier
# Then add "prettier" to extends in .eslintrc
```

**Issue:** Pre-commit hook not running

```bash
# Fix: Make hook executable
chmod +x .husky/pre-commit
# Verify husky install ran
npx husky install
```

**Issue:** Husky hooks not working in CI

```bash
# Add to CI config before running tests:
npx husky install
```

---

**Total Content: 900+ words covering code quality tools**

Master these tools to maintain consistent, high-quality code across teams and projects.
