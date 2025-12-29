# Context API Patterns - References

Comprehensive documentation for mastering Context API patterns in React.

## Core Concepts

### GUIDE.md
Complete technical guide covering:
- useContext hook fundamentals
- Context.createContext API
- Provider/Consumer patterns
- useReducer integration for state management
- Custom hooks with Context
- Performance optimization strategies
- Advanced composition patterns
- Integration with React features
- Best practices and anti-patterns

Topics include:
- Context creation and provider setup
- Consuming context with useContext
- Provider pattern implementation
- Using useReducer for complex state
- Creating custom hooks for encapsulation
- Preventing unnecessary re-renders
- useMemo and useCallback optimization
- Lazy context initialization
- Multiple context composition
- Error boundaries with Context

### PATTERNS.md
Real-world patterns and architectural approaches:
- Provider pattern (basic and advanced)
- Custom hook abstraction layer
- useContext + useReducer combination
- Context composition strategies
- Splitting contexts to optimize performance
- State management patterns
- Async operations with Context
- Middleware-like patterns
- Testing Context providers
- Combining multiple contexts
- Migration patterns from prop drilling
- Common pitfalls and solutions

## References

- [React Context API Documentation](https://react.dev/reference/react/useContext)
- [useReducer Hook](https://react.dev/reference/react/useReducer)
- [useCallback Optimization](https://react.dev/reference/react/useCallback)
- [useMemo Performance](https://react.dev/reference/react/useMemo)
- [Context Performance Considerations](https://react.dev/reference/react/useCallback#optimizing-a-context-provider)

## Quick Start

1. Read **GUIDE.md** for foundational concepts
2. Review **PATTERNS.md** for real-world approaches
3. Use scripts to validate and generate Context implementations
4. Practice with the example components

## Key Topics Covered

- **Fundamentals**: createContext, useContext, Provider patterns
- **State Management**: useReducer, action creators, reducer functions
- **Custom Hooks**: Encapsulation, reusability, type safety
- **Performance**: useMemo, useCallback, optimization strategies
- **Composition**: Multiple contexts, context splitting, combining contexts
- **Advanced Patterns**: Middleware-like behavior, async operations
- **Testing**: Testing providers, mocking contexts
- **Integration**: With React features, DevTools, testing libraries

## When to Use Context API

### Good Use Cases
- Theme switching (dark/light mode)
- Language/internationalization
- User authentication state
- Global notifications/toasts
- Modal/dialog visibility
- Feature flags
- Application configuration

### Consider Redux/Zustand For
- Highly complex state
- Frequent updates
- DevTools debugging needed
- Time-travel debugging required
- Large team collaboration
