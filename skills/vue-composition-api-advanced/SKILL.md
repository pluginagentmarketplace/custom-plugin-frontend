---
name: vue-composition-api-advanced
description: Master Vue 3 Composition API, reactive declarations, composables, and advanced state management patterns.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 03-frameworks-agent
bond_type: SECONDARY_BOND
category: framework-patterns
tags: [vue, composition-api, composables, reactivity, typescript, vue3]
complexity: advanced
estimated_time: 4-6 hours
prerequisites:
  - Vue 3 fundamentals
  - JavaScript ES6+
  - TypeScript basics (recommended)
  - Component architecture
---

# Vue Composition API Advanced

Master Vue 3 Composition API for building scalable, maintainable, and type-safe applications with modern reactive patterns.

## Input/Output Schema

### Input Requirements
```yaml
component_structure:
  type: object
  required:
    - component_type: enum      # sfc|functional|composable
    - state_complexity: enum    # simple|moderate|complex
    - reusability: boolean      # Reusable across components
  optional:
    - typescript: boolean       # Use TypeScript
    - ssr_support: boolean      # Server-side rendering
    - async_data: boolean       # Async data fetching

composable_config:
  type: object
  required:
    - name: string              # Composable name
    - inputs: array             # Input parameters
    - outputs: array            # Return values
  optional:
    - dependencies: array       # External dependencies
    - side_effects: array       # Side effect descriptions
    - lifecycle_hooks: array    # Used lifecycle hooks
```

### Output Deliverables
```yaml
components:
  - Single File Components with <script setup>
  - Reusable composables
  - Type definitions (if TypeScript)
  - Unit tests

patterns:
  - Reactive state management
  - Computed properties
  - Watchers and side effects
  - Lifecycle management
  - Error handling

metrics:
  - Code reusability: >70%
  - Type safety: 100% (TypeScript)
  - Test coverage: >80%
  - Bundle size: optimized
```

## MANDATORY

### 1. reactive() and ref() Functions

#### ref() - Primitive Values
```vue
<script setup>
import { ref } from 'vue';

// Primitive reactive value
const count = ref(0);
const message = ref('Hello');
const isActive = ref(true);

// Access value with .value
function increment() {
  count.value++;
}

// In template, .value is unwrapped automatically
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

#### reactive() - Objects
```vue
<script setup>
import { reactive, toRefs } from 'vue';

// Reactive object
const state = reactive({
  user: {
    name: 'John',
    age: 30
  },
  settings: {
    theme: 'dark',
    notifications: true
  }
});

// Modify nested properties
function updateUser() {
  state.user.name = 'Jane';
  state.user.age++;
}

// Destructure with toRefs to maintain reactivity
const { user, settings } = toRefs(state);
</script>

<template>
  <div>
    <p>Name: {{ state.user.name }}</p>
    <p>Age: {{ state.user.age }}</p>
  </div>
</template>
```

#### When to Use ref vs reactive
```javascript
// Use ref for:
// - Primitive values
// - Single values that might be reassigned
const count = ref(0);
const name = ref('John');

// Use reactive for:
// - Objects that won't be replaced entirely
// - Complex nested state
const state = reactive({
  items: [],
  pagination: { page: 1, limit: 10 },
  filters: { search: '', category: null }
});

// Don't do this with reactive (loses reactivity):
// state = { ...newState }

// Do this instead with ref:
const state = ref({ items: [] });
state.value = { items: newItems }; // Maintains reactivity
```

### 2. Computed Properties

```vue
<script setup>
import { ref, computed } from 'vue';

const firstName = ref('John');
const lastName = ref('Doe');

// Read-only computed
const fullName = computed(() => {
  return `${firstName.value} ${lastName.value}`;
});

// Writable computed
const fullNameEditable = computed({
  get() {
    return `${firstName.value} ${lastName.value}`;
  },
  set(value) {
    const parts = value.split(' ');
    firstName.value = parts[0] || '';
    lastName.value = parts[1] || '';
  }
});

// Complex computed with dependencies
const items = ref([
  { name: 'Apple', price: 1.0, quantity: 5 },
  { name: 'Banana', price: 0.5, quantity: 10 }
]);

const totalPrice = computed(() => {
  return items.value.reduce((sum, item) => {
    return sum + (item.price * item.quantity);
  }, 0);
});

const averagePrice = computed(() => {
  if (items.value.length === 0) return 0;
  return totalPrice.value / items.value.length;
});
</script>

<template>
  <div>
    <p>Full Name: {{ fullName }}</p>
    <input v-model="fullNameEditable" />
    <p>Total: ${{ totalPrice.toFixed(2) }}</p>
    <p>Average: ${{ averagePrice.toFixed(2) }}</p>
  </div>
</template>
```

### 3. Watchers (watch, watchEffect)

#### watch()
```vue
<script setup>
import { ref, watch } from 'vue';

const count = ref(0);
const message = ref('');

// Watch a single ref
watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`);
});

// Watch multiple sources
watch([count, message], ([newCount, newMessage], [oldCount, oldMessage]) => {
  console.log('Multiple values changed');
});

// Watch with options
watch(
  count,
  (newValue) => {
    console.log('Count:', newValue);
  },
  {
    immediate: true,  // Run immediately
    deep: true,       // Deep watch for objects
    flush: 'post'     // Timing: 'pre' | 'post' | 'sync'
  }
);

// Watch reactive object property
const state = reactive({ count: 0, name: 'John' });

watch(
  () => state.count,
  (newValue) => {
    console.log('State count:', newValue);
  }
);

// Stop watcher
const stop = watch(count, () => {
  // ...
});

// Later: stop watching
stop();
</script>
```

#### watchEffect()
```vue
<script setup>
import { ref, watchEffect } from 'vue';

const count = ref(0);
const multiplier = ref(2);

// Automatically tracks dependencies
watchEffect(() => {
  console.log(`Result: ${count.value * multiplier.value}`);
});

// With cleanup
watchEffect((onCleanup) => {
  const timer = setInterval(() => {
    console.log('Tick');
  }, 1000);

  onCleanup(() => {
    clearInterval(timer);
  });
});

// Async watchEffect
watchEffect(async (onCleanup) => {
  let cancelled = false;

  onCleanup(() => {
    cancelled = true;
  });

  const data = await fetchData();

  if (!cancelled) {
    // Use data
  }
});
</script>
```

### 4. Template Refs

```vue
<script setup>
import { ref, onMounted } from 'vue';

// Element ref
const inputRef = ref(null);

// Component ref
const childRef = ref(null);

onMounted(() => {
  // Access DOM element
  inputRef.value.focus();

  // Access child component methods
  childRef.value.someMethod();
});

// Ref in v-for
const itemRefs = ref([]);

function setItemRef(el) {
  if (el) {
    itemRefs.value.push(el);
  }
}

onMounted(() => {
  console.log(itemRefs.value); // Array of elements
});
</script>

<template>
  <div>
    <input ref="inputRef" />
    <ChildComponent ref="childRef" />

    <div
      v-for="item in items"
      :key="item.id"
      :ref="setItemRef"
    >
      {{ item.name }}
    </div>
  </div>
</template>
```

### 5. Lifecycle Hooks in Composition API

```vue
<script setup>
import {
  onBeforeMount,
  onMounted,
  onBeforeUpdate,
  onUpdated,
  onBeforeUnmount,
  onUnmounted,
  onErrorCaptured,
  onActivated,
  onDeactivated
} from 'vue';

// Component is about to be mounted
onBeforeMount(() => {
  console.log('Before mount');
});

// Component is mounted
onMounted(() => {
  console.log('Mounted');
  // DOM is available
  // Good for: API calls, DOM manipulation, timers
});

// Before component updates
onBeforeUpdate(() => {
  console.log('Before update');
});

// After component updates
onUpdated(() => {
  console.log('Updated');
  // Be careful: can cause infinite loops
});

// Before component unmounts
onBeforeUnmount(() => {
  console.log('Before unmount');
  // Cleanup: remove event listeners, cancel timers
});

// Component unmounted
onUnmounted(() => {
  console.log('Unmounted');
});

// Error handling
onErrorCaptured((err, instance, info) => {
  console.error('Error captured:', err, info);
  return false; // Prevent propagation
});

// Keep-alive hooks
onActivated(() => {
  console.log('Component activated');
});

onDeactivated(() => {
  console.log('Component deactivated');
});
</script>
```

### 6. Script Setup Syntax

```vue
<script setup>
// Imports are automatically available in template
import { ref, computed } from 'vue';
import ChildComponent from './ChildComponent.vue';

// Props
const props = defineProps({
  title: String,
  count: {
    type: Number,
    default: 0,
    required: true
  }
});

// Emits
const emit = defineEmits(['update', 'delete']);

function handleUpdate() {
  emit('update', { id: 1, name: 'Updated' });
}

// Expose public API
defineExpose({
  reset() {
    count.value = 0;
  }
});

// State
const count = ref(0);

// Computed
const doubleCount = computed(() => count.value * 2);

// Everything is automatically exposed to template
</script>

<template>
  <div>
    <h1>{{ title }}</h1>
    <p>Count: {{ count }}</p>
    <p>Double: {{ doubleCount }}</p>
    <ChildComponent @update="handleUpdate" />
  </div>
</template>
```

## OPTIONAL

### 1. Custom Composables

#### Basic Composable
```javascript
// composables/useCounter.js
import { ref, computed } from 'vue';

export function useCounter(initialValue = 0) {
  const count = ref(initialValue);

  const doubleCount = computed(() => count.value * 2);

  function increment() {
    count.value++;
  }

  function decrement() {
    count.value--;
  }

  function reset() {
    count.value = initialValue;
  }

  return {
    count,
    doubleCount,
    increment,
    decrement,
    reset
  };
}

// Usage in component
import { useCounter } from '@/composables/useCounter';

const { count, increment, decrement } = useCounter(10);
```

#### Async Data Fetching Composable
```javascript
// composables/useFetch.js
import { ref, unref } from 'vue';

export function useFetch(url) {
  const data = ref(null);
  const error = ref(null);
  const loading = ref(false);

  async function fetch() {
    loading.value = true;
    error.value = null;

    try {
      const response = await window.fetch(unref(url));

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      data.value = await response.json();
    } catch (e) {
      error.value = e;
    } finally {
      loading.value = false;
    }
  }

  return {
    data,
    error,
    loading,
    fetch
  };
}

// Usage
const { data, error, loading, fetch } = useFetch('/api/users');

onMounted(() => {
  fetch();
});
```

#### Mouse Position Composable
```javascript
// composables/useMouse.js
import { ref, onMounted, onUnmounted } from 'vue';

export function useMouse() {
  const x = ref(0);
  const y = ref(0);

  function update(event) {
    x.value = event.pageX;
    y.value = event.pageY;
  }

  onMounted(() => {
    window.addEventListener('mousemove', update);
  });

  onUnmounted(() => {
    window.removeEventListener('mousemove', update);
  });

  return { x, y };
}
```

### 2. Provide/Inject Pattern

```vue
<!-- Parent.vue -->
<script setup>
import { provide, ref } from 'vue';

const theme = ref('dark');
const user = ref({ name: 'John', role: 'admin' });

// Provide with key
provide('theme', theme);
provide('user', user);

// Provide with Symbol (better type safety)
export const ThemeKey = Symbol('theme');
provide(ThemeKey, theme);
</script>

<!-- Child.vue (any depth) -->
<script setup>
import { inject } from 'vue';

// Inject with default value
const theme = inject('theme', 'light');
const user = inject('user', { name: 'Guest', role: 'user' });

// Inject with Symbol
import { ThemeKey } from './Parent.vue';
const theme = inject(ThemeKey);

// Make injected value readonly
import { readonly } from 'vue';
const themeReadonly = readonly(inject('theme'));
</script>
```

### 3. Async Setup with Suspense

```vue
<!-- AsyncComponent.vue -->
<script setup>
// Top-level await in <script setup>
const data = await fetchUserData();
const settings = await fetchSettings();

// Component will wait for all promises to resolve
</script>

<template>
  <div>
    <p>{{ data.name }}</p>
    <p>{{ settings.theme }}</p>
  </div>
</template>

<!-- Parent.vue -->
<template>
  <Suspense>
    <template #default>
      <AsyncComponent />
    </template>

    <template #fallback>
      <div>Loading...</div>
    </template>
  </Suspense>
</template>

<!-- Multiple async components -->
<template>
  <Suspense>
    <template #default>
      <UserProfile />
      <UserPosts />
      <UserSettings />
    </template>

    <template #fallback>
      <LoadingSpinner />
    </template>
  </Suspense>
</template>

<!-- Error handling with Suspense -->
<script setup>
import { onErrorCaptured } from 'vue';

const error = ref(null);

onErrorCaptured((err) => {
  error.value = err;
  return false;
});
</script>

<template>
  <div v-if="error">
    Error: {{ error.message }}
  </div>

  <Suspense v-else>
    <AsyncComponent />
  </Suspense>
</template>
```

### 4. VueUse Library Integration

```vue
<script setup>
import {
  useLocalStorage,
  useMouse,
  useOnline,
  useWindowSize,
  useEventListener,
  useIntersectionObserver,
  useDebounceFn
} from '@vueuse/core';

// Local storage with reactivity
const user = useLocalStorage('user', {
  name: 'John',
  preferences: {}
});

// Mouse position
const { x, y } = useMouse();

// Online status
const online = useOnline();

// Window size
const { width, height } = useWindowSize();

// Event listener
useEventListener(window, 'scroll', () => {
  console.log('Scrolled');
});

// Intersection observer
const target = ref(null);
const { stop } = useIntersectionObserver(
  target,
  ([{ isIntersecting }]) => {
    console.log('Is visible:', isIntersecting);
  }
);

// Debounced function
const debouncedFn = useDebounceFn(() => {
  console.log('Debounced!');
}, 1000);
</script>
```

### 5. TypeScript with Composition API

```vue
<script setup lang="ts">
import { ref, computed, type Ref } from 'vue';

// Interface for props
interface Props {
  title: string;
  count?: number;
  items: Array<{ id: number; name: string }>;
}

const props = withDefaults(defineProps<Props>(), {
  count: 0
});

// Interface for emits
interface Emits {
  (e: 'update', value: number): void;
  (e: 'delete', id: number): void;
}

const emit = defineEmits<Emits>();

// Typed ref
const count: Ref<number> = ref(0);

// Typed reactive
interface State {
  user: {
    name: string;
    age: number;
  };
  items: string[];
}

const state = reactive<State>({
  user: { name: 'John', age: 30 },
  items: []
});

// Typed computed
const doubleCount = computed<number>(() => count.value * 2);

// Typed composable
interface UseCounterReturn {
  count: Ref<number>;
  increment: () => void;
  decrement: () => void;
}

function useCounter(initial: number = 0): UseCounterReturn {
  const count = ref(initial);

  const increment = () => {
    count.value++;
  };

  const decrement = () => {
    count.value--;
  };

  return { count, increment, decrement };
}
</script>
```

### 6. Reactivity Transform (Experimental)

```vue
<script setup>
// Enable in vite.config.js:
// vue({ reactivityTransform: true })

// $ref removes need for .value
let count = $ref(0);
let message = $ref('Hello');

// Use directly without .value
count++;
message = 'Hi';

// $computed for computed properties
const doubleCount = $computed(() => count * 2);

// $$ to get underlying ref
const countRef = $$count;

// Destructure reactive
const { x, y } = $$(useMouse());

// Works in template without changes
</script>

<template>
  <div>
    <p>{{ count }}</p>
    <p>{{ message }}</p>
    <p>{{ doubleCount }}</p>
  </div>
</template>
```

## ADVANCED

### 1. Shallow vs Deep Reactivity

```javascript
import {
  ref,
  shallowRef,
  reactive,
  shallowReactive,
  triggerRef
} from 'vue';

// Deep ref (default)
const deepState = ref({
  nested: {
    value: 1
  }
});

// Triggers reactivity
deepState.value.nested.value = 2;

// Shallow ref - only .value is reactive
const shallowState = shallowRef({
  nested: {
    value: 1
  }
});

// Does NOT trigger reactivity
shallowState.value.nested.value = 2;

// Does trigger reactivity
shallowState.value = { nested: { value: 2 } };

// Force trigger
shallowState.value.nested.value = 3;
triggerRef(shallowState);

// Shallow reactive
const state = shallowReactive({
  foo: 1,
  nested: {
    bar: 2
  }
});

// Reactive
state.foo = 2;

// NOT reactive
state.nested.bar = 3;

// Use case: Performance optimization for large objects
const largeData = shallowRef({
  // Large nested structure
  items: Array(10000).fill({})
});
```

### 2. Custom Ref Implementations

```javascript
import { customRef, triggerRef } from 'vue';

// Debounced ref
function useDebouncedRef(value, delay = 200) {
  let timeout;

  return customRef((track, trigger) => {
    return {
      get() {
        track();
        return value;
      },
      set(newValue) {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
          value = newValue;
          trigger();
        }, delay);
      }
    };
  });
}

// Usage
const search = useDebouncedRef('', 500);

// Validated ref
function useValidatedRef(initialValue, validator) {
  let value = initialValue;

  return customRef((track, trigger) => {
    return {
      get() {
        track();
        return value;
      },
      set(newValue) {
        if (validator(newValue)) {
          value = newValue;
          trigger();
        } else {
          console.warn('Validation failed');
        }
      }
    };
  });
}

// Usage
const age = useValidatedRef(0, (val) => val >= 0 && val <= 150);
```

### 3. Performance Optimization

```vue
<script setup>
import { ref, shallowRef, markRaw, computed } from 'vue';

// Use shallowRef for large non-reactive objects
const largeDataset = shallowRef({
  items: [] // Large array
});

// Mark objects as non-reactive
const nonReactiveData = markRaw({
  // Large object that doesn't need reactivity
  staticData: {}
});

// Computed with memo
const expensiveComputation = computed(() => {
  // Expensive calculation
  return heavyComputation(data.value);
});

// Virtual scrolling for large lists
import { useVirtualList } from '@vueuse/core';

const { list, containerProps, wrapperProps } = useVirtualList(
  allItems,
  { itemHeight: 50 }
);

// Lazy load components
import { defineAsyncComponent } from 'vue';

const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
);

// Keep-alive for expensive components
</script>

<template>
  <KeepAlive>
    <component :is="currentView" />
  </KeepAlive>
</template>
```

### 4. SSR Considerations

```vue
<script setup>
import { ref, onMounted, onServerPrefetch } from 'vue';

const data = ref(null);

// Server-side data fetching
onServerPrefetch(async () => {
  data.value = await fetchData();
});

// Client-side hydration
onMounted(() => {
  if (!data.value) {
    fetchData().then(result => {
      data.value = result;
    });
  }
});

// Check if running on server
import { inject } from 'vue';

const isServer = inject('isServer', false);

if (!isServer) {
  // Client-only code
  window.addEventListener('resize', handleResize);
}

// Use onMounted for client-only code
onMounted(() => {
  // This only runs on client
  initializeClientOnlyFeature();
});
```

### 5. Testing Composables

```javascript
// composables/useCounter.spec.js
import { describe, it, expect } from 'vitest';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { count } = useCounter();
    expect(count.value).toBe(0);
  });

  it('initializes with custom value', () => {
    const { count } = useCounter(10);
    expect(count.value).toBe(10);
  });

  it('increments count', () => {
    const { count, increment } = useCounter(0);
    increment();
    expect(count.value).toBe(1);
  });

  it('decrements count', () => {
    const { count, decrement } = useCounter(5);
    decrement();
    expect(count.value).toBe(4);
  });

  it('resets to initial value', () => {
    const { count, increment, reset } = useCounter(10);
    increment();
    increment();
    reset();
    expect(count.value).toBe(10);
  });

  it('computes double count', () => {
    const { count, doubleCount, increment } = useCounter(5);
    expect(doubleCount.value).toBe(10);
    increment();
    expect(doubleCount.value).toBe(12);
  });
});

// Test async composables
import { flushPromises } from '@vue/test-utils';

describe('useFetch', () => {
  it('fetches data successfully', async () => {
    const { data, loading, fetch } = useFetch('/api/test');

    expect(loading.value).toBe(false);

    const promise = fetch();
    expect(loading.value).toBe(true);

    await flushPromises();

    expect(loading.value).toBe(false);
    expect(data.value).toBeDefined();
  });
});
```

### 6. Advanced TypeScript Patterns

```typescript
// Advanced type definitions
import { type Ref, type ComputedRef, type UnwrapRef } from 'vue';

// Generic composable
function useList<T>(initialItems: T[] = []): {
  items: Ref<T[]>;
  add: (item: T) => void;
  remove: (index: number) => void;
  clear: () => void;
} {
  const items = ref<T[]>(initialItems);

  const add = (item: T) => {
    items.value.push(item);
  };

  const remove = (index: number) => {
    items.value.splice(index, 1);
  };

  const clear = () => {
    items.value = [];
  };

  return { items, add, remove, clear };
}

// Usage with type inference
const { items, add } = useList<string>(['a', 'b']);
add('c'); // Type-safe

// Complex return type
interface User {
  id: number;
  name: string;
  email: string;
}

interface UseUserReturn {
  user: Ref<User | null>;
  isLoading: Ref<boolean>;
  error: Ref<Error | null>;
  fetchUser: (id: number) => Promise<void>;
  updateUser: (data: Partial<User>) => Promise<void>;
}

function useUser(): UseUserReturn {
  const user = ref<User | null>(null);
  const isLoading = ref(false);
  const error = ref<Error | null>(null);

  const fetchUser = async (id: number) => {
    isLoading.value = true;
    try {
      const response = await fetch(`/api/users/${id}`);
      user.value = await response.json();
    } catch (e) {
      error.value = e as Error;
    } finally {
      isLoading.value = false;
    }
  };

  const updateUser = async (data: Partial<User>) => {
    if (!user.value) return;

    isLoading.value = true;
    try {
      const response = await fetch(`/api/users/${user.value.id}`, {
        method: 'PATCH',
        body: JSON.stringify(data)
      });
      user.value = await response.json();
    } catch (e) {
      error.value = e as Error;
    } finally {
      isLoading.value = false;
    }
  };

  return { user, isLoading, error, fetchUser, updateUser };
}
```

## Error Handling

| Error Type | Cause | Solution | Recovery Strategy |
|-----------|-------|----------|-------------------|
| `Reactive Mutation` | Mutating ref without .value | Use .value accessor | Fix accessor usage |
| `Lost Reactivity` | Destructuring reactive | Use toRefs() | Wrap with toRefs |
| `Memory Leak` | Forgotten cleanup | Add onUnmounted | Clean up resources |
| `Infinite Loop` | Watch triggers itself | Use proper watch options | Add flush option |
| `Type Error` | Incorrect TypeScript types | Fix type definitions | Update types |
| `Hydration Mismatch` | SSR/Client inconsistency | Fix conditional rendering | Use onMounted |
| `Provide/Inject Missing` | Missing provider | Add provide in parent | Provide default value |
| `Circular Dependency` | Composables depend on each other | Refactor structure | Break circular refs |

### Error Handling Implementation
```vue
<script setup>
import { ref, onErrorCaptured } from 'vue';

const error = ref(null);

// Capture errors from child components
onErrorCaptured((err, instance, info) => {
  error.value = {
    message: err.message,
    info
  };

  console.error('Error captured:', err);

  // Return false to prevent propagation
  return false;
});

// Error handling in composables
function useSafeAsync(asyncFn) {
  const data = ref(null);
  const error = ref(null);
  const loading = ref(false);

  const execute = async (...args) => {
    loading.value = true;
    error.value = null;

    try {
      data.value = await asyncFn(...args);
    } catch (e) {
      error.value = e;
      console.error('Async error:', e);
    } finally {
      loading.value = false;
    }
  };

  return { data, error, loading, execute };
}

// Global error handler
import { createApp } from 'vue';

const app = createApp(App);

app.config.errorHandler = (err, instance, info) => {
  console.error('Global error:', err, info);
  // Send to error tracking service
};
</script>

<template>
  <div v-if="error">
    <p>Error: {{ error.message }}</p>
  </div>
  <slot v-else />
</template>
```

## Test Templates

### Component Tests
```javascript
import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import Counter from './Counter.vue';

describe('Counter.vue', () => {
  it('renders with initial count', () => {
    const wrapper = mount(Counter, {
      props: { initialCount: 5 }
    });

    expect(wrapper.text()).toContain('5');
  });

  it('increments count on button click', async () => {
    const wrapper = mount(Counter);

    await wrapper.find('button.increment').trigger('click');

    expect(wrapper.vm.count).toBe(1);
  });

  it('emits update event', async () => {
    const wrapper = mount(Counter);

    await wrapper.find('button.increment').trigger('click');

    expect(wrapper.emitted('update')).toBeTruthy();
    expect(wrapper.emitted('update')[0]).toEqual([1]);
  });
});
```

### Composable Tests
```javascript
import { describe, it, expect, beforeEach } from 'vitest';
import { useCounter } from './useCounter';
import { ref } from 'vue';

describe('useCounter', () => {
  it('manages count state', () => {
    const { count, increment, decrement } = useCounter(0);

    expect(count.value).toBe(0);

    increment();
    expect(count.value).toBe(1);

    decrement();
    expect(count.value).toBe(0);
  });

  it('handles async operations', async () => {
    const { data, loading, fetch } = useFetch('/api/test');

    expect(loading.value).toBe(false);

    const promise = fetch();
    expect(loading.value).toBe(true);

    await promise;
    expect(loading.value).toBe(false);
    expect(data.value).toBeDefined();
  });
});
```

## Best Practices

### Code Organization
- Keep composables focused and single-purpose
- Use TypeScript for better type safety
- Follow consistent naming conventions (useXxx)
- Document composable inputs and outputs
- Avoid deep nesting in reactive objects

### Reactivity
- Use ref for primitives, reactive for objects
- Always access ref values with .value in JS
- Use toRefs when destructuring reactive objects
- Be cautious with watchers to avoid infinite loops
- Clean up side effects in onUnmounted

### Performance
- Use shallowRef/shallowReactive for large objects
- Implement virtual scrolling for large lists
- Lazy load heavy components
- Memoize expensive computations
- Use KeepAlive for expensive components

### TypeScript
- Define interfaces for props and emits
- Type all composable returns
- Use generic types for reusable composables
- Leverage type inference when possible
- Document complex types

## Production Configuration

### Vite Configuration
```javascript
// vite.config.js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';

export default defineConfig({
  plugins: [
    vue({
      reactivityTransform: true, // Enable if using
      script: {
        defineModel: true
      }
    })
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@composables': resolve(__dirname, 'src/composables')
    }
  },
  build: {
    target: 'esnext',
    minify: 'terser',
    sourcemap: true
  }
});
```

### TypeScript Configuration
```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "Node",
    "strict": true,
    "jsx": "preserve",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "types": ["vite/client", "@vue/runtime-core"],
    "paths": {
      "@/*": ["./src/*"],
      "@composables/*": ["./src/composables/*"]
    }
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.tsx", "src/**/*.vue"],
  "exclude": ["node_modules", "dist"]
}
```

### Environment Variables
```bash
# .env.production
VITE_API_URL=https://api.production.com
VITE_ENABLE_ANALYTICS=true
```

## Assets
- See `assets/vue-composition-config.yaml` for patterns

## Resources
- [Vue Composition API](https://vuejs.org/guide/extras/composition-api-faq.html)
- [Composables](https://vuejs.org/guide/reusability/composables.html)
- [VueUse](https://vueuse.org/)
- [Vue TypeScript Guide](https://vuejs.org/guide/typescript/overview.html)

---
**Status:** Active | **Version:** 2.0.0 | **Complexity:** Advanced | **Estimated Time:** 4-6 hours
