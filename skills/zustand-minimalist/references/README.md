# Zustand Minimalist - References

Comprehensive documentation for mastering Zustand state management.

## Core Concepts

### GUIDE.md
Complete technical guide covering:
- Zustand store creation with create()
- State definition and access
- Actions and state mutations
- Selectors for optimized access
- Middleware system (persist, devtools, immer)
- Subscriptions and listeners
- Integration with React components
- Performance optimization
- Async operations and thunks
- Testing stores

Topics include:
- create() API basics
- Store structure and organization
- Action definitions
- State updates (immer integration)
- Selector patterns for re-render optimization
- useShallow for shallow equality
- Middleware composition
- Persist middleware for storage
- DevTools integration
- Custom middleware creation
- Async patterns
- Error handling

### PATTERNS.md
Real-world patterns and architectural approaches:
- Store composition and modularization
- Middleware stacking patterns
- Persist patterns with hydration
- DevTools integration and debugging
- Async action patterns (request/success/failure)
- Selector patterns for performance
- Testing stores with Jest
- Combining multiple stores
- Immer integration for safe mutations
- Error handling strategies
- Type-safe stores with TypeScript
- Large-scale store architecture
- Common pitfalls and solutions

## References

- [Zustand Official Repository](https://github.com/pmndrs/zustand)
- [Zustand API Reference](https://github.com/pmndrs/zustand#api)
- [Zustand Middleware](https://github.com/pmndrs/zustand/tree/main/src/middleware)
- [Immer Integration](https://github.com/pmndrs/zustand/blob/main/docs/integrations/immer-middleware.md)
- [React Hooks Optimization](https://github.com/pmndrs/zustand#using-shallow-equality)

## Quick Start

1. Read **GUIDE.md** for foundational concepts
2. Review **PATTERNS.md** for real-world approaches
3. Use scripts to validate and generate Zustand stores
4. Practice with the example components

## Key Topics Covered

- **Fundamentals**: create(), state, actions, selectors
- **Middleware**: persist, devtools, immer, custom
- **Optimization**: useShallow, selective subscriptions
- **Integration**: React components, hooks
- **Async**: Promise patterns, thunks
- **Testing**: Jest, mocking, assertions
- **Architecture**: Composition, splitting, normalization
- **Performance**: Selectors, memoization, batching

## When to Use Zustand

### Good Use Cases
- Global state management
- Complex cross-component state
- Frequent state updates
- DevTools debugging needed
- Type-safe state (with TypeScript)
- Lightweight alternative to Redux
- Rapid prototyping with minimal setup

### Key Advantages
- Minimal boilerplate
- No providers needed (optional)
- Direct hook-based API
- Excellent performance
- Great DevTools integration
- TypeScript support
- Middleware system
- Small bundle size (~2KB)
