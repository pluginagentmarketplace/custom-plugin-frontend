# Zustand Minimalist - Real-World Patterns

## Table of Contents
1. [Store Composition](#store-composition)
2. [Middleware Patterns](#middleware-patterns)
3. [Persistence Patterns](#persistence-patterns)
4. [Async Patterns](#async-patterns)
5. [Selector Patterns](#selector-patterns)
6. [Testing Strategies](#testing-strategies)
7. [TypeScript Patterns](#typescript-patterns)
8. [Large-Scale Architecture](#large-scale-architecture)
9. [Common Pitfalls](#common-pitfalls)

## Store Composition

### Modular Stores

```javascript
// auth.store.js
import { create } from 'zustand';

export const useAuthStore = create((set) => ({
  user: null,
  token: null,

  login: async (email, password) => {
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    const { user, token } = await response.json();
    set({ user, token });
  },

  logout: () => set({ user: null, token: null }),
}));

// data.store.js
export const useDataStore = create((set) => ({
  items: [],
  filter: 'ALL',

  addItem: (item) =>
    set((state) => ({
      items: [...state.items, item],
    })),

  setFilter: (filter) => set({ filter }),
}));

// Usage - Import and use directly
function App() {
  const user = useAuthStore((state) => state.user);
  const items = useDataStore((state) => state.items);
  // ...
}
```

### Combined Store Hook

```javascript
// store.js
import { useAuthStore } from './auth.store';
import { useDataStore } from './data.store';
import { useUIStore } from './ui.store';

export function useAppStore() {
  return {
    auth: useAuthStore(),
    data: useDataStore(),
    ui: useUIStore(),
  };
}

// Usage
function App() {
  const { auth, data, ui } = useAppStore();
  // Access all stores at once
}
```

### Store Instance Pattern

```javascript
// For advanced scenarios, create store instances
function createUserStore(userId) {
  return create((set) => ({
    userId,
    profile: null,

    fetchProfile: async () => {
      const response = await fetch(`/api/users/${userId}`);
      const profile = await response.json();
      set({ profile });
    },
  }));
}

// Create separate store for each user
const userStore1 = createUserStore(1);
const userStore2 = createUserStore(2);
```

## Middleware Patterns

### Multiple Middleware Stacking

```javascript
import { create } from 'zustand';
import { devtools, persist, immer } from 'zustand/middleware';

const useStore = create(
  // Apply middleware from right to left
  devtools(
    persist(
      immer((set, get) => ({
        count: 0,
        increment: () =>
          set((state) => {
            state.count++;
          }),
      })),
      {
        name: 'count-storage',
        version: 1,
      }
    ),
    {
      name: 'CountStore',
    }
  )
);
```

### Custom Middleware

```javascript
// Timer middleware - auto-reset after delay
const timerMiddleware =
  (delayMs = 5000) =>
  (config) =>
  (set, get, api) =>
    config(
      (...args) => {
        set(...args);
        setTimeout(() => {
          set({ changed: false });
        }, delayMs);
      },
      get,
      api
    );

// Sync middleware - keep multiple stores in sync
const syncMiddleware = (otherStore) => (config) => (set, get, api) =>
  config(
    (state) => {
      set(state);
      otherStore.setState(state);
    },
    get,
    api
  );

// Usage
const store1 = create(
  syncMiddleware(store2)((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);
```

## Persistence Patterns

### Basic Persistence

```javascript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
    }),
    {
      name: 'app-storage',
      storage: localStorage,
    }
  )
);

// Automatically persists and hydrates on page load
```

### Selective Persistence

```javascript
const useStore = create(
  persist(
    (set) => ({
      user: null,
      theme: 'light',
      notifications: [],
      loading: false,

      setUser: (user) => set({ user }),
      setTheme: (theme) => set({ theme }),
      setNotifications: (notifications) => set({ notifications }),
      setLoading: (loading) => set({ loading }),
    }),
    {
      name: 'app-storage',
      // Only persist user and theme, not notifications or loading
      partialize: (state) => ({
        user: state.user,
        theme: state.theme,
      }),
    }
  )
);
```

### Versioned Migrations

```javascript
const useStore = create(
  persist(
    (set) => ({
      user: null,
      preferences: {},
    }),
    {
      name: 'app-storage',
      version: 2, // Increment when you change schema
      migrate: (persistedState, version) => {
        // Migrate from version 1 to 2
        if (version === 1) {
          // Transform old state to new shape
          return {
            ...persistedState,
            preferences: persistedState.prefs || {},
          };
        }
        return persistedState;
      },
    }
  )
);
```

### Custom Storage (IndexedDB, etc)

```javascript
const useStore = create(
  persist(
    (set) => ({
      items: [],
      addItem: (item) =>
        set((state) => ({
          items: [...state.items, item],
        })),
    }),
    {
      name: 'items-storage',
      storage: {
        getItem: async (key) => {
          const db = await openDB('myDB');
          return db.get('store', key);
        },
        setItem: async (key, value) => {
          const db = await openDB('myDB');
          await db.put('store', value, key);
        },
        removeItem: async (key) => {
          const db = await openDB('myDB');
          await db.delete('store', key);
        },
      },
    }
  )
);
```

## Async Patterns

### Request/Success/Failure

```javascript
const useStore = create((set) => ({
  data: null,
  loading: false,
  error: null,

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
}));

function DataComponent() {
  const { data, loading, error, fetchData } = useStore();

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div>{JSON.stringify(data)}</div>;
}
```

### Polling Pattern

```javascript
const useStore = create((set) => ({
  data: null,
  pollInterval: null,

  fetchData: async () => {
    const response = await fetch('/api/data');
    set({ data: await response.json() });
  },

  startPolling: (intervalMs = 5000) => {
    set({ pollInterval: setInterval(() => {}, intervalMs) });
    useStore.getState().fetchData();
  },

  stopPolling: () => {
    const { pollInterval } = useStore.getState();
    if (pollInterval) {
      clearInterval(pollInterval);
      set({ pollInterval: null });
    }
  },
}));

// Usage
useEffect(() => {
  const { startPolling, stopPolling } = useStore.getState();
  startPolling(5000);

  return () => stopPolling();
}, []);
```

### Conditional Fetching

```javascript
const useStore = create((set, get) => ({
  data: null,
  lastFetch: null,

  fetchDataIfNeeded: async () => {
    const { data, lastFetch } = get();

    // Don't refetch if recently fetched
    if (data && Date.now() - lastFetch < 5 * 60 * 1000) {
      return;
    }

    const response = await fetch('/api/data');
    set({
      data: await response.json(),
      lastFetch: Date.now(),
    });
  },
}));
```

## Selector Patterns

### Basic Selectors

```javascript
// Flat selectors
export const selectUser = (state) => state.user;
export const selectItems = (state) => state.items;
export const selectIsLoading = (state) => state.loading;

// Derived selectors
export const selectItemCount = (state) => state.items.length;
export const selectFilteredItems = (state) =>
  state.items.filter((item) => item.status === 'active');

// Custom hooks
export const useUser = () => useStore(selectUser);
export const useFilteredItems = () => useStore(selectFilteredItems);
```

### useShallow for Objects

```javascript
import { useShallow } from 'zustand/react';

function UserCard() {
  // Returns object with shallow equality - only re-renders if object structure changes
  const { name, email } = useStore(
    useShallow((state) => ({
      name: state.user?.name,
      email: state.user?.email,
    }))
  );

  return <div>{name} - {email}</div>;
}
```

### Memoized Selectors

```javascript
import { useMemo } from 'react';

function ActiveItems() {
  // Manually memoize computed selectors
  const activeItems = useStore(
    useMemo(
      () => (state) => state.items.filter((item) => item.active),
      []
    )
  );

  return <ul>{activeItems.map((item) => <li key={item.id}>{item.name}</li>)}</ul>;
}
```

## Testing Strategies

### Unit Testing Store

```javascript
describe('Store', () => {
  beforeEach(() => {
    // Reset state before each test
    useStore.setState({
      count: 0,
      items: [],
    });
  });

  it('increments count', () => {
    useStore.getState().increment();
    expect(useStore.getState().count).toBe(1);
  });

  it('adds item', () => {
    const item = { id: 1, name: 'Test' };
    useStore.getState().addItem(item);
    expect(useStore.getState().items).toContain(item);
  });
});
```

### Testing with Hooks

```javascript
import { renderHook, act } from '@testing-library/react';

test('hook updates count', () => {
  const { result } = renderHook(() => useStore((state) => state.count));

  act(() => {
    useStore.getState().increment();
  });

  expect(result.current).toBe(1);
});
```

### Mocking Store in Tests

```javascript
jest.mock('./store', () => ({
  useStore: jest.fn((selector) =>
    selector({
      user: { id: 1, name: 'Test User' },
      items: [],
      increment: jest.fn(),
    })
  ),
}));

// Now tests won't affect real store
```

## TypeScript Patterns

### Type-Safe Store

```typescript
interface StoreState {
  count: number;
  user: User | null;
  items: Item[];
  increment: () => void;
  setUser: (user: User) => void;
  addItem: (item: Item) => void;
}

export const useStore = create<StoreState>((set) => ({
  count: 0,
  user: null,
  items: [],

  increment: () => set((state) => ({ count: state.count + 1 })),
  setUser: (user) => set({ user }),
  addItem: (item) =>
    set((state) => ({
      items: [...state.items, item],
    })),
}));
```

### Typed Selectors

```typescript
export const selectUser = (state: StoreState) => state.user;
export const selectCount = (state: StoreState) => state.count;

export const useUser = () => useStore(selectUser);
export const useCount = () => useStore(selectCount);
```

## Large-Scale Architecture

### Feature-Based Stores

```javascript
// features/auth/store.js
export const useAuthStore = create((set) => ({
  // Auth state
}));

// features/posts/store.js
export const usePostsStore = create((set) => ({
  // Posts state
}));

// features/comments/store.js
export const useCommentsStore = create((set) => ({
  // Comments state
}));

// Root store composition
export function useAppStores() {
  return {
    auth: useAuthStore(),
    posts: usePostsStore(),
    comments: useCommentsStore(),
  };
}
```

### Normalized State

```javascript
const useStore = create((set) => ({
  // Normalized state
  usersById: {},
  postsById: {},
  commentsByPostId: {},

  // Denormalized selectors
  getUser: (id) => useStore.getState().usersById[id],
  getPost: (id) => useStore.getState().postsById[id],

  // Batch updates
  setUsers: (users) =>
    set({
      usersById: users.reduce((acc, user) => {
        acc[user.id] = user;
        return acc;
      }, {}),
    }),
}));
```

## Common Pitfalls

### 1. Object Reference Issues

```javascript
// ✗ WRONG: Returns new object each render
const user = useStore((state) => ({
  name: state.user?.name,
  email: state.user?.email,
})); // Causes re-render even if values unchanged

// ✓ CORRECT: Use useShallow
import { useShallow } from 'zustand/react';

const user = useStore(
  useShallow((state) => ({
    name: state.user?.name,
    email: state.user?.email,
  }))
);
```

### 2. Mutation Without Immer

```javascript
// ✗ WRONG: Mutates state directly
set((state) => {
  state.count++;
  return state; // Doesn't create new object
});

// ✓ CORRECT: Return new state
set((state) => ({
  count: state.count + 1,
}));

// ✓ OR: Use Immer middleware
set((state) => {
  state.count++;
});
```

### 3. Using Hooks Outside Components

```javascript
// ✗ WRONG: Hooks called outside React
function handleClick() {
  const count = useStore((state) => state.count); // Error!
}

// ✓ CORRECT: Use getState()
function handleClick() {
  const count = useStore.getState().count;
  useStore.getState().increment();
}
```

### 4. Missing Reset in Tests

```javascript
// ✗ WRONG: Tests interfere with each other
describe('Store', () => {
  it('test 1', () => {
    useStore.setState({ count: 5 });
  });

  it('test 2', () => {
    // count is still 5 from previous test!
    expect(useStore.getState().count).toBe(0);
  });
});

// ✓ CORRECT: Reset before each test
describe('Store', () => {
  beforeEach(() => {
    useStore.setState({ count: 0 }); // Reset
  });

  it('test 1', () => {
    useStore.setState({ count: 5 });
  });

  it('test 2', () => {
    expect(useStore.getState().count).toBe(0); // Passes
  });
});
```

### 5. Over-Subscription

```javascript
// ✗ WRONG: Subscribes to entire state
const store = useStore();
// Re-renders when ANY value changes

// ✓ CORRECT: Subscribe to specific values
const count = useStore((state) => state.count);
// Re-renders only when count changes
```

## Summary

Zustand patterns provide:
- **Simplicity**: Minimal boilerplate, maximum clarity
- **Modularity**: Separate stores by feature
- **Performance**: Optimized subscriptions
- **Flexibility**: Middleware, DevTools, Immer
- **Scalability**: From simple to complex apps
- **Type Safety**: Full TypeScript support

Best practices:
1. Create modular stores by feature
2. Use selectors for optimized subscriptions
3. Leverage middleware for persistence/debugging
4. Test stores independently with renderHook
5. Use useShallow for object selectors
6. Stack middleware carefully
7. Consider normalized state for complex data
8. Reset state in tests before each test
9. Use getState() outside components
10. Prefer composition over inheritance
