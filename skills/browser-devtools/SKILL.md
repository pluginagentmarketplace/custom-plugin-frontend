---
name: browser-devtools
description: Master Chrome DevTools for debugging, performance profiling, network analysis, and memory optimization.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 06-performance-agent
bond_type: SECONDARY_BOND
status: production
category: development-tools
tags:
  - devtools
  - debugging
  - performance
  - profiling
  - chrome
complexity: intermediate
estimated_time: 60-90min
prerequisites:
  - Basic understanding of web technologies
  - Knowledge of HTML, CSS, JavaScript
  - Familiarity with browser concepts
related_skills:
  - devtools-profiling
  - core-web-vitals
  - web-vitals-lighthouse
production_config:
  performance_recording: true
  memory_profiling: true
  network_throttling: enabled
  coverage_analysis: true
---

# Browser DevTools

Master Chrome DevTools for professional web development and debugging.

## Input Schema

```yaml
context:
  url: string                   # URL to analyze
  analysis_type: string         # performance, memory, network, debugging
  environment: string           # production, staging, development
  device_profile: string        # desktop, mobile, tablet

config:
  performance:
    recording_duration: number  # Seconds to record
    throttling:
      cpu: number               # CPU slowdown multiplier
      network: string           # 4G, 3G, offline, custom
    enable_screenshots: boolean

  memory:
    snapshot_type: string       # heap, allocation
    comparison_mode: boolean
    detect_leaks: boolean

  network:
    disable_cache: boolean
    throttling_profile: string
    request_blocking: array     # Patterns to block
    preserve_log: boolean

  coverage:
    analyze_css: boolean
    analyze_js: boolean
    highlight_unused: boolean

options:
  remote_debugging: boolean     # Debug remote devices
  save_profile: boolean         # Save profile to disk
  generate_report: boolean      # Generate analysis report
  compare_to_baseline: boolean  # Compare against baseline
```

## Output Schema

```yaml
analysis_results:
  performance:
    metrics:
      fcp: number
      lcp: number
      cls: number
      tbt: number
      tti: number
    long_tasks:
      - duration: number
        start_time: number
        attribution: string
    frames:
      total: number
      dropped: number
      fps: number
    summary:
      scripting_time: number
      rendering_time: number
      painting_time: number

  memory:
    heap_size:
      total: number
      used: number
      limit: number
    leaks:
      - type: string
        count: number
        retained_size: number
        location: string
    allocations:
      - constructor: string
        count: number
        shallow_size: number
        retained_size: number

  network:
    requests:
      total: number
      failed: number
      cached: number
    transfer_size:
      total: number
      by_type: object
    timing:
      total_time: number
      dns: number
      tcp: number
      request: number
      response: number
    waterfall: array

  coverage:
    css:
      total_bytes: number
      used_bytes: number
      unused_bytes: number
      unused_percentage: number
    javascript:
      total_bytes: number
      used_bytes: number
      unused_bytes: number
      unused_percentage: number

recommendations:
  - category: string            # performance, memory, network
    priority: string            # critical, high, medium, low
    issue: string
    solution: string
    estimated_impact: string

report:
  summary: string
  critical_issues: array
  next_steps: array
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| DT-001 | Chrome DevTools not available | DevTools not open or browser not Chrome | Open DevTools with F12 or Cmd+Option+I |
| DT-002 | Recording failed | Error starting performance recording | Close other tabs and try again |
| DT-003 | Heap snapshot failed | Insufficient memory for snapshot | Close unnecessary tabs and processes |
| DT-004 | Remote debugging error | Unable to connect to remote device | Check USB connection and enable USB debugging |
| DT-005 | Network throttling error | Invalid throttling profile | Use predefined profiles or check custom settings |
| DT-006 | Coverage analysis failed | Unable to collect coverage data | Refresh page and restart coverage recording |
| DT-007 | Timeline too large | Recording too long or complex | Reduce recording duration or simplify page |
| DT-008 | Source map error | Unable to load source maps | Verify source map files are accessible |
| DT-009 | Breakpoint not hit | Breakpoint in unreachable code | Verify code execution path and breakpoint location |
| DT-010 | Performance budget exceeded | Metrics exceed defined thresholds | Review failing metrics and optimize |

## MANDATORY

### Chrome DevTools Elements/Inspector
- **DOM inspection**: Navigate and inspect HTML structure
  - View and edit element attributes
  - Modify CSS styles in real-time
  - Test responsive layouts
  - Inspect accessibility tree

- **CSS debugging**: Identify and fix style issues
  - View computed styles
  - Track style inheritance
  - Debug CSS grid and flexbox
  - Identify unused CSS

- **Layout analysis**: Understand box model and positioning
  - Visualize margins, padding, borders
  - Debug layout issues
  - Inspect animations

### Sources Panel and Debugging
- **Breakpoint debugging**: Pause and inspect code execution
  ```javascript
  // Set breakpoints in DevTools or use debugger statement
  function complexCalculation(data) {
    debugger; // Execution will pause here
    return data.map(item => item * 2);
  }
  ```

- **Breakpoint types**:
  - Line breakpoints
  - Conditional breakpoints
  - DOM breakpoints (subtree modifications, attribute changes)
  - Event listener breakpoints
  - XHR/Fetch breakpoints

- **Step through code**: Step over, step into, step out
- **Call stack inspection**: Trace execution flow
- **Scope variables**: Inspect local and global variables

### Performance Profiling and Analysis
- **Record performance**: Capture page activity
  - Start recording before action
  - Perform user interaction
  - Stop recording and analyze

- **Analyze flame charts**: Identify bottlenecks
  - Long tasks (>50ms)
  - JavaScript execution time
  - Rendering and painting time
  - Layout thrashing

- **Web Vitals**: Track core metrics
  - LCP, FID/INP, CLS
  - FCP, TTFB
  - Custom performance marks

### Network Tab Analysis
- **Request inspection**: Analyze HTTP requests
  - View request/response headers
  - Inspect payload and preview
  - Check timing breakdown
  - Identify slow requests

- **Waterfall view**: Understand loading sequence
  - DNS lookup time
  - Connection time
  - Request/response time
  - Blocking time

- **Network throttling**: Test different conditions
  - Slow 3G, Fast 3G, 4G
  - Custom profiles
  - Offline mode

### Console Debugging Techniques
- **Console methods**: Effective logging
  ```javascript
  console.log('Simple log');
  console.warn('Warning message');
  console.error('Error message');
  console.table([{a:1, b:2}, {a:3, b:4}]);
  console.group('Group');
  console.log('Nested log');
  console.groupEnd();
  console.time('Timer');
  // code to measure
  console.timeEnd('Timer');
  ```

- **Advanced techniques**:
  - Object inspection
  - Live expressions
  - Command line API ($0, $_, $$())
  - Preserve log across navigation

### Application Tab
- **Storage inspection**: View and modify storage
  - Local Storage
  - Session Storage
  - IndexedDB
  - Cookies
  - Cache Storage

- **Service Workers**: Debug PWA functionality
- **Manifest**: Inspect web app manifest
- **Background services**: Monitor background sync, notifications

## OPTIONAL

### Remote Debugging
- **Mobile device debugging**: Debug on actual devices
  - Android via USB debugging
  - iOS via Safari Web Inspector
  - Chrome DevTools protocol

- **Remote targets**: Debug other Chrome instances
  - NodeJS applications
  - Electron apps
  - WebView in native apps

### Performance Recording and Analysis
- **Advanced flame chart reading**
- **Memory timeline correlation**
- **Frame rendering analysis**
- **GPU activity monitoring**

### Memory Profiling and Leak Detection
- **Heap snapshots**: Capture memory state
  - Take multiple snapshots
  - Compare snapshots
  - Identify retained objects
  - Find memory leaks

- **Allocation timeline**: Track memory allocations over time
- **Allocation sampling**: Lightweight profiling

### Coverage Analysis
- **Code coverage**: Identify unused code
  - CSS coverage
  - JavaScript coverage
  - Per-file breakdown
  - Unused code removal

### Lighthouse Integration
- **Automated audits**: Run Lighthouse from DevTools
- **Performance budgets**
- **Best practices checks**
- **Accessibility audits**

### Custom Performance Markers
- **Performance API**: Add custom timing marks
  ```javascript
  performance.mark('start-task');
  // Task code
  performance.mark('end-task');
  performance.measure('task-duration', 'start-task', 'end-task');

  const measures = performance.getEntriesByName('task-duration');
  console.log('Task took:', measures[0].duration, 'ms');
  ```

## ADVANCED

### Remote Debugging on Devices
- **Chrome DevTools Protocol**: Programmatic debugging
- **Automated device testing**
- **Cross-platform debugging**

### Performance Benchmarking
- **Automated performance testing**
- **Comparison across builds**
- **CI/CD integration**

### Memory Leak Detection Patterns
- **Detached DOM nodes**: Identify nodes not in DOM but in memory
- **Event listener leaks**: Unremoved event listeners
- **Closure leaks**: Unintended variable retention
- **Timer leaks**: Uncleaned setInterval/setTimeout

### Performance Regression Detection
- **Baseline comparisons**
- **Automated alerts**
- **Historical tracking**

### Lighthouse CI Integration
- **Continuous performance testing**
- **Automated budget enforcement**
- **PR performance checks**

### Custom DevTools Extensions
- **Chrome extension development**
- **Custom panels and tools**
- **Workflow automation**

## Test Templates

### Performance Testing
```javascript
// performance-test.js
describe('Performance Tests', () => {
  test('should load page within budget', async () => {
    const metrics = await page.metrics();

    expect(metrics.TaskDuration).toBeLessThan(2000);
    expect(metrics.LayoutDuration).toBeLessThan(500);
    expect(metrics.ScriptDuration).toBeLessThan(1000);
  });

  test('should have no long tasks', async () => {
    const longTasks = await page.evaluate(() => {
      return window.performance.getEntriesByType('longtask');
    });

    expect(longTasks.length).toBe(0);
  });
});
```

### Memory Leak Tests
```javascript
// memory-leak-test.js
describe('Memory Leak Detection', () => {
  test('should not leak memory on navigation', async () => {
    const initialMemory = await page.metrics().then(m => m.JSHeapUsedSize);

    // Perform actions that might leak
    for (let i = 0; i < 10; i++) {
      await page.goto(url);
      await page.goBack();
    }

    // Force garbage collection (requires --expose-gc flag)
    await page.evaluate(() => {
      if (window.gc) window.gc();
    });

    const finalMemory = await page.metrics().then(m => m.JSHeapUsedSize);
    const increase = finalMemory - initialMemory;

    // Allow some increase but not excessive
    expect(increase).toBeLessThan(initialMemory * 0.5);
  });
});
```

### Network Performance Tests
```javascript
// network-test.js
describe('Network Performance', () => {
  test('should not exceed resource count budget', async () => {
    const requests = await page.evaluate(() => {
      return performance.getEntriesByType('resource').length;
    });

    expect(requests).toBeLessThan(50);
  });

  test('should use compression', async () => {
    const responses = await page.evaluate(() => {
      return performance.getEntriesByType('resource')
        .map(r => ({
          name: r.name,
          transferSize: r.transferSize,
          decodedBodySize: r.decodedBodySize
        }));
    });

    responses.forEach(r => {
      if (r.decodedBodySize > 1024) {
        expect(r.transferSize).toBeLessThan(r.decodedBodySize);
      }
    });
  });
});
```

## Best Practices

### 1. Performance Profiling Workflow

**Recording performance:**
1. Open DevTools Performance panel
2. Click record button (or Cmd+E)
3. Perform the action to analyze
4. Stop recording
5. Analyze the flame chart

**Identifying bottlenecks:**
```javascript
// Add custom marks for better analysis
performance.mark('componentRender-start');
ReactDOM.render(<App />, container);
performance.mark('componentRender-end');
performance.measure('componentRender',
  'componentRender-start',
  'componentRender-end'
);
```

**What to look for:**
- Long tasks (red triangles in timeline)
- Layout thrashing (repeated layout/paint cycles)
- Heavy JavaScript execution
- Excessive rendering time

### 2. Memory Profiling Workflow

**Heap snapshot comparison:**
1. Take baseline snapshot
2. Perform action
3. Force garbage collection
4. Take another snapshot
5. Compare snapshots

**Finding memory leaks:**
```javascript
// Example of a memory leak
const listeners = [];

function attachListener() {
  const element = document.getElementById('button');
  const handler = () => console.log('clicked');
  element.addEventListener('click', handler);
  listeners.push(handler); // Leak: never cleaned up
}

// Fixed version
function attachListener() {
  const element = document.getElementById('button');
  const handler = () => console.log('clicked');
  element.addEventListener('click', handler);

  // Cleanup
  return () => element.removeEventListener('click', handler);
}
```

### 3. Network Optimization

**Analyzing waterfalls:**
- Identify blocking resources
- Check for request chaining
- Verify parallel downloads
- Look for unnecessary requests

**Using request blocking:**
```javascript
// Block third-party scripts to test impact
// DevTools Network > Right-click > Block request URL
// Or use pattern: *analytics.google.com*
```

### 4. Console Debugging Techniques

**Effective logging:**
```javascript
// Group related logs
console.group('User Action');
console.log('User clicked:', event.target);
console.log('Current state:', state);
console.groupEnd();

// Table format for arrays
console.table(users.map(u => ({ name: u.name, age: u.age })));

// Conditional logging
console.assert(value > 0, 'Value must be positive:', value);

// Count occurrences
for (let i = 0; i < items.length; i++) {
  console.count('iteration');
}
```

### 5. Debugging Best Practices

**Using breakpoints effectively:**
- Set conditional breakpoints for specific scenarios
- Use logpoints instead of console.log
- Enable async stack traces
- Use blackboxing to skip library code

**Command Line API:**
```javascript
// DevTools Console shortcuts
$_                    // Last evaluated expression
$0                    // Currently selected element
$('selector')         // document.querySelector
$$('selector')        // document.querySelectorAll
$x('xpath')          // XPath query
copy(object)         // Copy object to clipboard
monitor(function)    // Log function calls
monitorEvents(element, 'click') // Log events
```

## Production Configuration

### DevTools Protocol for Automation
```javascript
// puppeteer-devtools.js
const puppeteer = require('puppeteer');

async function capturePerformance(url) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  // Enable Performance domain
  const client = await page.target().createCDPSession();
  await client.send('Performance.enable');

  // Navigate and collect metrics
  await page.goto(url, { waitUntil: 'networkidle2' });

  const metrics = await client.send('Performance.getMetrics');
  const performanceMetrics = {};

  metrics.metrics.forEach(metric => {
    performanceMetrics[metric.name] = metric.value;
  });

  await browser.close();
  return performanceMetrics;
}
```

### Automated Memory Leak Detection
```javascript
// memory-leak-detector.js
async function detectMemoryLeaks(page, actions) {
  // Take baseline
  await page.evaluate(() => {
    if (window.gc) window.gc();
  });

  const baseline = await page.metrics();

  // Perform actions multiple times
  for (let i = 0; i < 10; i++) {
    await actions(page);
  }

  // Force GC and measure
  await page.evaluate(() => {
    if (window.gc) window.gc();
  });

  const final = await page.metrics();

  const growth = {
    jsHeap: final.JSHeapUsedSize - baseline.JSHeapUsedSize,
    documents: final.Documents - baseline.Documents,
    nodes: final.Nodes - baseline.Nodes,
    listeners: final.JSEventListeners - baseline.JSEventListeners
  };

  return growth;
}
```

### Network Monitoring
```javascript
// network-monitor.js
async function monitorNetwork(page) {
  const requests = [];

  page.on('request', request => {
    requests.push({
      url: request.url(),
      method: request.method(),
      resourceType: request.resourceType()
    });
  });

  page.on('response', response => {
    const request = requests.find(r => r.url === response.url());
    if (request) {
      request.status = response.status();
      request.size = response.headers()['content-length'];
      request.timing = response.timing();
    }
  });

  return requests;
}
```

## Scripts

See `scripts/README.md` for available tools:
- `profile-performance.js` - Automated performance profiling
- `detect-memory-leaks.js` - Memory leak detection
- `analyze-network.js` - Network request analysis
- `coverage-report.js` - Code coverage reporting

## References

- See `references/GUIDE.md` for comprehensive DevTools features
- See `references/PATTERNS.md` for debugging patterns
- See `references/EXAMPLES.md` for real-world scenarios

## Resources

### Official Documentation
- [Chrome DevTools Documentation](https://developer.chrome.com/docs/devtools/) - Complete guide
- [Debugging JavaScript](https://developer.chrome.com/docs/devtools/javascript/) - JavaScript debugging
- [Performance Analysis](https://developer.chrome.com/docs/devtools/performance/) - Performance profiling

### Learning Resources
- [DevTools Tips](https://devtoolstips.org/) - Daily DevTools tips
- [Mastering Chrome DevTools](https://frontendmasters.com/courses/chrome-dev-tools-v2/) - Video course
- [DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) - Protocol documentation

### Tools
- [Puppeteer](https://pptr.dev/) - Headless Chrome automation
- [Playwright](https://playwright.dev/) - Cross-browser automation
- [Chrome DevTools Protocol](https://github.com/ChromeDevTools/awesome-chrome-devtools) - Awesome list

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
