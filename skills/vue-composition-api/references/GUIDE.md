# Vue 3 Composition API Guide

## Core Reactivity

### ref vs reactive

```typescript
import { ref, reactive, computed, watch } from 'vue';

// ref - for primitives and single values
const count = ref(0);
const name = ref('Vue');
const user = ref<User | null>(null);

// Access/modify with .value (in script)
count.value++;
console.log(name.value);

// reactive - for objects (no .value needed)
const state = reactive({
  count: 0,
  user: null as User | null,
  items: [] as Item[],
});

state.count++;
state.items.push({ id: 1 });

// When to use which:
// ref: primitives, optional values, replacing entire objects
// reactive: complex state objects, nested properties
```

### computed

```typescript
// Basic computed
const doubleCount = computed(() => count.value * 2);

// Computed with getter and setter
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (value: string) => {
    const [first, last] = value.split(' ');
    firstName.value = first;
    lastName.value = last ?? '';
  },
});

// Use like a ref (read-only by default)
console.log(doubleCount.value);
fullName.value = 'John Doe'; // Triggers setter
```

### watch & watchEffect

```typescript
// watch - explicit dependencies
watch(count, (newVal, oldVal) => {
  console.log(`Count: ${oldVal} → ${newVal}`);
});

// Watch multiple sources
watch([firstName, lastName], ([newFirst, newLast], [oldFirst, oldLast]) => {
  console.log('Name changed');
});

// Watch reactive object (deep by default)
watch(
  () => state.user,
  (newUser) => {
    console.log('User changed:', newUser);
  },
  { deep: true }
);

// Immediate execution
watch(
  userId,
  async (id) => {
    if (id) {
      user.value = await fetchUser(id);
    }
  },
  { immediate: true }
);

// watchEffect - auto-tracks dependencies
watchEffect(() => {
  console.log(`Count is: ${count.value}`);
  // Automatically re-runs when count changes
});

// Cleanup side effects
watchEffect((onCleanup) => {
  const timer = setInterval(() => console.log('tick'), 1000);
  onCleanup(() => clearInterval(timer));
});
```

## Script Setup

### Basic Structure

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import type { User } from '@/types';

// Props
interface Props {
  userId: string;
  title?: string;
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Default Title',
});

// Emits
const emit = defineEmits<{
  (e: 'update', value: string): void;
  (e: 'delete', id: string): void;
}>();

// State
const user = ref<User | null>(null);
const loading = ref(false);

// Computed
const displayName = computed(() =>
  user.value?.name ?? 'Unknown'
);

// Methods
const fetchUser = async () => {
  loading.value = true;
  try {
    user.value = await api.getUser(props.userId);
  } finally {
    loading.value = false;
  }
};

const handleUpdate = (value: string) => {
  emit('update', value);
};

// Lifecycle
onMounted(() => {
  fetchUser();
});

// Expose to parent (optional)
defineExpose({
  refresh: fetchUser,
});
</script>

<template>
  <div>
    <h1>{{ title }}</h1>
    <p v-if="loading">Loading...</p>
    <p v-else>{{ displayName }}</p>
    <button @click="handleUpdate('new value')">
      Update
    </button>
  </div>
</template>
```

### Props with TypeScript

```typescript
// Simple props
const props = defineProps<{
  id: string;
  count: number;
  optional?: boolean;
}>();

// With defaults
const props = withDefaults(
  defineProps<{
    title: string;
    size?: 'sm' | 'md' | 'lg';
    items?: string[];
  }>(),
  {
    size: 'md',
    items: () => [], // Factory for non-primitives
  }
);

// Runtime validation (alternative)
const props = defineProps({
  id: {
    type: String,
    required: true,
  },
  count: {
    type: Number,
    default: 0,
    validator: (value: number) => value >= 0,
  },
});
```

### Emits with TypeScript

```typescript
// Type-safe emits
const emit = defineEmits<{
  (e: 'change', value: string): void;
  (e: 'submit', data: FormData): void;
  (e: 'cancel'): void;
}>();

// Usage
emit('change', 'new value');
emit('submit', { name: 'John' });
emit('cancel');

// v-model support
const modelValue = defineModel<string>();
// or with options
const modelValue = defineModel<string>({
  default: '',
  required: true,
});
```

## Composables

### Creating Composables

```typescript
// composables/useFetch.ts
import { ref, type Ref } from 'vue';

interface UseFetchReturn<T> {
  data: Ref<T | null>;
  error: Ref<Error | null>;
  loading: Ref<boolean>;
  execute: () => Promise<void>;
}

export function useFetch<T>(url: string): UseFetchReturn<T> {
  const data = ref<T | null>(null) as Ref<T | null>;
  const error = ref<Error | null>(null);
  const loading = ref(false);

  const execute = async () => {
    loading.value = true;
    error.value = null;

    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error(response.statusText);
      data.value = await response.json();
    } catch (e) {
      error.value = e instanceof Error ? e : new Error('Unknown error');
    } finally {
      loading.value = false;
    }
  };

  return { data, error, loading, execute };
}
```

### Common Composables

```typescript
// useLocalStorage
export function useLocalStorage<T>(key: string, defaultValue: T) {
  const storedValue = localStorage.getItem(key);
  const data = ref<T>(
    storedValue ? JSON.parse(storedValue) : defaultValue
  );

  watch(
    data,
    (newValue) => {
      localStorage.setItem(key, JSON.stringify(newValue));
    },
    { deep: true }
  );

  return data;
}

// useDebounce
export function useDebounce<T>(value: Ref<T>, delay = 300) {
  const debouncedValue = ref(value.value) as Ref<T>;

  watch(value, (newValue) => {
    const timer = setTimeout(() => {
      debouncedValue.value = newValue;
    }, delay);

    return () => clearTimeout(timer);
  });

  return debouncedValue;
}

// useEventListener
export function useEventListener<K extends keyof WindowEventMap>(
  target: Window,
  event: K,
  handler: (e: WindowEventMap[K]) => void
) {
  onMounted(() => target.addEventListener(event, handler));
  onUnmounted(() => target.removeEventListener(event, handler));
}
```

## Template Features

### Directives

```vue
<template>
  <!-- v-if / v-else-if / v-else -->
  <div v-if="status === 'loading'">Loading...</div>
  <div v-else-if="status === 'error'">Error!</div>
  <div v-else>{{ data }}</div>

  <!-- v-show (toggles display, keeps in DOM) -->
  <div v-show="isVisible">Toggled content</div>

  <!-- v-for with key -->
  <ul>
    <li v-for="item in items" :key="item.id">
      {{ item.name }}
    </li>
  </ul>

  <!-- v-for with index -->
  <div v-for="(item, index) in items" :key="item.id">
    {{ index }}: {{ item.name }}
  </div>

  <!-- v-model -->
  <input v-model="searchQuery" />
  <input v-model.trim="name" />
  <input v-model.number="age" type="number" />
  <input v-model.lazy="text" /> <!-- Update on blur -->

  <!-- v-bind shorthand -->
  <img :src="imageUrl" :alt="imageAlt" />
  <div :class="{ active: isActive, disabled: isDisabled }">
  <div :style="{ color: textColor, fontSize: fontSize + 'px' }">

  <!-- v-on shorthand -->
  <button @click="handleClick">Click</button>
  <button @click.prevent="handleSubmit">Submit</button>
  <input @keyup.enter="submit" />
</template>
```

### Slots

```vue
<!-- Parent -->
<Card>
  <template #header>
    <h1>Title</h1>
  </template>

  <template #default>
    <p>Content goes here</p>
  </template>

  <template #footer="{ close }">
    <button @click="close">Close</button>
  </template>
</Card>

<!-- Card.vue -->
<template>
  <div class="card">
    <header>
      <slot name="header" />
    </header>

    <main>
      <slot /> <!-- default slot -->
    </main>

    <footer>
      <slot name="footer" :close="closeCard" />
    </footer>
  </div>
</template>
```

## Best Practices

1. **Use `<script setup>`** - Less boilerplate, better TypeScript
2. **Prefer `ref` for primitives** - Explicit `.value` prevents bugs
3. **Extract logic to composables** - Reusable, testable
4. **Type your props and emits** - Full TypeScript support
5. **Use `computed` for derived state** - Auto-caches
6. **Clean up side effects** - Use `onUnmounted` or watchEffect cleanup
7. **Keep templates simple** - Move complex logic to script
8. **Use Suspense for async** - Better loading states
