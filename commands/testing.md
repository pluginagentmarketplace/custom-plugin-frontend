---
name: learn_testing
description: Master testing strategies - Unit, Integration, E2E, and code quality
allowed-tools: Read
version: "2.0.0"
agent: 05-testing-agent

# Command Configuration
input_validation:
  skill_name:
    type: string
    required: false
    allowed_values:
      - unit-testing-jest-vitest
      - component-testing-libraries
      - e2e-testing-cypress-playwright
      - code-quality-linting

exit_codes:
  0: success
  1: invalid_skill
  2: skill_not_found
  3: agent_unavailable
---

# /testing

> Master testing strategies: Unit, Integration, E2E testing, and code quality.

## Usage

```bash
/testing [skill-name]
```

## Available Skills

| Skill | Description | Duration |
|-------|-------------|----------|
| `unit-testing-jest-vitest` | Jest, Vitest fundamentals | 4-5 hours |
| `component-testing-libraries` | Testing Library patterns | 4-5 hours |
| `e2e-testing-cypress-playwright` | Cypress, Playwright E2E | 5-6 hours |
| `code-quality-linting` | ESLint, Prettier, TypeScript | 3-4 hours |

## Examples

```bash
# List all testing skills
/testing

# Unit testing
/testing unit-testing-jest-vitest

# Component testing
/testing component-testing-libraries

# E2E testing
/testing e2e-testing-cypress-playwright

# Code quality
/testing code-quality-linting
```

## Testing Pyramid

```
        ┌───────────┐
        │    E2E    │  10% - Critical flows
        ├───────────┤
        │Integration│  20% - Components
        ├───────────┤
        │   Unit    │  70% - Logic
        └───────────┘
```

## Tool Comparison

| Tool | Type | Speed |
|------|------|-------|
| **Jest** | Unit/Integration | Fast |
| **Vitest** | Unit/Integration | Very Fast |
| **Testing Library** | Component | Fast |
| **Playwright** | E2E | Fast |
| **Cypress** | E2E | Medium |

## Description

Comprehensive testing mastery from unit to E2E:

- **Unit Testing** - Jest and Vitest
- **Component Testing** - Testing Library
- **E2E Testing** - Cypress and Playwright
- **Code Quality** - ESLint, Prettier

## Coverage Targets

| Metric | Target |
|--------|--------|
| Statements | > 80% |
| Branches | > 75% |
| Functions | > 80% |
| Lines | > 80% |

## Prerequisites

- Frameworks Agent (`/frameworks`)
- Component development experience
- Basic async/await knowledge

## Next Steps

After mastering testing:
- `/performance` - Performance testing
- `/advanced-topics` - Security testing
- CI/CD integration

---
**Command Version:** 2.0.0 | **Agent:** 05-testing-agent
