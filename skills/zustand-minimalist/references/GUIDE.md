# Zustand Minimalist - Comprehensive Guide

## Table of Contents
1. [What is Zustand?](#what-is-zustand)
2. [Store Creation](#store-creation)
3. [State and Actions](#state-and-actions)
4. [Selectors](#selectors)
5. [Middleware](#middleware)
6. [Subscriptions](#subscriptions)
7. [React Integration](#react-integration)
8. [Async Operations](#async-operations)
9. [Testing](#testing)
10. [Performance](#performance)

## What is Zustand?

Zustand is a lightweight state management library for React with minimal boilerplate and excellent developer experience. It provides:

- **Simplicity**: Create stores with a single line of code
- **Performance**: Automatic optimization for re-renders
- **Flexibility**: Works without React Context or Providers
- **DevTools**: Full debugging support
- **Middleware**: Persist, logging, and custom middleware
- **Bundle Size**: Only ~2KB gzipped

Zustand follows these principles:
1. Simple API - one `create()` function for everything
2. Hooks-based - use stores directly in components
3. No boilerplate - minimal configuration needed
4. Immutability support - Immer middleware included
5. Middleware system - composable enhancements

## Store Creation

A Zustand store is created with the `create()` function.

### Basic Store

```javascript
import { create } from 'zustand';

const useStore = create((set, get) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}));
```

The `create()` function takes a function that receives `set` and `get`:
- `set()` - Update state (batches updates automatically)
- `get()` - Access current state (for computed values)

### Accessing in Components

```javascript
function Counter() {
  const count = useStore((state) => state.count);
  const increment = useStore((state) => state.increment);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
    </div>
  );
}
```

### Store with Multiple State Values

```javascript
const useAppStore = create((set) => ({
  // State
  user: null,
  theme: 'light',
  notifications: [],
  loading: false,

  // Actions
  setUser: (user) => set({ user }),
  setTheme: (theme) => set({ theme }),
  addNotification: (notification) =>
    set((state) => ({
      notifications: [...state.notifications, notification],
    })),
  setLoading: (loading) => set({ loading }),
}));
```

## State and Actions

### Pure State Updates

```javascript
// Update a single field
set({ count: 0 });

// Update with previous state
set((state) => ({ count: state.count + 1 }));

// Merge multiple updates (merges are shallow)
set({ count: 0, loading: false });
```

### Immutable Updates

```javascript
const useStore = create((set) => ({
  items: [],

  // Spread operator for arrays
  addItem: (item) =>
    set((state) => ({
      items: [...state.items, item],
    })),

  // Filter for removal
  removeItem: (id) =>
    set((state) => ({
      items: state.items.filter((item) => item.id !== id),
    })),

  // Map for updates
  updateItem: (id, updates) =>
    set((state) => ({
      items: state.items.map((item) =>
        item.id === id ? { ...item, ...updates } : item
      ),
    })),
}));
```

### Using Immer Middleware (Easier Mutations)

```javascript
import { create } from 'zustand';
import { immer } from 'zustand/middleware';

const useStore = create(
  immer((set) => ({
    items: [],

    // With Immer, mutations look natural
    addItem: (item) =>
      set((state) => {
        state.items.push(item); // Looks like mutation!
      }),

    updateItem: (id, updates) =>
      set((state) => {
        const item = state.items.find((item) => item.id === id);
        if (item) {
          Object.assign(item, updates); // Safe mutation
        }
      }),

    removeItem: (id) =>
      set((state) => {
        state.items = state.items.filter((item) => item.id !== id);
      }),
  }))
);
```

### Accessing State Outside Components

```javascript
// Get current state
const state = useStore.getState();
console.log(state.count);

// Dispatch action outside component
useStore.getState().increment();

// Direct state mutation (not recommended, but possible)
useStore.setState({ count: 5 });
```

## Selectors

Selectors optimize re-renders by letting components subscribe to only the state they use.

### Basic Selectors

```javascript
function UserProfile() {
  // Only re-render when user changes, not when other state changes
  const user = useStore((state) => state.user);
  const theme = useStore((state) => state.theme);

  return <div>{user?.name}</div>;
}
```

### Object Selectors

```javascript
// Creating new object on each render causes re-renders
// const { name, email } = useStore((state) => ({
//   name: state.user?.name,
//   email: state.user?.email,
// })); // ✗ BAD - new object each render

// ✓ GOOD - Use useShallow for shallow equality
import { useShallow } from 'zustand/react';

function UserProfile() {
  const user = useStore(
    useShallow((state) => ({
      name: state.user?.name,
      email: state.user?.email,
    }))
  );

  return (
    <div>
      <p>{user.name}</p>
      <p>{user.email}</p>
    </div>
  );
}
```

### Derived Selectors

```javascript
const useStore = create((set, get) => ({
  users: [],
  filter: 'ACTIVE',

  // Derived selector using get()
  getFilteredUsers: () => {
    const state = get();
    return state.users.filter((user) => user.status === state.filter);
  },
}));

// Access derived value
function UserList() {
  const filteredUsers = useStore((state) => state.getFilteredUsers());
  return <ul>{filteredUsers.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

### Custom Hook Selectors

```javascript
// Create reusable selector hooks
export const useUser = () => useStore((state) => state.user);
export const useTheme = () => useStore((state) => state.theme);
export const useIsLoading = () => useStore((state) => state.loading);

// Usage
function App() {
  const user = useUser();
  const theme = useTheme();
  // Only re-renders when user or theme changes
}
```

## Middleware

Middleware enhances Zustand stores with additional functionality.

### Using Built-in Middleware

```javascript
import { create } from 'zustand';
import { devtools, persist, immer } from 'zustand/middleware';

const useStore = create(
  devtools(
    persist(
      immer((set) => ({
        count: 0,
        increment: () =>
          set((state) => {
            state.count++;
          }),
      })),
      { name: 'store-storage' }
    )
  )
);
```

### Persist Middleware

Automatically saves state to localStorage:

```javascript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    {
      name: 'app-storage', // Key for localStorage
      version: 1, // For migrations
      // Persist only specific fields
      partialize: (state) => ({ count: state.count }), // Skip loading state
      // Custom storage
      storage: sessionStorage, // or custom storage
    }
  )
);
```

### DevTools Middleware

Enable time-travel debugging:

```javascript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }), { name: 'CountStore' })
);

// In browser: Open Redux DevTools Extension
// - See all actions
// - Time-travel through state
// - Inspect state at any point
```

### Immer Middleware

Write mutations that are automatically immutable:

```javascript
import { create } from 'zustand';
import { immer } from 'zustand/middleware';

const useStore = create(
  immer((set) => ({
    items: [],
    nested: { count: 0 },

    // Mutations look natural
    addItem: (item) =>
      set((state) => {
        state.items.push(item);
      }),

    // Deep updates
    incrementNested: () =>
      set((state) => {
        state.nested.count++;
      }),
  }))
);
```

### Custom Middleware

```javascript
const loggerMiddleware = (config) => (set, get, api) =>
  config(
    (...args) => {
      console.log('Previous state:', get());
      set(...args);
      console.log('New state:', get());
    },
    get,
    api
  );

const useStore = create(
  loggerMiddleware((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);
```

## Subscriptions

Listen to state changes outside of React components:

```javascript
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => {
    console.log('Count changed:', count);
  }
);

// Stop listening
unsubscribe();
```

### Subscription Examples

```javascript
// Listen to entire state
const unsubscribe = useStore.subscribe(
  (state) => state,
  (state) => {
    console.log('State updated:', state);
  }
);

// Listen to specific property
const unsubscribe = useStore.subscribe(
  (state) => state.user?.id,
  (userId) => {
    console.log('User ID changed:', userId);
  }
);

// Sync with external system
const unsubscribe = useStore.subscribe(
  (state) => state.data,
  (data) => {
    // Send to server
    api.updateData(data);
  }
);

// Cleanup
useEffect(() => {
  return unsubscribe;
}, []);
```

## React Integration

### Using in Components

```javascript
function Counter() {
  // Subscribe to count state only
  const count = useStore((state) => state.count);
  const increment = useStore((state) => state.increment);

  return (
    <button onClick={increment}>
      Count: {count}
    </button>
  );
}
```

### Multiple Values with useShallow

```javascript
import { useShallow } from 'zustand/react';

function UserInfo() {
  // Re-renders only when name or email change
  const { name, email } = useStore(
    useShallow((state) => ({
      name: state.user?.name,
      email: state.user?.email,
    }))
  );

  return <div>{name} ({email})</div>;
}
```

### Optional: Provider Pattern

```javascript
// If you prefer Provider, create one
const StoreProvider = ({ children }) => children;

function App() {
  return (
    <StoreProvider>
      <Counter />
    </StoreProvider>
  );
}

// No setup needed - just use useStore directly
```

## Async Operations

### Promise-based Actions

```javascript
const useStore = create((set) => ({
  user: null,
  loading: false,
  error: null,

  fetchUser: async (id) => {
    set({ loading: true, error: null });
    try {
      const response = await fetch(`/api/users/${id}`);
      const user = await response.json();
      set({ user, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },
}));

// Usage
function UserProfile({ userId }) {
  const { user, loading, error, fetchUser } = useStore();

  useEffect(() => {
    fetchUser(userId);
  }, [userId, fetchUser]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div>{user?.name}</div>;
}
```

### Async Thunk Pattern

```javascript
const useStore = create((set, get) => ({
  data: null,
  loading: false,

  // Thunk action
  loadData: async () => {
    set({ loading: true });
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      set({ data, loading: false });
    } catch (error) {
      set({ loading: false });
      console.error(error);
    }
  },

  // Action that uses get() to access state
  updateData: async (id, updates) => {
    const currentData = get().data;
    const newData = currentData.map((item) =>
      item.id === id ? { ...item, ...updates } : item
    );
    set({ data: newData });
  },
}));
```

## Testing

### Testing Store Directly

```javascript
import { renderHook, act } from '@testing-library/react';
import { useStore } from './store';

describe('Store', () => {
  beforeEach(() => {
    // Reset state
    useStore.setState({ count: 0 });
  });

  it('increments count', () => {
    const { result } = renderHook(() => useStore());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('can access state directly', () => {
    act(() => {
      useStore.setState({ count: 5 });
    });

    const state = useStore.getState();
    expect(state.count).toBe(5);
  });
});
```

### Testing Selectors

```javascript
test('count selector', () => {
  const { result } = renderHook(() =>
    useStore((state) => state.count)
  );

  expect(result.current).toBe(0);

  act(() => {
    useStore.getState().increment();
  });

  expect(result.current).toBe(1);
});
```

## Performance

### Subscription Optimization

```javascript
// ✓ GOOD: Subscribe to specific value
const count = useStore((state) => state.count);

// ✗ BAD: Subscribe to object (creates new object each render)
const { count, loading } = useStore((state) => ({
  count: state.count,
  loading: state.loading,
})); // Causes re-render even if values didn't change

// ✓ GOOD: Use useShallow for objects
const { count, loading } = useStore(
  useShallow((state) => ({
    count: state.count,
    loading: state.loading,
  }))
);
```

### Batching Updates

```javascript
// Multiple updates
set({ count: 1 });
set({ loading: false });
// Components re-render twice

// Better: Batch updates
set({
  count: 1,
  loading: false,
});
// Components re-render once
```

### Using getState() for Non-React Code

```javascript
// Don't use hooks outside components
// Use getState() instead
const state = useStore.getState();
console.log(state.count);

// For actions
useStore.getState().increment();
```

## Summary

Zustand provides:
- **Minimal API**: Just `create()` and hooks
- **Performance**: Automatic subscription optimization
- **Flexibility**: Works with or without React Context
- **Powerful Features**: Middleware, DevTools, Immer
- **Small Bundle**: ~2KB gzipped

Best practices:
1. Use selectors to subscribe to specific state
2. Use useShallow for object selectors
3. Leverage middleware for persistence and debugging
4. Use getState() outside React components
5. Test stores independently
6. Consider immer for complex state updates
7. Split large stores into smaller stores
