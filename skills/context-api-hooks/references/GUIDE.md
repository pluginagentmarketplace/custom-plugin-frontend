# React Context API Guide

## Creating Contexts

```typescript
import { createContext, useContext } from 'react'

// Define context type
interface ThemeContextType {
  theme: 'light' | 'dark'
  toggleTheme: () => void
}

// Create context
const ThemeContext = createContext<ThemeContextType | undefined>(undefined)
```

## Provider Component

```typescript
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  const value = {
    theme,
    toggleTheme: () => setTheme(t => t === 'light' ? 'dark' : 'light'),
  }

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}
```

## Custom Hooks

```typescript
export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider')
  }
  return context
}
```

## Usage

```typescript
function App() {
  return (
    <ThemeProvider>
      <MainApp />
    </ThemeProvider>
  )
}

function Header() {
  const { theme, toggleTheme } = useTheme()
  return (
    <header style={{ background: theme === 'light' ? '#fff' : '#000' }}>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </header>
  )
}
```

## Multiple Contexts

```typescript
<AuthProvider>
  <ThemeProvider>
    <NotificationProvider>
      <App />
    </NotificationProvider>
  </ThemeProvider>
</AuthProvider>
```

## Performance Optimization

Use `useMemo` to prevent unnecessary re-renders:

```typescript
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState('light')

  const value = useMemo(
    () => ({
      theme,
      toggleTheme: () => setTheme(t => t === 'light' ? 'dark' : 'light'),
    }),
    [theme]
  )

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}
```

## useReducer for Complex State

```typescript
interface State {
  theme: 'light' | 'dark'
  fontSize: number
}

function reducer(state: State, action: any) {
  switch (action.type) {
    case 'TOGGLE_THEME':
      return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' }
    case 'SET_FONT_SIZE':
      return { ...state, fontSize: action.payload }
    default:
      return state
  }
}

export function PreferencesProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, { theme: 'light', fontSize: 16 })
  return <PreferencesContext.Provider value={{ state, dispatch }}>{children}</PreferencesContext.Provider>
}
```

## Best Practices

1. **Create separate contexts** for different concerns
2. **Use custom hooks** to expose context values
3. **Memoize context values** to prevent unnecessary renders
4. **Error handling** in custom hooks
5. **Use TypeScript** for type safety
6. **Consider performance** when context updates frequently

