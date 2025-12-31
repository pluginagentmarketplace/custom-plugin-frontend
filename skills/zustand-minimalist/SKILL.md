---
name: zustand-minimalist
description: Master Zustand for lightweight, scalable state management with minimal boilerplate.
sasmp_version: "1.3.0"
bonded_agent: state-management
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  store_validation: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  state_tracking: true
---

# Zustand State Management

> **Purpose:** Lightweight, scalable state management with minimal boilerplate.

## Input/Output Schema

```typescript
interface ZustandInput {
  operation: 'create' | 'middleware' | 'selector' | 'persist';
  storeType: 'simple' | 'complex' | 'async';
  typescript?: boolean;
}

interface ZustandOutput {
  storeCode: string;
  usageExample: string;
  testExample: string;
  performanceNotes: string[];
}
```

## MANDATORY
- Store creation with create()
- State and actions definition
- useShallow for object selection
- Selectors for derived state
- Basic middleware (devtools, persist)
- Store subscriptions

## OPTIONAL
- Persist middleware for storage
- Immer middleware for immutable updates
- DevTools middleware for debugging
- Custom middleware development
- Async actions and thunks
- Store composition

## ADVANCED
- Complex middleware stacking
- Type-safe stores with TypeScript
- Large-scale store architecture
- State synchronization
- Server state integration
- Cross-tab communication

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Infinite re-render` | Selecting whole store | Use selectors |
| `State not updating` | Mutating state directly | Return new state object |
| `Stale state` | Closure over old state | Use get() in actions |
| `Persist not working` | Storage not available | Check storage access |

## Code Examples

```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface StoreState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useStore = create<StoreState>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((s) => ({ count: s.count + 1 })),
        decrement: () => set((s) => ({ count: s.count - 1 })),
        reset: () => set({ count: 0 }),
      }),
      { name: 'counter-storage' }
    ),
    { name: 'CounterStore' }
  )
);

// Usage with selector
const count = useStore((state) => state.count);
```

## Test Template

```typescript
import { renderHook, act } from '@testing-library/react';
import { useStore } from './store';

describe('Store', () => {
  beforeEach(() => {
    useStore.setState({ count: 0 });
  });

  it('increments count', () => {
    const { result } = renderHook(() => useStore());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

## Best Practices
- Use selectors to prevent unnecessary re-renders
- Keep stores focused and small
- Use TypeScript for type safety
- Add DevTools in development
- Test stores in isolation

## Resources
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [Zustand GitHub](https://github.com/pmndrs/zustand)

---
**Status:** Active | **Version:** 2.0.0
