# Context API Patterns - Real-World Patterns

## Table of Contents
1. [Provider Pattern](#provider-pattern)
2. [Custom Hook Abstraction](#custom-hook-abstraction)
3. [useContext + useReducer](#usecontext--usereducer)
4. [Context Composition](#context-composition)
5. [Splitting Contexts](#splitting-contexts)
6. [State Management Patterns](#state-management-patterns)
7. [Async Operations](#async-operations)
8. [Testing Strategies](#testing-strategies)
9. [Common Pitfalls](#common-pitfalls)

## Provider Pattern

The fundamental pattern for Context API usage.

### Basic Provider Implementation

```javascript
import React, { useState, createContext } from 'react';

// Create context
const ThemeContext = createContext();

// Create provider component
export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// Export custom hook
export function useTheme() {
  const context = React.useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Usage in App
function App() {
  return (
    <ThemeProvider>
      <Header />
      <Content />
    </ThemeProvider>
  );
}

// Usage in component
function Header() {
  const { theme, toggleTheme } = useTheme();
  return (
    <header style={{ background: theme === 'light' ? '#fff' : '#333' }}>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </header>
  );
}
```

### Advanced Provider with Memoization

```javascript
import React, { useState, useCallback, useMemo } from 'react';

export function AdvancedThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  // Memoize callback to prevent recreating on each render
  const toggleTheme = useCallback(() => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  }, []);

  // Memoize context value to prevent unnecessary re-renders
  const value = useMemo(() => ({
    theme,
    toggleTheme,
  }), [theme, toggleTheme]);

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
}
```

## Custom Hook Abstraction

Encapsulate context consumption in custom hooks for cleaner API.

### Single Custom Hook

```javascript
import { useContext } from 'react';

const AppContext = React.createContext(null);

export function useApp() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
}

// Usage in component
function MyComponent() {
  const { user, loading, error } = useApp();
  return <div>{user?.name}</div>;
}
```

### Multiple Specialized Hooks

```javascript
export function useAppState() {
  const { user, loading, error } = useApp();
  return { user, loading, error };
}

export function useAppActions() {
  const { login, logout, fetchUser } = useApp();
  return { login, logout, fetchUser };
}

export function useUser() {
  const { user } = useApp();
  return user;
}

export function useIsLoading() {
  const { loading } = useApp();
  return loading;
}

// Usage - components import only what they need
function UserCard() {
  const user = useUser(); // Only this value triggers re-renders
  return <div>{user?.name}</div>;
}

function LoginForm() {
  const { login } = useAppActions();
  return <form onSubmit={(e) => login(e)}>{...}</form>;
}
```

### Computed Value Hook

```javascript
export function useAppComputed() {
  const context = useApp();
  const { user, loading, error } = context;

  // Computed values - only calculate when deps change
  return useMemo(() => ({
    isAuthenticated: user !== null,
    hasError: error !== null,
    isIdle: !loading && user !== null,
    isLoading: loading,
  }), [user, loading, error]);
}

// Usage
function LoginStatus() {
  const { isAuthenticated, isLoading } = useAppComputed();

  if (isLoading) return <p>Logging in...</p>;
  return <p>{isAuthenticated ? 'Logged In' : 'Logged Out'}</p>;
}
```

## useContext + useReducer

Combine for powerful state management.

### Basic Reducer Pattern

```javascript
import React, { useReducer, createContext, useCallback, useMemo } from 'react';

const AppContext = createContext(null);

// Action types
const ACTIONS = {
  SET_USER: 'SET_USER',
  SET_LOADING: 'SET_LOADING',
  SET_ERROR: 'SET_ERROR',
  LOGOUT: 'LOGOUT',
};

// Initial state
const initialState = {
  user: null,
  loading: false,
  error: null,
};

// Reducer
function appReducer(state, action) {
  switch (action.type) {
    case ACTIONS.SET_USER:
      return { ...state, user: action.payload, error: null };

    case ACTIONS.SET_LOADING:
      return { ...state, loading: action.payload };

    case ACTIONS.SET_ERROR:
      return { ...state, error: action.payload, loading: false };

    case ACTIONS.LOGOUT:
      return { ...state, user: null };

    default:
      return state;
  }
}

// Provider
export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(appReducer, initialState);

  // Action helpers
  const login = useCallback(async (email, password) => {
    dispatch({ type: ACTIONS.SET_LOADING, payload: true });
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });
      const user = await response.json();
      dispatch({ type: ACTIONS.SET_USER, payload: user });
    } catch (error) {
      dispatch({ type: ACTIONS.SET_ERROR, payload: error.message });
    }
  }, []);

  const logout = useCallback(() => {
    dispatch({ type: ACTIONS.LOGOUT });
  }, []);

  const value = useMemo(() => ({
    state,
    dispatch,
    login,
    logout,
  }), [state, login, logout]);

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = React.useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
}
```

### Reducer with Thunks

```javascript
// Action for async operations
const THUNK_ACTIONS = {
  fetchUser: (userId) => async (dispatch) => {
    dispatch({ type: ACTIONS.SET_LOADING, payload: true });
    try {
      const response = await fetch(`/api/users/${userId}`);
      const user = await response.json();
      dispatch({ type: ACTIONS.SET_USER, payload: user });
    } catch (error) {
      dispatch({ type: ACTIONS.SET_ERROR, payload: error.message });
    }
  },
};

// Thunk middleware helper
function useThunkDispatch() {
  const { dispatch } = useApp();

  return useCallback((action) => {
    if (typeof action === 'function') {
      return action(dispatch);
    }
    return dispatch(action);
  }, [dispatch]);
}

// Usage in component
function UserProfile({ userId }) {
  const thunkDispatch = useThunkDispatch();

  useEffect(() => {
    thunkDispatch(THUNK_ACTIONS.fetchUser(userId));
  }, [userId, thunkDispatch]);

  // ...
}
```

## Context Composition

Combining multiple contexts effectively.

### Stacked Providers

```javascript
function RootProviders({ children }) {
  return (
    <ThemeProvider>
      <AuthProvider>
        <NotificationProvider>
          <LanguageProvider>
            {children}
          </LanguageProvider>
        </NotificationProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}

// In App.js
function App() {
  return (
    <RootProviders>
      <Header />
      <MainContent />
      <Footer />
    </RootProviders>
  );
}
```

### Composed Provider Component

```javascript
// Create a single component that wraps all providers
export function AppProviders({ children }) {
  return (
    <ThemeProvider>
      <AuthProvider>
        <DataProvider>
          {children}
        </DataProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}

// Simplified usage
<AppProviders>
  <App />
</AppProviders>
```

### Shared Context State

```javascript
// Multiple contexts sharing data
const AppStateContext = createContext(null);
const AppActionsContext = createContext(null);

export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  const value = useMemo(() => ({
    state,
    dispatch,
  }), [state]);

  return (
    <AppStateContext.Provider value={state}>
      <AppActionsContext.Provider value={dispatch}>
        {children}
      </AppActionsContext.Provider>
    </AppStateContext.Provider>
  );
}

// Separate hooks for state and actions
export function useAppState() {
  return React.useContext(AppStateContext);
}

export function useAppDispatch() {
  return React.useContext(AppActionsContext);
}
```

## Splitting Contexts

Break large contexts into smaller, focused ones.

### Before: Monolithic Context

```javascript
// Too much state in one context
const state = {
  user: { ...userState },
  notifications: { ...notificationsState },
  ui: { ...uiState },
  data: { ...dataState },
  settings: { ...settingsState },
};

// Every consumer re-renders when ANY value changes
function Component() {
  const { user, notifications, ui, data, settings } = useAppContext();
}
```

### After: Split Contexts

```javascript
// Separate contexts by domain
const UserContext = createContext(null);
const NotificationContext = createContext(null);
const UIContext = createContext(null);
const DataContext = createContext(null);

// Providers
export function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

export function NotificationProvider({ children }) {
  const [notifications, setNotifications] = useState([]);
  return (
    <NotificationContext.Provider value={{ notifications, setNotifications }}>
      {children}
    </NotificationContext.Provider>
  );
}

// Custom hooks only subscribe to relevant context
export function useUser() {
  return React.useContext(UserContext);
}

export function useNotifications() {
  return React.useContext(NotificationContext);
}

// Components only re-render when their specific context changes
function UserCard() {
  const { user } = useUser(); // Only re-renders on user changes
  return <div>{user?.name}</div>;
}

function NotificationCenter() {
  const { notifications } = useNotifications(); // Only re-renders on notification changes
  return <div>{notifications.length} notifications</div>;
}
```

## State Management Patterns

### Normalized State Pattern

```javascript
const initialState = {
  users: {
    byId: { 1: { id: 1, name: 'Alice' } },
    allIds: [1],
  },
  posts: {
    byId: { 1: { id: 1, title: 'First', authorId: 1 } },
    allIds: [1],
  },
};

function reducer(state, action) {
  switch (action.type) {
    case 'ADD_USER':
      return {
        ...state,
        users: {
          byId: { ...state.users.byId, [action.payload.id]: action.payload },
          allIds: [...state.users.allIds, action.payload.id],
        },
      };
    // ... other actions
  }
}

// Selector hooks for accessing normalized data
export function useUser(userId) {
  const { state } = useApp();
  return state.users.byId[userId];
}

export function useAllUsers() {
  const { state } = useApp();
  return state.users.allIds.map(id => state.users.byId[id]);
}
```

### Immer for Immutable Updates

```javascript
import produce from 'immer';

function reducer(state, action) {
  return produce(state, draft => {
    switch (action.type) {
      case 'ADD_USER':
        draft.users[action.payload.id] = action.payload;
        break;

      case 'UPDATE_USER':
        Object.assign(draft.users[action.payload.id], action.payload.updates);
        break;

      case 'DELETE_USER':
        delete draft.users[action.payload];
        break;
    }
  });
}

// Looks like mutation but is safe with Immer
```

## Async Operations

### Fetch Pattern

```javascript
const ASYNC_ACTIONS = {
  FETCH_REQUEST: 'FETCH_REQUEST',
  FETCH_SUCCESS: 'FETCH_SUCCESS',
  FETCH_ERROR: 'FETCH_ERROR',
};

export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  const fetchData = useCallback(async (url) => {
    dispatch({ type: ASYNC_ACTIONS.FETCH_REQUEST });
    try {
      const response = await fetch(url);
      const data = await response.json();
      dispatch({ type: ASYNC_ACTIONS.FETCH_SUCCESS, payload: data });
    } catch (error) {
      dispatch({ type: ASYNC_ACTIONS.FETCH_ERROR, payload: error.message });
    }
  }, []);

  return (
    <AppContext.Provider value={{ state, dispatch, fetchData }}>
      {children}
    </AppContext.Provider>
  );
}
```

### Polling Pattern

```javascript
export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  const startPolling = useCallback((url, interval = 5000) => {
    const pollInterval = setInterval(() => {
      fetchData(url);
    }, interval);

    return () => clearInterval(pollInterval);
  }, []);

  return (
    <AppContext.Provider value={{ state, dispatch, startPolling }}>
      {children}
    </AppContext.Provider>
  );
}

// Usage
useEffect(() => {
  const cleanup = startPolling('/api/data');
  return cleanup;
}, [startPolling]);
```

## Testing Strategies

### Test Provider Setup

```javascript
import { render, screen } from '@testing-library/react';
import { AppProvider } from './AppProvider';
import { useApp } from './useApp';

function TestComponent() {
  const { state } = useApp();
  return <div>{state.user?.name}</div>;
}

describe('AppProvider', () => {
  it('provides context to children', () => {
    render(
      <AppProvider>
        <TestComponent />
      </AppProvider>
    );

    expect(screen.getByText(/Guest/)).toBeInTheDocument();
  });
});
```

### Mock Context Provider

```javascript
// Create mock provider for testing
export function createMockProvider(mockValue) {
  return function MockProvider({ children }) {
    return (
      <AppContext.Provider value={mockValue}>
        {children}
      </AppContext.Provider>
    );
  };
}

// Usage in tests
const mockAppValue = {
  state: { user: { id: 1, name: 'Test User' } },
  dispatch: jest.fn(),
};

const MockProvider = createMockProvider(mockAppValue);

test('shows user name', () => {
  render(
    <MockProvider>
      <UserCard />
    </MockProvider>
  );

  expect(screen.getByText('Test User')).toBeInTheDocument();
});
```

## Common Pitfalls

### 1. Creating Context Inside Provider

```javascript
// ✗ WRONG: Creates new context on every render
function BadProvider({ children }) {
  const BadContext = React.createContext(); // New context each time!
  return (
    <BadContext.Provider value={...}>
      {children}
    </BadContext.Provider>
  );
}

// ✓ CORRECT: Context created once
const AppContext = React.createContext();

function GoodProvider({ children }) {
  return (
    <AppContext.Provider value={...}>
      {children}
    </AppContext.Provider>
  );
}
```

### 2. Object Recreation in Value

```javascript
// ✗ WRONG: New object every render
<AppContext.Provider value={{ user: state.user, loading: state.loading }}>

// ✓ CORRECT: Memoized value
const value = useMemo(() => ({
  user: state.user,
  loading: state.loading,
}), [state.user, state.loading]);

<AppContext.Provider value={value}>
```

### 3. Over-Subscribing to Context

```javascript
// ✗ WRONG: Component re-renders when unrelated values change
function UserCard() {
  const { user, notifications, theme } = useAppContext();
  return <div>{user?.name}</div>; // Re-renders on theme change too!
}

// ✓ CORRECT: Only subscribe to needed values
function useUser() {
  const context = useContext(AppContext);
  return context?.user;
}

function UserCard() {
  const user = useUser(); // Only re-renders on user change
  return <div>{user?.name}</div>;
}
```

### 4. Using Context Without Default Value

```javascript
// ✗ WRONG: Undefined context crashes component
function MyComponent() {
  const context = useContext(AppContext); // Could be undefined
  return <div>{context.user.name}</div>; // TypeError!
}

// ✓ CORRECT: Always check or throw error
function useApp() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
}
```

## Summary

Context API patterns provide:
- **Encapsulation**: Custom hooks hide complexity
- **Composition**: Combine multiple contexts cleanly
- **Performance**: Memoization and context splitting
- **Simplicity**: For moderate state complexity
- **Testing**: Easy to test with mock providers
- **Flexibility**: Scale from simple to complex state

Best practices:
1. Create context at module level, not in components
2. Memoize context values with useMemo
3. Use custom hooks for accessing context
4. Split large contexts into smaller domains
5. Always error handle in custom hooks
6. Test providers thoroughly
7. Consider Redux/Zustand for complex apps
