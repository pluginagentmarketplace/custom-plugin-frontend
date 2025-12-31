---
name: svelte-reactivity-stores
description: Master Svelte's compile-time reactivity, stores, and Svelte 5 runes.
sasmp_version: "1.3.0"
bonded_agent: frameworks
bond_type: SECONDARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  reactivity_check: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  performance_tracking: true
---

# Svelte Reactivity & Stores

> **Purpose:** Master Svelte's compile-time reactivity for minimal, performant applications.

## Input/Output Schema

```typescript
interface SvelteInput {
  feature: 'reactivity' | 'stores' | 'runes' | 'lifecycle';
  version: 'svelte4' | 'svelte5';
  pattern?: string;
}

interface SvelteOutput {
  code: string;
  explanation: string;
  bundleImpact: string;
  testExample: string;
}
```

## MANDATORY
- Reactive variables and declarations ($:)
- Two-way data binding (bind:)
- Stores (writable, readable, derived)
- Store auto-subscriptions ($store)
- Component lifecycle (onMount, onDestroy)
- Event handling

## OPTIONAL
- Custom store implementations
- Store subscriptions and patterns
- Context API (setContext, getContext)
- Transitions and animations
- Actions (use:)
- Component composition

## ADVANCED (Svelte 5)
- Runes ($state, $derived, $effect)
- Fine-grained reactivity
- Cross-component patterns
- SvelteKit integration
- Custom transitions
- Testing strategies

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Not reactive` | Mutating object | Use $state or assignment |
| `Memory leak` | Missing unsubscribe | Use $ prefix or cleanup |
| `Store not updating` | Wrong store type | Check writable vs readable |
| `SSR mismatch` | Browser-only code | Use browser check or onMount |

## Test Template

```typescript
import { render, fireEvent } from '@testing-library/svelte';
import Counter from './Counter.svelte';

describe('Counter', () => {
  it('increments on click', async () => {
    const { getByText } = render(Counter);

    await fireEvent.click(getByText('Increment'));

    expect(getByText('Count: 1')).toBeInTheDocument();
  });
});
```

## Best Practices
- Use $ prefix for store subscriptions
- Prefer $state runes in Svelte 5
- Keep stores small and focused
- Use derived stores for computed values
- Clean up subscriptions properly

## Resources
- [Svelte Tutorial](https://svelte.dev/tutorial)
- [Svelte 5 Runes](https://svelte-5-preview.vercel.app/docs/runes)

---
**Status:** Active | **Version:** 2.0.0
