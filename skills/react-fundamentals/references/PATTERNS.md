# React Design Patterns

## Container/Presenter Pattern

Separate logic from presentation:

```tsx
// Container (Smart Component)
const UserListContainer = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUsers()
      .then(setUsers)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  const handleDelete = async (id: string) => {
    await deleteUser(id);
    setUsers(users.filter(u => u.id !== id));
  };

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return <UserList users={users} onDelete={handleDelete} />;
};

// Presenter (Dumb Component)
interface UserListProps {
  users: User[];
  onDelete: (id: string) => void;
}

const UserList: React.FC<UserListProps> = ({ users, onDelete }) => (
  <ul className="user-list">
    {users.map(user => (
      <li key={user.id}>
        <span>{user.name}</span>
        <button onClick={() => onDelete(user.id)}>Delete</button>
      </li>
    ))}
  </ul>
);
```

## Higher-Order Components (HOC)

Reuse component logic:

```tsx
// withAuth HOC
function withAuth<P extends object>(
  WrappedComponent: React.ComponentType<P>
) {
  return function WithAuthComponent(props: P) {
    const { user, loading } = useAuth();

    if (loading) return <Spinner />;
    if (!user) return <Navigate to="/login" />;

    return <WrappedComponent {...props} user={user} />;
  };
}

// Usage
const ProtectedDashboard = withAuth(Dashboard);

// withLoading HOC
function withLoading<P extends { loading?: boolean }>(
  WrappedComponent: React.ComponentType<P>
) {
  return function WithLoadingComponent(props: P) {
    if (props.loading) {
      return <Spinner />;
    }
    return <WrappedComponent {...props} />;
  };
}
```

## Render Props Pattern

Share code via prop function:

```tsx
// Mouse tracker with render props
interface MousePosition {
  x: number;
  y: number;
}

interface MouseTrackerProps {
  render: (position: MousePosition) => React.ReactNode;
}

const MouseTracker: React.FC<MouseTrackerProps> = ({ render }) => {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return <>{render(position)}</>;
};

// Usage
<MouseTracker
  render={({ x, y }) => (
    <div>Mouse position: {x}, {y}</div>
  )}
/>

// Alternative: children as function
<MouseTracker>
  {({ x, y }) => <Cursor x={x} y={y} />}
</MouseTracker>
```

## Custom Hooks Pattern

Extract reusable logic:

```tsx
// useLocalStorage hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function
        ? value(storedValue)
        : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue] as const;
}

// useAsync hook
function useAsync<T>(asyncFn: () => Promise<T>, deps: any[] = []) {
  const [state, setState] = useState<{
    data: T | null;
    loading: boolean;
    error: Error | null;
  }>({
    data: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let cancelled = false;
    setState(s => ({ ...s, loading: true }));

    asyncFn()
      .then(data => {
        if (!cancelled) setState({ data, loading: false, error: null });
      })
      .catch(error => {
        if (!cancelled) setState({ data: null, loading: false, error });
      });

    return () => { cancelled = true; };
  }, deps);

  return state;
}

// useDebounce hook
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

## Compound Components Pattern

Create related components that work together:

```tsx
// Accordion compound component
interface AccordionContextType {
  activeId: string | null;
  toggle: (id: string) => void;
}

const AccordionContext = createContext<AccordionContextType | null>(null);

const Accordion = ({ children }: { children: React.ReactNode }) => {
  const [activeId, setActiveId] = useState<string | null>(null);

  const toggle = (id: string) => {
    setActiveId(prev => prev === id ? null : id);
  };

  return (
    <AccordionContext.Provider value={{ activeId, toggle }}>
      <div className="accordion">{children}</div>
    </AccordionContext.Provider>
  );
};

const AccordionItem = ({
  id,
  title,
  children
}: {
  id: string;
  title: string;
  children: React.ReactNode;
}) => {
  const context = useContext(AccordionContext);
  if (!context) throw new Error('AccordionItem must be inside Accordion');

  const { activeId, toggle } = context;
  const isOpen = activeId === id;

  return (
    <div className="accordion-item">
      <button
        className="accordion-header"
        onClick={() => toggle(id)}
        aria-expanded={isOpen}
      >
        {title}
        <span>{isOpen ? '−' : '+'}</span>
      </button>
      {isOpen && (
        <div className="accordion-content">
          {children}
        </div>
      )}
    </div>
  );
};

Accordion.Item = AccordionItem;

// Usage
<Accordion>
  <Accordion.Item id="1" title="Section 1">
    Content 1
  </Accordion.Item>
  <Accordion.Item id="2" title="Section 2">
    Content 2
  </Accordion.Item>
</Accordion>
```

## Provider Pattern

Global state with Context:

```tsx
// Theme provider
interface Theme {
  mode: 'light' | 'dark';
  colors: Record<string, string>;
}

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export const ThemeProvider = ({ children }: { children: React.ReactNode }) => {
  const [theme, setTheme] = useState<Theme>({
    mode: 'light',
    colors: lightColors,
  });

  const toggleTheme = useCallback(() => {
    setTheme(prev => ({
      mode: prev.mode === 'light' ? 'dark' : 'light',
      colors: prev.mode === 'light' ? darkColors : lightColors,
    }));
  }, []);

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

// Custom hook for consuming
export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};

// Usage
const ThemedButton = () => {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      style={{ backgroundColor: theme.colors.primary }}
      onClick={toggleTheme}
    >
      Toggle Theme
    </button>
  );
};
```

## Error Boundary Pattern

Catch rendering errors:

```tsx
interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

interface ErrorBoundaryProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
  onError?: (error: Error, info: React.ErrorInfo) => void;
}

class ErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    this.props.onError?.(error, info);
    // Log to error reporting service
    console.error('Error caught:', error, info);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <button onClick={() => this.setState({ hasError: false })}>
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary
  fallback={<ErrorPage />}
  onError={(error) => logToService(error)}
>
  <App />
</ErrorBoundary>
```

## Optimistic Updates Pattern

```tsx
const useTodos = () => {
  const [todos, setTodos] = useState<Todo[]>([]);

  const addTodo = async (text: string) => {
    // Optimistic update
    const tempId = `temp-${Date.now()}`;
    const newTodo = { id: tempId, text, completed: false };

    setTodos(prev => [...prev, newTodo]);

    try {
      // Actual API call
      const savedTodo = await api.createTodo(text);
      // Replace temp with real
      setTodos(prev =>
        prev.map(t => t.id === tempId ? savedTodo : t)
      );
    } catch (error) {
      // Rollback on error
      setTodos(prev => prev.filter(t => t.id !== tempId));
      throw error;
    }
  };

  return { todos, addTodo };
};
```
