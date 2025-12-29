# Redux Design Patterns

## Pattern 1: Feature-Based Folder Structure

```
src/
├── store/
│   ├── index.ts
│   ├── rootReducer.ts
│   └── slices/
│       ├── counterSlice.ts
│       ├── userSlice.ts
│       └── authSlice.ts
├── features/
│   ├── Counter/
│   │   ├── counterSlice.ts
│   │   ├── Counter.tsx
│   │   └── counter.test.ts
│   └── User/
│       ├── userSlice.ts
│       ├── User.tsx
│       └── user.test.ts
```

## Pattern 2: Action Dispatching with Type Safety

```typescript
import { useDispatch } from 'react-redux'
import { AppDispatch } from './store'

export const useAppDispatch = () => useDispatch<AppDispatch>()

// Usage
function MyComponent() {
  const dispatch = useAppDispatch()
  dispatch(fetchUser(userId))
}
```

## Pattern 3: Async Thunks with Request State

```typescript
export const fetchPosts = createAsyncThunk(
  'posts/fetchPosts',
  async (_, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/posts')
      if (!response.ok) throw new Error('Network error')
      return response.json()
    } catch (error) {
      return rejectWithValue(error.message)
    }
  }
)

const postsSlice = createSlice({
  name: 'posts',
  initialState: {
    entities: [],
    loading: 'idle',
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchPosts.pending, (state) => {
        state.loading = 'pending'
      })
      .addCase(fetchPosts.fulfilled, (state, action) => {
        state.loading = 'idle'
        state.entities = action.payload
      })
      .addCase(fetchPosts.rejected, (state, action) => {
        state.loading = 'idle'
        state.error = action.payload
      })
  },
})
```

## Pattern 4: Selector Composition

```typescript
const selectPostsState = (state: RootState) => state.posts

export const selectAllPosts = createSelector(
  [selectPostsState],
  (posts) => posts.entities
)

export const selectPostsLoading = createSelector(
  [selectPostsState],
  (posts) => posts.loading
)

export const selectPostById = createSelector(
  [selectAllPosts, (_, postId: string) => postId],
  (posts, postId) => posts.find((p) => p.id === postId)
)

// Usage
const post = useSelector((state) => selectPostById(state, postId))
```

## Pattern 5: Optimized Render Performance

```typescript
// Memoized selector prevents unnecessary re-renders
const selectVisiblePosts = createSelector(
  [(state: RootState) => state.posts.entities, (state) => state.posts.filter],
  (entities, filter) => entities.filter((p) => p.status === filter)
)

function PostList() {
  const posts = useSelector(selectVisiblePosts)
  return posts.map((p) => <PostItem key={p.id} post={p} />)
}
```

## Pattern 6: Slice with Normalized State

```typescript
interface NormalizedState {
  byId: { [id: string]: Item }
  allIds: string[]
  selectedId: string | null
}

const itemSlice = createSlice({
  name: 'items',
  initialState: { byId: {}, allIds: [], selectedId: null },
  reducers: {
    addItem: (state, action: PayloadAction<Item>) => {
      state.byId[action.payload.id] = action.payload
      state.allIds.push(action.payload.id)
    },
    updateItem: (state, action: PayloadAction<Item>) => {
      state.byId[action.payload.id] = action.payload
    },
  },
})

export const selectAllItems = createSelector(
  [(state: RootState) => state.items.byId, (state) => state.items.allIds],
  (byId, allIds) => allIds.map((id) => byId[id])
)
```

## Pattern 7: Error Handling Middleware

```typescript
const errorMiddleware = (store) => (next) => (action) => {
  try {
    return next(action)
  } catch (error) {
    store.dispatch(setError(error.message))
    throw error
  }
}

export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(errorMiddleware),
})
```

## Pattern 8: Action Logging

```typescript
const loggerMiddleware = (store) => (next) => (action) => {
  console.group(action.type)
  console.info('dispatching', action)
  const result = next(action)
  console.log('next state', store.getState())
  console.groupEnd()
  return result
}
```

## Pattern 9: Reusable Slice Generator

```typescript
function createDataSlice<T extends { id: string }>(name: string) {
  return createSlice({
    name,
    initialState: {
      entities: [] as T[],
      loading: false,
      error: null as string | null,
    },
    reducers: {
      addEntity: (state, action: PayloadAction<T>) => {
        state.entities.push(action.payload)
      },
      removeEntity: (state, action: PayloadAction<string>) => {
        state.entities = state.entities.filter((e) => e.id !== action.payload)
      },
    },
  })
}

const usersSlice = createDataSlice<User>('users')
const productsSlice = createDataSlice<Product>('products')
```

## Pattern 10: Undo/Redo Functionality

```typescript
interface StateWithHistory {
  past: any[]
  present: any
  future: any[]
}

const historySlice = createSlice({
  name: 'history',
  initialState: { past: [], present: {}, future: [] },
  reducers: {
    undo: (state) => {
      if (state.past.length > 0) {
        state.future.unshift(state.present)
        state.present = state.past.pop()!
      }
    },
    redo: (state) => {
      if (state.future.length > 0) {
        state.past.push(state.present)
        state.present = state.future.shift()!
      }
    },
  },
})
```

## Pattern 11: Lazy Loading Slices

```typescript
let store: any

export function configureAppStore() {
  store = configureStore({
    reducer: { app: appReducer },
  })
  return store
}

export function injectReducer(key: string, reducer: any) {
  if (store) {
    store.injectReducer(key, reducer)
  }
}

// Usage: injectReducer('user', userReducer) after user logs in
```

## Pattern 12: Testing Reducers

```typescript
describe('counterSlice', () => {
  it('should increment counter', () => {
    const initialState = { value: 0 }
    const newState = counterReducer(initialState, increment())
    expect(newState.value).toBe(1)
  })

  it('should handle async thunk', async () => {
    const store = configureStore({
      reducer: { user: userReducer },
    })
    await store.dispatch(fetchUser(userId) as any)
    const state = store.getState()
    expect(state.user.current).toBeDefined()
  })
})
```

