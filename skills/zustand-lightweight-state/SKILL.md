---
name: zustand-lightweight-state
description: Master Zustand minimalist state management with stores, hooks, and middleware.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 04-state-management-agent
bond_type: SECONDARY_BOND
production_config:
  performance_budget:
    store_update_time: "3ms"
    selector_compute_time: "2ms"
    subscription_overhead: "1ms"
  scalability:
    max_stores: 20
    max_subscribers_per_store: 200
    bundle_size_limit: "5KB"
  monitoring:
    devtools_integration: true
    performance_tracking: true
    state_persistence: true
---

# Zustand Lightweight State Management

Master Zustand's minimalist, un-opinionated state management solution for React applications with minimal boilerplate, excellent TypeScript support, and powerful middleware capabilities.

## Input Schema

```typescript
interface ZustandStoreConfig<T> {
  initialState: T;
  actions: Record<string, (set: SetState<T>, get: GetState<T>) => any>;
  middleware?: Middleware[];
  options?: {
    name?: string;
    persist?: PersistOptions;
    devtools?: boolean;
  };
}

interface StoreApi<T> {
  setState: (
    partial: T | Partial<T> | ((state: T) => T | Partial<T>),
    replace?: boolean
  ) => void;
  getState: () => T;
  subscribe: (listener: (state: T, prevState: T) => void) => () => void;
  destroy: () => void;
}

interface Selector<T, U> {
  (state: T): U;
  equality?: (a: U, b: U) => boolean;
}
```

## Output Schema

```typescript
interface ZustandImplementation<T> {
  useStore: <U = T>(selector?: Selector<T, U>) => U;
  api: StoreApi<T>;
  hooks: {
    useStoreState: () => T;
    useActions: () => Actions;
    useSelector: <U>(selector: Selector<T, U>) => U;
  };
  utilities: {
    getState: () => T;
    setState: (partial: Partial<T>) => void;
    subscribe: (callback: (state: T) => void) => Unsubscribe;
  };
  monitoring: {
    stateSnapshots: T[];
    subscriptionCount: number;
    updateFrequency: number;
  };
}

interface PerformanceMetrics {
  updateLatency: number;
  selectorExecutionTime: number;
  subscriptionOverhead: number;
  memoryUsage: number;
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `SHALLOW_EQUALITY_ISSUE` | Selector returns new object each time | Use shallow equality or custom comparator | Memoize selector returns |
| `SUBSCRIPTION_LEAK` | Subscriptions not cleaned up | Unsubscribe in cleanup | Use React hooks properly |
| `IMMER_INTEGRATION_ERROR` | Immer middleware misconfigured | Check immer middleware setup | Follow immer configuration docs |
| `PERSIST_HYDRATION_FAILURE` | Persisted state format mismatch | Add migration function | Version your persisted state |
| `DEVTOOLS_CONNECTION_FAILED` | DevTools middleware not configured | Add devtools middleware | Check middleware configuration |
| `CIRCULAR_DEPENDENCY` | Stores reference each other | Refactor store architecture | Use dependency injection |
| `MIDDLEWARE_ORDER_ERROR` | Middleware applied in wrong order | Reorder middleware chain | Understand middleware precedence |
| `TYPE_INFERENCE_ERROR` | TypeScript types not inferred | Explicitly type store | Use TypeScript generics properly |

## MANDATORY

### Store Creation with create()
```javascript
import create from 'zustand';

// Simple store
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 })
}));

// With TypeScript
interface BearState {
  bears: number;
  increase: () => void;
  decrease: () => void;
}

const useBearStore = create<BearState>((set) => ({
  bears: 0,
  increase: () => set((state) => ({ bears: state.bears + 1 })),
  decrease: () => set((state) => ({ bears: state.bears - 1 }))
}));

// Complex store with nested state
const useUserStore = create((set, get) => ({
  user: null,
  preferences: {
    theme: 'light',
    notifications: true
  },
  setUser: (user) => set({ user }),
  updatePreferences: (updates) =>
    set((state) => ({
      preferences: { ...state.preferences, ...updates }
    })),
  clearUser: () => set({ user: null })
}));
```

### State and Actions Definition
```javascript
// Organize actions logically
const useTodoStore = create((set, get) => ({
  // State
  todos: [],
  filter: 'all',
  loading: false,

  // Actions: CRUD operations
  addTodo: (text) =>
    set((state) => ({
      todos: [...state.todos, { id: nanoid(), text, completed: false }]
    })),

  removeTodo: (id) =>
    set((state) => ({
      todos: state.todos.filter((todo) => todo.id !== id)
    })),

  toggleTodo: (id) =>
    set((state) => ({
      todos: state.todos.map((todo) =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    })),

  updateTodo: (id, text) =>
    set((state) => ({
      todos: state.todos.map((todo) =>
        todo.id === id ? { ...todo, text } : todo
      )
    })),

  // Actions: Filtering
  setFilter: (filter) => set({ filter }),

  // Actions: Async operations
  fetchTodos: async () => {
    set({ loading: true });
    try {
      const todos = await api.getTodos();
      set({ todos, loading: false });
    } catch (error) {
      set({ loading: false });
      console.error('Failed to fetch todos:', error);
    }
  },

  // Computed/derived values using get()
  getFilteredTodos: () => {
    const { todos, filter } = get();
    switch (filter) {
      case 'active':
        return todos.filter((t) => !t.completed);
      case 'completed':
        return todos.filter((t) => t.completed);
      default:
        return todos;
    }
  }
}));
```

### Using Store Hooks
```javascript
import { useTodoStore } from './store';

// Use entire store (re-renders on any change)
function TodoApp() {
  const store = useTodoStore();

  return (
    <div>
      <TodoList todos={store.todos} />
      <button onClick={store.addTodo}>Add Todo</button>
    </div>
  );
}

// Select specific state (only re-renders when selected state changes)
function TodoCounter() {
  const count = useTodoStore((state) => state.todos.length);
  return <div>Total todos: {count}</div>;
}

// Select multiple values
function TodoHeader() {
  const { todos, filter } = useTodoStore((state) => ({
    todos: state.todos,
    filter: state.filter
  }));

  return (
    <div>
      {todos.length} todos - Filter: {filter}
    </div>
  );
}

// Select actions only (never re-renders)
function TodoActions() {
  const addTodo = useTodoStore((state) => state.addTodo);
  const clearAll = useTodoStore((state) => state.clearAll);

  return (
    <div>
      <button onClick={() => addTodo('New todo')}>Add</button>
      <button onClick={clearAll}>Clear All</button>
    </div>
  );
}
```

### Selecting State Slices
```javascript
import { shallow } from 'zustand/shallow';

// Shallow comparison for object selectors
function TodoFilters() {
  const { filter, setFilter } = useTodoStore(
    (state) => ({ filter: state.filter, setFilter: state.setFilter }),
    shallow
  );

  return (
    <select value={filter} onChange={(e) => setFilter(e.target.value)}>
      <option value="all">All</option>
      <option value="active">Active</option>
      <option value="completed">Completed</option>
    </select>
  );
}

// Custom equality function
function TodoList() {
  const todos = useTodoStore(
    (state) => state.todos,
    (oldTodos, newTodos) => oldTodos.length === newTodos.length
  );

  return <ul>{/* render todos */}</ul>;
}

// Selecting derived/computed state
function CompletedTodoCount() {
  const completedCount = useTodoStore(
    (state) => state.todos.filter((t) => t.completed).length
  );

  return <div>Completed: {completedCount}</div>;
}
```

### Updating State
```javascript
const useStore = create((set, get) => ({
  // Simple updates
  count: 0,
  increment: () => set({ count: get().count + 1 }),

  // Functional updates
  incrementBy: (amount) =>
    set((state) => ({ count: state.count + amount })),

  // Multiple properties
  updateProfile: (name, email) =>
    set({ name, email, updated: Date.now() }),

  // Nested updates
  user: { name: '', settings: { theme: 'light' } },
  updateTheme: (theme) =>
    set((state) => ({
      user: {
        ...state.user,
        settings: { ...state.user.settings, theme }
      }
    })),

  // Replace entire state (dangerous!)
  reset: () => set(initialState, true), // true = replace instead of merge

  // Batch updates
  batchUpdate: (updates) => set(updates),

  // Conditional updates
  conditionalIncrement: () => {
    const current = get().count;
    if (current < 100) {
      set({ count: current + 1 });
    }
  }
}));
```

### TypeScript Integration
```typescript
import create from 'zustand';

// Define state interface
interface TodoState {
  todos: Todo[];
  filter: Filter;
  addTodo: (text: string) => void;
  removeTodo: (id: string) => void;
  setFilter: (filter: Filter) => void;
}

// Create typed store
const useTodoStore = create<TodoState>((set) => ({
  todos: [],
  filter: 'all',
  addTodo: (text) =>
    set((state) => ({
      todos: [...state.todos, { id: nanoid(), text, completed: false }]
    })),
  removeTodo: (id) =>
    set((state) => ({
      todos: state.todos.filter((t) => t.id !== id)
    })),
  setFilter: (filter) => set({ filter })
}));

// Use in components with full type safety
function TypedComponent() {
  const todos = useTodoStore((state) => state.todos);
  const addTodo = useTodoStore((state) => state.addTodo);

  // TypeScript will enforce correct types
  addTodo('New todo'); // ✓ Correct
  // addTodo(123); // ✗ Type error
}
```

## OPTIONAL

### Middleware (persist, devtools)
```javascript
import create from 'zustand';
import { persist, devtools } from 'zustand/middleware';

// Persist middleware
const usePersistedStore = create(
  persist(
    (set) => ({
      token: null,
      user: null,
      login: (token, user) => set({ token, user }),
      logout: () => set({ token: null, user: null })
    }),
    {
      name: 'auth-storage', // localStorage key
      getStorage: () => localStorage, // or sessionStorage
      partialize: (state) => ({ token: state.token }), // Only persist token
      version: 1,
      migrate: (persistedState, version) => {
        // Handle migrations
        if (version === 0) {
          return { ...persistedState, newField: 'default' };
        }
        return persistedState;
      }
    }
  )
);

// DevTools middleware
const useDevToolsStore = create(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 }), false, 'increment'),
      decrement: () => set((state) => ({ count: state.count - 1 }), false, 'decrement')
    }),
    { name: 'CounterStore' }
  )
);

// Combine multiple middleware
const useStore = create(
  devtools(
    persist(
      (set) => ({
        user: null,
        setUser: (user) => set({ user })
      }),
      { name: 'user-storage' }
    ),
    { name: 'UserStore' }
  )
);
```

### Combining Stores
```javascript
// Separate stores for different domains
const useAuthStore = create((set) => ({
  user: null,
  login: (user) => set({ user }),
  logout: () => set({ user: null })
}));

const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) =>
    set((state) => ({ items: state.items.filter((i) => i.id !== id) }))
}));

const useUIStore = create((set) => ({
  theme: 'light',
  sidebar: false,
  toggleTheme: () =>
    set((state) => ({ theme: state.theme === 'light' ? 'dark' : 'light' })),
  toggleSidebar: () => set((state) => ({ sidebar: !state.sidebar }))
}));

// Use multiple stores in component
function App() {
  const user = useAuthStore((state) => state.user);
  const cart = useCartStore((state) => state.items);
  const theme = useUIStore((state) => state.theme);

  return (
    <div className={theme}>
      <Header user={user} cartCount={cart.length} />
    </div>
  );
}

// Cross-store communication
const useNotificationStore = create((set, get) => ({
  notifications: [],
  addNotification: (message) => {
    const user = useAuthStore.getState().user;
    set((state) => ({
      notifications: [
        ...state.notifications,
        { message, userId: user?.id, timestamp: Date.now() }
      ]
    }));
  }
}));
```

### Async Actions
```javascript
const useDataStore = create((set, get) => ({
  data: null,
  loading: false,
  error: null,

  // Basic async action
  fetchData: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      set({ data, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },

  // With abort controller
  fetchWithAbort: async (signal) => {
    set({ loading: true });
    try {
      const response = await fetch('/api/data', { signal });
      const data = await response.json();
      set({ data, loading: false });
    } catch (error) {
      if (error.name !== 'AbortError') {
        set({ error: error.message, loading: false });
      }
    }
  },

  // Optimistic updates
  updateItem: async (id, updates) => {
    const { data } = get();
    const originalItem = data.find((item) => item.id === id);

    // Optimistic update
    set({
      data: data.map((item) =>
        item.id === id ? { ...item, ...updates } : item
      )
    });

    try {
      await api.updateItem(id, updates);
    } catch (error) {
      // Revert on error
      set({
        data: data.map((item) => (item.id === id ? originalItem : item)),
        error: error.message
      });
    }
  }
}));
```

### Computed/Derived State
```javascript
const useTodoStore = create((set, get) => ({
  todos: [],
  filter: 'all',

  // Method that returns computed value
  getFilteredTodos: () => {
    const { todos, filter } = get();
    switch (filter) {
      case 'active':
        return todos.filter((t) => !t.completed);
      case 'completed':
        return todos.filter((t) => t.completed);
      default:
        return todos;
    }
  },

  getStats: () => {
    const todos = get().todos;
    return {
      total: todos.length,
      completed: todos.filter((t) => t.completed).length,
      active: todos.filter((t) => !t.completed).length
    };
  }
}));

// Use in component with selector
function TodoStats() {
  const stats = useTodoStore((state) => state.getStats());

  return (
    <div>
      <p>Total: {stats.total}</p>
      <p>Completed: {stats.completed}</p>
      <p>Active: {stats.active}</p>
    </div>
  );
}

// Alternative: Compute in selector
function TodoList() {
  const filteredTodos = useTodoStore((state) => {
    const { todos, filter } = state;
    return filter === 'active'
      ? todos.filter((t) => !t.completed)
      : todos;
  });

  return <ul>{/* render filtered todos */}</ul>;
}
```

### Immer Integration
```javascript
import create from 'zustand';
import { immer } from 'zustand/middleware/immer';

// Use Immer for easier nested updates
const useStore = create(
  immer((set) => ({
    user: {
      name: '',
      profile: {
        age: 0,
        settings: {
          theme: 'light',
          notifications: true
        }
      }
    },

    // Direct mutation with Immer
    updateTheme: (theme) =>
      set((state) => {
        state.user.profile.settings.theme = theme;
      }),

    updateAge: (age) =>
      set((state) => {
        state.user.profile.age = age;
      }),

    // Complex nested updates made simple
    updateSettings: (settings) =>
      set((state) => {
        Object.assign(state.user.profile.settings, settings);
      })
  }))
);
```

### Store Subscriptions
```javascript
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 }))
}));

// Subscribe outside React components
const unsubscribe = useStore.subscribe(
  (state) => console.log('State changed:', state),
  (state) => state.count // Optional selector
);

// Cleanup
unsubscribe();

// Subscribe with custom logic
useStore.subscribe((state, prevState) => {
  if (state.count !== prevState.count) {
    console.log(`Count changed from ${prevState.count} to ${state.count}`);
  }
});

// useEffect for subscriptions in components
useEffect(() => {
  const unsubscribe = useStore.subscribe((state) => {
    // React to state changes
    if (state.user) {
      analytics.track('user_loaded', { userId: state.user.id });
    }
  });

  return unsubscribe;
}, []);
```

## ADVANCED

### Custom Middleware
```javascript
// Logger middleware
const logger = (config) => (set, get, api) =>
  config(
    (...args) => {
      console.log('Before:', get());
      set(...args);
      console.log('After:', get());
    },
    get,
    api
  );

// Performance monitoring middleware
const monitor = (config) => (set, get, api) =>
  config(
    (...args) => {
      const start = performance.now();
      set(...args);
      const duration = performance.now() - start;
      console.log(`Update took ${duration}ms`);
    },
    get,
    api
  );

// Use custom middleware
const useStore = create(
  logger(
    monitor((set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 }))
    }))
  )
);
```

### Store Factories
```javascript
// Factory function for creating similar stores
function createResourceStore(resourceName, apiService) {
  return create((set, get) => ({
    items: [],
    loading: false,
    error: null,

    fetch: async () => {
      set({ loading: true });
      try {
        const items = await apiService.getAll();
        set({ items, loading: false });
      } catch (error) {
        set({ error: error.message, loading: false });
      }
    },

    add: async (item) => {
      try {
        const newItem = await apiService.create(item);
        set((state) => ({ items: [...state.items, newItem] }));
      } catch (error) {
        set({ error: error.message });
      }
    },

    remove: async (id) => {
      try {
        await apiService.delete(id);
        set((state) => ({
          items: state.items.filter((item) => item.id !== id)
        }));
      } catch (error) {
        set({ error: error.message });
      }
    }
  }));
}

// Create multiple stores using factory
const usePostStore = createResourceStore('posts', postsApi);
const useUserStore = createResourceStore('users', usersApi);
const useCommentStore = createResourceStore('comments', commentsApi);
```

### Testing Strategies
```javascript
import { renderHook, act } from '@testing-library/react-hooks';
import { useTodoStore } from './store';

describe('useTodoStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useTodoStore.setState({ todos: [], filter: 'all' });
  });

  test('adds todo', () => {
    const { result } = renderHook(() => useTodoStore());

    act(() => {
      result.current.addTodo('Test todo');
    });

    expect(result.current.todos).toHaveLength(1);
    expect(result.current.todos[0].text).toBe('Test todo');
  });

  test('removes todo', () => {
    const { result } = renderHook(() => useTodoStore());

    act(() => {
      result.current.addTodo('Test todo');
      const todoId = result.current.todos[0].id;
      result.current.removeTodo(todoId);
    });

    expect(result.current.todos).toHaveLength(0);
  });

  test('filters todos', () => {
    const { result } = renderHook(() => useTodoStore());

    act(() => {
      result.current.addTodo('Todo 1');
      result.current.addTodo('Todo 2');
      result.current.toggleTodo(result.current.todos[0].id);
      result.current.setFilter('completed');
    });

    const filtered = result.current.getFilteredTodos();
    expect(filtered).toHaveLength(1);
  });
});

// Test outside React
describe('Store API', () => {
  test('getState returns current state', () => {
    const state = useTodoStore.getState();
    expect(state.todos).toBeDefined();
  });

  test('setState updates state', () => {
    useTodoStore.setState({ filter: 'active' });
    expect(useTodoStore.getState().filter).toBe('active');
  });

  test('subscribe notifies listeners', () => {
    const listener = jest.fn();
    const unsubscribe = useTodoStore.subscribe(listener);

    useTodoStore.setState({ filter: 'completed' });

    expect(listener).toHaveBeenCalled();
    unsubscribe();
  });
});
```

## Test Templates

### Basic Store Tests
```javascript
describe('useStore', () => {
  test('initializes with default state', () => {
    const state = useStore.getState();
    expect(state.count).toBe(0);
  });

  test('increment increases count', () => {
    useStore.getState().increment();
    expect(useStore.getState().count).toBe(1);
  });
});
```

### Async Action Tests
```javascript
test('fetches data successfully', async () => {
  const mockData = [{ id: 1, name: 'Test' }];
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve(mockData)
    })
  );

  await useStore.getState().fetchData();

  expect(useStore.getState().data).toEqual(mockData);
  expect(useStore.getState().loading).toBe(false);
});
```

## Best Practices

### Store Design
- Keep stores focused and single-purpose
- Separate concerns across multiple stores
- Use TypeScript for type safety
- Normalize complex data structures
- Avoid storing derived data

### Performance
- Use selectors to prevent unnecessary re-renders
- Leverage shallow equality for object selections
- Memoize expensive computations
- Split large stores into smaller ones
- Monitor subscription counts

### State Updates
- Use functional updates for state depending on previous state
- Batch related updates together
- Implement optimistic updates for better UX
- Handle errors gracefully in async actions
- Use Immer middleware for complex nested updates

### Testing
- Reset store state between tests
- Test store logic independently of React
- Mock external dependencies
- Test both sync and async actions
- Verify subscription behavior

### TypeScript
- Define explicit interfaces for state
- Type actions and selectors properly
- Use generics for reusable patterns
- Leverage type inference where possible
- Add JSDoc comments for documentation

## Production Configuration

```javascript
import create from 'zustand';
import { persist, devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

export const useStore = create(
  devtools(
    persist(
      immer((set, get) => ({
        // State
        data: null,
        loading: false,
        error: null,

        // Actions
        fetchData: async () => {
          set({ loading: true, error: null });
          try {
            const response = await api.getData();
            set({ data: response, loading: false });
          } catch (error) {
            set({ error: error.message, loading: false });
            if (process.env.NODE_ENV === 'production') {
              errorTracking.log(error);
            }
          }
        }
      })),
      {
        name: 'app-storage',
        version: 1,
        partialize: (state) => ({ data: state.data }) // Only persist data
      }
    ),
    { name: 'AppStore', enabled: process.env.NODE_ENV !== 'production' }
  )
);
```

## Assets

- See `assets/zustand-config.yaml` for store patterns

## Resources

- [Zustand GitHub](https://github.com/pmndrs/zustand)
- [Zustand Guide](https://docs.pmnd.rs/zustand/)
- [Zustand TypeScript](https://docs.pmnd.rs/zustand/guides/typescript)
- [Zustand Middleware](https://docs.pmnd.rs/zustand/integrations/persisting-store-data)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
