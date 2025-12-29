# Browser DevTools Debugging Patterns

Real-world patterns for using DevTools effectively in production debugging.

## Custom Performance Markers Pattern

```typescript
/**
 * Application-wide performance tracking
 * Automatically marks important operations
 */

class AppPerformance {
  static startPageLoad() {
    performance.mark('page-load-start');
    window.addEventListener('load', () => {
      performance.mark('page-load-end');
      performance.measure('page-load', 'page-load-start', 'page-load-end');
      this.logMetrics('page-load');
    });
  }

  static markOperation(name: string) {
    performance.mark(`${name}-start`);
    return () => {
      performance.mark(`${name}-end`);
      performance.measure(name, `${name}-start`, `${name}-end`);
      this.logMetrics(name);
    };
  }

  static logMetrics(name: string) {
    const entries = performance.getEntriesByName(name);
    if (entries.length > 0) {
      const duration = (entries[entries.length - 1] as PerformanceMeasure).duration;
      console.log(`📊 ${name}: ${duration.toFixed(2)}ms`);
    }
  }
}

// Usage
const endDataFetch = AppPerformance.markOperation('data-fetch');
await fetchData();
endDataFetch();
```

## Memory Leak Detection Pattern

```typescript
/**
 * Monitor memory growth and detect leaks
 */

class MemoryLeakDetector {
  private snapshots: MemorySnapshot[] = [];
  private threshold = 50 * 1024 * 1024; // 50MB increase

  takeSnapshot(label: string) {
    const memory = (performance as any).memory;
    if (!memory) {
      console.warn('Memory API not available in this browser');
      return;
    }

    this.snapshots.push({
      label,
      timestamp: Date.now(),
      usedMemory: memory.usedJSHeapSize,
    });
  }

  analyzeGrowth() {
    for (let i = 1; i < this.snapshots.length; i++) {
      const prev = this.snapshots[i - 1];
      const curr = this.snapshots[i];
      const growth = curr.usedMemory - prev.usedMemory;

      if (growth > this.threshold) {
        console.warn(
          `⚠️ Memory growth detected: ${(growth / 1024 / 1024).toFixed(2)}MB`
        );
        console.log(`From: ${prev.label} → To: ${curr.label}`);
      }
    }
  }

  report() {
    console.table(
      this.snapshots.map((s) => ({
        Label: s.label,
        'Memory (MB)': (s.usedMemory / 1024 / 1024).toFixed(2),
      }))
    );
  }
}

interface MemorySnapshot {
  label: string;
  timestamp: number;
  usedMemory: number;
}
```

## Network Request Interceptor Pattern

```typescript
/**
 * Log all network requests for debugging
 */

class RequestLogger {
  static init() {
    this.interceptFetch();
    this.interceptXHR();
    this.setupNetworkListener();
  }

  private static interceptFetch() {
    const originalFetch = window.fetch;

    window.fetch = async (...args: any[]) => {
      const [url, options] = args;
      const startTime = performance.now();

      console.log(`→ Fetch: ${url}`);

      try {
        const response = await originalFetch(...args);
        const duration = performance.now() - startTime;

        console.log(
          `← ${response.status} ${url} (${duration.toFixed(2)}ms)`
        );

        return response;
      } catch (error) {
        console.error(`✗ Fetch failed: ${url}`, error);
        throw error;
      }
    };
  }

  private static interceptXHR() {
    const originalOpen = XMLHttpRequest.prototype.open;
    const originalSend = XMLHttpRequest.prototype.send;

    XMLHttpRequest.prototype.open = function (method: string, url: string) {
      this._startTime = performance.now();
      this._method = method;
      this._url = url;

      console.log(`→ XHR: ${method} ${url}`);

      return originalOpen.call(this, method, url);
    };

    XMLHttpRequest.prototype.send = function () {
      const startTime = this._startTime;
      const method = this._method;
      const url = this._url;

      this.addEventListener('load', () => {
        const duration = performance.now() - startTime;
        console.log(
          `← ${this.status} ${method} ${url} (${duration.toFixed(2)}ms)`
        );
      });

      return originalSend.apply(this);
    };
  }

  private static setupNetworkListener() {
    if ('connection' in navigator) {
      const connection = (navigator as any).connection;
      connection.addEventListener('change', () => {
        console.log(
          `Network: ${connection.effectiveType} - ${connection.downlink}Mbps`
        );
      });
    }
  }
}

// Initialize
RequestLogger.init();
```

## Performance Timeline Pattern

```typescript
/**
 * Create visual timeline in DevTools Performance tab
 */

class PerformanceTimeline {
  static markPhase(phase: 'start' | 'end', name: string) {
    performance.mark(
      `${name}-${phase}`,
      { detail: { name } }
    );
  }

  static measurePhase(name: string, startMark: string, endMark: string) {
    try {
      performance.measure(name, startMark, endMark);
    } catch (e) {
      console.warn(`Could not measure ${name}`);
    }
  }

  static createUserTiming(
    name: string,
    callback: () => void | Promise<void>
  ) {
    return async () => {
      performance.mark(`${name}-start`);

      try {
        await callback();
      } finally {
        performance.mark(`${name}-end`);
        this.measurePhase(name, `${name}-start`, `${name}-end`);
      }
    };
  }
}

// Usage
const measureDataLoad = PerformanceTimeline.createUserTiming(
  'api-call',
  async () => {
    const response = await fetch('/api/data');
    return response.json();
  }
);

await measureDataLoad();
// View in Performance tab → User Timing
```

## Console Utilities Pattern

```typescript
/**
 * Enhanced console utilities for debugging
 */

const DevConsole = {
  /**
   * Table with custom formatting
   */
  table(data: any[], title?: string) {
    if (title) console.group(title);
    console.table(data);
    if (title) console.groupEnd();
  },

  /**
   * Tree view for nested objects
   */
  tree(label: string, obj: any, depth = 0) {
    const indent = '  '.repeat(depth);
    console.log(`${indent}${label}:`);

    if (typeof obj === 'object') {
      for (const [key, value] of Object.entries(obj)) {
        if (typeof value === 'object') {
          this.tree(key, value, depth + 1);
        } else {
          console.log(`${indent}  ${key}: ${value}`);
        }
      }
    }
  },

  /**
   * Timeline view
   */
  timeline(events: TimelineEvent[]) {
    const sorted = events.sort((a, b) => a.time - b.time);
    const minTime = sorted[0].time;

    sorted.forEach((event) => {
      const offset = event.time - minTime;
      const bar = '█'.repeat(Math.ceil(offset / 100));
      console.log(`${bar} +${offset}ms - ${event.name}`);
    });
  },

  /**
   * Memory report
   */
  memoryReport() {
    if ((performance as any).memory) {
      const mem = (performance as any).memory;
      console.table({
        'Used (MB)': (mem.usedJSHeapSize / 1024 / 1024).toFixed(2),
        'Total (MB)': (mem.totalJSHeapSize / 1024 / 1024).toFixed(2),
        'Limit (MB)': (mem.jsHeapSizeLimit / 1024 / 1024).toFixed(2),
        'Usage %': ((mem.usedJSHeapSize / mem.jsHeapSizeLimit) * 100).toFixed(2),
      });
    }
  },
};

interface TimelineEvent {
  name: string;
  time: number;
}

// Usage
DevConsole.table(items, 'User List');
DevConsole.tree('Data', complexObject);
DevConsole.memoryReport();
```

## React DevTools Integration Pattern

```typescript
/**
 * Enhance React debugging in DevTools
 */

export const setupReactDevTools = () => {
  if (process.env.NODE_ENV === 'development') {
    // Mark component renders
    const originalConsoleGroup = console.group;
    const originalConsoleGroupEnd = console.groupEnd;

    let currentComponent: string | null = null;

    console.group = function (label: string) {
      if (label.includes('React')) {
        currentComponent = label;
        performance.mark(`${currentComponent}-start`);
      }
      return originalConsoleGroup.call(console, label);
    };

    console.groupEnd = function () {
      if (currentComponent) {
        performance.mark(`${currentComponent}-end`);
        performance.measure(
          currentComponent,
          `${currentComponent}-start`,
          `${currentComponent}-end`
        );
        currentComponent = null;
      }
      return originalConsoleGroupEnd.call(console);
    };
  }
};

// Call in React root
setupReactDevTools();
```

These patterns provide production-ready debugging and performance monitoring implementations.
