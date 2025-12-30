---
name: devtools-profiling
description: Master browser DevTools for performance profiling, memory debugging, and network analysis.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 06-performance-agent
bond_type: SECONDARY_BOND
status: production
category: development-tools
tags:
  - devtools
  - profiling
  - performance
  - memory
  - network-analysis
complexity: advanced
estimated_time: 60-90min
prerequisites:
  - Strong understanding of JavaScript
  - Familiarity with browser DevTools
  - Knowledge of performance concepts
related_skills:
  - browser-devtools
  - core-web-vitals
  - web-vitals-lighthouse
production_config:
  profiling_enabled: true
  flame_chart_analysis: true
  memory_tracking: true
  network_analysis: true
  cpu_throttling: 4x
---

# Browser DevTools Profiling

Advanced debugging and performance analysis with Chrome DevTools.

## Input Schema

```yaml
context:
  url: string                   # URL to profile
  profiling_type: string        # performance, memory, network, rendering
  scenario: string              # page-load, user-interaction, idle
  duration: number              # Profiling duration in seconds

config:
  performance:
    cpu_throttling: number      # CPU slowdown multiplier (1, 4, 6)
    network_throttling: string  # Fast 3G, Slow 3G, Offline, None
    enable_screenshots: boolean
    enable_paint_profiling: boolean
    record_layers: boolean

  memory:
    snapshot_interval: number   # Seconds between snapshots
    allocation_sampling: boolean
    track_allocations: boolean
    detect_detached_nodes: boolean

  network:
    preserve_log: boolean
    disable_cache: boolean
    block_patterns: array       # URL patterns to block
    capture_screenshots: boolean
    analyze_waterfall: boolean

  rendering:
    show_paint_rectangles: boolean
    show_fps_meter: boolean
    show_layout_shifts: boolean
    highlight_ad_frames: boolean

options:
  save_profile: boolean
  compare_to_baseline: boolean
  generate_report: boolean
  export_format: string         # json, csv, html
```

## Output Schema

```yaml
profiling_results:
  performance:
    summary:
      total_time: number
      scripting_time: number
      rendering_time: number
      painting_time: number
      idle_time: number

    metrics:
      fcp: number
      lcp: number
      cls: number
      tti: number
      tbt: number
      si: number

    long_tasks:
      - duration: number
        start_time: number
        function_name: string
        url: string
        line: number

    flame_chart:
      total_events: number
      max_depth: number
      hottest_functions: array

    frames:
      total_frames: number
      dropped_frames: number
      average_fps: number
      frame_budget_violations: number

  memory:
    heap_snapshot:
      total_size: number
      used_size: number
      objects_count: number

    leaks:
      - type: string
        count: number
        shallow_size: number
        retained_size: number
        retainer_path: array

    detached_nodes:
      - node_name: string
        count: number
        size: number
        detached_reason: string

    allocations:
      - constructor: string
        allocation_count: number
        total_size: number
        timeline: array

  network:
    summary:
      total_requests: number
      total_size: number
      total_time: number
      failed_requests: number
      cached_requests: number

    by_type:
      document: object
      stylesheet: object
      script: object
      image: object
      font: object
      xhr: object
      other: object

    waterfall:
      critical_path: array
      blocking_resources: array
      parallel_downloads: number
      connection_reuse: number

    timing_breakdown:
      dns: number
      tcp: number
      ssl: number
      ttfb: number
      download: number

  rendering:
    paint_events:
      - timestamp: number
        duration: number
        area: object
        layer_info: object

    layout_shifts:
      - timestamp: number
        score: number
        elements: array
        had_recent_input: boolean

    compositing:
      layers_count: number
      texture_memory: number
      paint_time: number

recommendations:
  - category: string
    severity: string            # critical, high, medium, low
    issue: string
    impact: string
    solution: string
    code_location: string

report:
  summary: string
  critical_issues: array
  optimization_opportunities: array
  next_steps: array
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| DP-001 | Profiling initialization failed | DevTools not properly initialized | Restart browser and try again |
| DP-002 | Recording timeout | Profile recording exceeded time limit | Reduce recording duration or simplify page |
| DP-003 | Memory snapshot too large | Heap size exceeds available memory | Close other tabs and reduce page complexity |
| DP-004 | Flame chart parsing error | Unable to parse performance data | Try recording again with shorter duration |
| DP-005 | Invalid CPU throttling | Unsupported throttling value | Use 1x, 4x, or 6x slowdown |
| DP-006 | Network capture failed | Unable to capture network activity | Check DevTools permissions and network access |
| DP-007 | Source map unavailable | Cannot load source maps for profiling | Ensure source maps are deployed and accessible |
| DP-008 | Allocation tracking failed | Unable to track memory allocations | Restart DevTools and try again |
| DP-009 | Layer visualization error | Cannot visualize composite layers | Check GPU acceleration settings |
| DP-010 | Export failed | Unable to export profiling data | Check disk space and file permissions |

## MANDATORY

### Performance Panel Basics
- **Recording workflow**: Capture and analyze performance
  1. Open Performance panel (Cmd/Ctrl + Shift + E)
  2. Configure recording options
  3. Start recording
  4. Perform actions to profile
  5. Stop recording
  6. Analyze results

- **Understanding the timeline**: Navigate the flame chart
  - Summary view: High-level breakdown
  - Bottom-up: Function call statistics
  - Call tree: Hierarchical call structure
  - Event log: Chronological events

### Network Panel Analysis
- **Request analysis**: Deep dive into HTTP requests
  ```javascript
  // Monitor specific request types
  performance.getEntriesByType('resource')
    .filter(entry => entry.initiatorType === 'fetch')
    .forEach(entry => {
      console.log(`${entry.name}: ${entry.duration}ms`);
    });
  ```

- **Waterfall interpretation**: Understand request timing
  - Queueing time
  - Stalled time
  - DNS lookup
  - Initial connection
  - SSL negotiation
  - Request sent
  - Waiting (TTFB)
  - Content download

- **Request filtering**: Focus on relevant requests
  - By domain
  - By resource type
  - By size
  - By duration

### Memory Panel Overview
- **Heap snapshots**: Capture memory state
  - Take snapshot
  - Navigate heap
  - Find retaining paths
  - Identify memory leaks

- **Allocation instrumentation**: Track allocations over time
  - Start recording
  - Perform actions
  - Stop and analyze
  - Compare timelines

- **Allocation sampling**: Lightweight memory profiling

### Coverage Tool Usage
- **Code coverage analysis**: Find unused code
  ```javascript
  // Start coverage recording
  // DevTools > More tools > Coverage
  // Or Command Menu (Cmd+Shift+P) > "Show Coverage"
  ```

- **Analyzing results**:
  - Red: Unused code
  - Blue: Used code
  - Per-file breakdown
  - Total bytes unused

### Console Debugging
- **Advanced console techniques**:
  ```javascript
  // Monitor function calls
  monitor(functionName);

  // Track events
  monitorEvents(document.body, 'click');

  // Profile function performance
  console.profile('MyProfile');
  expensiveOperation();
  console.profileEnd('MyProfile');

  // Memory profiling
  console.memory; // Shows heap size info
  ```

### Elements Inspection
- **Layout debugging**: Identify layout issues
  - Box model visualization
  - Computed styles
  - Event listeners
  - Accessibility tree

- **CSS profiling**: Optimize selectors
  - Unused CSS
  - Style recalculation time
  - Selector complexity

## OPTIONAL

### Flame Charts Interpretation
- **Reading flame charts**: Understand call stacks
  - X-axis: Time
  - Y-axis: Call stack depth
  - Width: Function duration
  - Color: Category (scripting, rendering, painting)

- **Identifying bottlenecks**:
  - Long horizontal bars (long-running functions)
  - Tall stacks (deep call hierarchies)
  - Repetitive patterns (inefficient loops)
  - Red triangles (long tasks >50ms)

### Memory Leak Detection
- **Common leak patterns**:
  ```javascript
  // Pattern 1: Detached DOM nodes
  let nodes = [];
  function createNodes() {
    const container = document.getElementById('container');
    for (let i = 0; i < 100; i++) {
      const node = document.createElement('div');
      container.appendChild(node);
      nodes.push(node); // Leak: keeping reference
    }
  }

  // Pattern 2: Event listeners
  function attachListeners() {
    document.getElementById('btn').addEventListener('click', function() {
      // Handler never removed
    });
  }

  // Pattern 3: Timers
  setInterval(() => {
    // Never cleared
  }, 1000);

  // Pattern 4: Closures
  function createClosure() {
    const largeData = new Array(1000000);
    return function() {
      console.log(largeData.length); // Retains largeData
    };
  }
  ```

- **Detection workflow**:
  1. Take baseline heap snapshot
  2. Perform action that might leak
  3. Force garbage collection
  4. Take comparison snapshot
  5. Analyze retained objects

### Network Throttling
- **Predefined profiles**:
  - Fast 3G: 1.6 Mbps, 150ms RTT
  - Slow 3G: 400 Kbps, 400ms RTT
  - Offline: No connectivity

- **Custom profiles**: Create realistic conditions
  ```javascript
  // Custom throttling via Puppeteer
  await page.emulateNetworkConditions({
    downloadThroughput: 500 * 1024 / 8,
    uploadThroughput: 500 * 1024 / 8,
    latency: 100
  });
  ```

### Custom Performance Marks
- **User Timing API**: Add custom marks
  ```javascript
  // Mark important moments
  performance.mark('search-start');
  performSearch();
  performance.mark('search-end');

  // Measure duration
  performance.measure('search-duration', 'search-start', 'search-end');

  // Get measurements
  const measures = performance.getEntriesByName('search-duration');
  console.log(`Search took ${measures[0].duration}ms`);

  // Clear marks
  performance.clearMarks();
  performance.clearMeasures();
  ```

### Rendering Analysis
- **Paint profiling**: Understand paint operations
  - Enable paint profiling in timeline
  - Record and analyze paint events
  - Identify expensive paints
  - Optimize paint regions

- **Layer analysis**: Optimize compositing
  ```javascript
  // Force layer creation (use sparingly)
  .element {
    will-change: transform;
    /* or */
    transform: translateZ(0);
  }
  ```

### Application Panel
- **Storage inspection**: Debug application state
  - Local Storage
  - Session Storage
  - IndexedDB
  - Web SQL
  - Cookies
  - Cache Storage

## ADVANCED

### Long Task Identification
- **Finding long tasks**: Tasks > 50ms that block the main thread
  ```javascript
  // Use PerformanceObserver to detect long tasks
  const observer = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      console.warn('Long task detected:', {
        duration: entry.duration,
        startTime: entry.startTime,
        attribution: entry.attribution
      });
    }
  });

  observer.observe({ entryTypes: ['longtask'] });
  ```

- **Breaking up long tasks**:
  ```javascript
  // Bad: Long blocking task
  function processLargeArray(items) {
    items.forEach(item => expensiveOperation(item));
  }

  // Good: Chunked with yielding
  async function processLargeArrayChunked(items, chunkSize = 50) {
    for (let i = 0; i < items.length; i += chunkSize) {
      const chunk = items.slice(i, i + chunkSize);
      chunk.forEach(item => expensiveOperation(item));

      // Yield to browser
      await new Promise(resolve => setTimeout(resolve, 0));
    }
  }
  ```

### Memory Heap Analysis
- **Heap snapshot comparison**:
  1. Take baseline snapshot (Snapshot 1)
  2. Perform action
  3. Force GC (DevTools > Performance Monitor > Collect garbage)
  4. Take comparison snapshot (Snapshot 2)
  5. Compare in "Comparison" view

- **Understanding retainers**:
  - Direct retainers: Objects directly holding references
  - Retaining path: Chain of references preventing GC
  - Distance: Steps from GC root

### JavaScript Profiling
- **CPU profiling**: Find hot functions
  ```javascript
  // Programmatic profiling
  console.profile('MyOperation');
  performExpensiveOperation();
  console.profileEnd('MyOperation');

  // Or use DevTools Profiler panel
  ```

- **Sampling profiler**: Low-overhead profiling
  - Bottom-up view: Most expensive functions
  - Top-down view: Call hierarchy
  - Heavy functions: Self time + children

### Layout Thrashing Detection
- **Identifying forced reflows**:
  ```javascript
  // Bad: Forces multiple reflows
  for (let i = 0; i < elements.length; i++) {
    elements[i].style.width = container.offsetWidth + 'px'; // Read
    elements[i].style.height = '100px'; // Write
  }

  // Good: Batch reads and writes
  const width = container.offsetWidth; // Single read
  for (let i = 0; i < elements.length; i++) {
    elements[i].style.width = width + 'px';
    elements[i].style.height = '100px';
  }
  ```

- **FastDOM for layout optimization**:
  ```javascript
  import fastdom from 'fastdom';

  fastdom.measure(() => {
    const width = element.offsetWidth;

    fastdom.mutate(() => {
      element.style.width = width * 2 + 'px';
    });
  });
  ```

### Third-party Script Impact
- **Measuring third-party impact**:
  ```javascript
  // Get third-party resource timing
  const thirdPartyResources = performance.getEntriesByType('resource')
    .filter(entry => !entry.name.includes(window.location.hostname))
    .reduce((acc, entry) => {
      const domain = new URL(entry.name).hostname;
      if (!acc[domain]) acc[domain] = { count: 0, size: 0, time: 0 };
      acc[domain].count++;
      acc[domain].size += entry.transferSize;
      acc[domain].time += entry.duration;
      return acc;
    }, {});

  console.table(thirdPartyResources);
  ```

- **Request blocking**: Test impact by blocking
  - DevTools Network > Right-click > Block request URL
  - Add pattern: `*thirdparty.com*`
  - Re-test performance

### Custom DevTools Extensions
- **Chrome DevTools Protocol**: Programmatic access
  ```javascript
  // Using Puppeteer
  const client = await page.target().createCDPSession();

  // Start performance recording
  await client.send('Performance.enable');
  await client.send('Profiler.enable');
  await client.send('Profiler.start');

  // Perform actions
  await page.click('#button');

  // Stop and get profile
  const { profile } = await client.send('Profiler.stop');
  ```

## Test Templates

### Performance Profiling Tests
```javascript
// performance-profiling.test.js
const puppeteer = require('puppeteer');

describe('Performance Profiling', () => {
  let browser, page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  test('should not have long tasks', async () => {
    await page.goto('https://example.com');

    const longTasks = await page.evaluate(() => {
      return new Promise((resolve) => {
        const tasks = [];
        const observer = new PerformanceObserver((list) => {
          tasks.push(...list.getEntries());
        });
        observer.observe({ entryTypes: ['longtask'] });

        setTimeout(() => {
          observer.disconnect();
          resolve(tasks);
        }, 5000);
      });
    });

    expect(longTasks.length).toBe(0);
  });

  test('should meet performance budget', async () => {
    const metrics = await page.metrics();

    expect(metrics.ScriptDuration).toBeLessThan(2000);
    expect(metrics.LayoutDuration).toBeLessThan(500);
    expect(metrics.RecalcStyleDuration).toBeLessThan(300);
  });
});
```

### Memory Leak Tests
```javascript
// memory-leak.test.js
describe('Memory Leak Detection', () => {
  test('should not leak memory on repeated actions', async () => {
    const client = await page.target().createCDPSession();
    await client.send('HeapProfiler.enable');

    // Baseline
    await client.send('HeapProfiler.collectGarbage');
    const baseline = await client.send('Runtime.getHeapUsage');

    // Perform action multiple times
    for (let i = 0; i < 50; i++) {
      await page.click('#button');
      await page.evaluate(() => {
        // Simulate some work
      });
    }

    // Measure after GC
    await client.send('HeapProfiler.collectGarbage');
    const final = await client.send('Runtime.getHeapUsage');

    const growth = final.usedSize - baseline.usedSize;
    const growthPercentage = (growth / baseline.usedSize) * 100;

    expect(growthPercentage).toBeLessThan(50); // Allow 50% growth
  });
});
```

### Network Performance Tests
```javascript
// network-performance.test.js
describe('Network Performance', () => {
  test('should optimize resource loading', async () => {
    const client = await page.target().createCDPSession();
    await client.send('Network.enable');

    const requests = [];
    client.on('Network.responseReceived', (params) => {
      requests.push(params.response);
    });

    await page.goto('https://example.com');

    // Check compression
    const uncompressed = requests.filter(r =>
      r.headers['content-encoding'] === undefined &&
      parseInt(r.headers['content-length']) > 1024
    );

    expect(uncompressed.length).toBe(0);

    // Check caching
    const uncached = requests.filter(r =>
      r.headers['cache-control'] === undefined
    );

    expect(uncached.length).toBeLessThan(5);
  });
});
```

## Best Practices

### 1. Effective Performance Profiling

**Profiling workflow:**
1. Establish baseline metrics
2. Enable CPU throttling (4x slowdown)
3. Record user journey
4. Identify long tasks
5. Optimize hotspots
6. Re-measure and validate

**Custom marks for better analysis:**
```javascript
// Mark render phases
performance.mark('app-init-start');
initializeApp();
performance.mark('app-init-end');

performance.mark('render-start');
renderUI();
performance.mark('render-end');

performance.mark('hydration-start');
hydrateComponents();
performance.mark('hydration-end');

// Measure each phase
['app-init', 'render', 'hydration'].forEach(phase => {
  performance.measure(phase, `${phase}-start`, `${phase}-end`);
});

// Log results
performance.getEntriesByType('measure').forEach(measure => {
  console.log(`${measure.name}: ${measure.duration.toFixed(2)}ms`);
});
```

### 2. Memory Profiling Workflow

**Finding memory leaks:**
1. Open Memory panel
2. Take heap snapshot (Snapshot 1)
3. Perform action that might leak
4. Interact and navigate
5. Force garbage collection
6. Take another snapshot (Snapshot 2)
7. Compare snapshots
8. Look for unexpected growth in object counts

**Analyzing heap snapshots:**
```javascript
// Use the Comparison view to find:
// - Detached DOM nodes
// - Unexpected object growth
// - Large arrays or strings
// - Event listeners
```

### 3. Network Optimization

**Analyzing the waterfall:**
- Identify blocking resources
- Check for unnecessary sequential loading
- Optimize critical rendering path
- Implement resource hints

**Resource hints:**
```html
<!-- DNS prefetch -->
<link rel="dns-prefetch" href="https://api.example.com">

<!-- Preconnect -->
<link rel="preconnect" href="https://cdn.example.com" crossorigin>

<!-- Prefetch -->
<link rel="prefetch" href="/next-page.html">

<!-- Preload critical resources -->
<link rel="preload" href="/critical.css" as="style">
<link rel="preload" href="/hero.webp" as="image">
```

### 4. Rendering Optimization

**Avoid layout thrashing:**
```javascript
// Bad: Multiple forced reflows
const heights = elements.map(el => el.offsetHeight); // Read
elements.forEach((el, i) => {
  el.style.height = heights[i] * 2 + 'px'; // Write
  el.style.width = el.offsetWidth + 'px'; // Read (forces reflow)
});

// Good: Batch reads then writes
const dimensions = elements.map(el => ({
  height: el.offsetHeight,
  width: el.offsetWidth
}));

elements.forEach((el, i) => {
  el.style.height = dimensions[i].height * 2 + 'px';
  el.style.width = dimensions[i].width + 'px';
});
```

**Use CSS containment:**
```css
.card {
  contain: layout style paint;
}

.infinite-scroll {
  contain: layout;
}
```

### 5. Coverage Analysis

**Remove unused code:**
1. Open Coverage panel
2. Start recording
3. Use the application
4. Stop recording
5. Sort by unused bytes
6. Remove or lazy-load unused code

## Production Configuration

### Automated Profiling Script
```javascript
// auto-profiler.js
const puppeteer = require('puppeteer');
const fs = require('fs').promises;

async function profilePage(url, options = {}) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  // Enable performance tracking
  const client = await page.target().createCDPSession();
  await client.send('Performance.enable');

  // Start tracing
  await page.tracing.start({
    screenshots: true,
    categories: ['devtools.timeline', 'v8.execute', 'disabled-by-default-devtools.timeline']
  });

  // Navigate and measure
  await page.goto(url, { waitUntil: 'networkidle2' });

  // Get metrics
  const metrics = await client.send('Performance.getMetrics');
  const trace = await page.tracing.stop();

  // Save results
  await fs.writeFile('trace.json', trace);
  await fs.writeFile('metrics.json', JSON.stringify(metrics, null, 2));

  await browser.close();

  return { metrics, trace };
}

module.exports = { profilePage };
```

### Memory Leak Detector
```javascript
// memory-leak-detector.js
async function detectLeaks(page, scenario) {
  const client = await page.target().createCDPSession();
  await client.send('HeapProfiler.enable');

  // Baseline
  await client.send('HeapProfiler.collectGarbage');
  let baseline = await client.send('Runtime.getHeapUsage');

  const measurements = [];

  // Run scenario multiple times
  for (let i = 0; i < 10; i++) {
    await scenario(page);

    await client.send('HeapProfiler.collectGarbage');
    const current = await client.send('Runtime.getHeapUsage');

    measurements.push({
      iteration: i,
      usedSize: current.usedSize,
      totalSize: current.totalSize,
      growth: current.usedSize - baseline.usedSize
    });
  }

  // Analyze trend
  const avgGrowth = measurements.reduce((sum, m) => sum + m.growth, 0) / measurements.length;

  return {
    measurements,
    avgGrowth,
    leakDetected: avgGrowth > baseline.usedSize * 0.1 // 10% growth threshold
  };
}
```

## Assets

See `assets/devtools-profiling-config.yaml` for profiling patterns and configuration examples.

## Resources

### Official Documentation
- [Chrome DevTools](https://developer.chrome.com/docs/devtools/) - Complete DevTools guide
- [Performance Debugging](https://developer.chrome.com/docs/devtools/performance/) - Performance panel docs
- [Memory Profiling](https://developer.chrome.com/docs/devtools/memory-problems/) - Memory debugging

### Learning Resources
- [DevTools Tips](https://devtoolstips.org/) - Daily tips and tricks
- [Performance Analysis Reference](https://developers.google.com/web/tools/chrome-devtools/evaluate-performance/reference) - Reference guide
- [Memory Terminology](https://developers.google.com/web/tools/chrome-devtools/memory-problems/memory-101) - Memory concepts

### Tools
- [Puppeteer](https://pptr.dev/) - Headless Chrome automation
- [Playwright](https://playwright.dev/) - Cross-browser testing
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) - Protocol docs

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
