# Context API Patterns

## Pattern 1: Compound Context with useReducer

```typescript
interface AppState {
  user: User | null
  notifications: Notification[]
  theme: 'light' | 'dark'
}

const AppContext = createContext<{ state: AppState; dispatch: Dispatch } | undefined>(undefined)

function appReducer(state: AppState, action: any) {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload }
    case 'ADD_NOTIFICATION':
      return { ...state, notifications: [...state.notifications, action.payload] }
    case 'TOGGLE_THEME':
      return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' }
    default:
      return state
  }
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, initialState)
  return <AppContext.Provider value={{ state, dispatch }}>{children}</AppContext.Provider>
}

export function useAppContext() {
  const context = useContext(AppContext)
  if (!context) throw new Error('useAppContext must be within AppProvider')
  return context
}
```

## Pattern 2: Split Provider for Performance

```typescript
// Separate contexts for state and dispatch
const UserStateContext = createContext<User | null>(null)
const UserDispatchContext = createContext<Dispatch | null>(null)

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, dispatch] = useReducer(userReducer, null)
  return (
    <UserStateContext.Provider value={user}>
      <UserDispatchContext.Provider value={dispatch}>
        {children}
      </UserDispatchContext.Provider>
    </UserStateContext.Provider>
  )
}

export function useUserState() {
  const context = useContext(UserStateContext)
  if (!context) throw new Error('useUserState must be within UserProvider')
  return context
}

export function useUserDispatch() {
  const context = useContext(UserDispatchContext)
  if (!context) throw new Error('useUserDispatch must be within UserProvider')
  return context
}
```

## Pattern 3: Context with Custom Hook Logic

```typescript
export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Restore from localStorage
    const saved = localStorage.getItem('user')
    if (saved) setUser(JSON.parse(saved))
    setLoading(false)
  }, [])

  const login = useCallback(async (email, password) => {
    setLoading(true)
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      })
      const user = await response.json()
      setUser(user)
      localStorage.setItem('user', JSON.stringify(user))
    } catch (error) {
      // handle error
    } finally {
      setLoading(false)
    }
  }, [])

  const logout = useCallback(() => {
    setUser(null)
    localStorage.removeItem('user')
  }, [])

  return { user, loading, login, logout }
}

const AuthContext = createContext<ReturnType<typeof useAuth> | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const auth = useAuth()
  return <AuthContext.Provider value={auth}>{children}</AuthContext.Provider>
}

export function useAuthContext() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuthContext must be within AuthProvider')
  return context
}
```

## Pattern 4: Context with Controlled Memoization

```typescript
export function PreferencesProvider({ children }: { children: ReactNode }) {
  const [preferences, setPreferences] = useState(defaultPreferences)

  const value = useMemo(() => ({
    preferences,
    updatePreference: (key: string, value: any) => {
      setPreferences(p => ({ ...p, [key]: value }))
    },
  }), [preferences])

  return (
    <PreferencesContext.Provider value={value}>
      {children}
    </PreferencesContext.Provider>
  )
}
```

## Pattern 5: Context Selectors for Performance

```typescript
function usePreferencesSelector<T>(selector: (prefs: Preferences) => T): T {
  const context = useContext(PreferencesContext)
  const value = selector(context.preferences)

  // Memoize to prevent re-renders
  const memoizedValue = useMemo(() => value, [value])
  return memoizedValue
}

// Usage - only re-renders when selected value changes
function Component() {
  const theme = usePreferencesSelector(p => p.theme)
  return <div>Theme: {theme}</div>
}
```

## Pattern 6: Nested Providers

```typescript
function RootProvider({ children }: { children: ReactNode }) {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <ThemeProvider>
          <NotificationProvider>
            <ModalProvider>
              {children}
            </ModalProvider>
          </NotificationProvider>
        </ThemeProvider>
      </AuthProvider>
    </ErrorBoundary>
  )
}
```

## Pattern 7: Context with Side Effects

```typescript
export function LocalStorageProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState(() => {
    const saved = localStorage.getItem('app-state')
    return saved ? JSON.parse(saved) : initialState
  })

  useEffect(() => {
    localStorage.setItem('app-state', JSON.stringify(state))
  }, [state])

  return <StateContext.Provider value={{ state, setState }}>{children}</StateContext.Provider>
}
```

## Pattern 8: Combining Redux and Context

```typescript
// Use Redux for global state, Context for UI state
const ThemeContext = createContext('light')
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme] = useSelector(state => state.settings.theme)
  const [localTheme, setLocalTheme] = useState(theme)

  return (
    <ThemeContext.Provider value={localTheme}>
      {children}
    </ThemeContext.Provider>
  )
}
```

## Pattern 9: Error Handling with Context

```typescript
interface ErrorContextType {
  error: Error | null
  setError: (error: Error | null) => void
  clearError: () => void
}

export function ErrorProvider({ children }: { children: ReactNode }) {
  const [error, setError] = useState<Error | null>(null)

  const value = useMemo(() => ({
    error,
    setError,
    clearError: () => setError(null),
  }), [error])

  return (
    <ErrorContext.Provider value={value}>
      {children}
      {error && <ErrorBoundary error={error} />}
    </ErrorContext.Provider>
  )
}
```

