# React Fundamentals Guide

## Component Basics

### Functional Components

```tsx
// Basic functional component
const Greeting: React.FC<{ name: string }> = ({ name }) => {
  return <h1>Hello, {name}!</h1>;
};

// With children
interface CardProps {
  title: string;
  children: React.ReactNode;
}

const Card: React.FC<CardProps> = ({ title, children }) => (
  <div className="card">
    <h2>{title}</h2>
    <div className="content">{children}</div>
  </div>
);

// Usage
<Card title="Welcome">
  <p>Card content here</p>
</Card>
```

### Props & TypeScript

```tsx
// Define props interface
interface ButtonProps {
  // Required props
  label: string;
  onClick: () => void;

  // Optional props with defaults
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;

  // Children
  children?: React.ReactNode;

  // HTML attributes passthrough
  className?: string;
}

const Button: React.FC<ButtonProps> = ({
  label,
  onClick,
  variant = 'primary',
  size = 'md',
  disabled = false,
  children,
  className = '',
}) => {
  return (
    <button
      className={`btn btn-${variant} btn-${size} ${className}`}
      onClick={onClick}
      disabled={disabled}
      type="button"
    >
      {children || label}
    </button>
  );
};
```

## State Management with Hooks

### useState

```tsx
// Basic state
const [count, setCount] = useState(0);

// State with type inference
const [user, setUser] = useState<User | null>(null);

// Lazy initialization (expensive computation)
const [data, setData] = useState(() => {
  return expensiveComputation();
});

// Functional updates
setCount(prev => prev + 1);

// Object state
const [form, setForm] = useState({ name: '', email: '' });
setForm(prev => ({ ...prev, name: 'John' }));
```

### useEffect

```tsx
// Mount effect (componentDidMount)
useEffect(() => {
  console.log('Component mounted');
  return () => console.log('Component unmounted');
}, []);

// Dependency tracking
useEffect(() => {
  console.log('userId changed:', userId);
}, [userId]);

// Data fetching pattern
useEffect(() => {
  let cancelled = false;

  const fetchData = async () => {
    try {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      if (!cancelled) {
        setUser(data);
      }
    } catch (error) {
      if (!cancelled) {
        setError(error);
      }
    }
  };

  fetchData();

  return () => {
    cancelled = true;
  };
}, [userId]);
```

### useCallback & useMemo

```tsx
// useCallback - memoize functions
const handleClick = useCallback(() => {
  console.log('Clicked:', id);
}, [id]);

// useMemo - memoize values
const expensiveValue = useMemo(() => {
  return items.filter(item => item.active).map(item => item.name);
}, [items]);

// When to use:
// - useCallback: Passing callbacks to optimized child components
// - useMemo: Expensive computations, referential equality
```

### useRef

```tsx
// DOM reference
const inputRef = useRef<HTMLInputElement>(null);

const focusInput = () => {
  inputRef.current?.focus();
};

<input ref={inputRef} type="text" />

// Mutable value (doesn't cause re-render)
const renderCount = useRef(0);

useEffect(() => {
  renderCount.current += 1;
});

// Previous value tracking
const usePrevious = <T,>(value: T): T | undefined => {
  const ref = useRef<T>();
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
};
```

## Event Handling

### Common Events

```tsx
// Click event
const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
  e.preventDefault();
  console.log('Clicked');
};

// Input change
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setName(e.target.value);
};

// Form submit
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
  // Process form
};

// Keyboard event
const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
  if (e.key === 'Enter') {
    submitForm();
  }
};
```

### Event Patterns

```tsx
// Pass data with event
const handleItemClick = (id: string) => (e: React.MouseEvent) => {
  console.log('Clicked item:', id);
};

<button onClick={handleItemClick(item.id)}>Click</button>

// Debounced input
const debouncedSearch = useMemo(
  () => debounce((query: string) => {
    searchAPI(query);
  }, 300),
  []
);

const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
  const query = e.target.value;
  setSearchTerm(query);
  debouncedSearch(query);
};
```

## Conditional Rendering

```tsx
// Ternary operator
{isLoggedIn ? <Dashboard /> : <Login />}

// Logical AND (short-circuit)
{isAdmin && <AdminPanel />}

// Multiple conditions
{status === 'loading' && <Spinner />}
{status === 'error' && <ErrorMessage />}
{status === 'success' && <Content data={data} />}

// Early return pattern
const UserProfile = ({ user }) => {
  if (!user) return <NotFound />;
  if (user.isBlocked) return <BlockedMessage />;

  return <ProfileContent user={user} />;
};

// Render props pattern
{items.length > 0 ? (
  <List items={items} />
) : (
  <EmptyState message="No items found" />
)}
```

## Lists & Keys

```tsx
// Basic list rendering
const TodoList = ({ todos }) => (
  <ul>
    {todos.map(todo => (
      <li key={todo.id}>
        {todo.text}
      </li>
    ))}
  </ul>
);

// ❌ Don't use index as key (unless list is static)
{items.map((item, index) => (
  <Item key={index} />  // Bad for dynamic lists
))}

// ✅ Use unique identifier
{items.map(item => (
  <Item key={item.id} data={item} />
))}

// Complex list with fragments
{users.map(user => (
  <React.Fragment key={user.id}>
    <UserHeader user={user} />
    <UserDetails user={user} />
    <hr />
  </React.Fragment>
))}
```

## Forms

### Controlled Components

```tsx
const ContactForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    // Clear error on change
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validate = () => {
    const newErrors: Record<string, string> = {};
    if (!formData.name) newErrors.name = 'Name is required';
    if (!formData.email) newErrors.email = 'Email is required';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      console.log('Submit:', formData);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <input
          name="name"
          value={formData.name}
          onChange={handleChange}
          placeholder="Name"
        />
        {errors.name && <span className="error">{errors.name}</span>}
      </div>

      <div>
        <input
          name="email"
          type="email"
          value={formData.email}
          onChange={handleChange}
          placeholder="Email"
        />
        {errors.email && <span className="error">{errors.email}</span>}
      </div>

      <div>
        <textarea
          name="message"
          value={formData.message}
          onChange={handleChange}
          placeholder="Message"
        />
      </div>

      <button type="submit">Send</button>
    </form>
  );
};
```

## Component Composition

### Children Pattern

```tsx
// Layout component
const Layout = ({ children }: { children: React.ReactNode }) => (
  <div className="layout">
    <Header />
    <main>{children}</main>
    <Footer />
  </div>
);

// Compound components
const Tabs = ({ children, defaultTab }: TabsProps) => {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
};

Tabs.List = TabList;
Tabs.Tab = Tab;
Tabs.Panel = TabPanel;

// Usage
<Tabs defaultTab="home">
  <Tabs.List>
    <Tabs.Tab id="home">Home</Tabs.Tab>
    <Tabs.Tab id="profile">Profile</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel id="home">Home content</Tabs.Panel>
  <Tabs.Panel id="profile">Profile content</Tabs.Panel>
</Tabs>
```

## Best Practices

1. **Keep components small and focused** - Single responsibility
2. **Use TypeScript** - Type safety catches bugs early
3. **Lift state up** - Share state via common ancestor
4. **Use composition** - Prefer composition over inheritance
5. **Memoize expensive operations** - useMemo, useCallback, React.memo
6. **Handle loading and error states** - Always show feedback
7. **Use semantic HTML** - Accessibility matters
8. **Colocate related code** - Keep styles, tests, types together
