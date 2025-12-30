---
name: code-quality-linting
description: Master ESLint, Prettier, TypeScript, and pre-commit hooks for code quality enforcement.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 05-testing-agent
bond_type: SECONDARY_BOND
config:
  production:
    eslint:
      max_warnings: 0
      max_errors: 0
      cache: true
      cache_location: .eslintcache
      report_unused_disable_directives: true
    prettier:
      print_width: 100
      tab_width: 2
      use_tabs: false
      semi: true
      single_quote: true
      trailing_comma: es5
    typescript:
      strict: true
      no_implicit_any: true
      strict_null_checks: true
      no_unused_locals: true
      no_unused_parameters: true
    pre_commit:
      enabled: true
      run_lint_staged: true
      run_type_check: true
      auto_fix: true
  development:
    eslint_auto_fix: true
    format_on_save: true
    show_inline_errors: true
  ci:
    fail_on_warning: true
    max_warnings: 0
    cache: false
    output_format: json
---

# Code Quality & Linting

Maintain code standards across projects with comprehensive linting, formatting, and quality enforcement.

## Input/Output Schema

### Input Schema
```yaml
lint_request:
  type: object
  required:
    - target_files
    - lint_type
  properties:
    lint_type:
      type: string
      enum: [eslint, prettier, typescript, stylelint, commitlint]
      description: Type of linting to perform
    target_files:
      type: array
      items:
        type: string
      description: Files or directories to lint
    auto_fix:
      type: boolean
      default: false
      description: Automatically fix fixable issues
    fail_on_warning:
      type: boolean
      default: false
      description: Treat warnings as errors
    config_file:
      type: string
      description: Path to custom config file
    rules_override:
      type: object
      description: Override specific rules
    ignore_patterns:
      type: array
      items:
        type: string
      description: Patterns to ignore
    output_format:
      type: string
      enum: [stylish, json, compact, html, checkstyle]
      default: stylish
    cache:
      type: boolean
      default: true
      description: Use cache for faster linting
```

### Output Schema
```yaml
lint_result:
  type: object
  properties:
    status:
      type: string
      enum: [passed, failed, warning]
    files_processed:
      type: integer
      description: Number of files checked
    error_count:
      type: integer
      description: Total number of errors
    warning_count:
      type: integer
      description: Total number of warnings
    fixed_count:
      type: integer
      description: Number of issues auto-fixed
    execution_time:
      type: number
      description: Execution time in milliseconds
    issues:
      type: array
      items:
        type: object
        properties:
          file:
            type: string
            description: File path with issue
          line:
            type: integer
            description: Line number
          column:
            type: integer
            description: Column number
          severity:
            type: string
            enum: [error, warning, info]
          rule_id:
            type: string
            description: Rule that triggered the issue
          message:
            type: string
            description: Error message
          fixable:
            type: boolean
            description: Whether issue can be auto-fixed
    summary:
      type: object
      properties:
        files_with_errors:
          type: integer
        files_with_warnings:
          type: integer
        clean_files:
          type: integer
```

## Error Handling

| Error Code | Error Type | Description | Resolution |
|------------|------------|-------------|------------|
| `LINT_001` | Configuration Error | ESLint/Prettier config invalid or missing | Create or fix .eslintrc.js, .prettierrc files |
| `LINT_002` | Plugin Not Found | Required ESLint plugin not installed | Install missing plugin via npm/yarn |
| `LINT_003` | Parser Error | Code cannot be parsed | Fix syntax errors in source files |
| `LINT_004` | Rule Conflict | Multiple rules contradict each other | Review and resolve conflicting rules |
| `LINT_005` | File Access Error | Cannot read/write file | Check file permissions and paths |
| `LINT_006` | Type Error | TypeScript compilation error | Fix type issues in code |
| `LINT_007` | Import Error | Cannot resolve import | Check import paths and module resolution |
| `LINT_008` | Hook Installation Failed | Pre-commit hook setup failed | Reinstall husky or git hooks |
| `LINT_009` | Cache Corruption | Lint cache is invalid | Delete cache and re-run |
| `LINT_010` | Version Mismatch | Incompatible tool versions | Update dependencies to compatible versions |
| `LINT_011` | Formatting Conflict | Prettier and ESLint rules conflict | Use eslint-config-prettier to disable conflicts |
| `LINT_012` | Commit Message Invalid | Commit message doesn't match format | Follow conventional commit format |

## Configuration Templates

### ESLint Configuration (.eslintrc.js)
```javascript
module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:jsx-a11y/recommended',
    'prettier', // Must be last to disable conflicting rules
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
    project: './tsconfig.json',
  },
  plugins: [
    'react',
    'react-hooks',
    '@typescript-eslint',
    'jsx-a11y',
    'import',
  ],
  rules: {
    // Possible Errors
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'no-debugger': 'warn',
    'no-unused-vars': 'off', // Use TypeScript version
    '@typescript-eslint/no-unused-vars': ['error', {
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_',
    }],

    // Best Practices
    'eqeqeq': ['error', 'always'],
    'no-var': 'error',
    'prefer-const': 'error',
    'prefer-arrow-callback': 'error',

    // React Specific
    'react/react-in-jsx-scope': 'off', // Not needed in React 17+
    'react/prop-types': 'off', // Using TypeScript
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',

    // TypeScript Specific
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-non-null-assertion': 'warn',

    // Import Order
    'import/order': ['error', {
      'groups': [
        'builtin',
        'external',
        'internal',
        'parent',
        'sibling',
        'index',
      ],
      'newlines-between': 'always',
      'alphabetize': { order: 'asc', caseInsensitive: true },
    }],
  },
  settings: {
    react: {
      version: 'detect',
    },
    'import/resolver': {
      typescript: {},
    },
  },
  ignorePatterns: [
    'dist',
    'build',
    'node_modules',
    'coverage',
    '*.config.js',
  ],
};
```

### Prettier Configuration (.prettierrc.js)
```javascript
module.exports = {
  // Print
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,

  // Syntax
  semi: true,
  singleQuote: true,
  quoteProps: 'as-needed',
  jsxSingleQuote: false,
  trailingComma: 'es5',

  // Whitespace
  bracketSpacing: true,
  bracketSameLine: false,
  arrowParens: 'always',

  // Special
  endOfLine: 'lf',
  embeddedLanguageFormatting: 'auto',

  // Overrides for specific file types
  overrides: [
    {
      files: '*.json',
      options: {
        printWidth: 80,
      },
    },
    {
      files: '*.md',
      options: {
        proseWrap: 'always',
      },
    },
  ],
};
```

### TypeScript Configuration (tsconfig.json)
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "jsx": "react-jsx",

    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,

    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,

    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,

    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "build"]
}
```

### Husky Pre-Commit Hook (.husky/pre-commit)
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run lint-staged
npx lint-staged

# Run type check
npm run type-check
```

### Lint-Staged Configuration (.lintstagedrc.js)
```javascript
module.exports = {
  '*.{js,jsx,ts,tsx}': [
    'eslint --fix',
    'prettier --write',
  ],
  '*.{json,md,yml,yaml}': [
    'prettier --write',
  ],
  '*.css': [
    'stylelint --fix',
    'prettier --write',
  ],
};
```

### Commitlint Configuration (.commitlintrc.js)
```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Formatting
        'refactor', // Code restructuring
        'perf',     // Performance
        'test',     // Tests
        'chore',    // Maintenance
        'ci',       // CI/CD
        'revert',   // Revert commit
      ],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'never', ['upper-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
  },
};
```

## NPM Scripts

### Package.json Scripts
```json
{
  "scripts": {
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "format:check": "prettier --check \"src/**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "type-check": "tsc --noEmit",
    "style-lint": "stylelint \"src/**/*.css\"",
    "style-lint:fix": "stylelint \"src/**/*.css\" --fix",
    "quality": "npm run lint && npm run format:check && npm run type-check",
    "quality:fix": "npm run lint:fix && npm run format && npm run type-check",
    "prepare": "husky install"
  }
}
```

## Editor Integration

### VS Code Settings (.vscode/settings.json)
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

### VS Code Extensions (.vscode/extensions.json)
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "stylelint.vscode-stylelint",
    "editorconfig.editorconfig"
  ]
}
```

## Best Practices

### ESLint Rules
1. **Start with Recommended**: Extend eslint:recommended and plugin recommendations
2. **Layer Configurations**: Use extends to build up config (recommended → airbnb → prettier)
3. **Disable Conflicting Rules**: Use eslint-config-prettier to disable formatting rules
4. **Custom Rules Sparingly**: Only add project-specific rules when necessary
5. **Document Overrides**: Comment why specific rules are disabled or modified

### Prettier Integration
1. **Run Prettier Last**: Always run Prettier after ESLint to avoid conflicts
2. **Use eslint-config-prettier**: Disables conflicting ESLint formatting rules
3. **Format All File Types**: Include JSON, Markdown, YAML in formatting
4. **Consistent Line Width**: Match printWidth across team preferences
5. **Commit Formatted Code**: Never commit unformatted code

### TypeScript Strict Mode
1. **Enable Strict Mode**: Use "strict": true for maximum type safety
2. **No Implicit Any**: Force explicit types with noImplicitAny
3. **Strict Null Checks**: Catch null/undefined errors with strictNullChecks
4. **No Unused Variables**: Enable noUnusedLocals and noUnusedParameters
5. **Index Signatures**: Use noUncheckedIndexedAccess for safer array access

### Pre-Commit Hooks
1. **Install Husky**: Use husky for reliable git hooks
2. **Use lint-staged**: Only lint changed files for speed
3. **Run Type Check**: Include TypeScript checks in pre-commit
4. **Auto-Fix When Possible**: Fix ESLint and Prettier issues automatically
5. **Allow Hook Bypass**: Document when to use --no-verify

### CI/CD Integration
1. **Fail on Warnings**: Set maxWarnings: 0 in CI
2. **Cache Dependencies**: Speed up CI with dependency caching
3. **Parallel Checks**: Run lint, format, and type-check in parallel
4. **Report Generation**: Output JSON reports for analysis
5. **Block Merge on Failure**: Enforce quality gates

### Code Review
1. **Automate Style Discussions**: Let tools handle formatting debates
2. **Focus on Logic**: Code review should focus on logic, not style
3. **Document Exceptions**: Explain any eslint-disable comments
4. **Regular Updates**: Keep linting tools and configs up to date
5. **Team Alignment**: Discuss and agree on rule changes as a team

## Common Issues and Solutions

### Issue: ESLint and Prettier Conflict
```bash
# Install eslint-config-prettier
npm install -D eslint-config-prettier

# Add to .eslintrc.js extends (must be last)
extends: [
  'eslint:recommended',
  'prettier', // Disables conflicting rules
],
```

### Issue: Import Order Not Enforced
```bash
# Install import plugin
npm install -D eslint-plugin-import

# Add to .eslintrc.js
plugins: ['import'],
rules: {
  'import/order': ['error', {
    'groups': ['builtin', 'external', 'internal'],
    'newlines-between': 'always',
  }],
},
```

### Issue: TypeScript Errors Not Caught
```javascript
// Enable TypeScript-specific rules in .eslintrc.js
parser: '@typescript-eslint/parser',
parserOptions: {
  project: './tsconfig.json', // Enable type-aware rules
},
rules: {
  '@typescript-eslint/no-floating-promises': 'error',
  '@typescript-eslint/await-thenable': 'error',
},
```

## MANDATORY

- ESLint configuration and basic rules
- Prettier formatting setup and integration
- TypeScript strict mode configuration
- Editor integration (VS Code, WebStorm)
- NPM scripts for linting and formatting
- Basic rule configuration and understanding
- Running lint checks locally
- Fixing common linting errors

## OPTIONAL

- Custom ESLint rules and plugins
- Husky pre-commit hooks setup
- lint-staged for staged files only
- Stylelint for CSS/SCSS linting
- commitlint for commit message format
- Shared ESLint configurations
- Import order enforcement
- Accessibility linting with jsx-a11y

## ADVANCED

- Custom ESLint plugin development
- Performance optimization for large codebases
- Monorepo ESLint configurations
- CI/CD integration and reporting
- Automated fixing in pipelines
- Migration strategies between configs
- Custom Prettier plugins
- AST-based code transformations
- Security linting with eslint-plugin-security

## Installation Guide

### Initial Setup
```bash
# Install ESLint and Prettier
npm install -D eslint prettier

# Install TypeScript support
npm install -D @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Install React plugins
npm install -D eslint-plugin-react eslint-plugin-react-hooks

# Install Prettier integration
npm install -D eslint-config-prettier

# Install additional plugins
npm install -D eslint-plugin-import eslint-plugin-jsx-a11y

# Install Husky and lint-staged
npm install -D husky lint-staged

# Initialize Husky
npx husky install
npm pkg set scripts.prepare="husky install"

# Add pre-commit hook
npx husky add .husky/pre-commit "npx lint-staged"

# Install commitlint (optional)
npm install -D @commitlint/cli @commitlint/config-conventional
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit ${1}'
```

## Assets

- See `assets/code-quality-config.yaml` for configurations
- See `assets/eslint-rules/` for custom rule examples
- See `assets/ci-configs/` for CI/CD integration examples

## Resources

- [ESLint Documentation](https://eslint.org/)
- [Prettier Documentation](https://prettier.io/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Husky Documentation](https://typicode.github.io/husky/)
- [lint-staged](https://github.com/okonet/lint-staged)
- [Conventional Commits](https://www.conventionalcommits.org/)

---
**Status:** Active | **Version:** 2.0.0 | **Production-Ready**
