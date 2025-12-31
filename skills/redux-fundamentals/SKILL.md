---
name: redux-fundamentals
description: Core Redux concepts including store setup, reducers, actions, dispatch, middleware, and Redux DevTools integration for predictable state management.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: state-management
bond_type: PRIMARY_BOND
production_config:
  performance_budget:
    store_size_limit: "5MB"
    action_payload_limit: "100KB"
    reducer_execution_time: "16ms"
  monitoring:
    redux_devtools: true
    action_logging: true
    performance_tracking: true
  optimization:
    selector_memoization: true
    immutable_updates: true
    normalized_state: true
---

# Redux Fundamentals

Master the core concepts of Redux for building predictable, maintainable state management systems with comprehensive store configuration, middleware integration, and debugging capabilities.

## Input Schema

```typescript
interface ReduxStoreConfig {
  initialState?: Record<string, any>;
  reducers: Record<string, ReducerFunction>;
  middleware?: Middleware[];
  enhancers?: StoreEnhancer[];
  devTools?: boolean;
}

interface Action {
  type: string;
  payload?: any;
  meta?: Record<string, any>;
  error?: boolean;
}

interface ReducerFunction {
  (state: any, action: Action): any;
}

interface StoreInstance {
  getState: () => any;
  dispatch: (action: Action) => Action;
  subscribe: (listener: () => void) => () => void;
  replaceReducer: (nextReducer: ReducerFunction) => void;
}
```

## Output Schema

```typescript
interface ReduxImplementation {
  store: StoreInstance;
  rootReducer: ReducerFunction;
  actionCreators: Record<string, (...args: any[]) => Action>;
  selectors: Record<string, (state: any) => any>;
  middleware: Middleware[];
  types: {
    actions: Record<string, string>;
    state: Record<string, any>;
  };
}

interface PerformanceMetrics {
  actionDispatchTime: number;
  reducerExecutionTime: number;
  stateSize: number;
  subscriberCount: number;
}
```

## Error Handling

| Error Type | Cause | Resolution | Prevention |
|------------|-------|------------|------------|
| `REDUCER_MUTATION` | Direct state mutation in reducer | Use spread operators or immer | Enable Redux DevTools mutation detection |
| `UNDEFINED_ACTION` | Action type not handled in reducer | Add default case returning current state | Use TypeScript for action types |
| `CIRCULAR_REFERENCE` | Circular objects in state | Serialize/normalize data structure | Use normalized state pattern |
| `MIDDLEWARE_ERROR` | Exception in middleware chain | Add error boundary middleware | Wrap middleware in try-catch |
| `DEVTOOLS_CONNECTION` | DevTools extension not available | Make DevTools optional with fallback | Check window.__REDUX_DEVTOOLS_EXTENSION__ |
| `ASYNC_DISPATCH` | Dispatching promise instead of action | Use Redux Thunk middleware | Type-check actions before dispatch |
| `LARGE_PAYLOAD` | Action payload exceeds size limits | Normalize and reference by ID | Monitor action sizes in DevTools |

## MANDATORY

### Store Setup and Configuration
```javascript
import { createStore, applyMiddleware, compose } from 'redux';
import { Provider } from 'react-redux';

// Configure Redux DevTools
const composeEnhancers =
  (typeof window !== 'undefined' &&
   window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__) || compose;

// Create store with middleware
const store = createStore(
  rootReducer,
  initialState,
  composeEnhancers(applyMiddleware(...middleware))
);

// Provide store to React app
<Provider store={store}>
  <App />
</Provider>
```

### Pure Reducer Functions
```javascript
// CORRECT: Pure reducer with immutable updates
const todoReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };
    case 'REMOVE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload.id)
      };
    default:
      return state;
  }
};

// INCORRECT: Mutating state directly
const badReducer = (state = initialState, action) => {
  state.todos.push(action.payload); // NEVER DO THIS
  return state;
};
```

### Action Creators
```javascript
// Action types as constants
export const ADD_TODO = 'todos/ADD_TODO';
export const REMOVE_TODO = 'todos/REMOVE_TODO';

// Simple action creators
export const addTodo = (todo) => ({
  type: ADD_TODO,
  payload: todo
});

export const removeTodo = (id) => ({
  type: REMOVE_TODO,
  payload: { id }
});
```

### React-Redux Integration
```javascript
import { useSelector, useDispatch } from 'react-redux';

function TodoList() {
  // Select state with useSelector
  const todos = useSelector(state => state.todos);
  const dispatch = useDispatch();

  // Dispatch actions
  const handleAdd = (todo) => {
    dispatch(addTodo(todo));
  };

  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>{todo.text}</li>
      ))}
    </ul>
  );
}
```

### Combining Reducers
```javascript
import { combineReducers } from 'redux';

const rootReducer = combineReducers({
  todos: todoReducer,
  user: userReducer,
  ui: uiReducer
});

// State shape: { todos: [], user: {}, ui: {} }
```

## OPTIONAL

### Redux Thunk for Async Actions
```javascript
import thunk from 'redux-thunk';

// Async action creator
export const fetchTodos = () => async (dispatch, getState) => {
  dispatch({ type: 'FETCH_TODOS_REQUEST' });

  try {
    const response = await fetch('/api/todos');
    const data = await response.json();
    dispatch({ type: 'FETCH_TODOS_SUCCESS', payload: data });
  } catch (error) {
    dispatch({ type: 'FETCH_TODOS_FAILURE', payload: error.message });
  }
};
```

### Custom Middleware Development
```javascript
const logger = store => next => action => {
  console.log('dispatching', action);
  const result = next(action);
  console.log('next state', store.getState());
  return result;
};

const errorHandler = store => next => action => {
  try {
    return next(action);
  } catch (error) {
    console.error('Action error:', error);
    store.dispatch({ type: 'ERROR_OCCURRED', payload: error });
  }
};
```

### Selector Pattern with Reselect
```javascript
import { createSelector } from 'reselect';

// Input selectors
const getTodos = state => state.todos;
const getFilter = state => state.filter;

// Memoized selector
const getVisibleTodos = createSelector(
  [getTodos, getFilter],
  (todos, filter) => {
    switch (filter) {
      case 'COMPLETED':
        return todos.filter(t => t.completed);
      case 'ACTIVE':
        return todos.filter(t => !t.completed);
      default:
        return todos;
    }
  }
);
```

### Redux Toolkit Basics
```javascript
import { configureStore, createSlice } from '@reduxjs/toolkit';

const todosSlice = createSlice({
  name: 'todos',
  initialState: [],
  reducers: {
    addTodo: (state, action) => {
      // Direct mutation works with Immer under the hood
      state.push(action.payload);
    },
    removeTodo: (state, action) => {
      return state.filter(todo => todo.id !== action.payload.id);
    }
  }
});

const store = configureStore({
  reducer: {
    todos: todosSlice.reducer
  }
});
```

## ADVANCED

### Middleware Composition and Chaining
```javascript
const analyticsMiddleware = store => next => action => {
  // Pre-processing
  const startTime = performance.now();

  // Pass to next middleware
  const result = next(action);

  // Post-processing
  const duration = performance.now() - startTime;
  analytics.track(action.type, { duration });

  return result;
};

// Middleware execution order matters
const middleware = [thunk, logger, analyticsMiddleware, errorHandler];
```

### Normalized State Structure
```javascript
const initialState = {
  entities: {
    todos: {
      byId: {
        '1': { id: '1', text: 'Learn Redux', userId: 'u1' },
        '2': { id: '2', text: 'Build app', userId: 'u1' }
      },
      allIds: ['1', '2']
    },
    users: {
      byId: {
        'u1': { id: 'u1', name: 'John' }
      },
      allIds: ['u1']
    }
  },
  ui: {
    selectedTodoId: null
  }
};

// Selector for denormalized data
const getTodoWithUser = createSelector(
  [getTodoById, getUserById],
  (todo, user) => ({ ...todo, user })
);
```

### Time-Travel Debugging
```javascript
// Configure Redux DevTools with time-travel
const store = createStore(
  rootReducer,
  window.__REDUX_DEVTOOLS_EXTENSION__?.({
    features: {
      pause: true,
      lock: true,
      persist: true,
      export: true,
      import: 'custom',
      jump: true,
      skip: true,
      reorder: true,
      dispatch: true,
      test: true
    }
  })
);
```

### Testing Redux Logic
```javascript
import { createStore } from 'redux';
import todoReducer, { addTodo, removeTodo } from './todoSlice';

describe('todoReducer', () => {
  let store;

  beforeEach(() => {
    store = createStore(todoReducer);
  });

  test('should add todo', () => {
    const todo = { id: '1', text: 'Test' };
    store.dispatch(addTodo(todo));

    expect(store.getState().todos).toContainEqual(todo);
  });

  test('should remove todo', () => {
    store.dispatch(addTodo({ id: '1', text: 'Test' }));
    store.dispatch(removeTodo('1'));

    expect(store.getState().todos).toHaveLength(0);
  });
});
```

## Test Templates

### Unit Tests
```javascript
// Reducer tests
describe('todoReducer', () => {
  test('should return initial state', () => {
    expect(todoReducer(undefined, {})).toEqual(initialState);
  });

  test('should handle ADD_TODO', () => {
    const action = addTodo({ id: '1', text: 'Test' });
    const state = todoReducer(undefined, action);
    expect(state.todos).toHaveLength(1);
  });
});

// Action creator tests
describe('action creators', () => {
  test('addTodo should create correct action', () => {
    const todo = { id: '1', text: 'Test' };
    expect(addTodo(todo)).toEqual({
      type: 'ADD_TODO',
      payload: todo
    });
  });
});

// Selector tests
describe('selectors', () => {
  test('getVisibleTodos should filter correctly', () => {
    const state = {
      todos: [
        { id: '1', completed: true },
        { id: '2', completed: false }
      ],
      filter: 'COMPLETED'
    };
    expect(getVisibleTodos(state)).toHaveLength(1);
  });
});
```

### Integration Tests
```javascript
import { renderWithProviders } from './test-utils';

describe('Redux Integration', () => {
  test('component dispatches action and updates state', () => {
    const { getByText, store } = renderWithProviders(<TodoList />);

    fireEvent.click(getByText('Add Todo'));

    expect(store.getState().todos).toHaveLength(1);
  });
});
```

### Middleware Tests
```javascript
describe('custom middleware', () => {
  test('logger middleware logs actions', () => {
    const logSpy = jest.spyOn(console, 'log');
    const store = createStore(reducer, applyMiddleware(logger));

    store.dispatch({ type: 'TEST_ACTION' });

    expect(logSpy).toHaveBeenCalledWith('dispatching', { type: 'TEST_ACTION' });
  });
});
```

## Best Practices

### State Design
- Keep state normalized to avoid duplication
- Separate domain data from UI state
- Use meaningful state shape that mirrors data relationships
- Avoid deeply nested state structures
- Store only serializable data (no functions, classes)

### Action Design
- Use action creators instead of inline objects
- Define action types as constants
- Include metadata in actions (timestamps, source)
- Keep action payloads minimal and focused
- Follow Flux Standard Action (FSA) pattern

### Reducer Design
- Never mutate state directly
- Keep reducers pure and deterministic
- Return current state for unhandled actions
- Split complex reducers using combineReducers
- Use switch statements or lookup tables

### Performance Optimization
- Use reselect for expensive computations
- Connect components at appropriate levels
- Use shallow equality checks wisely
- Normalize state to reduce redundant updates
- Implement shouldComponentUpdate or React.memo

### DevTools Integration
- Always enable Redux DevTools in development
- Use action sanitization for sensitive data
- Configure action blacklisting for noisy actions
- Export/import state for debugging
- Use time-travel debugging effectively

### Type Safety
- Use TypeScript for type-safe Redux
- Define action types and payloads
- Type reducers and selectors
- Use discriminated unions for actions
- Leverage Redux Toolkit for better types

## Production Configuration

### Store Setup
```javascript
import { configureStore } from '@reduxjs/toolkit';

const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST'],
        ignoredPaths: ['socket.connection']
      },
      immutableCheck: true,
      thunk: true
    }).concat(customMiddleware),
  devTools: process.env.NODE_ENV !== 'production',
  preloadedState: loadStateFromStorage(),
  enhancers: [monitorReducerEnhancer]
});
```

### Monitoring and Analytics
```javascript
const analyticsMiddleware = store => next => action => {
  if (process.env.NODE_ENV === 'production') {
    analytics.track(`REDUX_${action.type}`, {
      payload: action.payload,
      timestamp: Date.now()
    });
  }
  return next(action);
};
```

## References

- [Redux Official Documentation](https://redux.js.org/)
- [React-Redux Hooks API](https://react-redux.js.org/api/hooks)
- [Redux Thunk](https://github.com/reduxjs/redux-thunk)
- [Reselect](https://github.com/reduxjs/reselect)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [Redux DevTools Extension](https://github.com/reduxjs/redux-devtools)

---
**Status:** Production Ready | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
