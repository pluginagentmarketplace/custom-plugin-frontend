# React Hooks Patterns Guide

## Built-in Hooks Quick Reference

### State Hooks

```typescript
// useState - Component state
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);

// useReducer - Complex state logic
const [state, dispatch] = useReducer(reducer, initialState);
```

### Effect Hooks

```typescript
// useEffect - Side effects
useEffect(() => {
  // Effect runs after render
  const subscription = api.subscribe(handleChange);

  // Cleanup function
  return () => subscription.unsubscribe();
}, [handleChange]); // Dependencies

// useLayoutEffect - DOM measurements (synchronous)
useLayoutEffect(() => {
  const rect = elementRef.current?.getBoundingClientRect();
  setDimensions(rect);
}, []);
```

### Context Hooks

```typescript
// useContext - Access context value
const theme = useContext(ThemeContext);
const { user, logout } = useContext(AuthContext);
```

### Ref Hooks

```typescript
// useRef - Mutable reference
const inputRef = useRef<HTMLInputElement>(null);
const previousValue = useRef(value);

// useImperativeHandle - Expose methods to parent
useImperativeHandle(ref, () => ({
  focus: () => inputRef.current?.focus(),
  scrollTo: (pos) => element.scrollTo(pos),
}));
```

### Performance Hooks

```typescript
// useMemo - Memoize expensive computation
const filteredItems = useMemo(
  () => items.filter(item => item.active),
  [items]
);

// useCallback - Stable function reference
const handleClick = useCallback(
  (id: string) => dispatch({ type: 'SELECT', id }),
  [dispatch]
);
```

## Common Patterns

### Data Fetching Hook

```typescript
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url, {
          signal: controller.signal,
        });
        if (!response.ok) throw new Error(response.statusText);
        const json = await response.json();
        setData(json);
      } catch (err) {
        if (err instanceof Error && err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        setLoading(false);
      }
    };

    fetchData();

    return () => controller.abort();
  }, [url]);

  return { data, loading, error };
}
```

### Local Storage Hook

```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
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
      localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error('Error saving to localStorage:', error);
    }
  };

  return [storedValue, setValue] as const;
}
```

### Debounce Hook

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

## Rules of Hooks

### ✅ DO

1. Call hooks at the top level of components
2. Call hooks from React function components
3. Name custom hooks starting with "use"
4. Include all dependencies in dependency arrays

### ❌ DON'T

1. Call hooks inside conditions
2. Call hooks inside loops
3. Call hooks inside nested functions
4. Forget cleanup in useEffect

## Best Practices

### Dependency Arrays

```typescript
// ✅ Good - All dependencies listed
useEffect(() => {
  doSomething(a, b, c);
}, [a, b, c]);

// ❌ Bad - Missing dependency
useEffect(() => {
  doSomething(a, b, c);
}, [a, b]); // Missing 'c'

// ✅ Good - Stable function with useCallback
const stableCallback = useCallback(() => {
  doSomething(a);
}, [a]);

useEffect(() => {
  stableCallback();
}, [stableCallback]);
```

### Cleanup Pattern

```typescript
useEffect(() => {
  // Setup
  const subscription = someAPI.subscribe();
  const timer = setInterval(() => {}, 1000);

  // Always cleanup
  return () => {
    subscription.unsubscribe();
    clearInterval(timer);
  };
}, []);
```
