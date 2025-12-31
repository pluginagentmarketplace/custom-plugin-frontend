---
name: react-hooks-patterns
description: Master React Hooks and advanced patterns for building performant functional components.
sasmp_version: "1.3.0"
bonded_agent: frameworks
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  hooks_rules: strict

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  performance_tracking: true
---

# React Hooks & Patterns

> **Purpose:** Master modern React development with Hooks-based architecture.

## Input/Output Schema

```typescript
interface HooksInput {
  hook: 'useState' | 'useEffect' | 'useContext' | 'useReducer' | 'custom';
  pattern: 'basic' | 'optimization' | 'testing';
  context?: string;
}

interface HooksOutput {
  implementation: string;
  dependencies: string[];
  pitfalls: string[];
  testExample: string;
}
```

## MANDATORY
- useState for state management
- useEffect for side effects and cleanup
- useContext for context consumption
- useReducer for complex state logic
- Rules of Hooks (top-level, React functions only)
- Dependency arrays (empty, specific, none)

## OPTIONAL
- useCallback for memoized callbacks
- useMemo for expensive computations
- useRef for mutable references
- Custom hooks creation
- useLayoutEffect vs useEffect
- useImperativeHandle for ref APIs

## ADVANCED
- Performance optimization (React.memo, selective re-renders)
- Concurrent React (useTransition, useDeferredValue)
- Server Components integration
- Suspense for data fetching
- Error boundaries with hooks
- Testing hooks with @testing-library/react-hooks

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Invalid hook call` | Hook outside component | Move to component/custom hook |
| `Stale closure` | Missing dependency | Add to dependency array |
| `Infinite loop` | Object/array in deps | Use useMemo or useCallback |
| `Memory leak` | Missing cleanup | Return cleanup function |

## Test Template

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

## Best Practices
- Keep hooks simple and focused
- Extract complex logic into custom hooks
- Always specify all dependencies
- Use ESLint exhaustive-deps rule
- Avoid unnecessary re-renders

## Resources
- [React Hooks Docs](https://react.dev/reference/react/hooks)
- [Rules of Hooks](https://react.dev/warnings/invalid-hook-call-warning)

---
**Status:** Active | **Version:** 2.0.0
