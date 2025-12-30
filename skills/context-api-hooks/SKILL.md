---
name: context-api-hooks
description: Master React Context API and custom hooks for state management without Redux.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 04-state-management-agent
bond_type: SECONDARY_BOND
production_config:
  performance_budget:
    hook_execution_time: "5ms"
    context_propagation_time: "10ms"
    max_hook_depth: 10
  optimization:
    memoization_enabled: true
    batched_updates: true
    lazy_initialization: true
  monitoring:
    hook_performance: true
    re_render_tracking: true
    dependency_analysis: true
---

# Context API & Custom Hooks

Master React's built-in state management solution with Context API and custom hooks for creating maintainable, performant applications without external dependencies.

## Input Schema

```typescript
interface ContextHookConfiguration {
  context: {
    name: string;
    defaultValue: any;
    type: 'single' | 'compound' | 'split';
  };
  hooks: {
    name: string;
    dependencies: string[];
    memoized: boolean;
    selector?: boolean;
  }[];
  providers: {
    composition: 'nested' | 'flat' | 'factory';
    lazy: boolean;
  };
}

interface CustomHookDefinition<T> {
  name: string;
  inputs: Parameter[];
  outputs: T;
  dependencies: any[];
  cleanup?: () => void;
}
```

## Output Schema

```typescript
interface ContextHookImplementation<T> {
  Context: React.Context<T>;
  Provider: React.ComponentType<{
    children: ReactNode;
    value?: T;
  }>;
  hooks: {
    useContext: () => T;
    useSelector: <S>(selector: (state: T) => S) => S;
    useActions: () => Actions;
  };
  utilities: {
    withContext: (Component: ComponentType) => ComponentType;
    createSelector: <S>(selector: (state: T) => S) => () => S;
  };
}

interface HookPerformanceMetrics {
  executionTime: number;
  renderCount: number;
  dependencyChanges: number;
  memoizationHits: number;
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `HOOK_OUTSIDE_PROVIDER` | Hook called outside Provider | Wrap in Provider component | Add Provider to component tree |
| `HOOK_RULES_VIOLATION` | Hooks called conditionally | Move hooks to top level | Follow Rules of Hooks |
| `INFINITE_LOOP` | Hook dependencies cause re-render loop | Fix dependency array | Use useCallback/useMemo properly |
| `STALE_CLOSURE` | Captured stale values in callback | Update dependencies | Include all used values in deps |
| `MEMORY_LEAK` | Missing cleanup in useEffect | Add cleanup function | Return cleanup from useEffect |
| `DEFAULT_VALUE_ERROR` | Default context value is undefined | Provide valid default | Set meaningful default value |
| `TYPE_MISMATCH` | TypeScript type errors in context | Fix type definitions | Use proper TypeScript types |
| `UNNECESSARY_RENDERS` | Context updates trigger too many renders | Split context or memoize | Use context splitting pattern |

## MANDATORY

### Creating Context with createContext
```javascript
import { createContext, useContext, useState } from 'react';

// Create context with default value
const UserContext = createContext({
  user: null,
  setUser: () => {},
  isAuthenticated: false
});

// Set display name for DevTools
UserContext.displayName = 'UserContext';

// Alternative: undefined default with type safety
const ThemeContext = createContext(undefined);

// Type-safe context (TypeScript)
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);
```

### Provider Component Setup
```javascript
import { useState, useMemo } from 'react';

// Simple Provider
export function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const value = useMemo(() => ({
    user,
    setUser,
    isAuthenticated,
    setIsAuthenticated,
    login: async (credentials) => {
      const userData = await api.login(credentials);
      setUser(userData);
      setIsAuthenticated(true);
    },
    logout: () => {
      setUser(null);
      setIsAuthenticated(false);
    }
  }), [user, isAuthenticated]);

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}

// Provider with reducer
import { useReducer } from 'react';

function userReducer(state, action) {
  switch (action.type) {
    case 'LOGIN':
      return { ...state, user: action.payload, isAuthenticated: true };
    case 'LOGOUT':
      return { user: null, isAuthenticated: false };
    default:
      return state;
  }
}

export function UserProviderWithReducer({ children }) {
  const [state, dispatch] = useReducer(userReducer, {
    user: null,
    isAuthenticated: false
  });

  const value = useMemo(() => ({ ...state, dispatch }), [state]);

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}
```

### useContext Hook Usage
```javascript
import { useContext } from 'react';

// Consuming context directly
function UserProfile() {
  const { user, logout } = useContext(UserContext);

  if (!user) {
    return <div>Not logged in</div>;
  }

  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}

// Custom hook wrapper (recommended)
export function useUser() {
  const context = useContext(UserContext);

  if (context === undefined) {
    throw new Error('useUser must be used within UserProvider');
  }

  return context;
}

// Using custom hook
function Dashboard() {
  const { user, isAuthenticated } = useUser();

  return (
    <div>
      {isAuthenticated ? (
        <h1>Welcome, {user.name}!</h1>
      ) : (
        <LoginForm />
      )}
    </div>
  );
}
```

### Context with TypeScript
```typescript
import { createContext, useContext, ReactNode, useState } from 'react';

// Define types
interface User {
  id: string;
  name: string;
  email: string;
}

interface UserContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

// Create typed context
const UserContext = createContext<UserContextType | undefined>(undefined);

// Typed Provider
interface UserProviderProps {
  children: ReactNode;
}

export function UserProvider({ children }: UserProviderProps) {
  const [user, setUser] = useState<User | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const login = async (credentials: Credentials) => {
    const userData = await api.login(credentials);
    setUser(userData);
    setIsAuthenticated(true);
  };

  const logout = () => {
    setUser(null);
    setIsAuthenticated(false);
  };

  const value: UserContextType = {
    user,
    isAuthenticated,
    login,
    logout
  };

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}

// Typed hook
export function useUser(): UserContextType {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within UserProvider');
  }
  return context;
}
```

### Avoiding Prop Drilling
```javascript
// Before: Prop drilling
function App() {
  const [theme, setTheme] = useState('light');
  return <Layout theme={theme} setTheme={setTheme} />;
}

function Layout({ theme, setTheme }) {
  return <Sidebar theme={theme} setTheme={setTheme} />;
}

function Sidebar({ theme, setTheme }) {
  return <ThemeToggle theme={theme} setTheme={setTheme} />;
}

// After: Using Context
function App() {
  return (
    <ThemeProvider>
      <Layout />
    </ThemeProvider>
  );
}

function Layout() {
  return <Sidebar />;
}

function Sidebar() {
  return <ThemeToggle />;
}

function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();
  return <button onClick={toggleTheme}>Toggle {theme}</button>;
}
```

### Default Values
```javascript
// Meaningful default values
const ConfigContext = createContext({
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3
});

// Default functions that warn
const defaultContextValue = {
  user: null,
  login: () => {
    console.warn('login called outside UserProvider');
  },
  logout: () => {
    console.warn('logout called outside UserProvider');
  }
};

const UserContext = createContext(defaultContextValue);

// No default (requires Provider)
const DataContext = createContext(undefined);

export function useData() {
  const context = useContext(DataContext);
  if (context === undefined) {
    throw new Error('useData must be used within DataProvider');
  }
  return context;
}
```

## OPTIONAL

### Multiple Contexts
```javascript
// Define multiple contexts
const ThemeContext = createContext();
const UserContext = createContext();
const DataContext = createContext();

// Compose providers
function AppProviders({ children }) {
  return (
    <ThemeProvider>
      <UserProvider>
        <DataProvider>
          {children}
        </DataProvider>
      </UserProvider>
    </ThemeProvider>
  );
}

// Use multiple contexts in component
function ComplexComponent() {
  const { theme } = useTheme();
  const { user } = useUser();
  const { data } = useData();

  return (
    <div className={theme}>
      <h1>Hello, {user.name}</h1>
      <DataDisplay data={data} />
    </div>
  );
}
```

### Context with useReducer
```javascript
import { createContext, useContext, useReducer, useMemo } from 'react';

// Define state and actions
const initialState = {
  items: [],
  loading: false,
  error: null,
  filter: 'ALL'
};

function todoReducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM':
      return {
        ...state,
        items: [...state.items, action.payload]
      };
    case 'REMOVE_ITEM':
      return {
        ...state,
        items: state.items.filter(item => item.id !== action.payload)
      };
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload };
    case 'SET_FILTER':
      return { ...state, filter: action.payload };
    default:
      return state;
  }
}

const TodoContext = createContext();

export function TodoProvider({ children }) {
  const [state, dispatch] = useReducer(todoReducer, initialState);

  // Memoize value to prevent unnecessary re-renders
  const value = useMemo(() => ({ state, dispatch }), [state]);

  return (
    <TodoContext.Provider value={value}>
      {children}
    </TodoContext.Provider>
  );
}

export function useTodos() {
  const context = useContext(TodoContext);
  if (!context) {
    throw new Error('useTodos must be used within TodoProvider');
  }
  return context;
}
```

### Performance Considerations
```javascript
import { memo, useMemo, useCallback } from 'react';

// 1. Memoize context value
function OptimizedProvider({ children }) {
  const [state, setState] = useState(initialState);

  const value = useMemo(() => ({
    state,
    updateState: setState
  }), [state]); // Only recreate when state changes

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}

// 2. Split contexts by update frequency
const DataContext = createContext(); // Rarely changes
const UIContext = createContext(); // Changes frequently

// 3. Memoize child components
const ExpensiveChild = memo(function ExpensiveChild({ data }) {
  // Only re-renders when data prop changes
  return <div>{/* expensive computation */}</div>;
});

// 4. Use selective consumption
function SelectiveConsumer() {
  const { user } = useUser(); // Only subscribes to user
  // Won't re-render when other context values change
  return <div>{user.name}</div>;
}
```

### Context Composition
```javascript
// Compose contexts efficiently
function combineProviders(...providers) {
  return providers.reduce(
    (Combined, Provider) =>
      ({ children }) => (
        <Combined>
          <Provider>{children}</Provider>
        </Combined>
      ),
    ({ children }) => <>{children}</>
  );
}

const AllProviders = combineProviders(
  ThemeProvider,
  UserProvider,
  DataProvider
);

function App() {
  return (
    <AllProviders>
      <Main />
    </AllProviders>
  );
}
```

### Custom Provider Hooks
```javascript
// Custom hook that provides both state and actions
export function useAuthProvider() {
  const [state, dispatch] = useReducer(authReducer, initialState);

  const actions = useMemo(() => ({
    login: async (credentials) => {
      dispatch({ type: 'LOGIN_START' });
      try {
        const user = await api.login(credentials);
        dispatch({ type: 'LOGIN_SUCCESS', payload: user });
      } catch (error) {
        dispatch({ type: 'LOGIN_ERROR', payload: error });
      }
    },
    logout: () => dispatch({ type: 'LOGOUT' })
  }), []);

  return { state, actions };
}

// Use in Provider
export function AuthProvider({ children }) {
  const auth = useAuthProvider();

  return (
    <AuthContext.Provider value={auth}>
      {children}
    </AuthContext.Provider>
  );
}
```

### Context Selectors
```javascript
// Selector pattern for Context
export function useUserSelector(selector) {
  const context = useContext(UserContext);
  return useMemo(() => selector(context), [context, selector]);
}

// Usage
function UserName() {
  const name = useUserSelector(ctx => ctx.user?.name);
  return <span>{name}</span>;
}

// With equality check
import { useRef, useEffect } from 'react';

export function useContextSelector(context, selector, equalityFn = Object.is) {
  const value = useContext(context);
  const selectedRef = useRef();

  const selected = selector(value);

  if (!equalityFn(selected, selectedRef.current)) {
    selectedRef.current = selected;
  }

  return selectedRef.current;
}
```

## ADVANCED

### Context Optimization Patterns
```javascript
// Split state and dispatch contexts
const StateContext = createContext();
const DispatchContext = createContext();

function Provider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <StateContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  );
}

// Consumers only re-render when they need to
function StateConsumer() {
  const state = useContext(StateContext);
  // Re-renders when state changes
  return <div>{state.value}</div>;
}

function ActionConsumer() {
  const dispatch = useContext(DispatchContext);
  // Never re-renders (dispatch is stable)
  return <button onClick={() => dispatch({ type: 'ACTION' })}>Click</button>;
}
```

### Testing Context Providers
```javascript
import { render, screen } from '@testing-library/react';
import { renderHook, act } from '@testing-library/react-hooks';

// Test wrapper
function TestWrapper({ children }) {
  return <UserProvider>{children}</UserProvider>;
}

describe('UserContext', () => {
  test('provides user data', () => {
    const { result } = renderHook(() => useUser(), {
      wrapper: TestWrapper
    });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });

  test('login updates user', async () => {
    const { result } = renderHook(() => useUser(), {
      wrapper: TestWrapper
    });

    await act(async () => {
      await result.current.login({ email: 'test@example.com' });
    });

    expect(result.current.isAuthenticated).toBe(true);
  });
});
```

## Test Templates

### Context Provider Tests
```javascript
describe('ThemeProvider', () => {
  test('provides default theme', () => {
    const { result } = renderHook(() => useTheme(), {
      wrapper: ThemeProvider
    });

    expect(result.current.theme).toBe('light');
  });

  test('toggles theme', () => {
    const { result } = renderHook(() => useTheme(), {
      wrapper: ThemeProvider
    });

    act(() => {
      result.current.toggleTheme();
    });

    expect(result.current.theme).toBe('dark');
  });
});
```

### Custom Hook Tests
```javascript
describe('useUser', () => {
  test('throws error outside provider', () => {
    expect(() => {
      renderHook(() => useUser());
    }).toThrow('useUser must be used within UserProvider');
  });
});
```

## Best Practices

### Context Usage
- Use Context for truly global state
- Avoid Context for frequently changing values
- Split contexts by domain and update frequency
- Provide meaningful default values
- Always memoize context values

### Custom Hooks
- Prefix custom hooks with "use"
- Extract reusable logic into hooks
- Keep hooks focused and single-purpose
- Document hook dependencies
- Test hooks in isolation

### Performance
- Memoize context values and callbacks
- Split providers to minimize re-renders
- Use React.memo for expensive children
- Monitor render counts in development
- Implement selector patterns when needed

### Type Safety
- Use TypeScript for context types
- Define explicit interfaces
- Type custom hooks properly
- Validate context values at runtime
- Provide type guards when necessary

## Production Configuration

```javascript
// Production-ready context setup
import { createContext, useContext, useReducer, useMemo, useEffect } from 'react';

export function createProductionContext(name, reducer, initialState, middleware = []) {
  const Context = createContext(undefined);
  Context.displayName = name;

  function Provider({ children }) {
    const [state, baseDispatch] = useReducer(reducer, initialState);

    const dispatch = useMemo(() => {
      return (action) => {
        middleware.forEach(mw => mw(state, action));
        return baseDispatch(action);
      };
    }, [state]);

    const value = useMemo(() => ({ state, dispatch }), [state, dispatch]);

    // Development monitoring
    if (process.env.NODE_ENV !== 'production') {
      useEffect(() => {
        console.log(`${name} state updated:`, state);
      }, [state]);
    }

    return <Context.Provider value={value}>{children}</Context.Provider>;
  }

  function useContextHook() {
    const context = useContext(Context);
    if (context === undefined) {
      throw new Error(`use${name} must be used within ${name}Provider`);
    }
    return context;
  }

  return { Provider, useContextHook };
}
```

## Assets

- See `assets/context-api-config.yaml` for patterns

## Resources

- [React Context](https://react.dev/reference/react/useContext)
- [Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
- [Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks)
- [useReducer](https://react.dev/reference/react/useReducer)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
