---
name: context-api-patterns
description: Master React Context API patterns for state management including Provider patterns, useReducer, custom hooks, and avoiding common pitfalls.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 04-state-management-agent
bond_type: PRIMARY_BOND
production_config:
  performance_budget:
    context_update_time: "8ms"
    provider_nesting_limit: 5
    consumer_count_limit: 100
  optimization:
    context_splitting: true
    selective_rendering: true
    memoization: true
  monitoring:
    render_tracking: true
    context_updates: true
    performance_profiling: true
---

# Context API Patterns

Advanced patterns and techniques for effective state management with React Context API, including optimal provider structures, performance optimization, and composable architectures.

## Input Schema

```typescript
interface ContextConfiguration {
  providers: {
    name: string;
    defaultValue: any;
    displayName?: string;
  }[];
  consumers: {
    contextName: string;
    components: string[];
    selectors?: Selector[];
  }[];
  patterns: {
    splitting: boolean;
    composition: boolean;
    lazy: boolean;
  };
}

interface ContextValue<T> {
  state: T;
  actions: Record<string, (...args: any[]) => void>;
  dispatch?: Dispatch<any>;
}

interface ProviderProps<T> {
  children: ReactNode;
  initialValue?: T;
  onStateChange?: (state: T) => void;
}
```

## Output Schema

```typescript
interface ContextImplementation<T> {
  Context: React.Context<T>;
  Provider: React.FC<ProviderProps<T>>;
  useContextHook: () => T;
  useContextSelector: <S>(selector: (state: T) => S) => S;
  utilities: {
    actions: Record<string, ActionCreator>;
    selectors: Record<string, Selector>;
  };
  monitoring: {
    renderCount: number;
    updateFrequency: number;
    consumerCount: number;
  };
}

interface PerformanceMetrics {
  providerRenderTime: number;
  contextUpdateTime: number;
  consumerRenderCount: number;
  memoizationHitRate: number;
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `CONTEXT_NOT_FOUND` | Using context outside Provider | Wrap components in Provider | Add Provider to component tree |
| `UNNECESSARY_RENDERS` | Context value changes unnecessarily | Memoize context value with useMemo | Use React.memo and useMemo |
| `PROVIDER_NESTING_DEPTH` | Too many nested Providers | Flatten or compose Providers | Create composite Provider components |
| `CONTEXT_VALUE_MUTATION` | Direct mutation of context value | Use immutable updates | Use useReducer or state update functions |
| `CONSUMER_PERFORMANCE` | Too many consumers re-rendering | Split contexts by concern | Separate frequently/infrequently updated data |
| `DEFAULT_VALUE_MISMATCH` | Default value doesn't match actual | Align default with Provider value | Use TypeScript for type safety |
| `MEMORY_LEAK` | Context subscriptions not cleaned up | Ensure proper cleanup | Use useEffect cleanup functions |

## MANDATORY

### Context Creation and Provider Patterns
```javascript
import { createContext, useContext, useState, useMemo } from 'react';

// Create context with type safety
const ThemeContext = createContext(undefined);

// Custom Provider component
export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');
  const [colors, setColors] = useState(defaultColors);

  // Memoize context value to prevent unnecessary re-renders
  const value = useMemo(() => ({
    theme,
    colors,
    setTheme,
    setColors,
    toggleTheme: () => setTheme(prev => prev === 'light' ? 'dark' : 'light')
  }), [theme, colors]);

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
}

// Custom hook for consuming context
export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}
```

### useContext Hook for Consuming Context
```javascript
import { useContext } from 'react';
import { ThemeContext } from './ThemeContext';

function ThemedButton() {
  // Consume context with useContext
  const { theme, toggleTheme } = useContext(ThemeContext);

  return (
    <button
      onClick={toggleTheme}
      className={`btn-${theme}`}
    >
      Toggle Theme
    </button>
  );
}

// Alternative: Using custom hook
function ThemedComponent() {
  const { theme, colors } = useTheme();

  return (
    <div style={{ backgroundColor: colors.background }}>
      Current theme: {theme}
    </div>
  );
}
```

### Provider Component Implementation
```javascript
import { createContext, useContext, useReducer, useMemo } from 'react';

// Define state shape and actions
const initialState = {
  user: null,
  isAuthenticated: false,
  loading: false
};

// Reducer for complex state logic
function authReducer(state, action) {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, loading: true };
    case 'LOGIN_SUCCESS':
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true,
        loading: false
      };
    case 'LOGIN_FAILURE':
      return { ...state, loading: false };
    case 'LOGOUT':
      return { ...initialState };
    default:
      return state;
  }
}

const AuthContext = createContext(undefined);

export function AuthProvider({ children }) {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Memoize actions
  const actions = useMemo(() => ({
    login: async (credentials) => {
      dispatch({ type: 'LOGIN_START' });
      try {
        const user = await api.login(credentials);
        dispatch({ type: 'LOGIN_SUCCESS', payload: user });
      } catch (error) {
        dispatch({ type: 'LOGIN_FAILURE' });
      }
    },
    logout: () => {
      dispatch({ type: 'LOGOUT' });
    }
  }), []);

  const value = useMemo(() => ({
    ...state,
    ...actions
  }), [state, actions]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

### useReducer for Complex State
```javascript
import { useReducer } from 'react';

const todoReducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };
    case 'TOGGLE_TODO':
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload.id
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
    case 'DELETE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload.id)
      };
    case 'SET_FILTER':
      return {
        ...state,
        filter: action.payload
      };
    default:
      return state;
  }
};

function TodoProvider({ children }) {
  const [state, dispatch] = useReducer(todoReducer, {
    todos: [],
    filter: 'ALL'
  });

  return (
    <TodoContext.Provider value={{ state, dispatch }}>
      {children}
    </TodoContext.Provider>
  );
}
```

### Custom Hooks with Context
```javascript
// Abstraction layer over context
export function useTodos() {
  const { state, dispatch } = useContext(TodoContext);

  return {
    todos: state.todos,
    filter: state.filter,
    addTodo: (text) => dispatch({
      type: 'ADD_TODO',
      payload: { id: nanoid(), text, completed: false }
    }),
    toggleTodo: (id) => dispatch({
      type: 'TOGGLE_TODO',
      payload: { id }
    }),
    deleteTodo: (id) => dispatch({
      type: 'DELETE_TODO',
      payload: { id }
    }),
    setFilter: (filter) => dispatch({
      type: 'SET_FILTER',
      payload: filter
    })
  };
}

// Selector-based hook
export function useFilteredTodos() {
  const { todos, filter } = useTodos();

  return useMemo(() => {
    switch (filter) {
      case 'ACTIVE':
        return todos.filter(t => !t.completed);
      case 'COMPLETED':
        return todos.filter(t => t.completed);
      default:
        return todos;
    }
  }, [todos, filter]);
}
```

### Multiple Context Composition
```javascript
// Compose multiple providers
export function AppProviders({ children }) {
  return (
    <ThemeProvider>
      <AuthProvider>
        <TodoProvider>
          <NotificationProvider>
            {children}
          </NotificationProvider>
        </TodoProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}

// Usage
function App() {
  return (
    <AppProviders>
      <Main />
    </AppProviders>
  );
}

// Component using multiple contexts
function Dashboard() {
  const { theme } = useTheme();
  const { user } = useAuth();
  const { todos } = useTodos();

  return (
    <div className={theme}>
      <h1>Welcome, {user.name}</h1>
      <TodoList todos={todos} />
    </div>
  );
}
```

## OPTIONAL

### Context Splitting Strategies
```javascript
// Split by update frequency
const UserContext = createContext(); // Rarely changes
const PreferencesContext = createContext(); // Changes frequently

function UserProvider({ children }) {
  const [user, setUser] = useState(null);

  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

function PreferencesProvider({ children }) {
  const [preferences, setPreferences] = useState({});

  return (
    <PreferencesContext.Provider value={{ preferences, setPreferences }}>
      {children}
    </PreferencesContext.Provider>
  );
}

// Split by domain
const DataContext = createContext(); // Data state
const UIContext = createContext(); // UI state
const ActionsContext = createContext(); // Actions only

function AppProvider({ children }) {
  const [data, setData] = useState({});
  const [ui, setUI] = useState({});

  const actions = useMemo(() => ({
    updateData: setData,
    updateUI: setUI
  }), []);

  return (
    <DataContext.Provider value={data}>
      <UIContext.Provider value={ui}>
        <ActionsContext.Provider value={actions}>
          {children}
        </ActionsContext.Provider>
      </UIContext.Provider>
    </DataContext.Provider>
  );
}
```

### Performance Optimization
```javascript
import { memo, useMemo, useCallback } from 'react';

// Memoize Provider value
function OptimizedProvider({ children }) {
  const [state, setState] = useState(initialState);

  // Memoize callbacks
  const updateUser = useCallback((user) => {
    setState(prev => ({ ...prev, user }));
  }, []);

  const updateSettings = useCallback((settings) => {
    setState(prev => ({ ...prev, settings }));
  }, []);

  // Memoize entire context value
  const value = useMemo(() => ({
    state,
    updateUser,
    updateSettings
  }), [state, updateUser, updateSettings]);

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}

// Memo consumer components
const ExpensiveComponent = memo(({ data }) => {
  // Only re-renders when data changes
  return <div>{/* render data */}</div>;
});

// Selective context consumption
function SelectiveConsumer() {
  const { user } = useContext(AppContext);
  // Only subscribes to user changes, not entire context

  return <UserProfile user={user} />;
}
```

### Context Composition Patterns
```javascript
// Higher-order Provider pattern
function withProviders(...providers) {
  return function ProviderComposer({ children }) {
    return providers.reduceRight(
      (acc, Provider) => <Provider>{acc}</Provider>,
      children
    );
  };
}

const ComposedProvider = withProviders(
  ThemeProvider,
  AuthProvider,
  DataProvider
);

// Factory pattern for contexts
function createContextFactory(name) {
  const Context = createContext(undefined);
  Context.displayName = name;

  function Provider({ children, value }) {
    return <Context.Provider value={value}>{children}</Context.Provider>;
  }

  function useContextHook() {
    const context = useContext(Context);
    if (context === undefined) {
      throw new Error(`use${name} must be used within ${name}Provider`);
    }
    return context;
  }

  return [Provider, useContextHook];
}

const [ThemeProvider, useTheme] = createContextFactory('Theme');
const [UserProvider, useUser] = createContextFactory('User');
```

### Lazy Context Initialization
```javascript
function LazyProvider({ children }) {
  const [state, setState] = useState(() => {
    // Expensive initialization only runs once
    return loadInitialState();
  });

  const value = useMemo(() => ({
    state,
    setState
  }), [state]);

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}

// Lazy loading context data
function DataProvider({ children }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let cancelled = false;

    async function loadData() {
      setLoading(true);
      const result = await fetchData();
      if (!cancelled) {
        setData(result);
        setLoading(false);
      }
    }

    loadData();

    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <DataContext.Provider value={{ data, loading }}>
      {children}
    </DataContext.Provider>
  );
}
```

## ADVANCED

### Context with Async Operations
```javascript
function AsyncDataProvider({ children }) {
  const [state, dispatch] = useReducer(dataReducer, {
    data: null,
    loading: false,
    error: null
  });

  const fetchData = useCallback(async (id) => {
    dispatch({ type: 'FETCH_START' });
    try {
      const data = await api.fetchData(id);
      dispatch({ type: 'FETCH_SUCCESS', payload: data });
    } catch (error) {
      dispatch({ type: 'FETCH_ERROR', payload: error.message });
    }
  }, []);

  const value = useMemo(() => ({
    ...state,
    fetchData
  }), [state, fetchData]);

  return (
    <DataContext.Provider value={value}>
      {children}
    </DataContext.Provider>
  );
}
```

### Middleware-like Patterns
```javascript
function createMiddleware(middleware) {
  return function MiddlewareProvider({ children }) {
    const [state, baseDispatch] = useReducer(reducer, initialState);

    const dispatch = useCallback((action) => {
      const chain = middleware.map(mw => mw({ getState: () => state }));
      const composedDispatch = chain.reduceRight(
        (next, mw) => mw(next),
        baseDispatch
      );
      return composedDispatch(action);
    }, [state]);

    return (
      <AppContext.Provider value={{ state, dispatch }}>
        {children}
      </AppContext.Provider>
    );
  };
}

// Logger middleware
const logger = ({ getState }) => next => action => {
  console.log('Action:', action);
  const result = next(action);
  console.log('Next State:', getState());
  return result;
};

// Usage
const AppProvider = createMiddleware([logger, analytics]);
```

### Testing Context Providers
```javascript
import { render, screen } from '@testing-library/react';
import { ThemeProvider, useTheme } from './ThemeContext';

// Test wrapper
function TestWrapper({ children, initialValue }) {
  return (
    <ThemeProvider initialValue={initialValue}>
      {children}
    </ThemeProvider>
  );
}

// Test component
function TestComponent() {
  const { theme, toggleTheme } = useTheme();
  return (
    <div>
      <span data-testid="theme">{theme}</span>
      <button onClick={toggleTheme}>Toggle</button>
    </div>
  );
}

describe('ThemeContext', () => {
  test('provides theme value', () => {
    render(<TestComponent />, { wrapper: TestWrapper });
    expect(screen.getByTestId('theme')).toHaveTextContent('light');
  });

  test('toggles theme', () => {
    render(<TestComponent />, { wrapper: TestWrapper });
    fireEvent.click(screen.getByText('Toggle'));
    expect(screen.getByTestId('theme')).toHaveTextContent('dark');
  });
});
```

### Context Performance Debugging
```javascript
import { useEffect, useRef } from 'react';

// Hook to track renders
function useRenderCount(componentName) {
  const renderCount = useRef(0);

  useEffect(() => {
    renderCount.current += 1;
    console.log(`${componentName} rendered ${renderCount.current} times`);
  });
}

// Performance monitoring Provider
function MonitoredProvider({ children }) {
  const [state, setState] = useState(initialState);
  const renderCount = useRef(0);

  useEffect(() => {
    renderCount.current += 1;
    if (renderCount.current > 10) {
      console.warn('Provider re-rendered too many times!');
    }
  });

  return (
    <AppContext.Provider value={{ state, setState }}>
      {children}
    </AppContext.Provider>
  );
}
```

## Test Templates

### Provider Tests
```javascript
describe('AuthProvider', () => {
  test('provides initial state', () => {
    const { result } = renderHook(() => useAuth(), {
      wrapper: AuthProvider
    });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  test('login updates state', async () => {
    const { result } = renderHook(() => useAuth(), {
      wrapper: AuthProvider
    });

    await act(async () => {
      await result.current.login({ email: 'test@example.com' });
    });

    expect(result.current.isAuthenticated).toBe(true);
  });
});
```

### Custom Hook Tests
```javascript
describe('useFilteredTodos', () => {
  test('filters active todos', () => {
    const wrapper = ({ children }) => (
      <TodoProvider initialState={{ filter: 'ACTIVE', todos: mockTodos }}>
        {children}
      </TodoProvider>
    );

    const { result } = renderHook(() => useFilteredTodos(), { wrapper });

    expect(result.current).toHaveLength(2);
  });
});
```

## Best Practices

### Context Design
- Create separate contexts for different concerns
- Split frequently and infrequently updated data
- Use meaningful context names with displayName
- Provide sensible default values
- Document context usage and requirements

### Performance
- Always memoize context values with useMemo
- Memoize callbacks with useCallback
- Split contexts to minimize re-renders
- Use React.memo for consumer components
- Monitor render counts in development

### Error Handling
- Throw errors when context is used outside Provider
- Validate context values at boundaries
- Provide clear error messages
- Handle async errors gracefully
- Use error boundaries around Providers

### Type Safety
- Use TypeScript for context types
- Define explicit interfaces for context values
- Type custom hooks properly
- Use generics for reusable context patterns
- Validate runtime types when necessary

### Testing
- Test Providers in isolation
- Mock context values for component tests
- Test custom hooks with renderHook
- Verify error handling
- Test async operations thoroughly

## Production Configuration

```javascript
import { createContext, useContext, useReducer, useMemo } from 'react';

// Production-ready context factory
export function createProductionContext(name, reducer, initialState) {
  const Context = createContext(undefined);
  Context.displayName = name;

  function Provider({ children }) {
    const [state, dispatch] = useReducer(reducer, initialState);

    const value = useMemo(() => {
      return {
        state,
        dispatch
      };
    }, [state]);

    // Development warnings
    if (process.env.NODE_ENV !== 'production') {
      const renderCount = useRef(0);
      useEffect(() => {
        renderCount.current += 1;
        if (renderCount.current > 50) {
          console.warn(`${name}Provider re-rendered ${renderCount.current} times`);
        }
      });
    }

    return <Context.Provider value={value}>{children}</Context.Provider>;
  }

  function useContextHook() {
    const context = useContext(Context);
    if (context === undefined) {
      throw new Error(
        `use${name} must be used within ${name}Provider`
      );
    }
    return context;
  }

  return { Provider, useContextHook };
}
```

## References

- [React Context API Documentation](https://react.dev/reference/react/useContext)
- [useReducer Hook](https://react.dev/reference/react/useReducer)
- [Context Performance](https://react.dev/reference/react/useCallback)
- [Context Best Practices](https://react.dev/learn/passing-data-deeply-with-context)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
