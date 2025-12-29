# Browser DevTools Scripts

Production scripts for DevTools integration and debugging utilities.

## validate-devtools.sh
Validate DevTools implementation in your project.

**Checks:**
- Source maps configuration
- Debug logging setup
- Performance markers usage
- Error handling
- Network monitoring
- DevTools integration

**Output:** `.devtools-validation.json`

## generate-devtools-config.sh
Generate DevTools utilities module.

**Includes:**
- PerformanceMarker - Custom performance.mark/measure helpers
- DebugLogger - Structured logging with log levels
- MemoryMonitor - Memory usage tracking and leak detection
- NetworkInterceptor - Automatic fetch/XHR logging
- ConsoleUtils - Helper functions for debugging

## Key Features

- **Source Maps:** Debug minified code
- **Performance Markers:** Custom timing measurements
- **Memory Monitoring:** Track heap usage
- **Network Logging:** All requests logged to console
- **Error Reporting:** Automatic backend error sending
- **Global API:** Access via `window.__DEVTOOLS__`
