# Browser DevTools Technical Guide

Comprehensive guide to Chrome DevTools features for debugging, profiling, and performance optimization.

## Table of Contents
1. [Elements/Inspector Panel](#elementsinspector-panel)
2. [Sources Panel and Debugging](#sources-panel-and-debugging)
3. [Performance Tab](#performance-tab)
4. [Network Tab](#network-tab)
5. [Console and Logging](#console-and-logging)
6. [Application/Storage Tab](#applicationstorage-tab)
7. [Lighthouse Integration](#lighthouse-integration)
8. [Custom Performance Markers](#custom-performance-markers)

---

## Elements/Inspector Panel

The Elements panel allows you to inspect and modify the DOM in real-time.

### Inspecting Elements
```javascript
// Right-click → Inspect Element
// Or use Ctrl+Shift+C (Windows/Linux) or Cmd+Opt+C (Mac)
```

### Editing DOM
- Double-click text to edit
- Right-click element for context menu
- Add/remove classes
- Edit attributes

### CSS Debugging
```css
/* View computed styles, box model, event listeners */
/* Useful for debugging layout issues and CLS */
```

### Best Practices
- Use element picker to find components
- Check for accessibility tree
- Verify semantic HTML
- Inspect for layout shift sources

---

## Sources Panel and Debugging

Debug JavaScript with breakpoints, watches, and step-through execution.

### Setting Breakpoints
```javascript
// Click line number to set breakpoint
// Or add: debugger; statement in code
debugger; // Pauses execution here

// Conditional breakpoints: Right-click line → Add conditional breakpoint
if (userId === undefined) {
  debugger; // Pauses only when condition true
}
```

### Debugger Controls
- Step over (F10) - Execute next line
- Step into (F11) - Enter function
- Step out (Shift+F11) - Exit function
- Resume (F8) - Continue execution

### Watch Expressions
```javascript
// Add watches for variables
// Example watches:
// - userData.id
// - cart.length
// - performance.now()
```

### Source Maps
```json
{
  "devtool": "source-map",
  "output": {
    "sourceMapFilename": "[name].js.map"
  }
}
```

Source maps allow debugging TypeScript/minified code as if it were original source.

---

## Performance Tab

Profile application performance to find bottlenecks.

### Recording Performance
```javascript
// Manual performance API
performance.mark('operation-start');
// ... do work ...
performance.mark('operation-end');
performance.measure('operation', 'operation-start', 'operation-end');

// View in DevTools → Performance tab → User Timing section
```

### Flame Chart Analysis
- Red bars = Problematic performance
- Blue = JavaScript execution
- Purple = Rendering
- Yellow = Scripting

### Key Metrics
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Cumulative Layout Shift (CLS)
- Total Blocking Time (TBT)

### Performance Recording Process
1. Open Performance tab
2. Click Record
3. Interact with page
4. Click Stop
5. Analyze results

---

## Network Tab

Monitor and analyze network requests.

### Request Details
```
Headers → Request/Response headers
Preview → Formatted response
Response → Raw response body
Timing → Detailed timing breakdown
```

### Network Throttling
```javascript
// Simulate slow networks
// DevTools → Network → Throttling dropdown
// - Fast 3G
// - Slow 3G
// - Offline

// Also in JavaScript:
const controller = new AbortController();
fetch('/api/data', { signal: controller.signal });
```

### Request Waterfall
- Queueing - Waiting for connection
- Stalled - Waiting for proxy/network
- DNS Lookup - Domain resolution
- Initial Connection - TCP handshake
- SSL - TLS negotiation
- Request Sent - Sending to server
- Waiting (TTFB) - Server processing
- Content Download - Receiving response

### Filtering and Search
- Type in filter box to search requests
- Filter by resource type (JS, XHR, Img)
- Right-click request → Copy as cURL for testing

---

## Console and Logging

Powerful console for debugging and interactive testing.

### Console Methods
```javascript
console.log('Info:', value);        // General logging
console.warn('Warning:', problem);  // Warnings
console.error('Error:', err);       // Errors
console.table(data);                 // Tabular display
console.group('Group');              // Grouping
console.time('label');               // Timing
console.assert(test, 'message');     // Assertions
```

### Advanced Logging
```javascript
// Styled console output
console.log('%cStyled text', 'color: red; font-size: 20px;');

// Object inspection
console.log('User:', user);
console.dir(element); // Show properties

// Conditional logging
if (process.env.DEBUG) {
  console.log('Debug info');
}
```

### Interactive Console
```javascript
// Execute JavaScript in console
// Access variables from current scope
// Call functions
// Modify DOM

// Example:
document.querySelectorAll('.button').forEach(btn => {
  btn.style.backgroundColor = 'red';
});
```

---

## Application/Storage Tab

Inspect and manage browser storage.

### Storage Types
- **Local Storage** - Persistent key-value store
- **Session Storage** - Session-only key-value store
- **Cookies** - HTTP cookies with domain/path
- **IndexedDB** - Client-side database
- **Web SQL** - Deprecated but still accessible
- **Cache Storage** - Service Worker cache

### Debugging Storage
```javascript
// Local Storage
localStorage.setItem('key', 'value');
console.log(localStorage.getItem('key'));
localStorage.removeItem('key');

// Check in DevTools → Application → Local Storage
```

### Service Worker
- View registered workers
- Check caches
- Update/unregister workers
- View fetch events

---

## Lighthouse Integration

Automated performance auditing.

### Running Lighthouse
1. DevTools → Lighthouse tab
2. Select device (Mobile/Desktop)
3. Choose categories (Performance, Accessibility, etc.)
4. Click "Generate report"

### Key Metrics
- Performance Score (0-100)
- Opportunities - What to optimize
- Diagnostics - Helpful info
- Passed Audits - What's working well

### Performance Budgets
```json
{
  "performance": [
    {
      "name": "LCP",
      "alerts": [
        { "metric": "largest-contentful-paint", "measurement": "<=2.5" }
      ]
    }
  ]
}
```

---

## Custom Performance Markers

Create custom measurements for application-specific metrics.

### Performance API
```javascript
// Mark the start of an operation
performance.mark('database-query-start');

// Run the operation
const results = await queryDatabase();

// Mark the end
performance.mark('database-query-end');

// Measure the duration
performance.measure(
  'database-query',
  'database-query-start',
  'database-query-end'
);

// Retrieve measurement
const measures = performance.getEntriesByName('database-query');
console.log('Duration:', measures[0].duration);
```

### Viewing Markers in DevTools
```
Performance tab → Recording → User Timing section
Shows all custom marks and measures
```

### Real-World Example
```javascript
// Track React component render time
class MyComponent extends React.Component {
  componentDidMount() {
    performance.mark('component-mount-start');
  }

  componentDidMount() {
    performance.mark('component-mount-end');
    performance.measure(
      'component-mount',
      'component-mount-start',
      'component-mount-end'
    );
  }

  render() {
    return <div>Content</div>;
  }
}
```

---

## Best Practices

### Debugging Strategy
1. **Identify Problem** - Use console, DevTools, error logs
2. **Set Breakpoints** - Sources panel with strategic breakpoints
3. **Step Through** - Execute code step-by-step
4. **Watch Variables** - Monitor changing values
5. **Inspect State** - Check component/application state
6. **Test Fix** - Verify solution works

### Performance Optimization
1. **Measure** - Use Performance tab and custom markers
2. **Identify Bottlenecks** - Find slow functions/requests
3. **Optimize** - Address root causes
4. **Verify** - Re-run Performance recording

### Network Optimization
1. **Monitor** - Check Network tab during usage
2. **Analyze Waterfall** - Identify slow resources
3. **Optimize** - Compress, cache, CDN
4. **Verify** - Compare before/after

This comprehensive guide covers all major DevTools capabilities for production debugging and optimization.
