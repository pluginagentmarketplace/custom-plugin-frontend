#!/bin/bash
# Generate complete Redux store with actions, reducers, and middleware

set -e

OUTPUT_DIR="${1:-src/store}"
STORE_NAME="${2:-app}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error() { echo -e "${RED}✗ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ $1${NC}"; }

# Header
echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Redux Store Generator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Create output directory
mkdir -p "$OUTPUT_DIR"
log_success "Created store directory: $OUTPUT_DIR"

# Generate action types
cat > "$OUTPUT_DIR/actionTypes.js" << 'EOF'
// Action Types - Define all actions your store can handle
// Convention: FEATURE/ACTION_TYPE

export const INIT_STATE = 'INIT_STATE';

// User actions
export const SET_USER = 'user/SET_USER';
export const CLEAR_USER = 'user/CLEAR_USER';
export const SET_LOADING = 'user/SET_LOADING';
export const SET_ERROR = 'user/SET_ERROR';

// Data actions
export const FETCH_DATA_REQUEST = 'data/FETCH_DATA_REQUEST';
export const FETCH_DATA_SUCCESS = 'data/FETCH_DATA_SUCCESS';
export const FETCH_DATA_FAILURE = 'data/FETCH_DATA_FAILURE';

// UI actions
export const SET_THEME = 'ui/SET_THEME';
export const TOGGLE_SIDEBAR = 'ui/TOGGLE_SIDEBAR';
EOF
log_success "Generated actionTypes.js"

# Generate action creators
cat > "$OUTPUT_DIR/actions.js" << 'EOF'
// Action Creators - Functions that return action objects
// Action = { type: string, payload?: any }

import * as types from './actionTypes';

export const setUser = (user) => ({
  type: types.SET_USER,
  payload: user,
});

export const clearUser = () => ({
  type: types.CLEAR_USER,
});

export const setLoading = (isLoading) => ({
  type: types.SET_LOADING,
  payload: isLoading,
});

export const setError = (error) => ({
  type: types.SET_ERROR,
  payload: error,
});

// Thunk for async actions
export const fetchUser = (userId) => async (dispatch) => {
  dispatch({ type: types.SET_LOADING, payload: true });
  try {
    // Simulated API call
    const response = await fetch(`/api/users/${userId}`);
    const user = await response.json();
    dispatch({
      type: types.SET_USER,
      payload: user,
    });
  } catch (error) {
    dispatch({
      type: types.SET_ERROR,
      payload: error.message,
    });
  } finally {
    dispatch({ type: types.SET_LOADING, payload: false });
  }
};

export const setTheme = (theme) => ({
  type: types.SET_THEME,
  payload: theme, // 'light' or 'dark'
});

export const toggleSidebar = () => ({
  type: types.TOGGLE_SIDEBAR,
});

// Data actions
export const fetchDataRequest = () => ({
  type: types.FETCH_DATA_REQUEST,
});

export const fetchDataSuccess = (data) => ({
  type: types.FETCH_DATA_SUCCESS,
  payload: data,
});

export const fetchDataFailure = (error) => ({
  type: types.FETCH_DATA_FAILURE,
  payload: error,
});
EOF
log_success "Generated actions.js"

# Generate reducer
cat > "$OUTPUT_DIR/reducer.js" << 'EOF'
// Reducer - Pure function that returns new state based on action
// Key principle: NEVER mutate state, always return new state

import * as types from './actionTypes';

const initialState = {
  user: null,
  isLoading: false,
  error: null,
  data: [],
  theme: 'light',
  sidebarOpen: true,
};

export default function rootReducer(state = initialState, action) {
  switch (action.type) {
    // User management
    case types.SET_USER:
      return {
        ...state,
        user: action.payload,
        error: null,
      };

    case types.CLEAR_USER:
      return {
        ...state,
        user: null,
      };

    case types.SET_LOADING:
      return {
        ...state,
        isLoading: action.payload,
      };

    case types.SET_ERROR:
      return {
        ...state,
        error: action.payload,
        isLoading: false,
      };

    // Data fetching
    case types.FETCH_DATA_REQUEST:
      return {
        ...state,
        isLoading: true,
        error: null,
      };

    case types.FETCH_DATA_SUCCESS:
      return {
        ...state,
        data: action.payload,
        isLoading: false,
        error: null,
      };

    case types.FETCH_DATA_FAILURE:
      return {
        ...state,
        isLoading: false,
        error: action.payload,
      };

    // UI state
    case types.SET_THEME:
      return {
        ...state,
        theme: action.payload,
      };

    case types.TOGGLE_SIDEBAR:
      return {
        ...state,
        sidebarOpen: !state.sidebarOpen,
      };

    case types.INIT_STATE:
      return state;

    default:
      return state;
  }
}
EOF
log_success "Generated reducer.js"

# Generate selectors
cat > "$OUTPUT_DIR/selectors.js" << 'EOF'
// Selectors - Extract derived state from the store
// Benefits: Reusable, memoizable, encapsulate state shape

// User selectors
export const selectUser = (state) => state.user;
export const selectUserName = (state) => state.user?.name || 'Guest';
export const selectUserEmail = (state) => state.user?.email || '';
export const selectIsAuthenticated = (state) => state.user !== null;

// Loading/Error selectors
export const selectIsLoading = (state) => state.isLoading;
export const selectError = (state) => state.error;
export const selectHasError = (state) => state.error !== null;

// Data selectors
export const selectData = (state) => state.data;
export const selectDataCount = (state) => state.data.length;

// UI selectors
export const selectTheme = (state) => state.theme;
export const selectIsDarkMode = (state) => state.theme === 'dark';
export const selectSidebarOpen = (state) => state.sidebarOpen;

// Combined selectors (derive from other selectors)
export const selectUserInfo = (state) => ({
  name: selectUserName(state),
  email: selectUserEmail(state),
  isAuthenticated: selectIsAuthenticated(state),
  theme: selectTheme(state),
});
EOF
log_success "Generated selectors.js"

# Generate store index with DevTools
cat > "$OUTPUT_DIR/index.js" << 'EOF'
// Redux Store Configuration
// Setup: createStore, middleware, devtools, enhancers

import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from './reducer';

// Redux DevTools Browser Extension
const composeEnhancers =
  (typeof window !== 'undefined' &&
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__) ||
  compose;

// Middleware: Functions that can intercept actions
const middleware = [thunk];

// Custom logging middleware example
const logger = (store) => (next) => (action) => {
  console.group(action.type);
  console.info('dispatching', action);
  console.log('prev state', store.getState());
  const result = next(action);
  console.log('next state', store.getState());
  console.groupEnd();
  return result;
};

// Add logger in development
if (process.env.NODE_ENV === 'development') {
  middleware.push(logger);
}

// Create store with middleware and DevTools
export const store = createStore(
  rootReducer,
  composeEnhancers(applyMiddleware(...middleware))
);

// Enable hot module replacement for reducers
if (module.hot) {
  module.hot.accept('./reducer', () => {
    const nextRootReducer = require('./reducer').default;
    store.replaceReducer(nextRootReducer);
  });
}

export default store;
EOF
log_success "Generated index.js with DevTools"

# Generate React hooks file
cat > "$OUTPUT_DIR/hooks.js" << 'EOF'
// Custom Redux Hooks
// Encapsulate useSelector and useDispatch for reusability

import { useSelector, useDispatch } from 'react-redux';
import {
  selectUser,
  selectIsLoading,
  selectError,
  selectTheme,
  selectSidebarOpen,
  selectData,
} from './selectors';
import * as actions from './actions';

// User hooks
export const useUser = () => useSelector(selectUser);
export const useIsAuthenticated = () => useSelector(state => state.user !== null);

// Loading/Error hooks
export const useIsLoading = () => useSelector(selectIsLoading);
export const useError = () => useSelector(selectError);

// UI hooks
export const useTheme = () => useSelector(selectTheme);
export const useSidebarOpen = () => useSelector(selectSidebarOpen);

// Data hooks
export const useData = () => useSelector(selectData);

// Combined dispatch hook
export const useUserActions = () => {
  const dispatch = useDispatch();
  return {
    setUser: (user) => dispatch(actions.setUser(user)),
    clearUser: () => dispatch(actions.clearUser()),
    fetchUser: (userId) => dispatch(actions.fetchUser(userId)),
  };
};

export const useUIActions = () => {
  const dispatch = useDispatch();
  return {
    setTheme: (theme) => dispatch(actions.setTheme(theme)),
    toggleSidebar: () => dispatch(actions.toggleSidebar()),
  };
};
EOF
log_success "Generated hooks.js for React integration"

# Generate example component
cat > "$OUTPUT_DIR/example.component.jsx" << 'EOF'
// Example Component - Using Redux Store
import React, { useEffect } from 'react';
import { useUser, useIsLoading, useUserActions, useTheme, useUIActions } from './hooks';

export function UserProfile() {
  const user = useUser();
  const isLoading = useIsLoading();
  const { fetchUser, clearUser } = useUserActions();
  const theme = useTheme();
  const { setTheme } = useUIActions();

  useEffect(() => {
    // Fetch user on component mount
    if (!user) {
      fetchUser(1);
    }
  }, [user, fetchUser]);

  if (isLoading) return <div>Loading...</div>;
  if (!user) return <div>No user loaded</div>;

  return (
    <div className={`profile ${theme}`}>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Toggle Theme
      </button>
      <button onClick={clearUser}>Logout</button>
    </div>
  );
}

export default UserProfile;
EOF
log_success "Generated example.component.jsx"

# Generate middleware example
cat > "$OUTPUT_DIR/middleware.js" << 'EOF'
// Custom Middleware Examples
// Middleware: store => next => action => ...

// Logging middleware
export const loggerMiddleware = (store) => (next) => (action) => {
  console.log('Action:', action);
  console.log('State before:', store.getState());
  const result = next(action);
  console.log('State after:', store.getState());
  return result;
};

// Error handling middleware
export const errorMiddleware = (store) => (next) => (action) => {
  try {
    return next(action);
  } catch (error) {
    console.error('Error in action:', action.type, error);
    store.dispatch({ type: 'ERROR', payload: error.message });
    throw error;
  }
};

// Analytics middleware
export const analyticsMiddleware = (store) => (next) => (action) => {
  const result = next(action);
  // Send action to analytics service
  if (window.gtag) {
    window.gtag('event', action.type, {
      state: store.getState(),
    });
  }
  return result;
};

// Persistence middleware
export const persistenceMiddleware = (store) => (next) => (action) => {
  const result = next(action);
  // Persist state to localStorage
  localStorage.setItem('reduxState', JSON.stringify(store.getState()));
  return result;
};
EOF
log_success "Generated middleware.js"

# Generate package.json snippet
cat > "$OUTPUT_DIR/package.json.snippet" << 'EOF'
{
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-redux": "^8.0.0",
    "redux": "^4.2.0",
    "redux-thunk": "^2.4.0"
  },
  "devDependencies": {
    "redux-devtools": "^3.7.0"
  }
}
EOF
log_success "Generated package.json.snippet"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Generation Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

log_info "Created Redux store in: $OUTPUT_DIR"
echo -e "\n${GREEN}Files created:${NC}"
echo "  • actionTypes.js - Action type constants"
echo "  • actions.js - Action creators and thunks"
echo "  • reducer.js - Pure reducer function"
echo "  • selectors.js - State selectors"
echo "  • index.js - Store configuration with DevTools"
echo "  • hooks.js - React custom hooks"
echo "  • middleware.js - Custom middleware examples"
echo "  • example.component.jsx - Example React component"

echo -e "\n${GREEN}Next steps:${NC}"
echo "  1. Install dependencies: npm install redux react-redux redux-thunk"
echo "  2. Wrap your App with Provider: <Provider store={store}>"
echo "  3. Import store: import store from './store'"
echo "  4. Use hooks in components: useUser(), useUserActions(), etc."
echo "  5. Review example.component.jsx for usage patterns"

echo -e "\n${GREEN}Key patterns:${NC}"
echo "  • Actions describe what happened"
echo "  • Reducers update state immutably"
echo "  • Selectors extract state"
echo "  • Middleware intercepts actions"
echo "  • Hooks simplify component integration"

echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"
