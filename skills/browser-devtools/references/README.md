# Browser DevTools References

Comprehensive documentation for Chrome DevTools debugging and profiling.

## GUIDE.md
**600+ word technical guide** covering:
- Elements/Inspector panel for DOM debugging
- Sources panel with breakpoints and stepping
- Performance tab for profiling
- Network tab for request analysis
- Console methods and interactive debugging
- Application/Storage tab for persistence
- Lighthouse integration
- Custom performance markers

## PATTERNS.md
**600+ word real-world patterns** including:
- Custom performance markers pattern
- Memory leak detection
- Network request interceptor
- Performance timeline visualization
- Console utilities helper
- React DevTools integration

## Key Tools

### Performance Analysis
- **Performance Tab** - Record and analyze page performance
- **Lighthouse** - Automated audits
- **Custom Markers** - Application-specific metrics

### Debugging Tools
- **Sources Panel** - Breakpoints, stepping, watches
- **Console** - Logging and interactive testing
- **Elements** - DOM inspection and modification

### Network Monitoring
- **Network Tab** - Request/response inspection
- **Request Interceptor** - Automatic logging
- **Throttling** - Simulate slow networks

### Memory Debugging
- **Memory Tab** - Heap snapshots
- **Memory Monitor** - Track allocation
- **Leak Detection** - Find memory leaks

## Essential Shortcuts

| Action | Windows/Linux | Mac |
|--------|---------------|-----|
| Open DevTools | F12 | Cmd+Opt+I |
| Inspect Element | Ctrl+Shift+C | Cmd+Opt+C |
| Toggle Console | Ctrl+Shift+J | Cmd+Opt+J |
| Step Over | F10 | F10 |
| Step Into | F11 | F11 |
| Step Out | Shift+F11 | Shift+F11 |
| Resume | F8 | F8 |

## Best Practices

1. **Always Use Source Maps** - Debug original code
2. **Custom Markers** - Measure application-specific operations
3. **Network Throttling** - Test realistic conditions
4. **Memory Monitoring** - Detect leaks early
5. **Console Organization** - Use groups for clarity
6. **Breakpoint Strategy** - Focus on suspect areas
