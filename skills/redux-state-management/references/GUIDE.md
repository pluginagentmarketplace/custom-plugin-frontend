# Redux State Management Guide

## Redux Architecture

Redux is a predictable state management library that follows the Flux architecture pattern. It centralizes application state in a single store and uses pure functions (reducers) to handle state changes.

### Core Concepts

**Store**: Holds the entire application state as a single object.
**Actions**: Plain objects describing what happened, with a `type` property.
**Reducers**: Pure functions that take the current state and an action, returning a new state.
**Selectors**: Functions to extract specific parts of state.
**Middleware**: Intercepts actions before they reach reducers.

### Store Creation

```javascript
import { createStore, combineReducers, applyMiddleware, compose } from 'redux'

const rootReducer = combineReducers({
  counter: counterReducer,
  user: userReducer,
})

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
const store = createStore(rootReducer, composeEnhancers(applyMiddleware(...middlewares)))
```

## Redux Toolkit (Modern Redux)

Redux Toolkit is the official library for writing Redux logic efficiently with less boilerplate.

### Creating Slices

A slice is a collection of reducer logic and actions for a single feature:

```typescript
import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface CounterState {
  value: number
}

const initialState: CounterState = { value: 0 }

export const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1
    },
    incrementByAmount: (state, action: PayloadAction<number>) => {
      state.value += action.payload
    },
  },
})

export const { increment, incrementByAmount } = counterSlice.actions
export default counterSlice.reducer
```

### Configuring Store

```typescript
import { configureStore } from '@reduxjs/toolkit'
import counterReducer from './counterSlice'

export const store = configureStore({
  reducer: {
    counter: counterReducer,
  },
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch
```

## Async Thunks

Handle asynchronous operations with `createAsyncThunk`:

```typescript
import { createAsyncThunk } from '@reduxjs/toolkit'

export const fetchUser = createAsyncThunk(
  'user/fetchUser',
  async (userId: string, { rejectWithValue }) => {
    try {
      const response = await fetch(`/api/users/${userId}`)
      if (!response.ok) throw new Error('Failed to fetch')
      return response.json()
    } catch (error) {
      return rejectWithValue(error.message)
    }
  }
)

export const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => {
        state.loading = true
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.user = action.payload
        state.loading = false
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.error = action.payload
        state.loading = false
      })
  },
})
```

## Using Redux in React

### Provider Setup

```jsx
import { Provider } from 'react-redux'
import { store } from './store'

function App() {
  return (
    <Provider store={store}>
      <MainApp />
    </Provider>
  )
}
```

### useSelector Hook

Access state values:

```jsx
import { useSelector } from 'react-redux'
import { RootState } from './store'

function Counter() {
  const count = useSelector((state: RootState) => state.counter.value)
  return <div>{count}</div>
}
```

### useDispatch Hook

Dispatch actions:

```jsx
import { useDispatch } from 'react-redux'
import { increment, incrementByAmount } from './counterSlice'

function CounterButtons() {
  const dispatch = useDispatch()

  return (
    <>
      <button onClick={() => dispatch(increment())}>+1</button>
      <button onClick={() => dispatch(incrementByAmount(5))}>+5</button>
    </>
  )
}
```

## Selectors and Memoization

Use `createSelector` to memoize derived state:

```typescript
import { createSelector } from '@reduxjs/toolkit'

const selectCounter = (state: RootState) => state.counter

export const selectCounterValue = createSelector(
  [selectCounter],
  (counter) => counter.value
)

export const selectCounterDoubled = createSelector(
  [selectCounterValue],
  (value) => value * 2
)
```

## Middleware

Middleware intercepts and can enhance actions:

```typescript
export const loggerMiddleware = (store) => (next) => (action) => {
  console.log('Dispatching:', action)
  const result = next(action)
  console.log('New state:', store.getState())
  return result
}
```

## Normalization

Organize state for easier updates:

```typescript
interface NormalizedState {
  users: {
    byId: { [id: string]: User }
    allIds: string[]
  }
}

const state = {
  users: {
    byId: {
      '1': { id: '1', name: 'John' },
      '2': { id: '2', name: 'Jane' },
    },
    allIds: ['1', '2'],
  },
}
```

## Best Practices

1. **Immutability**: Use Redux Toolkit which handles immutability internally
2. **Normalization**: Flatten nested data structures
3. **Selectors**: Use functions to access state
4. **Memoization**: Use `createSelector` for derived state
5. **Middleware**: Handle side effects with thunks or custom middleware
6. **DevTools**: Use Redux DevTools for time-travel debugging

