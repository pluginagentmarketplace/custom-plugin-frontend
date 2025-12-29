#!/bin/bash
# Generate complete Context with Provider, reducer, and custom hook

set -e

OUTPUT_DIR="${1:-src/context}"
CONTEXT_NAME="${2:-app}"
CONTEXT_NAME_UPPER=$(echo "$CONTEXT_NAME" | tr '[:lower:]' '[:upper:]' | cut -c1)$(echo "$CONTEXT_NAME" | cut -c2-)
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
echo -e "${BLUE}Context API Generator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Create output directory
mkdir -p "$OUTPUT_DIR"
log_success "Created context directory: $OUTPUT_DIR"

# Generate Context file
cat > "$OUTPUT_DIR/${CONTEXT_NAME}Context.js" << EOF
/**
 * ${CONTEXT_NAME_UPPER} Context
 * Provides ${CONTEXT_NAME} state to components
 */

import React from 'react';

/**
 * Context for ${CONTEXT_NAME} state management
 * Default value includes state and dispatch
 */
const ${CONTEXT_NAME_UPPER}Context = React.createContext({
  state: null,
  dispatch: () => {},
});

export default ${CONTEXT_NAME_UPPER}Context;
EOF
log_success "Generated ${CONTEXT_NAME}Context.js"

# Generate reducer file
cat > "$OUTPUT_DIR/reducer.js" << 'EOF'
/**
 * Reducer for managing complex state
 * Pure function that returns new state based on action
 */

export const initialState = {
  loading: false,
  error: null,
  data: null,
  selectedId: null,
};

export const actionTypes = {
  // Loading states
  SET_LOADING: 'SET_LOADING',

  // Data operations
  FETCH_START: 'FETCH_START',
  FETCH_SUCCESS: 'FETCH_SUCCESS',
  FETCH_ERROR: 'FETCH_ERROR',

  // Item operations
  SET_DATA: 'SET_DATA',
  SELECT_ITEM: 'SELECT_ITEM',
  CLEAR_DATA: 'CLEAR_DATA',

  // Error handling
  CLEAR_ERROR: 'CLEAR_ERROR',
};

/**
 * Reducer function
 * @param {Object} state - Current state
 * @param {Object} action - Action object with type and payload
 * @returns {Object} New state
 */
export function reducer(state = initialState, action) {
  switch (action.type) {
    case actionTypes.SET_LOADING:
      return {
        ...state,
        loading: action.payload,
      };

    case actionTypes.FETCH_START:
      return {
        ...state,
        loading: true,
        error: null,
      };

    case actionTypes.FETCH_SUCCESS:
      return {
        ...state,
        data: action.payload,
        loading: false,
        error: null,
      };

    case actionTypes.FETCH_ERROR:
      return {
        ...state,
        error: action.payload,
        loading: false,
      };

    case actionTypes.SET_DATA:
      return {
        ...state,
        data: action.payload,
      };

    case actionTypes.SELECT_ITEM:
      return {
        ...state,
        selectedId: action.payload,
      };

    case actionTypes.CLEAR_DATA:
      return {
        ...state,
        data: null,
        selectedId: null,
      };

    case actionTypes.CLEAR_ERROR:
      return {
        ...state,
        error: null,
      };

    default:
      return state;
  }
}

export default reducer;
EOF
log_success "Generated reducer.js"

# Generate actions file
cat > "$OUTPUT_DIR/actions.js" << 'EOF'
/**
 * Action creators for context reducer
 */

import { actionTypes } from './reducer';

export const setLoading = (loading) => ({
  type: actionTypes.SET_LOADING,
  payload: loading,
});

export const fetchStart = () => ({
  type: actionTypes.FETCH_START,
});

export const fetchSuccess = (data) => ({
  type: actionTypes.FETCH_SUCCESS,
  payload: data,
});

export const fetchError = (error) => ({
  type: actionTypes.FETCH_ERROR,
  payload: error,
});

export const setData = (data) => ({
  type: actionTypes.SET_DATA,
  payload: data,
});

export const selectItem = (id) => ({
  type: actionTypes.SELECT_ITEM,
  payload: id,
});

export const clearData = () => ({
  type: actionTypes.CLEAR_DATA,
});

export const clearError = () => ({
  type: actionTypes.CLEAR_ERROR,
});

// Async action example
export const fetchData = (url) => async (dispatch) => {
  dispatch(fetchStart());
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    dispatch(fetchSuccess(data));
  } catch (error) {
    dispatch(fetchError(error.message));
  }
};
EOF
log_success "Generated actions.js"

# Generate Provider component
cat > "$OUTPUT_DIR/${CONTEXT_NAME_UPPER}Provider.jsx" << EOF
/**
 * ${CONTEXT_NAME_UPPER} Provider Component
 * Manages state with useReducer and provides via Context
 */

import React, { useReducer, useMemo, useCallback } from 'react';
import ${CONTEXT_NAME_UPPER}Context from './${CONTEXT_NAME}Context';
import reducer, { initialState } from './reducer';

/**
 * Provider component that wraps child components
 * Provides state and dispatch through context
 */
export function ${CONTEXT_NAME_UPPER}Provider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  // Memoize context value to prevent unnecessary re-renders
  const value = useMemo(() => {
    return {
      state,
      dispatch,
    };
  }, [state, dispatch]);

  return (
    <${CONTEXT_NAME_UPPER}Context.Provider value={value}>
      {children}
    </\${CONTEXT_NAME_UPPER}Context.Provider>
  );
}

export default ${CONTEXT_NAME_UPPER}Provider;
EOF
log_success "Generated ${CONTEXT_NAME_UPPER}Provider.jsx"

# Generate custom hook
cat > "$OUTPUT_DIR/use${CONTEXT_NAME_UPPER}.js" << EOF
/**
 * Custom hook for consuming ${CONTEXT_NAME} context
 * Provides type-safe access to context state and dispatch
 */

import { useContext } from 'react';
import ${CONTEXT_NAME_UPPER}Context from './${CONTEXT_NAME}Context';

/**
 * Hook to use ${CONTEXT_NAME} context
 * @returns {{state: Object, dispatch: Function}} Context value
 * @throws {Error} If used outside of ${CONTEXT_NAME_UPPER}Provider
 */
export function use${CONTEXT_NAME_UPPER}() {
  const context = useContext(${CONTEXT_NAME_UPPER}Context);

  if (!context) {
    throw new Error(
      'use${CONTEXT_NAME_UPPER}} must be used within <${CONTEXT_NAME_UPPER}Provider>'
    );
  }

  return context;
}

/**
 * Hook to access only state from context
 * Prevents unnecessary re-renders when dispatch is not needed
 */
export function use${CONTEXT_NAME_UPPER}State() {
  const { state } = use${CONTEXT_NAME_UPPER}();
  return state;
}

/**
 * Hook to access only dispatch from context
 * Useful for action dispatching without state dependency
 */
export function use${CONTEXT_NAME_UPPER}Dispatch() {
  const { dispatch } = use${CONTEXT_NAME_UPPER}();
  return dispatch;
}

export default use${CONTEXT_NAME_UPPER};
EOF
log_success "Generated use${CONTEXT_NAME_UPPER}.js custom hook"

# Generate example component
cat > "$OUTPUT_DIR/example.jsx" << EOF
/**
 * Example Component
 * Demonstrates how to use the ${CONTEXT_NAME_UPPER} context
 */

import React, { useEffect } from 'react';
import use${CONTEXT_NAME_UPPER}, {
  use${CONTEXT_NAME_UPPER}State,
  use${CONTEXT_NAME_UPPER}Dispatch,
} from './use${CONTEXT_NAME_UPPER}';
import {
  setLoading,
  fetchSuccess,
  fetchError,
  clearError,
} from './actions';

/**
 * Example: Component using entire context
 */
export function ComponentWithFullContext() {
  const { state, dispatch } = use${CONTEXT_NAME_UPPER}();

  const handleFetch = () => {
    dispatch(setLoading(true));
    // Simulate API call
    setTimeout(() => {
      dispatch(
        fetchSuccess({
          id: 1,
          name: 'Example Data',
        })
      );
    }, 1000);
  };

  return (
    <div>
      <h2>Full Context Example</h2>
      <p>Loading: {state.loading ? 'Yes' : 'No'}</p>
      <p>Data: {JSON.stringify(state.data)}</p>
      {state.error && <p style={{ color: 'red' }}>Error: {state.error}</p>}
      <button onClick={handleFetch}>Fetch Data</button>
      {state.error && (
        <button onClick={() => dispatch(clearError())}>Clear Error</button>
      )}
    </div>
  );
}

/**
 * Example: Component using only state
 * Prevents unnecessary re-renders when dispatch is not needed
 */
export function ComponentWithStateOnly() {
  const state = use${CONTEXT_NAME_UPPER}State();

  return (
    <div>
      <h3>State Only Example</h3>
      <p>Selected: {state.selectedId}</p>
      <p>Data: {state.data?.name}</p>
    </div>
  );
}

/**
 * Example: Component using only dispatch
 * For action dispatchers that don't need state
 */
export function ComponentWithDispatchOnly() {
  const dispatch = use${CONTEXT_NAME_UPPER}Dispatch();

  const handleAction = () => {
    dispatch(setLoading(true));
    // Do something...
  };

  return <button onClick={handleAction}>Trigger Action</button>;
}

/**
 * Example: Using context with useEffect
 */
export function ComponentWithEffect() {
  const { state, dispatch } = use${CONTEXT_NAME_UPPER}();

  useEffect(() => {
    // Fetch data when component mounts
    dispatch(setLoading(true));

    const fetchData = async () => {
      try {
        const response = await fetch('/api/data');
        const data = await response.json();
        dispatch(fetchSuccess(data));
      } catch (error) {
        dispatch(fetchError(error.message));
      }
    };

    fetchData();
  }, []); // Run once on mount

  if (state.loading) return <div>Loading...</div>;
  if (state.error) return <div>Error: {state.error}</div>;

  return (
    <div>
      <h2>Data Fetched</h2>
      <pre>{JSON.stringify(state.data, null, 2)}</pre>
    </div>
  );
}

export default ComponentWithFullContext;
EOF
log_success "Generated example.jsx"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Generation Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

log_info "Created Context in: $OUTPUT_DIR"
echo -e "\n${GREEN}Files created:${NC}"
echo "  • ${CONTEXT_NAME}Context.js - Context definition"
echo "  • reducer.js - Reducer function and action types"
echo "  • actions.js - Action creators"
echo "  • ${CONTEXT_NAME_UPPER}Provider.jsx - Provider component"
echo "  • use${CONTEXT_NAME_UPPER}.js - Custom hooks"
echo "  • example.jsx - Usage examples"

echo -e "\n${GREEN}Next steps:${NC}"
echo "  1. Wrap your app with the Provider:"
echo "     <${CONTEXT_NAME_UPPER}Provider><App /></${CONTEXT_NAME_UPPER}Provider>"
echo "  2. Import and use the custom hook in components:"
echo "     const { state, dispatch } = use${CONTEXT_NAME_UPPER}();"
echo "  3. Review example.jsx for usage patterns"
echo "  4. Consider splitting state if context gets large"

echo -e "\n${GREEN}Key patterns used:${NC}"
echo "  • useReducer for complex state"
echo "  • Context.Provider for distribution"
echo "  • Custom hooks for encapsulation"
echo "  • useMemo for optimization"
echo "  • Action creators for dispatching"

echo -e "\n${YELLOW}Performance tips:${NC}"
echo "  • Use separate hooks for state-only and dispatch-only"
echo "  • Memoize context value with useMemo"
echo "  • Consider useCallback for callback functions"
echo "  • Split large contexts into multiple providers"
echo "  • Use React.memo for components heavy on context"

echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"
