# Redux Fundamentals - Comprehensive Guide

## Table of Contents
1. [What is Redux?](#what-is-redux)
2. [Core Concepts](#core-concepts)
3. [Store Creation](#store-creation)
4. [Reducers](#reducers)
5. [Actions](#actions)
6. [Dispatch](#dispatch)
7. [Middleware System](#middleware-system)
8. [Redux Thunk](#redux-thunk)
9. [React Integration](#react-integration)
10. [Redux DevTools](#redux-devtools)
11. [Performance](#performance)

## What is Redux?

Redux is a predictable state management library that helps you manage complex application state consistently. It provides a single source of truth (the store), making state changes predictable and debuggable. Redux follows these principles:

1. **Single Source of Truth**: Application state lives in a single store object
2. **State is Read-Only**: The only way to change state is by dispatching actions
3. **Changes are Made with Pure Functions**: Reducers are pure functions that take state and action, return new state

```javascript
// Redux flow visualization
User Action (click button)
    ↓
Action Creator (function that returns action)
    ↓
dispatch(action) - Send action to Redux
    ↓
Middleware (optional - intercept action)
    ↓
Reducer (pure function - handle action)
    ↓
New State
    ↓
Components Re-render (via useSelector)
```

## Core Concepts

### The Store
The store is a single JavaScript object that holds your entire application state. It's created once during app initialization and exposed to all components.

```javascript
import { createStore } from 'redux';
import rootReducer from './reducer';

const store = createStore(rootReducer);
```

The store provides three critical methods:
- `getState()` - Returns current state
- `dispatch(action)` - Sends an action to the reducer
- `subscribe(listener)` - Listens for state changes

### Actions
An action is a plain JavaScript object that describes what happened. Actions must have a `type` property.

```javascript
// Simple action
const addTodoAction = {
  type: 'ADD_TODO',
  payload: {
    id: 1,
    text: 'Learn Redux',
    completed: false
  }
};

// Action creator function
function addTodo(text) {
  return {
    type: 'ADD_TODO',
    payload: {
      id: Date.now(),
      text: text,
      completed: false
    }
  };
}

// Usage
dispatch(addTodo('Learn Redux'));
```

### Reducers
A reducer is a pure function that takes the current state and an action, then returns a new state. It must not mutate the original state.

```javascript
// Initial state
const initialState = {
  todos: [],
  filter: 'SHOW_ALL'
};

// Reducer function
function todoReducer(state = initialState, action) {
  switch(action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };

    case 'REMOVE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload)
      };

    case 'TOGGLE_TODO':
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };

    default:
      return state;
  }
}
```

Key reducer principles:
- **Pure function**: Same input always produces same output
- **No mutations**: Always return new state objects
- **No side effects**: No API calls, no async operations
- **Handle unknown actions**: Always return current state for unknown action types

### Dispatch
Dispatch is the only way to trigger a state change. It takes an action and sends it through the middleware chain to the reducer.

```javascript
// In a component or middleware
store.dispatch({ type: 'ADD_TODO', payload: { text: 'Buy milk' } });

// With action creators
store.dispatch(addTodo('Buy milk'));
```

## Store Creation

### Basic Store Setup
```javascript
import { createStore } from 'redux';

const store = createStore(
  rootReducer,  // Reducer function
  preloadedState,  // Optional: Initial state
  enhancer  // Optional: Middleware/DevTools
);
```

### With Middleware
```javascript
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

const middleware = [thunk];
const enhancer = applyMiddleware(...middleware);

const store = createStore(rootReducer, enhancer);
```

### Combining Multiple Reducers
Large applications split state into domains, each with its own reducer.

```javascript
import { combineReducers } from 'redux';

const rootReducer = combineReducers({
  todos: todoReducer,
  user: userReducer,
  ui: uiReducer,
  notifications: notificationReducer
});

// State shape:
// {
//   todos: { ... },
//   user: { ... },
//   ui: { ... },
//   notifications: { ... }
// }
```

## Reducers

### Pure Function Requirements
```javascript
// ✓ GOOD: Pure function
function reducer(state = {}, action) {
  if (action.type === 'SET_NAME') {
    // Return NEW object, don't mutate
    return { ...state, name: action.payload };
  }
  return state;
}

// ✗ BAD: Mutates state
function badReducer(state = {}, action) {
  if (action.type === 'SET_NAME') {
    state.name = action.payload;  // MUTATION!
    return state;
  }
  return state;
}

// ✗ BAD: Has side effects
function badReducer(state = {}, action) {
  if (action.type === 'SAVE_DATA') {
    fetch('/api/save', { body: action.payload });  // Side effect!
    return state;
  }
  return state;
}
```

### Immutability Patterns
```javascript
// Spread operator for objects
const newState = {
  ...state,
  user: {
    ...state.user,
    name: 'John'
  }
};

// Array concatenation
const newArray = [...state.items, newItem];
const filteredArray = state.items.filter(item => item.id !== removeId);
const mappedArray = state.items.map(item =>
  item.id === updateId ? { ...item, ...updates } : item
);

// Using Object.assign
const newState = Object.assign({}, state, { theme: 'dark' });

// Modern Immer library (safer immutability)
import produce from 'immer';

const newState = produce(state, draft => {
  draft.user.name = 'John';  // Looks like mutation but is safe
  draft.items.push(newItem);
});
```

### Handling Multiple Action Types
```javascript
function reducer(state = initialState, action) {
  switch(action.type) {
    case 'USER_LOGIN':
      return { ...state, user: action.payload, isAuthenticated: true };

    case 'USER_LOGOUT':
      return { ...state, user: null, isAuthenticated: false };

    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };

    case 'SET_ERROR':
      return { ...state, error: action.payload };

    default:
      return state;
  }
}
```

## Actions

### Action Objects
Actions are plain objects with at minimum a `type` property.

```javascript
const action = {
  type: 'TODO_ADDED',
  payload: {
    id: 1,
    text: 'Learn Redux',
    completed: false
  },
  meta: {
    timestamp: Date.now(),
    source: 'user'
  }
};
```

### Action Creators
Functions that create and return action objects.

```javascript
// Simple action creator
const addTodo = (text) => ({
  type: 'ADD_TODO',
  payload: { text, id: Date.now() }
});

// Action creator with validation
const updateTodo = (id, updates) => {
  if (!id) throw new Error('ID required');
  return {
    type: 'UPDATE_TODO',
    payload: { id, ...updates }
  };
};

// Async action creator (with thunk middleware)
const fetchUser = (userId) => async (dispatch) => {
  dispatch({ type: 'FETCH_START' });
  try {
    const response = await fetch(`/api/users/${userId}`);
    const data = await response.json();
    dispatch({ type: 'FETCH_SUCCESS', payload: data });
  } catch (error) {
    dispatch({ type: 'FETCH_ERROR', payload: error.message });
  }
};
```

## Dispatch

### Direct Dispatch
```javascript
// In React component
import { useDispatch } from 'react-redux';

function MyComponent() {
  const dispatch = useDispatch();

  const handleClick = () => {
    dispatch({ type: 'INCREMENT' });
  };

  return <button onClick={handleClick}>Increment</button>;
}
```

### With Action Creators
```javascript
import { useDispatch } from 'react-redux';
import { addTodo } from './actions';

function TodoForm() {
  const dispatch = useDispatch();

  const handleSubmit = (text) => {
    dispatch(addTodo(text));
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

### Dispatching Multiple Actions
```javascript
const handleMultipleActions = () => {
  dispatch(setLoading(true));
  dispatch(clearErrors());
  dispatch(fetchData(id));
};
```

## Middleware System

Middleware provides a way to intercept and potentially transform actions before they reach the reducer.

### Middleware Structure
```javascript
// Middleware signature: store => next => action => ...
const myMiddleware = (store) => (next) => (action) => {
  // Called before reducer
  console.log('Before:', store.getState());

  // Pass action to next middleware or reducer
  const result = next(action);

  // Called after reducer
  console.log('After:', store.getState());

  return result;
};

// Usage
const store = createStore(reducer, applyMiddleware(myMiddleware));
```

### Common Middleware Examples

**Logging Middleware**
```javascript
const logger = (store) => (next) => (action) => {
  console.group(action.type);
  console.log('Dispatching:', action);
  const result = next(action);
  console.log('Next state:', store.getState());
  console.groupEnd();
  return result;
};
```

**Error Handling Middleware**
```javascript
const errorHandler = (store) => (next) => (action) => {
  try {
    return next(action);
  } catch (error) {
    console.error('Error:', error);
    store.dispatch({ type: 'ERROR_OCCURRED', payload: error.message });
    throw error;
  }
};
```

**Analytics Middleware**
```javascript
const analytics = (store) => (next) => (action) => {
  const result = next(action);

  // Track action in analytics service
  if (window.gtag) {
    window.gtag('event', action.type, {
      state: store.getState()
    });
  }

  return result;
};
```

### Applying Middleware
```javascript
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';

const middleware = [logger, errorHandler, thunk];
const enhancers = compose(
  applyMiddleware(...middleware),
  window.__REDUX_DEVTOOLS_EXTENSION__ ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f
);

const store = createStore(rootReducer, enhancers);
```

## Redux Thunk

Redux Thunk middleware allows action creators to return functions instead of plain objects. This enables async operations and conditional dispatching.

### Basic Thunk Pattern
```javascript
// Regular action creator returns object
const syncAction = (data) => ({
  type: 'SYNC_ACTION',
  payload: data
});

// Thunk action creator returns function
const asyncAction = (id) => async (dispatch, getState) => {
  // Can dispatch multiple actions
  dispatch({ type: 'REQUEST_START' });

  try {
    const state = getState();  // Access current state
    const response = await fetch(`/api/data/${id}`);
    const data = await response.json();

    dispatch({ type: 'REQUEST_SUCCESS', payload: data });
  } catch (error) {
    dispatch({ type: 'REQUEST_ERROR', payload: error.message });
  }
};
```

### Thunk with Conditions
```javascript
const fetchUserIfNeeded = (userId) => (dispatch, getState) => {
  const state = getState();
  const user = state.users[userId];

  // Don't fetch if already loaded
  if (user) {
    return Promise.resolve(user);
  }

  return dispatch(fetchUser(userId));
};
```

### Chaining Thunks
```javascript
const loginUser = (credentials) => async (dispatch) => {
  const user = await dispatch(authenticateUser(credentials));
  await dispatch(loadUserPreferences(user.id));
  await dispatch(loadUserNotifications(user.id));
};
```

## React Integration

### Provider Setup
```javascript
import { Provider } from 'react-redux';
import store from './store';

function App() {
  return (
    <Provider store={store}>
      <YourAppComponent />
    </Provider>
  );
}
```

### useSelector Hook
Subscribes to state changes and returns selected state.

```javascript
import { useSelector } from 'react-redux';

function UserProfile() {
  // Re-renders when user changes
  const user = useSelector(state => state.user);

  // Re-renders only when userId changes (optimized selector)
  const userId = useSelector(state => state.user?.id);

  // Selectors with input
  const selectedUser = useSelector(
    state => state.users[state.selectedUserId]
  );

  return <div>{user?.name}</div>;
}
```

### useDispatch Hook
Gets the dispatch function to send actions.

```javascript
import { useDispatch } from 'react-redux';
import { addTodo } from './actions';

function TodoForm() {
  const dispatch = useDispatch();

  const handleAdd = (text) => {
    dispatch(addTodo(text));
  };

  return <form onSubmit={handleAdd}>...</form>;
}
```

### useCallback Optimization
```javascript
import { useCallback } from 'react';
import { useDispatch } from 'react-redux';

function TodoItem() {
  const dispatch = useDispatch();

  // Memoize callback to prevent child re-renders
  const handleToggle = useCallback(() => {
    dispatch(toggleTodo(id));
  }, [dispatch, id]);

  return <button onClick={handleToggle}>Toggle</button>;
}
```

## Redux DevTools

Redux DevTools Browser Extension provides powerful debugging capabilities.

### Setup
```javascript
import { createStore, compose } from 'redux';

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__
    ? window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({})
    : compose;

const store = createStore(
  rootReducer,
  composeEnhancers(applyMiddleware(...middleware))
);
```

### DevTools Features
- **Time-travel debugging**: Step through actions and state
- **State inspection**: View entire state tree at any point
- **Action history**: See all dispatched actions in order
- **State diffing**: Compare state before/after actions
- **Dispatch**: Manually dispatch actions from DevTools
- **Action filters**: Hide/show specific action types
- **Replay**: Replay a sequence of actions

```javascript
// In DevTools console, you can dispatch actions
store.dispatch({ type: 'INCREMENT' })

// Jump to specific action
// Use the Redux DevTools UI
```

## Performance

### Selector Memoization
Selectors should return the same reference when input doesn't change.

```javascript
// ✗ BAD: Creates new array on every render
const selectTodos = (state) => state.todos.filter(t => !t.completed);

// ✓ GOOD: Returns same reference when todos unchanged
import { createSelector } from 'reselect';

const selectAllTodos = (state) => state.todos;
const selectCompletedFilter = (state) => state.filter;

const selectActiveTodos = createSelector(
  [selectAllTodos, selectCompletedFilter],
  (todos, filter) => filter === 'active'
    ? todos.filter(t => !t.completed)
    : todos
);
```

### Component Subscriptions
Only subscribe to the exact state you need.

```javascript
// ✓ GOOD: Only listens to name
const userName = useSelector(state => state.user.name);

// ✗ BAD: Subscribes to entire user object
const user = useSelector(state => state.user);
```

### State Normalization
Normalize complex state to avoid deep nesting.

```javascript
// ✗ BAD: Nested structure, hard to update
const state = {
  posts: [
    {
      id: 1,
      title: 'Post 1',
      author: { id: 1, name: 'John' },
      comments: [{ id: 1, text: 'Comment 1' }]
    }
  ]
};

// ✓ GOOD: Normalized structure
const state = {
  posts: {
    1: { id: 1, title: 'Post 1', authorId: 1, commentIds: [1] }
  },
  authors: {
    1: { id: 1, name: 'John' }
  },
  comments: {
    1: { id: 1, text: 'Comment 1' }
  }
};
```

### Batching Actions
Reduce re-renders by batching multiple actions.

```javascript
import { batch } from 'react-redux';

const handleMultipleUpdates = () => {
  batch(() => {
    dispatch(action1());
    dispatch(action2());
    dispatch(action3());
  });
  // Components re-render once, not three times
};
```

## Summary

Redux provides:
- **Predictable state management** through pure functions
- **Centralized store** as single source of truth
- **Powerful debugging** with time-travel and DevTools
- **Scalability** for complex applications
- **Testability** of actions and reducers
- **Middleware system** for cross-cutting concerns

Key patterns to remember:
1. Actions describe what happened
2. Reducers update state immutably
3. Store manages state and dispatch
4. Middleware intercepts actions
5. React hooks connect components to store
6. Selectors encapsulate state queries
