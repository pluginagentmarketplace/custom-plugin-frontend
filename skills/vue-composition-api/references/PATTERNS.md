# Vue 3 Composition API Patterns

## Provide/Inject Pattern

Share state across component tree:

```typescript
// types.ts
import type { InjectionKey, Ref } from 'vue';

export interface ThemeContext {
  theme: Ref<'light' | 'dark'>;
  toggleTheme: () => void;
}

export const ThemeKey: InjectionKey<ThemeContext> = Symbol('theme');

// Provider component
// ThemeProvider.vue
<script setup lang="ts">
import { ref, provide } from 'vue';
import { ThemeKey, type ThemeContext } from './types';

const theme = ref<'light' | 'dark'>('light');

const toggleTheme = () => {
  theme.value = theme.value === 'light' ? 'dark' : 'light';
};

provide<ThemeContext>(ThemeKey, {
  theme,
  toggleTheme,
});
</script>

<template>
  <div :class="theme">
    <slot />
  </div>
</template>

// Consumer composable
// composables/useTheme.ts
import { inject } from 'vue';
import { ThemeKey, type ThemeContext } from '@/types';

export function useTheme(): ThemeContext {
  const context = inject(ThemeKey);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Usage in any child component
<script setup lang="ts">
import { useTheme } from '@/composables/useTheme';

const { theme, toggleTheme } = useTheme();
</script>
```

## Async Component Pattern

Load components lazily:

```typescript
// Async component with loading/error states
import { defineAsyncComponent } from 'vue';

const AsyncDashboard = defineAsyncComponent({
  loader: () => import('./Dashboard.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorDisplay,
  delay: 200, // Show loading after 200ms
  timeout: 10000, // Timeout after 10s
});

// Simple async import
const LazyComponent = defineAsyncComponent(
  () => import('./HeavyComponent.vue')
);

// With Suspense
<template>
  <Suspense>
    <template #default>
      <AsyncDashboard />
    </template>
    <template #fallback>
      <LoadingSpinner />
    </template>
  </Suspense>
</template>
```

## State Machine Pattern

Manage complex state transitions:

```typescript
// composables/useStateMachine.ts
import { ref, computed, type Ref } from 'vue';

type State = 'idle' | 'loading' | 'success' | 'error';
type Event = 'FETCH' | 'RESOLVE' | 'REJECT' | 'RESET';

interface StateMachine {
  state: Ref<State>;
  can: (event: Event) => boolean;
  send: (event: Event) => void;
}

const transitions: Record<State, Partial<Record<Event, State>>> = {
  idle: { FETCH: 'loading' },
  loading: { RESOLVE: 'success', REJECT: 'error' },
  success: { RESET: 'idle', FETCH: 'loading' },
  error: { RESET: 'idle', FETCH: 'loading' },
};

export function useStateMachine(initial: State = 'idle'): StateMachine {
  const state = ref<State>(initial);

  const can = (event: Event): boolean => {
    return !!transitions[state.value][event];
  };

  const send = (event: Event): void => {
    const nextState = transitions[state.value][event];
    if (nextState) {
      state.value = nextState;
    } else {
      console.warn(`Cannot transition from ${state.value} via ${event}`);
    }
  };

  return { state, can, send };
}

// Usage
const { state, send, can } = useStateMachine();

const fetchData = async () => {
  if (!can('FETCH')) return;

  send('FETCH');
  try {
    const data = await api.getData();
    send('RESOLVE');
    return data;
  } catch (error) {
    send('REJECT');
    throw error;
  }
};
```

## Composable Factory Pattern

Create configurable composables:

```typescript
// composables/createPagination.ts
import { ref, computed, type Ref, type ComputedRef } from 'vue';

interface PaginationOptions {
  pageSize?: number;
  initialPage?: number;
}

interface PaginationReturn<T> {
  currentPage: Ref<number>;
  pageSize: Ref<number>;
  totalPages: ComputedRef<number>;
  paginatedItems: ComputedRef<T[]>;
  nextPage: () => void;
  prevPage: () => void;
  goToPage: (page: number) => void;
}

export function createPagination<T>(
  items: Ref<T[]>,
  options: PaginationOptions = {}
): PaginationReturn<T> {
  const { pageSize: initialPageSize = 10, initialPage = 1 } = options;

  const currentPage = ref(initialPage);
  const pageSize = ref(initialPageSize);

  const totalPages = computed(() =>
    Math.ceil(items.value.length / pageSize.value)
  );

  const paginatedItems = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value;
    const end = start + pageSize.value;
    return items.value.slice(start, end);
  });

  const nextPage = () => {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  };

  const prevPage = () => {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  };

  const goToPage = (page: number) => {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  };

  return {
    currentPage,
    pageSize,
    totalPages,
    paginatedItems,
    nextPage,
    prevPage,
    goToPage,
  };
}
```

## Render Function Pattern

Dynamic component generation:

```typescript
import { h, defineComponent, type PropType } from 'vue';

// Dynamic heading component
const DynamicHeading = defineComponent({
  props: {
    level: {
      type: Number as PropType<1 | 2 | 3 | 4 | 5 | 6>,
      default: 1,
    },
  },
  setup(props, { slots }) {
    return () => h(`h${props.level}`, slots.default?.());
  },
});

// Functional component
const FunctionalButton = (props: { onClick: () => void }, { slots }) => {
  return h(
    'button',
    { onClick: props.onClick, class: 'btn' },
    slots.default?.()
  );
};

// Complex render with JSX (requires setup)
const ComplexComponent = defineComponent({
  setup() {
    const items = ref(['A', 'B', 'C']);

    return () => (
      <ul>
        {items.value.map((item) => (
          <li key={item}>{item}</li>
        ))}
      </ul>
    );
  },
});
```

## Event Bus Pattern (Vue 3)

```typescript
// composables/useEventBus.ts
import { ref, onUnmounted } from 'vue';

type EventHandler = (...args: any[]) => void;
type EventMap = Map<string, Set<EventHandler>>;

const events: EventMap = new Map();

export function useEventBus() {
  const registeredEvents: Array<{ event: string; handler: EventHandler }> = [];

  const on = (event: string, handler: EventHandler) => {
    if (!events.has(event)) {
      events.set(event, new Set());
    }
    events.get(event)!.add(handler);
    registeredEvents.push({ event, handler });
  };

  const off = (event: string, handler: EventHandler) => {
    events.get(event)?.delete(handler);
  };

  const emit = (event: string, ...args: any[]) => {
    events.get(event)?.forEach((handler) => handler(...args));
  };

  const once = (event: string, handler: EventHandler) => {
    const wrapper = (...args: any[]) => {
      handler(...args);
      off(event, wrapper);
    };
    on(event, wrapper);
  };

  // Auto-cleanup on unmount
  onUnmounted(() => {
    registeredEvents.forEach(({ event, handler }) => {
      off(event, handler);
    });
  });

  return { on, off, emit, once };
}

// Usage
// ComponentA.vue
const { emit } = useEventBus();
emit('user:updated', { id: 1, name: 'John' });

// ComponentB.vue
const { on } = useEventBus();
on('user:updated', (user) => {
  console.log('User updated:', user);
});
```

## Optimistic Update Pattern

```typescript
// composables/useOptimisticUpdate.ts
import { ref, type Ref } from 'vue';

interface UseOptimisticUpdateReturn<T> {
  data: Ref<T>;
  update: (newData: Partial<T>, asyncFn: () => Promise<T>) => Promise<void>;
  isUpdating: Ref<boolean>;
  error: Ref<Error | null>;
}

export function useOptimisticUpdate<T extends object>(
  initialData: T
): UseOptimisticUpdateReturn<T> {
  const data = ref<T>(initialData) as Ref<T>;
  const isUpdating = ref(false);
  const error = ref<Error | null>(null);

  const update = async (
    newData: Partial<T>,
    asyncFn: () => Promise<T>
  ) => {
    // Save previous state
    const previousData = { ...data.value };

    // Optimistic update
    data.value = { ...data.value, ...newData };
    isUpdating.value = true;
    error.value = null;

    try {
      // Actual update
      const result = await asyncFn();
      data.value = result;
    } catch (e) {
      // Rollback on error
      data.value = previousData;
      error.value = e instanceof Error ? e : new Error('Update failed');
      throw e;
    } finally {
      isUpdating.value = false;
    }
  };

  return { data, update, isUpdating, error };
}

// Usage
const { data: user, update, isUpdating } = useOptimisticUpdate({
  id: '1',
  name: 'John',
});

const updateName = (newName: string) => {
  update(
    { name: newName },
    () => api.updateUser({ id: user.value.id, name: newName })
  );
};
```

## VModel Pattern (Custom)

```vue
<!-- CustomInput.vue -->
<script setup lang="ts">
// Vue 3.4+ defineModel
const modelValue = defineModel<string>({ required: true });

// Pre 3.4 approach
// const props = defineProps<{ modelValue: string }>();
// const emit = defineEmits<{ (e: 'update:modelValue', value: string): void }>();
</script>

<template>
  <input
    :value="modelValue"
    @input="modelValue = ($event.target as HTMLInputElement).value"
  />
</template>

<!-- Multiple v-model -->
<script setup lang="ts">
const firstName = defineModel<string>('firstName');
const lastName = defineModel<string>('lastName');
</script>

<!-- Usage -->
<CustomInput v-model="text" />
<NameInput v-model:firstName="first" v-model:lastName="last" />
```
