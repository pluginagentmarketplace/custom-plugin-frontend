# Redux Fundamentals - Scripts

Validation and generation scripts for Redux fundamentals.

## Scripts

### validate-redux.sh
Validates Redux store implementation structure.

**Usage:**
```bash
./scripts/validate-redux.sh [store-file-path]
```

**Checks:**
- Store creation with `createStore()` or `configureStore()`
- Reducer function implementation
- Action types definition
- Action creators
- Middleware configuration (applyMiddleware)
- Redux Thunk/Saga imports if used
- Redux DevTools integration
- Proper immutability in reducers
- store.dispatch() usage patterns
- React-Redux Provider setup

**Example:**
```bash
./scripts/validate-redux.sh src/store/index.js
```

### generate-redux-store.sh
Generates a complete Redux store with reducer, actions, middleware, and DevTools.

**Usage:**
```bash
./scripts/generate-redux-store.sh [output-directory] [store-name]
```

**Generates:**
- `index.js` - Store configuration with middleware and DevTools
- `actions.js` - Action creators with proper typing
- `reducer.js` - Pure reducer function with initial state
- `selectors.js` - Basic selectors for derived state
- `middleware.js` - Custom middleware example (optional)

**Example:**
```bash
./scripts/generate-redux-store.sh src/store userStore
# Creates src/store/userStore/ with all necessary files
```

## Script Dependencies

- `bash` 4.0+
- `grep` for pattern matching
- `node` (for generation script)

## Output Validation

Both scripts provide colored output:
- ✓ Green: Successful validation/creation
- ✗ Red: Error or missing requirement
- ⚠ Yellow: Warning or optional element
