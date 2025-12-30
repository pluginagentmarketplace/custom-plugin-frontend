---
name: vue-composition-api
description: Master Vue 3 Composition API - reactive state, composables, and modern patterns.
sasmp_version: "1.3.0"
bonded_agent: 03-frameworks-agent
bond_type: PRIMARY_BOND

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

# Vue Composition API

> **Purpose:** Build scalable Vue 3 applications with the Composition API.

## Input/Output Schema

```typescript
interface VueCompositionInput {
  concept: 'reactivity' | 'composables' | 'lifecycle' | 'watchers';
  level: 'beginner' | 'intermediate' | 'advanced';
  typescript?: boolean;
}

interface VueCompositionOutput {
  code: string;
  explanation: string;
  composablePattern?: string;
  testExample: string;
}
```

## MANDATORY
- `<script setup>` syntax
- Reactive state (ref, reactive)
- Computed properties
- Watchers (watch, watchEffect)
- Lifecycle hooks (onMounted, onUnmounted)
- Template refs

## OPTIONAL
- Composables development (useX pattern)
- Provide/Inject for dependency injection
- Custom directives
- Teleport component
- Suspense support
- Transition components

## ADVANCED
- Advanced reactivity (shallowRef, triggerRef)
- Performance optimization
- TypeScript integration
- Render functions with JSX
- SSR with Composition API
- State management with Pinia

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `Ref not reactive` | Missing .value access | Use .value in script |
| `Lost reactivity` | Destructuring reactive | Use toRefs() |
| `Watcher not firing` | Deep object mutation | Use deep: true or watch getter |
| `Memory leak` | No cleanup | Return cleanup in watchEffect |

## Test Template

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import MyComponent from './MyComponent.vue';

describe('MyComponent', () => {
  it('renders reactive state', async () => {
    const wrapper = mount(MyComponent);
    await wrapper.find('button').trigger('click');
    expect(wrapper.text()).toContain('1');
  });
});
```

## Best Practices
- Use `<script setup>` for cleaner code
- Create composables for reusable logic
- Prefer ref() for primitives, reactive() for objects
- Use TypeScript for better IDE support
- Follow naming convention (useXxx for composables)

## Resources
- [Vue 3 Composition API](https://vuejs.org/guide/extras/composition-api-faq.html)
- [Vue Composables](https://vuejs.org/guide/reusability/composables.html)

---
**Status:** Active | **Version:** 2.0.0
