# React Hooks Design Patterns

## Compound Component Pattern

Share state between components implicitly:

```typescript
// Parent provides context
const TabsContext = createContext<TabsContextType | null>(null);

function Tabs({ children, defaultValue }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

// Child components consume context
function TabList({ children }: { children: ReactNode }) {
  return <div className="tab-list">{children}</div>;
}

function Tab({ value, children }: TabProps) {
  const { activeTab, setActiveTab } = useContext(TabsContext)!;

  return (
    <button
      className={activeTab === value ? 'active' : ''}
      onClick={() => setActiveTab(value)}
    >
      {children}
    </button>
  );
}

// Usage
<Tabs defaultValue="tab1">
  <TabList>
    <Tab value="tab1">First</Tab>
    <Tab value="tab2">Second</Tab>
  </TabList>
  <TabPanel value="tab1">Content 1</TabPanel>
  <TabPanel value="tab2">Content 2</TabPanel>
</Tabs>
```

## Render Props with Hooks

Convert render props to hooks:

```typescript
// Traditional render prop
<Mouse>
  {({ x, y }) => <p>Position: {x}, {y}</p>}
</Mouse>

// Hook version
function useMouse() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handler);
    return () => window.removeEventListener('mousemove', handler);
  }, []);

  return position;
}

// Usage
function Component() {
  const { x, y } = useMouse();
  return <p>Position: {x}, {y}</p>;
}
```

## State Reducer Pattern

Allow state customization:

```typescript
interface State {
  count: number;
}

type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'set'; payload: number };

function useCounter(
  initialValue = 0,
  reducer?: (state: State, action: Action) => State
) {
  const internalReducer = (state: State, action: Action): State => {
    const changes = getChanges(state, action);

    // Allow custom reducer to override
    return reducer ? reducer(state, { ...action, changes }) : changes;
  };

  const [state, dispatch] = useReducer(internalReducer, {
    count: initialValue,
  });

  return {
    count: state.count,
    increment: () => dispatch({ type: 'increment' }),
    decrement: () => dispatch({ type: 'decrement' }),
    set: (value: number) => dispatch({ type: 'set', payload: value }),
  };
}

// Custom reducer to prevent negative values
const preventNegative = (state, action) => {
  const changes = action.changes;
  if (changes.count < 0) return state;
  return changes;
};

// Usage
const counter = useCounter(0, preventNegative);
```

## Control Props Pattern

Let parent control component state:

```typescript
interface UseToggleProps {
  isOn?: boolean;
  onChange?: (isOn: boolean) => void;
}

function useToggle({ isOn: controlledIsOn, onChange }: UseToggleProps = {}) {
  const isControlled = controlledIsOn !== undefined;
  const [internalIsOn, setInternalIsOn] = useState(false);

  const isOn = isControlled ? controlledIsOn : internalIsOn;

  const toggle = useCallback(() => {
    if (isControlled) {
      onChange?.(!controlledIsOn);
    } else {
      setInternalIsOn(prev => !prev);
    }
  }, [isControlled, controlledIsOn, onChange]);

  return { isOn, toggle };
}

// Uncontrolled usage
const { isOn, toggle } = useToggle();

// Controlled usage
const [isOn, setIsOn] = useState(false);
const toggleProps = useToggle({
  isOn,
  onChange: setIsOn,
});
```

## Prop Collection Pattern

Group related props together:

```typescript
function useToggle() {
  const [isOn, setIsOn] = useState(false);
  const toggle = () => setIsOn(prev => !prev);

  // Prop collection
  const getToggleProps = (props = {}) => ({
    'aria-pressed': isOn,
    onClick: toggle,
    ...props,
  });

  const getInputProps = (props = {}) => ({
    type: 'checkbox',
    checked: isOn,
    onChange: toggle,
    ...props,
  });

  return {
    isOn,
    toggle,
    getToggleProps,
    getInputProps,
  };
}

// Usage
const { isOn, getToggleProps, getInputProps } = useToggle();

<button {...getToggleProps()}>Toggle</button>
<input {...getInputProps()} />
```

## State Initializer Pattern

Allow resetting to initial state:

```typescript
function useToggle(initialOn = false) {
  const initialState = useRef(initialOn);
  const [isOn, setIsOn] = useState(initialOn);

  const toggle = useCallback(() => setIsOn(prev => !prev), []);
  const reset = useCallback(() => setIsOn(initialState.current), []);

  return { isOn, toggle, reset };
}
```

## Best Practices Summary

1. **Keep hooks focused** - One responsibility per hook
2. **Return stable references** - Use useMemo/useCallback
3. **Handle cleanup** - Always clean up subscriptions/timers
4. **Type your hooks** - Use TypeScript for better DX
5. **Document with JSDoc** - Help users understand the hook
