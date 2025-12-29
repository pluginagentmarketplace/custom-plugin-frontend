# Redux Fundamentals - Real-World Patterns

## Table of Contents
1. [Ducks Pattern](#ducks-pattern)
2. [Feature-Based Structure](#feature-based-structure)
3. [Normalized State Shape](#normalized-state-shape)
4. [Async Action Patterns](#async-action-patterns)
5. [Middleware Patterns](#middleware-patterns)
6. [Selector Patterns](#selector-patterns)
7. [Redux Toolkit Basics](#redux-toolkit-basics)
8. [Testing Redux](#testing-redux)
9. [Common Pitfalls](#common-pitfalls)

## Ducks Pattern

The Ducks pattern (also called Modular Redux) bundles related reducers, actions, and action types in a single file.

### Structure
```
store/
├── index.js
├── ducks/
│   ├── todos.js
│   ├── users.js
│   ├── ui.js
│   └── notifications.js
└── selectors.js
```

### Example Duck: todos.js
```javascript
// Action types
const ADD_TODO = 'app/todos/ADD_TODO';
const REMOVE_TODO = 'app/todos/REMOVE_TODO';
const TOGGLE_TODO = 'app/todos/TOGGLE_TODO';

// Initial state
const initialState = {
  items: [],
  filter: 'ALL',
};

// Reducer
export default function todosReducer(state = initialState, action = {}) {
  switch (action.type) {
    case ADD_TODO:
      return {
        ...state,
        items: [
          ...state.items,
          {
            id: action.payload.id,
            text: action.payload.text,
            completed: false,
          },
        ],
      };

    case REMOVE_TODO:
      return {
        ...state,
        items: state.items.filter(todo => todo.id !== action.payload),
      };

    case TOGGLE_TODO:
      return {
        ...state,
        items: state.items.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        ),
      };

    default:
      return state;
  }
}

// Action creators
export const addTodo = (text) => ({
  type: ADD_TODO,
  payload: { id: Date.now(), text },
});

export const removeTodo = (id) => ({
  type: REMOVE_TODO,
  payload: id,
});

export const toggleTodo = (id) => ({
  type: TOGGLE_TODO,
  payload: id,
});

// Selectors
export const selectTodos = (state) => state.todos.items;
export const selectFilter = (state) => state.todos.filter;
export const selectActiveTodos = (state) =>
  state.todos.items.filter(todo => !todo.completed);
export const selectCompletedTodos = (state) =>
  state.todos.items.filter(todo => todo.completed);
```

### Store Index
```javascript
import { combineReducers, createStore } from 'redux';
import todosReducer from './ducks/todos';
import usersReducer from './ducks/users';
import uiReducer from './ducks/ui';

const rootReducer = combineReducers({
  todos: todosReducer,
  users: usersReducer,
  ui: uiReducer,
});

export default createStore(rootReducer);
```

## Feature-Based Structure

Organize Redux state and components by feature/domain.

### Folder Structure
```
src/
├── store/
│   ├── index.js
│   ├── auth/
│   │   ├── reducer.js
│   │   ├── actions.js
│   │   ├── selectors.js
│   │   └── thunks.js
│   ├── posts/
│   │   ├── reducer.js
│   │   ├── actions.js
│   │   ├── selectors.js
│   │   └── thunks.js
│   └── comments/
│       ├── reducer.js
│       ├── actions.js
│       ├── selectors.js
│       └── thunks.js
├── features/
│   ├── Auth/
│   │   ├── Login.jsx
│   │   ├── Profile.jsx
│   │   └── useAuth.js (custom hook)
│   ├── Posts/
│   │   ├── PostList.jsx
│   │   ├── PostForm.jsx
│   │   └── usePosts.js
│   └── Comments/
│       ├── CommentList.jsx
│       └── useComments.js
```

### Feature Reducer Example: posts/reducer.js
```javascript
const initialState = {
  list: [],
  selectedPost: null,
  loading: false,
  error: null,
};

export default function postsReducer(state = initialState, action) {
  switch (action.type) {
    case 'POSTS/FETCH_REQUEST':
      return { ...state, loading: true, error: null };

    case 'POSTS/FETCH_SUCCESS':
      return { ...state, list: action.payload, loading: false };

    case 'POSTS/FETCH_ERROR':
      return { ...state, error: action.payload, loading: false };

    case 'POSTS/SELECT':
      return { ...state, selectedPost: action.payload };

    case 'POSTS/ADD':
      return {
        ...state,
        list: [...state.list, action.payload],
      };

    case 'POSTS/UPDATE':
      return {
        ...state,
        list: state.list.map(post =>
          post.id === action.payload.id ? action.payload : post
        ),
      };

    case 'POSTS/DELETE':
      return {
        ...state,
        list: state.list.filter(post => post.id !== action.payload),
      };

    default:
      return state;
  }
}
```

### Feature Actions: posts/actions.js
```javascript
export const fetchPosts = () => async (dispatch) => {
  dispatch({ type: 'POSTS/FETCH_REQUEST' });
  try {
    const response = await fetch('/api/posts');
    const data = await response.json();
    dispatch({ type: 'POSTS/FETCH_SUCCESS', payload: data });
  } catch (error) {
    dispatch({ type: 'POSTS/FETCH_ERROR', payload: error.message });
  }
};

export const selectPost = (post) => ({
  type: 'POSTS/SELECT',
  payload: post,
});

export const createPost = (post) => async (dispatch) => {
  dispatch({ type: 'POSTS/FETCH_REQUEST' });
  try {
    const response = await fetch('/api/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(post),
    });
    const newPost = await response.json();
    dispatch({ type: 'POSTS/ADD', payload: newPost });
  } catch (error) {
    dispatch({ type: 'POSTS/FETCH_ERROR', payload: error.message });
  }
};
```

## Normalized State Shape

For complex data relationships, normalize your state to avoid deep nesting and duplication.

### Example: Blog with Posts, Authors, Comments
```javascript
// ✗ BAD: Denormalized (nested, duplicated data)
const state = {
  posts: [
    {
      id: 1,
      title: 'First Post',
      author: {
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
      },
      comments: [
        {
          id: 1,
          text: 'Great post!',
          author: {
            id: 2,
            name: 'Bob',
            email: 'bob@example.com',
          },
        },
      ],
    },
  ],
};

// ✓ GOOD: Normalized (flattened, referenced by ID)
const state = {
  posts: {
    byId: {
      1: {
        id: 1,
        title: 'First Post',
        authorId: 1,
        commentIds: [1],
      },
    },
    allIds: [1],
  },
  authors: {
    byId: {
      1: { id: 1, name: 'Alice', email: 'alice@example.com' },
      2: { id: 2, name: 'Bob', email: 'bob@example.com' },
    },
    allIds: [1, 2],
  },
  comments: {
    byId: {
      1: {
        id: 1,
        text: 'Great post!',
        authorId: 2,
      },
    },
    allIds: [1],
  },
};
```

### Normalized Selectors with Denormalization
```javascript
// Get a single post with nested author and comments
export const selectPostWithDetails = (state, postId) => {
  const post = state.posts.byId[postId];
  if (!post) return null;

  return {
    ...post,
    author: state.authors.byId[post.authorId],
    comments: post.commentIds.map(commentId => {
      const comment = state.comments.byId[commentId];
      return {
        ...comment,
        author: state.authors.byId[comment.authorId],
      };
    }),
  };
};

// Update a post
const updatePost = (postId, updates) => (dispatch) => {
  dispatch({
    type: 'POSTS/UPDATE',
    payload: { id: postId, ...updates },
  });
};

// Delete with cascading (remove comments when post deleted)
const deletePost = (postId) => (dispatch, getState) => {
  const state = getState();
  const post = state.posts.byId[postId];

  // Delete comments first
  post.commentIds.forEach(commentId => {
    dispatch({ type: 'COMMENTS/DELETE', payload: commentId });
  });

  // Then delete post
  dispatch({ type: 'POSTS/DELETE', payload: postId });
};
```

## Async Action Patterns

### Request/Success/Failure Pattern
```javascript
const initialState = {
  data: null,
  loading: false,
  error: null,
  lastFetch: null,
};

function reducer(state = initialState, action) {
  switch (action.type) {
    case 'FETCH_REQUEST':
      return { ...state, loading: true, error: null };

    case 'FETCH_SUCCESS':
      return {
        ...state,
        loading: false,
        data: action.payload,
        lastFetch: Date.now(),
      };

    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload };

    default:
      return state;
  }
}

// Thunk with error handling and retry
export const fetchData = (retries = 3) => async (dispatch) => {
  dispatch({ type: 'FETCH_REQUEST' });

  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      const response = await fetch('/api/data');
      if (!response.ok) throw new Error(`HTTP ${response.status}`);

      const data = await response.json();
      dispatch({ type: 'FETCH_SUCCESS', payload: data });
      return;
    } catch (error) {
      if (attempt === retries - 1) {
        dispatch({ type: 'FETCH_ERROR', payload: error.message });
      }
      // Wait before retrying
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
};
```

### Polling Pattern
```javascript
let pollInterval = null;

export const startPolling = (interval = 5000) => (dispatch) => {
  pollInterval = setInterval(() => {
    dispatch(fetchData());
  }, interval);
};

export const stopPolling = () => {
  if (pollInterval) {
    clearInterval(pollInterval);
  }
};
```

### Conditional Fetching
```javascript
export const fetchDataIfNeeded = () => (dispatch, getState) => {
  const state = getState();
  const { data, loading, lastFetch } = state;

  // Don't fetch if:
  // 1. Already loading
  // 2. Data exists and is fresh (less than 5 minutes old)
  if (loading) return;
  if (data && Date.now() - lastFetch < 5 * 60 * 1000) return;

  dispatch(fetchData());
};
```

## Middleware Patterns

### Thunk Middleware Basics
```javascript
// Redux Thunk signature
const thunk = store => next => action => {
  if (typeof action === 'function') {
    return action(store.dispatch, store.getState);
  }
  return next(action);
};

// Usage
const myThunk = () => async (dispatch, getState) => {
  const state = getState();
  dispatch({ type: 'ACTION_1' });
  // ...
};

dispatch(myThunk());
```

### Persistence Middleware
```javascript
const persistenceMiddleware = store => next => action => {
  const result = next(action);

  // Save state to localStorage after every action
  try {
    const state = store.getState();
    localStorage.setItem('appState', JSON.stringify(state));
  } catch (error) {
    console.error('Failed to save state:', error);
  }

  return result;
};

// Hydrate on startup
const savedState = localStorage.getItem('appState');
const preloadedState = savedState ? JSON.parse(savedState) : undefined;

const store = createStore(rootReducer, preloadedState, applyMiddleware(persistenceMiddleware));
```

### Debounce Middleware
```javascript
const debounceMiddleware = store => next => action => {
  let debounceTimer = null;

  return (finalAction) => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      next(finalAction);
    }, 300);
  };
};

// Dispatch same action multiple times, only last one goes through
```

## Selector Patterns

### Basic Selectors
```javascript
// Flat selectors
export const selectUser = state => state.user;
export const selectUserId = state => state.user?.id;
export const selectUserName = state => state.user?.name;
export const selectIsAuthenticated = state => state.user !== null;

// Derived selectors
export const selectUserRole = state => {
  const user = state.user;
  return user?.roles?.[0] || 'guest';
};

export const selectIsAdmin = state => {
  const user = state.user;
  return user?.roles?.includes('admin') || false;
};
```

### Memoized Selectors with Reselect
```javascript
import { createSelector } from 'reselect';

// Input selectors (access state)
const selectPostsState = state => state.posts;
const selectFilterState = state => state.filter;

// Memoized selector (only recomputes when inputs change)
export const selectFilteredPosts = createSelector(
  [selectPostsState, selectFilterState],
  (posts, filter) => {
    // This function only runs when posts or filter changes
    return posts.filter(post => post.status === filter);
  }
);

// Chained selectors
export const selectPostsWithAuthors = createSelector(
  [selectFilteredPosts, state => state.authors],
  (posts, authors) => {
    return posts.map(post => ({
      ...post,
      author: authors[post.authorId],
    }));
  }
);
```

### Parameterized Selectors
```javascript
// Factory pattern for parameterized selectors
export const selectPostById = (postId) =>
  createSelector(
    [state => state.posts.byId],
    (postsById) => postsById[postId]
  );

// Usage in component
const post = useSelector(state => selectPostById(postId)(state));
```

## Redux Toolkit Basics

Redux Toolkit simplifies Redux boilerplate with utilities like `createSlice`.

### createSlice Example
```javascript
import { createSlice } from '@reduxjs/toolkit';

const todosSlice = createSlice({
  name: 'todos',
  initialState: {
    items: [],
    filter: 'ALL',
  },
  reducers: {
    // Synchronous actions
    addTodo: (state, action) => {
      // RTK uses Immer, so mutations are safe
      state.items.push({
        id: Date.now(),
        text: action.payload,
        completed: false,
      });
    },

    removeTodo: (state, action) => {
      state.items = state.items.filter(todo => todo.id !== action.payload);
    },

    toggleTodo: (state, action) => {
      const todo = state.items.find(t => t.id === action.payload);
      if (todo) {
        todo.completed = !todo.completed;
      }
    },

    setFilter: (state, action) => {
      state.filter = action.payload;
    },
  },
  extraReducers: (builder) => {
    // Handle async thunks
    builder
      .addCase(fetchTodos.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchTodos.fulfilled, (state, action) => {
        state.items = action.payload;
        state.loading = false;
      })
      .addCase(fetchTodos.rejected, (state, action) => {
        state.error = action.error.message;
        state.loading = false;
      });
  },
});

// Auto-generated action creators
export const { addTodo, removeTodo, toggleTodo, setFilter } = todosSlice.actions;

// Auto-generated reducer
export default todosSlice.reducer;

// Selectors
export const selectTodos = state => state.todos.items;
export const selectFilter = state => state.todos.filter;
```

### createAsyncThunk
```javascript
import { createAsyncThunk } from '@reduxjs/toolkit';

export const fetchTodos = createAsyncThunk(
  'todos/fetchTodos',
  async (_, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/todos');
      if (!response.ok) throw new Error('Failed to fetch');
      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);
```

## Testing Redux

### Testing Reducers
```javascript
import todosReducer from './reducer';
import { addTodo, removeTodo, toggleTodo } from './actions';

describe('Todos Reducer', () => {
  it('should handle addTodo', () => {
    const initialState = { items: [], filter: 'ALL' };
    const action = addTodo('Learn Redux');

    const newState = todosReducer(initialState, action);

    expect(newState.items).toHaveLength(1);
    expect(newState.items[0].text).toBe('Learn Redux');
    expect(newState.items[0].completed).toBe(false);
  });

  it('should handle toggleTodo', () => {
    const initialState = {
      items: [{ id: 1, text: 'Learn Redux', completed: false }],
    };
    const action = toggleTodo(1);

    const newState = todosReducer(initialState, action);

    expect(newState.items[0].completed).toBe(true);
  });
});
```

### Testing Selectors
```javascript
import { selectFilteredPosts, selectPostsWithAuthors } from './selectors';

describe('Selectors', () => {
  const mockState = {
    posts: [
      { id: 1, title: 'Post 1', status: 'published' },
      { id: 2, title: 'Post 2', status: 'draft' },
    ],
    filter: 'published',
    authors: {
      1: { id: 1, name: 'Alice' },
      2: { id: 2, name: 'Bob' },
    },
  };

  it('should filter posts by status', () => {
    const result = selectFilteredPosts(mockState);
    expect(result).toHaveLength(1);
    expect(result[0].title).toBe('Post 1');
  });
});
```

### Testing Thunks
```javascript
import { fetchTodos } from './thunks';

describe('Thunk Actions', () => {
  it('should fetch todos', async () => {
    const dispatch = jest.fn();
    const getState = jest.fn(() => ({ todos: [] }));

    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve([{ id: 1, text: 'Test' }]),
      })
    );

    await fetchTodos()(dispatch, getState);

    expect(dispatch).toHaveBeenCalledWith(
      expect.objectContaining({ type: expect.stringContaining('REQUEST') })
    );
  });
});
```

## Common Pitfalls

### 1. Mutating State
```javascript
// ✗ WRONG: Mutates state
reducer(state, action) {
  state.user.name = action.payload;
  return state;
}

// ✓ CORRECT: Returns new state
reducer(state, action) {
  return {
    ...state,
    user: { ...state.user, name: action.payload }
  };
}
```

### 2. Async Operations in Reducers
```javascript
// ✗ WRONG: Has side effects
reducer(state, action) {
  fetch('/api/data').then(data => {
    state.data = data;  // Also mutation!
  });
  return state;
}

// ✓ CORRECT: Use thunks for async
const fetchData = () => async (dispatch) => {
  const data = await fetch('/api/data').then(r => r.json());
  dispatch({ type: 'SET_DATA', payload: data });
};
```

### 3. Infinite Loops with useSelector
```javascript
// ✗ WRONG: Creates new object every render
const user = useSelector(state => ({ ...state.user }));

// ✓ CORRECT: Return same reference when unchanged
const user = useSelector(state => state.user);

// ✓ OR: Use selector that handles equality
import { shallowEqual } from 'react-redux';
const user = useSelector(state => state.user, shallowEqual);
```

### 4. Prop Drilling with Redux
```javascript
// ✗ WRONG: Passing redux state as props
function Parent(props) {
  return <Child user={props.user} />;
}

// ✓ CORRECT: Components access Redux directly
function Parent() {
  const user = useSelector(state => state.user);
  return <Child />;  // Pass only necessary props
}

function Child() {
  const user = useSelector(state => state.user);
  // Use user directly
}
```

### 5. Over-complicated State Structure
```javascript
// ✗ WRONG: Deeply nested
const state = {
  app: {
    ui: {
      sidebar: {
        isOpen: true,
        width: 250,
      },
    },
  },
};

// ✓ BETTER: Flattened
const state = {
  sidebarOpen: true,
  sidebarWidth: 250,
};
```

## Summary

Key patterns for Redux success:
1. **Ducks Pattern**: Collocate related code
2. **Feature-Based Structure**: Organize by domain
3. **Normalization**: Flatten complex data
4. **Request/Success/Failure**: Handle async consistently
5. **Middleware**: Extract cross-cutting concerns
6. **Selectors**: Encapsulate state shape
7. **Toolkit**: Use modern, simplified APIs
8. **Testing**: Test reducers, selectors, and thunks
9. **Avoid Pitfalls**: Immutability, no side effects, pure functions
