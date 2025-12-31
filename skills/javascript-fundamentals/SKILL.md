---
name: javascript-fundamentals
description: Master JavaScript ES6+ fundamentals - variables, functions, async programming, and modern syntax.
sasmp_version: "1.3.0"
bonded_agent: frontend-fundamentals
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  type_checking: enabled

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  performance_tracking: true
---

# JavaScript Fundamentals

> **Purpose:** Master modern JavaScript for building robust frontend applications.

## Input/Output Schema

```typescript
interface JSFundamentalsInput {
  topic: 'variables' | 'functions' | 'async' | 'arrays' | 'objects' | 'es6';
  level: 'beginner' | 'intermediate' | 'advanced';
  useTypeScript?: boolean;
}

interface JSFundamentalsOutput {
  explanation: string;
  codeExample: string;
  commonPitfalls: string[];
  performanceNotes: string[];
}
```

## MANDATORY
- Variables (let, const) and data types
- Functions and arrow functions
- Array methods (map, filter, reduce, find, some, every)
- Object destructuring and spread operator
- Template literals
- Promises and async/await
- Modules (import/export)

## OPTIONAL
- Classes and prototypes
- Error handling (try/catch/finally)
- Regular expressions
- Symbol and iterators
- WeakMap and WeakSet
- Optional chaining (?.) and nullish coalescing (??)

## ADVANCED
- Event loop and microtasks
- Closures and scope chain
- Proxy and Reflect
- Generators and iterators
- Memory management and garbage collection
- Web Workers

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `undefined is not a function` | Missing method | Check object/array type |
| `Cannot read property of undefined` | Null reference | Use optional chaining |
| `Unhandled promise rejection` | Missing catch | Add error handling |
| `Maximum call stack` | Infinite recursion | Add base case |

## Test Template

```typescript
describe('arrayUtils', () => {
  describe('unique', () => {
    it('removes duplicates from array', () => {
      expect(unique([1, 2, 2, 3])).toEqual([1, 2, 3]);
    });

    it('handles empty array', () => {
      expect(unique([])).toEqual([]);
    });
  });
});
```

## Best Practices
- Use `const` by default, `let` when needed
- Avoid `var` in modern code
- Use descriptive variable names
- Handle errors explicitly
- Use pure functions when possible

## Resources
- [MDN JavaScript Guide](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide)
- [JavaScript.info](https://javascript.info/)

---
**Status:** Active | **Version:** 2.0.0
