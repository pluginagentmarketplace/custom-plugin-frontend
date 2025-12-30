---
name: typescript-enterprise-patterns
description: Master advanced TypeScript patterns for enterprise-grade type safety.
sasmp_version: "1.3.0"
bonded_agent: 07-advanced-topics-agent
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  type_checking: strict

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  type_coverage: true
---

# Advanced TypeScript Patterns

> **Purpose:** Enterprise-grade type system mastery for safer, more maintainable code.

## Input/Output Schema

```typescript
interface TypeScriptInput {
  pattern: 'branded' | 'discriminated' | 'conditional' | 'mapped';
  useCase: string;
  strictness: 'basic' | 'strict' | 'extreme';
}

interface TypeScriptOutput {
  typeDefinition: string;
  usageExample: string;
  explanation: string;
  testExample: string;
}
```

## MANDATORY
- Branded types and nominal typing
- Discriminated unions
- Type guards and type assertions
- Generic constraints
- Mapped types (Partial, Required, Pick, Omit)
- Utility types

## OPTIONAL
- Conditional types (infer, extends)
- Template literal types
- Declaration merging
- Recursive types
- Variance annotations (in, out)
- Module augmentation

## ADVANCED
- Type-level programming
- Higher-kinded types emulation
- Design patterns with types
- Phantom types
- Builder pattern with types
- Plugin architecture typing

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Type is not assignable` | Incompatible types | Check type compatibility |
| `Type instantiation too deep` | Complex recursive type | Simplify or add depth limit |
| `Cannot find name` | Missing import/type | Import or declare type |
| `Implicit any` | Missing type annotation | Add explicit type |

## Code Examples

```typescript
// Branded Types
type UserId = string & { readonly __brand: 'UserId' };
const createUserId = (id: string): UserId => id as UserId;

// Discriminated Unions
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: Error };

function handle<T>(result: Result<T>) {
  if (result.success) {
    return result.data; // TypeScript knows this is T
  }
  throw result.error;
}

// Conditional Types
type ArrayElement<T> = T extends (infer U)[] ? U : never;
```

## Test Template

```typescript
import { expectType } from 'tsd';

// Type-level tests
expectType<UserId>(createUserId('123'));
expectType<string>(unwrapResult({ success: true, data: 'test' }));
```

## Best Practices
- Use branded types for domain primitives
- Prefer discriminated unions over type assertions
- Keep conditional types simple
- Document complex types
- Use strict mode in tsconfig

## Resources
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Type Challenges](https://github.com/type-challenges/type-challenges)

---
**Status:** Active | **Version:** 2.0.0
