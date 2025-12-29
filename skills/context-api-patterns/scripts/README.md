# Context API Patterns - Scripts

Validation and generation scripts for Context API patterns.

## Scripts

### validate-context.sh
Validates Context API implementation and patterns.

**Usage:**
```bash
./scripts/validate-context.sh [context-directory]
```

**Checks:**
- React.createContext() usage
- useContext hook implementation
- Provider component setup
- useReducer integration (if used)
- Proper destructuring in components
- Custom hook patterns
- Performance considerations (useMemo, useCallback)
- Multiple context composition
- Context value stability

**Example:**
```bash
./scripts/validate-context.sh src/context
```

### generate-context-hook.sh
Generates complete Context with Provider, custom hook, and useReducer pattern.

**Usage:**
```bash
./scripts/generate-context-hook.sh [output-directory] [context-name]
```

**Generates:**
- `{name}Context.js` - Context creation
- `{name}Provider.jsx` - Provider component with useReducer
- `use{Name}.js` - Custom hook for consuming context
- `reducer.js` - Reducer function for complex state
- `actions.js` - Action creators
- `example.jsx` - Example component showing usage

**Example:**
```bash
./scripts/generate-context-hook.sh src/context/auth Auth
# Creates src/context/auth/ with all necessary files
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

## Generated Files Structure

```
src/context/{contextName}/
├── {contextName}Context.js     - Context creation with default value
├── {contextName}Provider.jsx   - Provider component with reducer
├── use{Name}.js                - Custom hook for context consumption
├── reducer.js                  - Reducer function
├── actions.js                  - Action creators
└── example.jsx                 - Example usage component
```

All generated files follow React best practices and include:
- TypeScript-ready patterns (JSDoc types)
- Performance optimization (useMemo, useCallback)
- Error boundaries
- Proper null checks
- Documentation comments
