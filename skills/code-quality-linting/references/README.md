# Code Quality & Linting References

Comprehensive guides for maintaining code quality across projects.

## Contents

### GUIDE.md
Complete technical guide covering:
- ESLint configuration and rules
- Prettier code formatting
- TypeScript strict mode configuration
- Pre-commit hooks with Husky
- Staged changes linting with lint-staged
- IDE integration (VSCode)
- CI/CD integration
- Custom linting rules
- Performance optimization

**Target:** Master code quality tools fundamentals
**Read Time:** 25-35 minutes

### PATTERNS.md
Real-world patterns and best practices:
- ESLint rule customization
- Prettier plugin configuration
- Husky + lint-staged workflow
- Custom ESLint rule development
- IDE configuration patterns
- CI/CD automation patterns
- Code review automation
- Monorepo quality strategies
- Common pitfalls and solutions

**Target:** Apply code quality effectively in teams
**Read Time:** 25-35 minutes

## Quick Navigation

| Topic | Reference |
|-------|-----------|
| ESLint setup | GUIDE.md - ESLint Configuration |
| Prettier setup | GUIDE.md - Prettier Formatting |
| TypeScript config | GUIDE.md - TypeScript Strict Mode |
| Pre-commit hooks | GUIDE.md - Husky Setup |
| IDE integration | GUIDE.md - IDE Integration |
| Custom rules | PATTERNS.md - Rule Customization |
| Workflows | PATTERNS.md - Workflow Patterns |
| Monorepo setup | PATTERNS.md - Monorepo Strategies |

## Key Concepts

### The Quality Stack
```
┌─────────────────────────────────┐
│ ESLint      - Logical errors    │
│ Prettier    - Code formatting   │
│ TypeScript  - Type safety       │
│ Husky       - Pre-commit hooks  │
│ lint-staged - Staged files only │
└─────────────────────────────────┘
```

### Essential Scripts
```json
{
  "lint": "eslint src",
  "lint:fix": "eslint src --fix",
  "format": "prettier --write .",
  "type-check": "tsc --noEmit",
  "quality": "npm run lint && npm run format && npm run type-check"
}
```

### ESLint vs Prettier
- **ESLint:** Finds problematic patterns (logic errors)
- **Prettier:** Formats code consistently (styling)
- **Together:** Comprehensive quality coverage

## Files in This Directory

```
references/
├── README.md          (this file)
├── GUIDE.md          (technical guide - 600+ words)
└── PATTERNS.md       (patterns & examples - 600+ words)
```

## Learning Path

1. **Start here:** GUIDE.md - ESLint section
2. **Learn formatting:** Prettier section
3. **Master types:** TypeScript Strict Mode section
4. **Automate quality:** Husky + lint-staged section
5. **Apply patterns:** PATTERNS.md for workflows

## Best Practices

- **Consistent style** across team
- **Automated checking** at commit time
- **Type safety** with TypeScript
- **Clear error messages** from ESLint
- **No conflicts** between ESLint and Prettier

## External Resources

- [ESLint Documentation](https://eslint.org/)
- [Prettier Documentation](https://prettier.io/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Husky Documentation](https://typicode.github.io/husky/)
- [lint-staged Documentation](https://github.com/okonet/lint-staged)

## Related Skills

- jest-unit-testing: Unit testing fundamentals
- react-testing-library: Component testing
- e2e-testing-cypress: End-to-end testing

---

**Version:** 2.0.0 | **Last Updated:** 2025-12-28
