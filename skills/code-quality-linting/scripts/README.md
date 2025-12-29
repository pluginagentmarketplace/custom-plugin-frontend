# Code Quality Tools Scripts

This directory contains scripts for validating and generating code quality configurations.

## Available Scripts

### validate-quality.sh
Validates code quality setup and configuration:
- Checks for `.eslintrc.json` or `.eslintrc.js`
- Verifies `.prettierrc` configuration
- Validates TypeScript strict mode settings
- Checks husky pre-commit hooks setup
- Verifies lint-staged configuration
- Reports on SonarQube integration
- Validates code quality tool integration

**Usage:**
```bash
./scripts/validate-quality.sh [path-to-project]
```

### generate-quality-config.sh
Generates comprehensive code quality configuration:
- Creates `.eslintrc.json` with recommended rules
- Generates `.prettierrc` for code formatting
- Sets up `.husky/pre-commit` hook
- Creates `.lintstagedrc` configuration
- Generates TypeScript strict mode config
- Creates GitHub Actions workflow for CI/CD

**Usage:**
```bash
./scripts/generate-quality-config.sh [project-name]
```

## Examples

```bash
# Validate existing project
./scripts/validate-quality.sh ~/my-project

# Generate quality configuration
./scripts/generate-quality-config.sh my-project
```

## Key Tools

### ESLint
JavaScript/TypeScript linter with customizable rules
- Config: `.eslintrc.json`
- Detects problematic code patterns
- Auto-fix capability

### Prettier
Code formatter for consistent style
- Config: `.prettierrc`
- Formats on save
- Opinionated defaults

### TypeScript Strict Mode
Enable strict type checking
- `strict: true` in `tsconfig.json`
- Catches type errors early
- Better IDE support

### Husky + Lint-Staged
Pre-commit hooks for quality checks
- Prevents commits with errors
- Runs linters on staged files only
- Fast, incremental checking

## Best Practices

1. Use Prettier for formatting, ESLint for logic
2. Enable TypeScript strict mode
3. Run linters on pre-commit with husky
4. Configure IDE integration (VSCode)
5. Use consistent settings across team
