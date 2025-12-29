# Jest Unit Testing Scripts

This directory contains scripts for validating and generating Jest configurations and test files.

## Available Scripts

### validate-jest.sh
Validates Jest configuration and test structure:
- Checks for `jest.config.js` or `jest.config.ts`
- Verifies `__tests__` directory structure
- Validates `.test.js`/`.spec.js` file existence
- Checks coverage thresholds configuration
- Verifies mock setup files
- Reports on test discovery patterns

**Usage:**
```bash
./scripts/validate-jest.sh [path-to-project]
```

### generate-jest-config.sh
Generates complete Jest configuration boilerplate:
- Creates `jest.config.js` with coverage thresholds
- Sets up babel/ts preset support
- Configures module mocking
- Sets test environment (jsdom, node)
- Generates sample test boilerplate

**Usage:**
```bash
./scripts/generate-jest-config.sh [project-name]
```

## Examples

```bash
# Validate existing project
./scripts/validate-jest.sh ~/my-project

# Generate new Jest setup
./scripts/generate-jest-config.sh my-new-project
```
