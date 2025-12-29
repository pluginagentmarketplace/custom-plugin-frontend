# Zustand Minimalist - Scripts

Validation and generation scripts for Zustand stores.

## Scripts

### validate-zustand.sh
Validates Zustand store implementation and patterns.

**Usage:**
```bash
./scripts/validate-zustand.sh [store-directory]
```

**Checks:**
- Store creation with create()
- State definition in store
- Actions and getters implementation
- Middleware usage (persist, devtools, immer)
- Selector patterns
- TypeScript support (if using .ts/.tsx)
- Testing patterns
- Performance optimizations
- Proper error handling

**Example:**
```bash
./scripts/validate-zustand.sh src/store
```

### generate-zustand-store.sh
Generates complete Zustand store with middleware, selectors, and testing setup.

**Usage:**
```bash
./scripts/generate-zustand-store.sh [output-directory] [store-name]
```

**Generates:**
- `{name}Store.js` - Main store definition with create()
- `{name}Selectors.js` - Selector functions
- `{name}Middleware.js` - Custom middleware (persist, devtools, immer)
- `{name}.test.js` - Jest test suite
- `example.jsx` - Example component using store
- `types.js` - JSDoc type definitions

**Example:**
```bash
./scripts/generate-zustand-store.sh src/store userStore
# Creates src/store/userStore.js with all necessary files
```

## Script Dependencies

- `bash` 4.0+
- `grep` for pattern matching
- `node` (for generation script)

## Output Features

Both scripts provide:
- Colored output (success/warning/error)
- Detailed validation reports
- Usage examples
- Performance recommendations
- Best practice suggestions
- TypeScript compatibility checks

## Generated File Structure

```
src/store/
├── userStore.js          - Main store with create(), state, actions
├── userSelectors.js      - Optimized selectors
├── userMiddleware.js     - Middleware (persist, devtools, immer)
├── userStore.test.js     - Comprehensive test suite
├── example.jsx           - Usage example component
└── types.js              - JSDoc type definitions
```

All generated files follow Zustand best practices:
- Minimal boilerplate
- Proper middleware stacking
- Optimized selectors
- Full test coverage
- TypeScript-ready JSDoc
- DevTools integration
