---
name: redux-state-management
description: Master Redux for predictable state management with actions, reducers, middleware, and Redux Toolkit.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 04-state-management-agent
bond_type: PRIMARY_BOND
production_config:
  performance_budget:
    state_update_time: "16ms"
    selector_compute_time: "10ms"
    middleware_chain_time: "5ms"
  scalability:
    max_store_size: "10MB"
    max_concurrent_actions: 100
    normalized_entities: true
  monitoring:
    action_tracking: true
    performance_metrics: true
    error_boundaries: true
---

# Redux State Management

Comprehensive Redux state management for complex, scalable applications with predictable state updates, middleware chains, and advanced patterns.

## Input Schema

```typescript
interface ReduxArchitecture {
  store: {
    configuration: StoreConfig;
    enhancers: StoreEnhancer[];
    middleware: Middleware[];
  };
  state: {
    shape: StateShape;
    initialState: Record<string, any>;
    normalization: NormalizationSchema;
  };
  actions: {
    types: Record<string, string>;
    creators: Record<string, ActionCreator>;
    validators: Record<string, Validator>;
  };
  reducers: {
    slices: Record<string, Reducer>;
    combinedReducer: CombinedReducer;
  };
}

interface ActionCreator {
  (...args: any[]): Action | ThunkAction;
  type?: string;
  match?: (action: Action) => boolean;
}

interface ThunkAction {
  (dispatch: Dispatch, getState: () => any, extraArgument?: any): any;
}
```

## Output Schema

```typescript
interface ReduxStateManagement {
  store: Store;
  selectors: {
    memoized: Record<string, MemoizedSelector>;
    simple: Record<string, Selector>;
  };
  hooks: {
    useAppDispatch: () => Dispatch;
    useAppSelector: <T>(selector: Selector<T>) => T;
  };
  utilities: {
    actionCreators: Record<string, ActionCreator>;
    middleware: Middleware[];
    enhancers: StoreEnhancer[];
  };
  monitoring: {
    actionLog: Action[];
    performanceMetrics: PerformanceData;
    stateHistory: any[];
  };
}

interface PerformanceData {
  actionCount: number;
  averageDispatchTime: number;
  stateSize: number;
  listenerCount: number;
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `IMMUTABILITY_VIOLATION` | State mutation in reducer | Use immutable update patterns | Enable Immer or Redux Toolkit |
| `SERIALIZATION_ERROR` | Non-serializable values in state | Remove functions/classes from state | Use serializableCheck middleware |
| `CIRCULAR_DEPENDENCY` | Circular references in state | Normalize data structure | Use entity normalization |
| `REDUCER_ERROR` | Exception in reducer function | Add error handling in reducer | Wrap reducers in try-catch |
| `MIDDLEWARE_CRASH` | Middleware throws exception | Add error boundary middleware | Implement error handling in middleware |
| `THUNK_REJECTION` | Async thunk fails | Handle rejection in component | Use createAsyncThunk with error handling |
| `SELECTOR_PERFORMANCE` | Expensive selector computations | Use memoized selectors | Implement reselect |
| `HYDRATION_MISMATCH` | State shape mismatch on hydration | Validate persisted state | Use migration strategies |

## MANDATORY

### Actions and Action Creators
```javascript
import { createAction } from '@reduxjs/toolkit';

// Define action types
export const ADD_TODO = 'todos/add';
export const UPDATE_TODO = 'todos/update';
export const DELETE_TODO = 'todos/delete';

// Redux Toolkit action creators
export const addTodo = createAction('todos/add', (text) => ({
  payload: {
    id: nanoid(),
    text,
    completed: false,
    createdAt: Date.now()
  }
}));

export const updateTodo = createAction('todos/update');
export const deleteTodo = createAction('todos/delete');

// Async thunk action
import { createAsyncThunk } from '@reduxjs/toolkit';

export const fetchTodos = createAsyncThunk(
  'todos/fetch',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await api.getTodos(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);
```

### Reducers and Pure Functions
```javascript
import { createReducer, createSlice } from '@reduxjs/toolkit';

// Using createSlice (recommended)
const todosSlice = createSlice({
  name: 'todos',
  initialState: {
    items: [],
    loading: false,
    error: null
  },
  reducers: {
    addTodo: (state, action) => {
      state.items.push(action.payload);
    },
    updateTodo: (state, action) => {
      const todo = state.items.find(t => t.id === action.payload.id);
      if (todo) {
        Object.assign(todo, action.payload);
      }
    },
    deleteTodo: (state, action) => {
      state.items = state.items.filter(t => t.id !== action.payload.id);
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchTodos.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchTodos.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload;
      })
      .addCase(fetchTodos.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  }
});

export const { addTodo, updateTodo, deleteTodo } = todosSlice.actions;
export default todosSlice.reducer;
```

### Store Configuration
```javascript
import { configureStore } from '@reduxjs/toolkit';
import todosReducer from './slices/todosSlice';
import userReducer from './slices/userSlice';

export const store = configureStore({
  reducer: {
    todos: todosReducer,
    user: userReducer
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST']
      }
    }),
  devTools: process.env.NODE_ENV !== 'production'
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### React-Redux Hooks
```typescript
import { useSelector, useDispatch } from 'react-redux';
import type { TypedUseSelectorHook } from 'react-redux';
import type { RootState, AppDispatch } from './store';

// Typed hooks
export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

// Component usage
function TodoList() {
  const todos = useAppSelector((state) => state.todos.items);
  const loading = useAppSelector((state) => state.todos.loading);
  const dispatch = useAppDispatch();

  const handleAdd = (text: string) => {
    dispatch(addTodo(text));
  };

  useEffect(() => {
    dispatch(fetchTodos(userId));
  }, [userId, dispatch]);

  if (loading) return <Spinner />;

  return <ul>{todos.map(todo => <TodoItem key={todo.id} {...todo} />)}</ul>;
}
```

### Immutable Update Patterns
```javascript
// Array operations
const addItem = (state) => ({
  ...state,
  items: [...state.items, newItem]
});

const removeItem = (state, id) => ({
  ...state,
  items: state.items.filter(item => item.id !== id)
});

const updateItem = (state, id, updates) => ({
  ...state,
  items: state.items.map(item =>
    item.id === id ? { ...item, ...updates } : item
  )
});

// Nested object updates
const updateNestedState = (state) => ({
  ...state,
  user: {
    ...state.user,
    profile: {
      ...state.user.profile,
      name: 'New Name'
    }
  }
});

// With Immer (Redux Toolkit)
const updateWithImmer = (state, action) => {
  state.user.profile.name = 'New Name'; // Direct mutation works!
};
```

## OPTIONAL

### Redux Toolkit Query (RTK Query)
```javascript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const todosApi = createApi({
  reducerPath: 'todosApi',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['Todo'],
  endpoints: (builder) => ({
    getTodos: builder.query({
      query: () => 'todos',
      providesTags: ['Todo']
    }),
    addTodo: builder.mutation({
      query: (todo) => ({
        url: 'todos',
        method: 'POST',
        body: todo
      }),
      invalidatesTags: ['Todo']
    }),
    updateTodo: builder.mutation({
      query: ({ id, ...patch }) => ({
        url: `todos/${id}`,
        method: 'PATCH',
        body: patch
      }),
      invalidatesTags: ['Todo']
    })
  })
});

export const { useGetTodosQuery, useAddTodoMutation, useUpdateTodoMutation } = todosApi;

// Usage in component
function TodoList() {
  const { data: todos, isLoading } = useGetTodosQuery();
  const [addTodo] = useAddTodoMutation();

  return <div>{/* render todos */}</div>;
}
```

### Middleware Patterns
```javascript
// Custom logging middleware
const loggerMiddleware = (store) => (next) => (action) => {
  console.group(action.type);
  console.log('Previous State:', store.getState());
  console.log('Action:', action);
  const result = next(action);
  console.log('Next State:', store.getState());
  console.groupEnd();
  return result;
};

// Error handling middleware
const errorMiddleware = (store) => (next) => (action) => {
  try {
    return next(action);
  } catch (error) {
    console.error('Redux Error:', error);
    store.dispatch({
      type: 'ERROR_OCCURRED',
      payload: { error: error.message, action }
    });
  }
};

// Analytics middleware
const analyticsMiddleware = (store) => (next) => (action) => {
  if (action.meta?.analytics) {
    analytics.track(action.type, action.payload);
  }
  return next(action);
};
```

### Selectors with Reselect
```javascript
import { createSelector } from '@reduxjs/toolkit';

// Input selectors
const selectTodos = (state) => state.todos.items;
const selectFilter = (state) => state.todos.filter;
const selectSearchTerm = (state) => state.todos.searchTerm;

// Memoized selector
export const selectFilteredTodos = createSelector(
  [selectTodos, selectFilter, selectSearchTerm],
  (todos, filter, searchTerm) => {
    let filtered = todos;

    // Apply filter
    if (filter === 'COMPLETED') {
      filtered = filtered.filter(t => t.completed);
    } else if (filter === 'ACTIVE') {
      filtered = filtered.filter(t => !t.completed);
    }

    // Apply search
    if (searchTerm) {
      filtered = filtered.filter(t =>
        t.text.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    return filtered;
  }
);

// Selector with parameters
export const makeSelectTodoById = () =>
  createSelector(
    [selectTodos, (_, id) => id],
    (todos, id) => todos.find(t => t.id === id)
  );
```

### Entity Adapters
```javascript
import { createEntityAdapter, createSlice } from '@reduxjs/toolkit';

const todosAdapter = createEntityAdapter({
  selectId: (todo) => todo.id,
  sortComparer: (a, b) => b.createdAt - a.createdAt
});

const todosSlice = createSlice({
  name: 'todos',
  initialState: todosAdapter.getInitialState({
    loading: false,
    error: null
  }),
  reducers: {
    todoAdded: todosAdapter.addOne,
    todosReceived: todosAdapter.setAll,
    todoUpdated: todosAdapter.updateOne,
    todoDeleted: todosAdapter.removeOne
  }
});

// Generated selectors
export const {
  selectAll: selectAllTodos,
  selectById: selectTodoById,
  selectIds: selectTodoIds
} = todosAdapter.getSelectors((state) => state.todos);
```

## ADVANCED

### Custom Middleware Development
```javascript
const createSocketMiddleware = (socket) => {
  return (store) => {
    socket.on('message', (data) => {
      store.dispatch({ type: 'SOCKET_MESSAGE', payload: data });
    });

    return (next) => (action) => {
      if (action.meta?.socket) {
        socket.emit(action.type, action.payload);
      }
      return next(action);
    };
  };
};

// Batching middleware
const batchMiddleware = (store) => {
  let scheduled = false;
  let batch = [];

  return (next) => (action) => {
    if (action.meta?.batch) {
      batch.push(action);

      if (!scheduled) {
        scheduled = true;
        queueMicrotask(() => {
          const actions = batch;
          batch = [];
          scheduled = false;
          store.dispatch({ type: 'BATCH', payload: actions });
        });
      }
      return action;
    }
    return next(action);
  };
};
```

### Performance Optimization
```javascript
import { shallowEqual } from 'react-redux';

// Optimized selector usage
function TodoList() {
  const todos = useAppSelector(selectFilteredTodos, shallowEqual);

  // Memoize callbacks
  const handleAdd = useCallback((text) => {
    dispatch(addTodo(text));
  }, [dispatch]);

  return <List items={todos} onAdd={handleAdd} />;
}

// Split selectors for better memoization
const selectTodoIds = createSelector(
  [selectAllTodos],
  (todos) => todos.map(t => t.id)
);

const selectTodoById = createSelector(
  [(state, id) => state.todos.entities[id]],
  (todo) => todo
);
```

### Testing Redux Logic
```javascript
import { configureStore } from '@reduxjs/toolkit';
import todosReducer, { addTodo, fetchTodos } from './todosSlice';

describe('todosSlice', () => {
  let store;

  beforeEach(() => {
    store = configureStore({ reducer: { todos: todosReducer } });
  });

  test('should add todo', () => {
    const todo = { text: 'Test todo' };
    store.dispatch(addTodo(todo.text));

    const state = store.getState().todos;
    expect(state.items).toHaveLength(1);
    expect(state.items[0].text).toBe(todo.text);
  });

  test('should handle async fetch', async () => {
    const mockTodos = [{ id: '1', text: 'Test' }];
    api.getTodos = jest.fn().mockResolvedValue({ data: mockTodos });

    await store.dispatch(fetchTodos('user1'));

    const state = store.getState().todos;
    expect(state.items).toEqual(mockTodos);
    expect(state.loading).toBe(false);
  });
});
```

## Test Templates

### Reducer Tests
```javascript
describe('todosReducer', () => {
  test('should return initial state', () => {
    expect(todosReducer(undefined, { type: 'unknown' })).toEqual(initialState);
  });

  test('should handle addTodo', () => {
    const actual = todosReducer(initialState, addTodo('Test'));
    expect(actual.items).toHaveLength(1);
  });
});
```

### Async Thunk Tests
```javascript
describe('fetchTodos', () => {
  test('should fetch todos successfully', async () => {
    const mockTodos = [{ id: '1', text: 'Test' }];
    api.getTodos = jest.fn().mockResolvedValue({ data: mockTodos });

    const result = await store.dispatch(fetchTodos('user1'));
    expect(result.payload).toEqual(mockTodos);
  });
});
```

### Selector Tests
```javascript
describe('selectors', () => {
  test('selectFilteredTodos should filter completed', () => {
    const state = {
      todos: {
        items: [
          { id: '1', completed: true },
          { id: '2', completed: false }
        ],
        filter: 'COMPLETED'
      }
    };
    expect(selectFilteredTodos(state)).toHaveLength(1);
  });
});
```

## Best Practices

### State Design
- Normalize complex/nested data
- Keep state minimal and derive data
- Separate domain, UI, and app state
- Use entity adapters for collections
- Avoid duplicate data

### Action Design
- Use Redux Toolkit action creators
- Follow FSA (Flux Standard Action) pattern
- Include metadata for analytics/logging
- Keep payloads focused and minimal
- Use action creators for consistency

### Reducer Design
- Use createSlice for reducers
- Keep reducers pure and predictable
- Handle all possible action types
- Use Immer for complex updates
- Split large reducers into slices

### Performance
- Use memoized selectors
- Connect at granular levels
- Implement selector equality checks
- Batch actions when possible
- Monitor state size

### Type Safety
- Define TypeScript types for state
- Type action creators and reducers
- Use ReturnType for inferred types
- Leverage Redux Toolkit types
- Create typed hooks

## Production Configuration

```javascript
import { configureStore } from '@reduxjs/toolkit';
import { persistStore, persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage';

const persistConfig = {
  key: 'root',
  storage,
  whitelist: ['user', 'settings']
};

const persistedReducer = persistReducer(persistConfig, rootReducer);

export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE']
      },
      immutableCheck: process.env.NODE_ENV !== 'production',
      thunk: true
    }).concat(
      process.env.NODE_ENV === 'production'
        ? [analyticsMiddleware, errorMiddleware]
        : [loggerMiddleware]
    ),
  devTools: process.env.NODE_ENV !== 'production',
  preloadedState: loadPersistedState()
});

export const persistor = persistStore(store);
```

## Assets

- See `assets/redux-config.yaml` for Redux patterns

## Resources

- [Redux Official Docs](https://redux.js.org/)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [React-Redux Hooks](https://react-redux.js.org/api/hooks)
- [Reselect](https://github.com/reduxjs/reselect)
- [RTK Query](https://redux-toolkit.js.org/rtk-query/overview)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
