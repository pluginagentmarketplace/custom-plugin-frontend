# TypeScript Enterprise Patterns Scripts

Validation and generation scripts for enterprise TypeScript implementations.

## Scripts

### `validate-typescript.sh`
Validates TypeScript enterprise practices:
- TypeScript strict mode enabled
- Generics usage and complexity
- Decorator usage (class, method, property)
- Type inference correctness
- Absence of `any` types (encourages `unknown`)
- Proper type guards implementation

Usage:
```bash
./scripts/validate-typescript.sh /path/to/project
```

### `generate-typescript-advanced.sh`
Generates enterprise TypeScript patterns:
- Generic factory patterns
- Decorator implementations
- Discriminated unions
- Advanced type utilities
- Inversion of Control patterns
- Type-safe API clients

Usage:
```bash
./scripts/generate-typescript-advanced.sh /path/to/project
```

## Enterprise TypeScript Checklist

- [ ] TypeScript strict mode enabled
- [ ] No `any` types (use `unknown` or types)
- [ ] Generics for reusable components
- [ ] Discriminated unions for type narrowing
- [ ] Decorators for cross-cutting concerns
- [ ] Utility types used effectively
- [ ] Type guards implemented
- [ ] Interfaces for contracts
- [ ] Enums for constants
- [ ] Higher-order types for advanced patterns

## Key Patterns

- Generic factories
- Decorator patterns (validation, memoization, logging)
- Type narrowing with discriminated unions
- Utility types (Partial, Required, Pick, Record, etc.)
- Type guards and type predicates
- Inversion of Control
- Provider pattern
