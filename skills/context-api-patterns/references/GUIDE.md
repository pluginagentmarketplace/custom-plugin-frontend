# Context API Patterns - Comprehensive Guide

## Table of Contents
1. [Context Fundamentals](#context-fundamentals)
2. [useContext Hook](#usecontext-hook)
3. [Provider Pattern](#provider-pattern)
4. [useReducer Integration](#usereducer-integration)
5. [Custom Hooks](#custom-hooks)
6. [Performance Optimization](#performance-optimization)
7. [Advanced Patterns](#advanced-patterns)
8. [Testing Context](#testing-context)

## Context Fundamentals

React Context provides a way to pass data through the component tree without having to pass props down manually at every level. It solves the "prop drilling" problem where props must be passed through many intermediate components.

### Creating a Context

```javascript
import React from 'react';

// Create a context with default value
const ThemeContext = React.createContext({
  theme: 'light',
  toggleTheme: () => {},
});

export default ThemeContext;
```

The default value passed to `createContext()` is used when no Provider is found above a component that consumes the context.

### Context Components

A Context has two main parts:
1. **Context Object**: Created by `createContext()`
2. **Provider Component**: Supplies value to consuming components
3. **Consumer Components**: Access value via `useContext()` or `<Context.Consumer>`

## useContext Hook

`useContext` is the primary way to consume context in functional components.

### Basic Usage

```javascript
import React, { useContext } from 'react';
import ThemeContext from './ThemeContext';

function ThemedButton() {
  const { theme, toggleTheme } = useContext(ThemeContext);

  return (
    <button
      style={{
        background: theme === 'light' ? '#fff' : '#000',
        color: theme === 'light' ? '#000' : '#fff',
      }}
      onClick={toggleTheme}
    >
      Current theme: {theme}
    </button>
  );
}
```

### Default Values

When `useContext` is called outside a Provider, it uses the default value:

```javascript
// If ThemeContext has a default value
const context = useContext(ThemeContext); // Uses default if no Provider above

// Warning: Using undefined context values causes errors
// Solution: Always provide default values or throw error in hook
```

### Error Handling in Hooks

```javascript
function useTheme() {
  const context = useContext(ThemeContext);

  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }

  return context;
}

function App() {
  return (
    <ThemeProvider>
      <ThemedButton /> {/* OK: Inside Provider */}
    </ThemeProvider>
  );
}

// <ThemedButton /> outside provider would throw error
```

## Provider Pattern

The Provider pattern wraps components and supplies context value to all descendants.

### Basic Provider Implementation

```javascript
import React, { useState } from 'react';
import ThemeContext from './ThemeContext';

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  const value = {
    theme,
    toggleTheme,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
}

// Usage
function App() {
  return (
    <ThemeProvider>
      <Header />
      <MainContent />
      <Footer />
    </ThemeProvider>
  );
}
```

### Provider with Complex State

```javascript
import React, { useReducer } from 'react';

function AppProvider({ children }) {
  const [state, dispatch] = useReducer(appReducer, initialState);

  const value = {
    state,
    dispatch,
  };

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}
```

### Provider Composition

Combining multiple providers:

```javascript
function MultiProvider({ children }) {
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

// Usage
<MultiProvider>
  <App />
</MultiProvider>
```

## useReducer Integration

For complex state management, combine `useReducer` with Context.

### Reducer with Context

```javascript
// Action types
const ACTION_TYPES = {
  SET_USER: 'SET_USER',
  SET_LOADING: 'SET_LOADING',
  SET_ERROR: 'SET_ERROR',
};

// Initial state
const initialState = {
  user: null,
  loading: false,
  error: null,
};

// Reducer function
function authReducer(state, action) {
  switch (action.type) {
    case ACTION_TYPES.SET_USER:
      return { ...state, user: action.payload, error: null };

    case ACTION_TYPES.SET_LOADING:
      return { ...state, loading: action.payload };

    case ACTION_TYPES.SET_ERROR:
      return { ...state, error: action.payload, loading: false };

    default:
      return state;
  }
}

// Provider with reducer
function AuthProvider({ children }) {
  const [state, dispatch] = useReducer(authReducer, initialState);

  const login = async (email, password) => {
    dispatch({ type: ACTION_TYPES.SET_LOADING, payload: true });
    try {
      const user = await authenticate(email, password);
      dispatch({ type: ACTION_TYPES.SET_USER, payload: user });
    } catch (error) {
      dispatch({ type: ACTION_TYPES.SET_ERROR, payload: error.message });
    }
  };

  const logout = () => {
    dispatch({ type: ACTION_TYPES.SET_USER, payload: null });
  };

  const value = { state, dispatch, login, logout };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}
```

## Custom Hooks

Custom hooks encapsulate context consumption and provide a cleaner API.

### Simple Custom Hook

```javascript
function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }

  return context;
}

// Usage in component
function Profile() {
  const { state, logout } = useAuth();

  return (
    <div>
      <h1>Welcome, {state.user?.name}</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

### Custom Hook with Selectors

```javascript
function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
}

function useUser() {
  const { state } = useAuth();
  return state.user;
}

function useIsAuthenticated() {
  const { state } = useAuth();
  return state.user !== null;
}

function useAuthActions() {
  const { login, logout } = useAuth();
  return { login, logout };
}

// Usage - components can import only what they need
function UserBadge() {
  const user = useUser(); // Only subscribes to user
  return <span>{user?.name}</span>;
}

function LoginForm() {
  const { login } = useAuthActions(); // Only gets actions
  return <form onSubmit={(e) => login(e.target.email.value)}>{...}</form>;
}
```

### Custom Hook with Computed Values

```javascript
function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');

  const { state, ...actions } = context;

  // Computed values
  const isAdmin = state.user?.role === 'admin';
  const isLoaded = state.user !== null || !state.loading;

  return {
    ...state,
    ...actions,
    isAdmin,
    isLoaded,
  };
}

// Usage
function AdminPanel() {
  const { isAdmin, user } = useAuth();

  if (!isAdmin) return null;

  return <div>Admin: {user.name}</div>;
}
```

## Performance Optimization

Context can cause unnecessary re-renders. Optimize with memoization.

### useMemo for Context Value

```javascript
function AppProvider({ children }) {
  const [theme, setTheme] = useState('light');
  const [user, setUser] = useState(null);

  // Without useMemo: New object every render
  // const value = { theme, user };

  // With useMemo: Only new when dependencies change
  const value = useMemo(() => ({
    theme,
    user,
  }), [theme, user]);

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}
```

### useCallback for Functions

```javascript
function AuthProvider({ children }) {
  const [user, setUser] = useState(null);

  // Without useCallback: New function every render
  // const logout = () => setUser(null);

  // With useCallback: Memoized function
  const logout = useCallback(() => {
    setUser(null);
  }, []);

  const value = useMemo(() => ({
    user,
    logout,
  }), [user, logout]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}
```

### React.memo for Consumers

```javascript
// Consumer that only needs theme, won't re-render if other values change
const ThemedComponent = React.memo(({ theme }) => (
  <div style={{ background: theme === 'light' ? '#fff' : '#000' }}>
    Content
  </div>
));

// Separate selectors to prevent unnecessary re-renders
function useTheme() {
  const context = useContext(AppContext);
  return context.theme;
}

function ThemedBox() {
  const theme = useTheme();
  return <ThemedComponent theme={theme} />;
}
```

## Advanced Patterns

### Lazy Initialization

```javascript
function AppProvider({ children, initialState }) {
  const [state, dispatch] = useReducer(appReducer, initialState || {}, (initial) => {
    // Expensive initialization happens here
    return {
      ...initial,
      initialized: true,
      timestamp: Date.now(),
    };
  });

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}
```

### DevTools Integration

```javascript
function AppProvider({ children }) {
  const [state, dispatch] = useReducer(appReducer, initialState);

  // Send actions to Redux DevTools for debugging
  useEffect(() => {
    if (window.__REDUX_DEVTOOLS_EXTENSION__) {
      const devtools = window.__REDUX_DEVTOOLS_EXTENSION__.connect();
      devtools.init(state);
    }
  }, [state]);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}
```

### Persistence Middleware

```javascript
function PersistentProvider({ children }) {
  const [state, dispatch] = useReducer(appReducer, initialState, (initial) => {
    // Load from localStorage
    const saved = localStorage.getItem('appState');
    return saved ? JSON.parse(saved) : initial;
  });

  // Save to localStorage after each update
  useEffect(() => {
    localStorage.setItem('appState', JSON.stringify(state));
  }, [state]);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}
```

## Testing Context

### Testing Provider

```javascript
import { render, screen } from '@testing-library/react';
import AuthProvider from './AuthProvider';
import useAuth from './useAuth';

function TestComponent() {
  const { user } = useAuth();
  return <div>{user?.name || 'Guest'}</div>;
}

test('AuthProvider supplies context', () => {
  render(
    <AuthProvider>
      <TestComponent />
    </AuthProvider>
  );

  expect(screen.getByText('Guest')).toBeInTheDocument();
});
```

### Mocking Context in Tests

```javascript
import { createContext } from 'react';

// Create mock context for testing
export const mockAuthContext = {
  user: { id: 1, name: 'Test User' },
  logout: jest.fn(),
};

// Wrap component with mock provider
function renderWithAuth(component, mockValue = mockAuthContext) {
  return render(
    <AuthContext.Provider value={mockValue}>
      {component}
    </AuthContext.Provider>
  );
}

test('uses context values', () => {
  renderWithAuth(<UserProfile />);
  expect(screen.getByText('Test User')).toBeInTheDocument();
});
```

## Summary

Context API provides:
- **Prop Drilling Solution**: Pass data through nested components cleanly
- **Global State**: Theme, auth, notifications, language
- **Encapsulation**: Custom hooks hide complexity
- **Performance Options**: useMemo, useCallback, React.memo
- **Simplicity**: Compared to Redux for simpler use cases
- **Built-in**: No external dependencies

Best practices:
1. Use custom hooks to encapsulate context access
2. Memoize context values with useMemo
3. Consider splitting large contexts
4. Error handle in custom hooks
5. Test providers and context consumers
6. Prefer Context for simple/moderate state
7. Use Redux/Zustand for complex apps
