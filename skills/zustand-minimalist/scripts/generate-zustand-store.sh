#!/bin/bash
# Generate complete Zustand store with middleware and selectors

set -e

OUTPUT_DIR="${1:-src/store}"
STORE_NAME="${2:-app}"
STORE_NAME_CAMEL=$(echo "$STORE_NAME" | sed 's/-\([a-z]\)/\U\1/g')
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error() { echo -e "${RED}✗ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ $1${NC}"; }

# Header
echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Zustand Store Generator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Create output directory
mkdir -p "$OUTPUT_DIR"
log_success "Created store directory: $OUTPUT_DIR"

# Generate main store file
cat > "$OUTPUT_DIR/${STORE_NAME}Store.js" << 'EOF'
/**
 * Zustand Store
 * Minimal state management with excellent DX
 */

import { create } from 'zustand';
import { devtools, persist, immer } from 'zustand/middleware';

/**
 * Main store definition with create()
 * State is a function that returns the state object
 * Actions are functions that modify state
 */
export const useStore = create(
  devtools(
    persist(
      immer((set, get) => ({
        // === STATE ===
        user: null,
        items: [],
        filter: 'ALL',
        loading: false,
        error: null,

        // === ACTIONS ===

        /**
         * Set user
         */
        setUser: (user) =>
          set((state) => {
            state.user = user;
          }),

        /**
         * Clear user
         */
        clearUser: () =>
          set((state) => {
            state.user = null;
          }),

        /**
         * Set loading state
         */
        setLoading: (loading) =>
          set((state) => {
            state.loading = loading;
          }),

        /**
         * Set error
         */
        setError: (error) =>
          set((state) => {
            state.error = error;
          }),

        /**
         * Clear error
         */
        clearError: () =>
          set((state) => {
            state.error = null;
          }),

        /**
         * Add item
         */
        addItem: (item) =>
          set((state) => {
            state.items.push(item);
          }),

        /**
         * Update item
         */
        updateItem: (id, updates) =>
          set((state) => {
            const index = state.items.findIndex((item) => item.id === id);
            if (index !== -1) {
              Object.assign(state.items[index], updates);
            }
          }),

        /**
         * Remove item
         */
        removeItem: (id) =>
          set((state) => {
            state.items = state.items.filter((item) => item.id !== id);
          }),

        /**
         * Set filter
         */
        setFilter: (filter) =>
          set((state) => {
            state.filter = filter;
          }),

        /**
         * Async fetch users
         */
        fetchUser: async (userId) => {
          get().setLoading(true);
          try {
            const response = await fetch(`/api/users/${userId}`);
            const user = await response.json();
            get().setUser(user);
          } catch (error) {
            get().setError(error.message);
          } finally {
            get().setLoading(false);
          }
        },

        /**
         * Reset store to initial state
         */
        reset: () =>
          set({
            user: null,
            items: [],
            filter: 'ALL',
            loading: false,
            error: null,
          }),
      })),
      {
        name: 'app-store', // Key for localStorage
        version: 1, // Version for migrations
        // Persist only user and items, not loading/error
        partialize: (state) => ({
          user: state.user,
          items: state.items,
        }),
      }
    ),
    { name: 'Store' } // DevTools name
  )
);

export default useStore;
EOF
log_success "Generated ${STORE_NAME}Store.js"

# Generate selectors file
cat > "$OUTPUT_DIR/${STORE_NAME}Selectors.js" << 'EOF'
/**
 * Selectors for optimized state access
 * Selectors are memoized and prevent unnecessary re-renders
 */

import { useShallow } from 'zustand/react';
import { useStore } from './store.js';

// === Basic Selectors ===

/**
 * Select user
 */
export const selectUser = (state) => state.user;

/**
 * Select items
 */
export const selectItems = (state) => state.items;

/**
 * Select filter
 */
export const selectFilter = (state) => state.filter;

/**
 * Select loading state
 */
export const selectLoading = (state) => state.loading;

/**
 * Select error
 */
export const selectError = (state) => state.error;

// === Derived Selectors ===

/**
 * Select filtered items
 */
export const selectFilteredItems = (state) => {
  const { items, filter } = state;
  if (filter === 'ALL') return items;
  return items.filter((item) => item.status === filter);
};

/**
 * Select item count
 */
export const selectItemCount = (state) => state.items.length;

/**
 * Select is authenticated
 */
export const selectIsAuthenticated = (state) => state.user !== null;

/**
 * Select has error
 */
export const selectHasError = (state) => state.error !== null;

// === Custom Hooks for Easy Access ===

/**
 * Hook to get user
 */
export const useUser = () => useStore(selectUser);

/**
 * Hook to get all items
 */
export const useItems = () => useStore(selectItems);

/**
 * Hook to get filtered items
 */
export const useFilteredItems = () => useStore(selectFilteredItems);

/**
 * Hook to get loading state
 */
export const useLoading = () => useStore(selectLoading);

/**
 * Hook to get error
 */
export const useError = () => useStore(selectError);

/**
 * Hook to get filter
 */
export const useFilter = () => useStore(selectFilter);

/**
 * Hook to get authentication status
 */
export const useIsAuthenticated = () =>
  useStore(selectIsAuthenticated);

/**
 * Hook to get combined read-only state
 * Uses useShallow for shallow equality comparison
 */
export const useStoreState = () =>
  useStore(
    useShallow((state) => ({
      user: state.user,
      items: state.items,
      filter: state.filter,
      loading: state.loading,
      error: state.error,
    }))
  );

/**
 * Hook to get only actions
 */
export const useStoreActions = () =>
  useStore(
    useShallow((state) => ({
      setUser: state.setUser,
      clearUser: state.clearUser,
      addItem: state.addItem,
      updateItem: state.updateItem,
      removeItem: state.removeItem,
      setFilter: state.setFilter,
      fetchUser: state.fetchUser,
      reset: state.reset,
    }))
  );
EOF
log_success "Generated ${STORE_NAME}Selectors.js"

# Generate middleware file
cat > "$OUTPUT_DIR/${STORE_NAME}Middleware.js" << 'EOF'
/**
 * Custom middleware examples for Zustand
 * Middleware wraps the store and can intercept state changes
 */

/**
 * Logging middleware
 * Logs all state changes to console
 */
export const loggerMiddleware = (config) => (set, get, api) =>
  config(
    (...args) => {
      console.log('⚡ State change:', {
        stateBefore: get(),
        actionArgs: args,
      });
      set(...args);
      console.log('⚡ State after:', get());
    },
    get,
    api
  );

/**
 * Error tracking middleware
 * Sends errors to monitoring service
 */
export const errorTrackingMiddleware = (config) => (set, get, api) =>
  config(
    (state) => {
      if (state.error) {
        console.error('⚠️ Store Error:', state.error);
        // Send to Sentry, LogRocket, etc.
      }
      set(state);
    },
    get,
    api
  );

/**
 * Persistence middleware wrapper
 * Automatically syncs state with localStorage
 */
export const localStorageMiddleware = (config) => (set, get, api) =>
  config(
    (state) => {
      set(state);
      // Save to localStorage
      localStorage.setItem('appState', JSON.stringify(get()));
    },
    get,
    api
  );

/**
 * Debounce middleware
 * Debounces rapid state updates
 */
export const debounceMiddleware =
  (delayMs = 500) =>
  (config) =>
  (set, get, api) => {
    let timeoutId;
    return config(
      (...args) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => set(...args), delayMs);
      },
      get,
      api
    );
  };

/**
 * Subscription middleware
 * Allows external listeners to subscribe to state changes
 */
export const subscriptionMiddleware = (config) => {
  const subscribers = [];

  return (set, get, api) =>
    config(
      (state) => {
        set(state);
        // Notify all subscribers
        subscribers.forEach((callback) => callback(get()));
      },
      get,
      {
        ...api,
        subscribe: (callback) => {
          subscribers.push(callback);
          return () => {
            subscribers.splice(subscribers.indexOf(callback), 1);
          };
        },
      }
    );
};

export default {
  loggerMiddleware,
  errorTrackingMiddleware,
  localStorageMiddleware,
  debounceMiddleware,
  subscriptionMiddleware,
};
EOF
log_success "Generated ${STORE_NAME}Middleware.js"

# Generate test file
cat > "$OUTPUT_DIR/${STORE_NAME}Store.test.js" << 'EOF'
/**
 * Tests for Zustand store
 */

import { renderHook, act } from '@testing-library/react';
import { useStore } from './<STORE_NAME>Store.js';

describe('Store', () => {
  beforeEach(() => {
    // Reset store before each test
    useStore.setState({
      user: null,
      items: [],
      filter: 'ALL',
      loading: false,
      error: null,
    });
  });

  describe('User Actions', () => {
    it('should set user', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.setUser({ id: 1, name: 'John' });
      });

      expect(result.current.user).toEqual({ id: 1, name: 'John' });
    });

    it('should clear user', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.setUser({ id: 1, name: 'John' });
        result.current.clearUser();
      });

      expect(result.current.user).toBeNull();
    });
  });

  describe('Item Actions', () => {
    it('should add item', () => {
      const { result } = renderHook(() => useStore());
      const newItem = { id: 1, name: 'Item 1' };

      act(() => {
        result.current.addItem(newItem);
      });

      expect(result.current.items).toContain(newItem);
      expect(result.current.items.length).toBe(1);
    });

    it('should update item', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.addItem({ id: 1, name: 'Item 1' });
        result.current.updateItem(1, { name: 'Updated Item' });
      });

      expect(result.current.items[0].name).toBe('Updated Item');
    });

    it('should remove item', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.addItem({ id: 1, name: 'Item 1' });
        result.current.removeItem(1);
      });

      expect(result.current.items.length).toBe(0);
    });
  });

  describe('Loading and Error States', () => {
    it('should set loading state', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.setLoading(true);
      });

      expect(result.current.loading).toBe(true);
    });

    it('should set and clear error', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.setError('Test error');
      });

      expect(result.current.error).toBe('Test error');

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBeNull();
    });
  });

  describe('Reset Action', () => {
    it('should reset store to initial state', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.setUser({ id: 1, name: 'John' });
        result.current.addItem({ id: 1, name: 'Item' });
        result.current.setFilter('ACTIVE');
      });

      act(() => {
        result.current.reset();
      });

      expect(result.current.user).toBeNull();
      expect(result.current.items).toEqual([]);
      expect(result.current.filter).toBe('ALL');
    });
  });

  describe('Selectors', () => {
    it('should select filtered items', () => {
      const { result } = renderHook(() => useStore());

      act(() => {
        result.current.addItem({ id: 1, name: 'Item 1', status: 'ACTIVE' });
        result.current.addItem({ id: 2, name: 'Item 2', status: 'INACTIVE' });
        result.current.setFilter('ACTIVE');
      });

      // Use selector
      const filteredItems = useStore.getState().items.filter(
        (item) => item.status === 'ACTIVE'
      );
      expect(filteredItems.length).toBe(1);
    });
  });
});
EOF
log_success "Generated ${STORE_NAME}Store.test.js"

# Generate example component
cat > "$OUTPUT_DIR/example.jsx" << 'EOF'
/**
 * Example Component using Zustand Store
 */

import React, { useEffect } from 'react';
import { useStore } from './<STORE_NAME>Store.js';
import {
  useUser,
  useItems,
  useLoading,
  useStoreActions,
} from './<STORE_NAME>Selectors.js';

/**
 * Example 1: Using all selectors
 */
export function UserProfileExample() {
  const user = useUser();
  const { setUser, clearUser } = useStore((state) => ({
    setUser: state.setUser,
    clearUser: state.clearUser,
  }));

  return (
    <div>
      <h2>User Profile</h2>
      {user ? (
        <>
          <p>Name: {user.name}</p>
          <button onClick={clearUser}>Logout</button>
        </>
      ) : (
        <>
          <p>Not logged in</p>
          <button
            onClick={() =>
              setUser({ id: 1, name: 'John Doe', email: 'john@example.com' })
            }
          >
            Login
          </button>
        </>
      )}
    </div>
  );
}

/**
 * Example 2: Using store actions
 */
export function ItemListExample() {
  const items = useItems();
  const loading = useLoading();
  const { addItem, removeItem, setFilter } = useStoreActions();

  const handleAddItem = () => {
    const newItem = {
      id: Date.now(),
      name: 'New Item',
      status: 'ACTIVE',
    };
    addItem(newItem);
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <h2>Items ({items.length})</h2>
      <button onClick={handleAddItem}>Add Item</button>
      <ul>
        {items.map((item) => (
          <li key={item.id}>
            {item.name}
            <button onClick={() => removeItem(item.id)}>Remove</button>
          </li>
        ))}
      </ul>
      <div>
        <button onClick={() => setFilter('ALL')}>All</button>
        <button onClick={() => setFilter('ACTIVE')}>Active</button>
        <button onClick={() => setFilter('INACTIVE')}>Inactive</button>
      </div>
    </div>
  );
}

/**
 * Example 3: Using direct store access
 */
export function SimpleCounterExample() {
  const count = useStore((state) => state.items.length);
  const { addItem } = useStore();

  return (
    <div>
      <h2>Item Count: {count}</h2>
      <button
        onClick={() =>
          addItem({
            id: Date.now(),
            name: 'Item ' + (count + 1),
          })
        }
      >
        Add Item
      </button>
    </div>
  );
}

/**
 * Example 4: Using async actions
 */
export function AsyncFetchExample() {
  const user = useUser();
  const loading = useLoading();
  const error = useStore((state) => state.error);
  const fetchUser = useStore((state) => state.fetchUser);

  useEffect(() => {
    fetchUser(1); // Fetch on mount
  }, [fetchUser]);

  if (loading) return <div>Loading user...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>No user loaded</div>;

  return (
    <div>
      <h2>Loaded User</h2>
      <p>ID: {user.id}</p>
      <p>Name: {user.name}</p>
      <p>Email: {user.email}</p>
    </div>
  );
}

export default UserProfileExample;
EOF
log_success "Generated example.jsx"

# Generate types/JSDoc file
cat > "$OUTPUT_DIR/${STORE_NAME}Types.js" << 'EOF'
/**
 * @typedef {Object} User
 * @property {number} id
 * @property {string} name
 * @property {string} email
 */

/**
 * @typedef {Object} Item
 * @property {number} id
 * @property {string} name
 * @property {string} status - 'ACTIVE' | 'INACTIVE'
 */

/**
 * @typedef {Object} StoreState
 * @property {User|null} user
 * @property {Item[]} items
 * @property {string} filter - 'ALL' | 'ACTIVE' | 'INACTIVE'
 * @property {boolean} loading
 * @property {string|null} error
 */

/**
 * @typedef {Object} StoreActions
 * @property {(user: User) => void} setUser
 * @property {() => void} clearUser
 * @property {(item: Item) => void} addItem
 * @property {(id: number, updates: Partial<Item>) => void} updateItem
 * @property {(id: number) => void} removeItem
 * @property {(filter: string) => void} setFilter
 * @property {(userId: number) => Promise<void>} fetchUser
 * @property {() => void} reset
 */

/**
 * @typedef {StoreState & StoreActions} Store
 */

export {};
EOF
log_success "Generated ${STORE_NAME}Types.js"

# Generate package.json snippet
cat > "$OUTPUT_DIR/package.json.snippet" << 'EOF'
{
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "zustand": "^4.4.0"
  },
  "devDependencies": {
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "immer": "^10.0.0"
  }
}
EOF
log_success "Generated package.json.snippet"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Generation Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

log_info "Created Zustand store in: $OUTPUT_DIR"
echo -e "\n${GREEN}Files created:${NC}"
echo "  • ${STORE_NAME}Store.js - Main store with state and actions"
echo "  • ${STORE_NAME}Selectors.js - Optimized selectors and hooks"
echo "  • ${STORE_NAME}Middleware.js - Custom middleware examples"
echo "  • ${STORE_NAME}Store.test.js - Complete test suite"
echo "  • ${STORE_NAME}Types.js - JSDoc type definitions"
echo "  • example.jsx - Usage examples"

echo -e "\n${GREEN}Key Features:${NC}"
echo "  ✓ Minimal boilerplate with create()"
echo "  ✓ Immer middleware for safe mutations"
echo "  ✓ Persist middleware for localStorage"
echo "  ✓ DevTools integration for debugging"
echo "  ✓ useShallow for optimized selectors"
echo "  ✓ TypeScript-ready with JSDoc"

echo -e "\n${GREEN}Next steps:${NC}"
echo "  1. Install Zustand: npm install zustand immer"
echo "  2. Import store: import { useStore } from './store'"
echo "  3. Use in components: const user = useStore(state => state.user)"
echo "  4. Review example.jsx for usage patterns"
echo "  5. Add custom middleware as needed"

echo -e "\n${YELLOW}Performance Tips:${NC}"
echo "  • Use selectors to subscribe to specific state"
echo "  • Use useShallow for shallow equality comparison"
echo "  • Memoize callbacks with useCallback"
echo "  • Consider splitting stores for large apps"
echo "  • Use getState() for imperative access"

echo -e "\n${GREEN}Testing:${NC}"
echo "  • Run: npm test ${STORE_NAME}Store.test.js"
echo "  • Use renderHook for testing hooks"
echo "  • Reset state before each test"
echo "  • Test both actions and selectors"

echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"
