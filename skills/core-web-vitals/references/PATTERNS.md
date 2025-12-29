# Core Web Vitals Patterns

Real-world patterns and best practices for implementing Core Web Vitals optimization across your application.

## LCP Optimization Patterns

### Pattern 1: Critical Resource Prioritization Pipeline

```typescript
/**
 * Intelligent resource loading based on LCP impact analysis
 * Prioritizes resources that directly impact LCP
 */

class LCPResourceManager {
  private criticalResources: Set<string>;
  private resourcePriority: Map<string, number>;

  constructor() {
    this.criticalResources = new Set([
      'hero-image',
      'above-the-fold-css',
      'main-font',
      'critical-vendor-js',
    ]);
    this.resourcePriority = new Map();
  }

  /**
   * Analyze which resource is likely to be LCP element
   */
  analyzeLCPElement(): PerformanceEntry | null {
    const entries = performance.getEntriesByType('largest-contentful-paint');
    return entries[entries.length - 1] || null;
  }

  /**
   * Preload resources based on detected LCP element
   */
  optimizeForDetectedLCP(elementType: 'image' | 'text' | 'video'): void {
    if (elementType === 'image') {
      this.preloadCriticalImages();
    } else if (elementType === 'text') {
      this.preloadFonts();
      this.inlineCriticalCSS();
    } else if (elementType === 'video') {
      this.preloadVideoThumbnail();
    }
  }

  private preloadCriticalImages(): void {
    const images = document.querySelectorAll('[data-lcp-candidate]');
    images.forEach((img) => {
      const link = document.createElement('link');
      link.rel = 'preload';
      link.as = 'image';
      link.href = img.getAttribute('src') || img.getAttribute('data-src');
      document.head.appendChild(link);
    });
  }

  private preloadFonts(): void {
    const fonts = [
      '/fonts/main.woff2',
      '/fonts/heading.woff2',
    ];

    fonts.forEach((font) => {
      const link = document.createElement('link');
      link.rel = 'preload';
      link.as = 'font';
      link.href = font;
      link.type = 'font/woff2';
      link.crossOrigin = 'anonymous';
      document.head.appendChild(link);
    });
  }

  private inlineCriticalCSS(): void {
    // Inject critical CSS directly in <head>
    const criticalCSS = `
      body { margin: 0; font-family: system-ui; }
      .hero { height: 100vh; }
      .hero h1 { font-size: 3rem; color: white; }
    `;
    const style = document.createElement('style');
    style.textContent = criticalCSS;
    document.head.insertBefore(style, document.head.firstChild);
  }

  private preloadVideoThumbnail(): void {
    const video = document.querySelector('video[data-lcp]');
    if (video?.poster) {
      const link = document.createElement('link');
      link.rel = 'preload';
      link.as = 'image';
      link.href = video.poster;
      document.head.appendChild(link);
    }
  }
}

// Usage
const lcpManager = new LCPResourceManager();
setTimeout(() => {
  const lcpElement = lcpManager.analyzeLCPElement();
  console.log('Detected LCP element:', lcpElement);
}, 5000);
```

### Pattern 2: Adaptive Font Loading Strategy

```typescript
/**
 * Load fonts adaptively based on network conditions and device
 * Prevents font-loading layout shifts
 */

class AdaptiveFontLoader {
  private fontLoads: Map<string, Promise<void>>;
  private connection: 'fast' | 'slow' | 'unknown';

  constructor() {
    this.fontLoads = new Map();
    this.connection = this.detectConnectionSpeed();
  }

  private detectConnectionSpeed(): 'fast' | 'slow' | 'unknown' {
    if ('connection' in navigator) {
      const connection = (navigator as any).connection;
      const effectiveType = connection?.effectiveType;

      if (effectiveType === '4g') return 'fast';
      if (effectiveType === '3g' || effectiveType === '2g') return 'slow';
    }
    return 'unknown';
  }

  /**
   * Load fonts with appropriate strategy
   */
  loadFonts(): void {
    if (this.connection === 'slow') {
      this.useSystemFontsOnly();
    } else if (this.connection === 'fast') {
      this.preloadAllFonts();
    } else {
      this.loadFontsProgressively();
    }
  }

  private useSystemFontsOnly(): void {
    // Disable custom fonts on slow connections
    document.documentElement.style.fontFamily = 'system-ui';
    console.log('Using system fonts (slow connection detected)');
  }

  private preloadAllFonts(): void {
    const fonts = [
      { name: 'main', url: '/fonts/main.woff2' },
      { name: 'heading', url: '/fonts/heading.woff2' },
      { name: 'mono', url: '/fonts/mono.woff2' },
    ];

    fonts.forEach(({ name, url }) => {
      this.loadFont(name, url, 'preload');
    });
  }

  private loadFontsProgressively(): void {
    const fonts = [
      { name: 'main', url: '/fonts/main.woff2' },
    ];

    fonts.forEach(({ name, url }) => {
      this.loadFont(name, url, 'prefetch');
    });
  }

  private loadFont(
    name: string,
    url: string,
    strategy: 'preload' | 'prefetch'
  ): void {
    if (this.fontLoads.has(name)) return;

    const promise = new Promise<void>((resolve) => {
      const link = document.createElement('link');
      link.rel = strategy;
      link.as = 'font';
      link.href = url;
      link.type = 'font/woff2';
      link.crossOrigin = 'anonymous';
      link.onload = () => resolve();
      link.onerror = () => resolve(); // Don't fail on font error
      document.head.appendChild(link);
    });

    this.fontLoads.set(name, promise);
  }

  /**
   * Wait for critical fonts to load
   */
  async waitForCriticalFonts(): Promise<void> {
    const criticalFonts = ['main', 'heading'];
    await Promise.all(
      criticalFonts
        .map((name) => this.fontLoads.get(name))
        .filter(Boolean) as Promise<void>[]
    );
  }
}

// Usage
const fontLoader = new AdaptiveFontLoader();
fontLoader.loadFonts();
fontLoader.waitForCriticalFonts().then(() => {
  console.log('Critical fonts loaded');
});
```

### Pattern 3: Server-Side Rendering Optimization

```typescript
/**
 * SSR-specific LCP optimization
 * Render critical content server-side to minimize client-side work
 */

// server.js (Node.js/Express)
const express = require('express');
const { renderToString } = require('react-dom/server');
const App = require('./App');

app.get('/', async (req, res) => {
  // Measure server rendering time
  const renderStart = Date.now();

  // Render app on server
  const html = renderToString(App());

  // Extract critical CSS for this page
  const criticalCSS = await extractCriticalCSS(html);

  // Create HTML with inline critical CSS and resources
  const page = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <style>${criticalCSS}</style>
        <link rel="preload" as="font" href="/fonts/main.woff2" crossorigin>
        <link rel="preload" as="image" href="/hero.jpg">
      </head>
      <body>
        <div id="app">${html}</div>
        <script src="/app.js"></script>
      </body>
    </html>
  `;

  const renderTime = Date.now() - renderStart;
  console.log(`Server render time: ${renderTime}ms`);

  res.send(page);
});

/**
 * Extract critical CSS for above-the-fold content
 */
async function extractCriticalCSS(html) {
  // In production, use critical library
  const critical = require('critical');
  const { css } = await critical.generate({
    inline: true,
    base: __dirname,
    html: html,
    dimensions: [
      { height: 1280, width: 800 },
      { height: 720, width: 1200 },
    ],
  });

  return css;
}
```

---

## INP/FID Optimization Patterns

### Pattern 1: Event Handler Optimization Framework

```typescript
/**
 * Framework for optimizing event handlers to reduce INP
 * Automatically debounces, defers, and optimizes event handling
 */

class OptimizedEventHandler {
  private handlers: Map<string, Function>;
  private debouncedHandlers: Map<string, (...args: any[]) => void>;
  private deferredHandlers: Map<string, (...args: any[]) => void>;

  constructor() {
    this.handlers = new Map();
    this.debouncedHandlers = new Map();
    this.deferredHandlers = new Map();
  }

  /**
   * Register handler with automatic optimization
   */
  on(
    eventName: string,
    selector: string,
    handler: (e: Event) => void,
    options: {
      passive?: boolean;
      debounce?: number;
      defer?: boolean;
      priority?: 'high' | 'normal' | 'low';
    } = {}
  ): void {
    const key = `${eventName}:${selector}`;
    const { passive = false, debounce = 0, defer = false, priority = 'normal' } = options;

    // Wrap handler with optimization
    let wrappedHandler = handler;

    if (debounce > 0) {
      wrappedHandler = this.createDebouncedHandler(handler, debounce);
    }

    if (defer) {
      wrappedHandler = this.createDeferredHandler(handler, priority);
    }

    // Attach with passive flag for better performance
    const elements = document.querySelectorAll(selector);
    elements.forEach((element) => {
      element.addEventListener(eventName, wrappedHandler, { passive });
    });

    this.handlers.set(key, handler);
  }

  /**
   * Create debounced handler to reduce event firing
   */
  private createDebouncedHandler(
    handler: (e: Event) => void,
    delay: number
  ): (e: Event) => void {
    let timeout: NodeJS.Timeout;

    return (event: Event) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => handler(event), delay);
    };
  }

  /**
   * Create deferred handler using requestIdleCallback
   */
  private createDeferredHandler(
    handler: (e: Event) => void,
    priority: 'high' | 'normal' | 'low'
  ): (e: Event) => void {
    return (event: Event) => {
      if ('requestIdleCallback' in window) {
        requestIdleCallback(
          () => handler(event),
          { timeout: this.getTimeoutForPriority(priority) }
        );
      } else {
        setTimeout(() => handler(event), 0);
      }
    };
  }

  private getTimeoutForPriority(priority: string): number {
    switch (priority) {
      case 'high':
        return 1000; // High priority: must complete within 1s
      case 'normal':
        return 5000; // Normal: within 5s
      case 'low':
        return 10000; // Low: within 10s
      default:
        return 5000;
    }
  }
}

// Usage
const eventHandler = new OptimizedEventHandler();

// Debounce search input to reduce API calls
eventHandler.on('input', '#search', (e) => {
  const query = (e.target as HTMLInputElement).value;
  performSearch(query);
}, { debounce: 300 });

// Defer analytics tracking
eventHandler.on('click', 'a, button', (e) => {
  trackClick(e.target as HTMLElement);
}, { defer: true, priority: 'low' });

// Optimize scroll with passive listener
eventHandler.on('scroll', document, () => {
  updateScrollIndicator();
}, { passive: true });
```

### Pattern 2: JavaScript Task Chunking

```typescript
/**
 * Break long-running JavaScript into smaller, non-blocking chunks
 * Maintains responsiveness during heavy computation
 */

class TaskScheduler {
  /**
   * Execute function in small chunks with yielding
   */
  static async executeInChunks<T>(
    items: T[],
    processor: (item: T) => void,
    chunkSize: number = 100
  ): Promise<void> {
    for (let i = 0; i < items.length; i += chunkSize) {
      const chunk = items.slice(i, i + chunkSize);

      // Process chunk synchronously
      chunk.forEach(processor);

      // Yield to browser
      await new Promise((resolve) => setTimeout(resolve, 0));
    }
  }

  /**
   * Execute with scheduler API if available
   */
  static async executeWithScheduler<T>(
    items: T[],
    processor: (item: T) => void
  ): Promise<void> {
    for (const item of items) {
      if ('scheduler' in window && 'yield' in (window.scheduler as any)) {
        await (window.scheduler as any).yield();
      } else {
        await new Promise((resolve) => setTimeout(resolve, 0));
      }

      processor(item);
    }
  }

  /**
   * Execute with priority and timeout
   */
  static async executeWithPriority<T>(
    items: T[],
    processor: (item: T) => void,
    priority: 'user-blocking' | 'user-visible' | 'background' = 'user-visible'
  ): Promise<void> {
    if ('scheduler' in window && 'scheduleCallback' in (window.scheduler as any)) {
      // Use Scheduler API if available
      await new Promise<void>((resolve) => {
        let remaining = items.length;

        const process = () => {
          if (items.length === 0) {
            resolve();
            return;
          }

          const item = items.shift();
          if (item) processor(item);

          if (items.length > 0) {
            (window.scheduler as any).scheduleCallback(
              this.getPriorityLevel(priority),
              process
            );
          } else {
            resolve();
          }
        };

        (window.scheduler as any).scheduleCallback(
          this.getPriorityLevel(priority),
          process
        );
      });
    } else {
      // Fallback to chunking
      await this.executeInChunks(items, processor);
    }
  }

  private static getPriorityLevel(priority: string): number {
    // ImmediatePriority = 1, UserBlockingPriority = 2, NormalPriority = 3, etc.
    switch (priority) {
      case 'user-blocking':
        return 1;
      case 'user-visible':
        return 2;
      case 'background':
        return 5;
      default:
        return 3;
    }
  }
}

// Usage
async function processLargeDataset(data: any[]): Promise<void> {
  // Process with automatic chunking
  await TaskScheduler.executeInChunks(data, (item) => {
    renderListItem(item);
  }, 50); // 50 items per chunk

  console.log('Processing complete');
}

// With priority
async function processWithPriority(data: any[]): Promise<void> {
  await TaskScheduler.executeWithPriority(
    data,
    (item) => updateUI(item),
    'user-visible'
  );
}
```

---

## CLS Prevention Patterns

### Pattern 1: Dynamic Content Container Manager

```typescript
/**
 * Automatically reserve space for dynamic content to prevent CLS
 * Handles images, ads, embeds, and dynamic text
 */

class DynamicContentManager {
  /**
   * Create container with reserved space
   */
  static createReservedContainer(
    elementType: 'image' | 'ad' | 'embed' | 'video',
    width: number,
    height: number,
    className: string = ''
  ): HTMLDivElement {
    const container = document.createElement('div');
    container.className = `reserved-space ${className}`;

    // Set dimensions based on element type
    const styles: Partial<CSSStyleDeclaration> = {
      width: `${width}px`,
      height: `${height}px`,
      position: 'relative',
      overflow: 'hidden',
      backgroundColor: '#f5f5f5',
    };

    // Calculate aspect ratio
    const aspectRatio = (height / width * 100).toFixed(2);

    // Use contain property for optimization
    if (elementType === 'ad' || elementType === 'embed') {
      styles.contain = 'layout style paint';
    }

    Object.assign(container.style, styles);

    // Add aspect-ratio for responsive sizing
    container.style.aspectRatio = `${width} / ${height}`;

    // Create loading placeholder
    const placeholder = document.createElement('div');
    placeholder.className = 'placeholder';
    placeholder.style.cssText = `
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(90deg, #e0e0e0 25%, #f0f0f0 50%, #e0e0e0 75%);
      background-size: 200% 100%;
      animation: loading 1.5s infinite;
    `;

    container.appendChild(placeholder);

    return container;
  }

  /**
   * Load image in reserved space
   */
  static loadImageInContainer(
    container: HTMLElement,
    src: string,
    alt: string = ''
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      const img = document.createElement('img');
      img.src = src;
      img.alt = alt;
      img.style.cssText = 'width: 100%; height: 100%; object-fit: cover;';

      img.onload = () => {
        container.innerHTML = '';
        container.appendChild(img);
        resolve();
      };

      img.onerror = reject;
    });
  }

  /**
   * Load ad in reserved space
   */
  static loadAdInContainer(container: HTMLElement, adSlot: string): void {
    // Clear placeholder
    const placeholder = container.querySelector('.placeholder');
    if (placeholder) placeholder.remove();

    // Insert ad HTML
    const adHTML = `
      <ins class="adsbygoogle"
           style="display:block;width:100%;height:100%;"
           data-ad-client="ca-pub-xxxxxxxxxxxxxxxx"
           data-ad-slot="${adSlot}"></ins>
    `;

    container.innerHTML = adHTML;

    // Trigger ad rendering
    if ('adsbygoogle' in window) {
      ((window as any).adsbygoogle = window.adsbygoogle || []).push({});
    }
  }

  /**
   * Manage font loading to prevent CLS
   */
  static manageFontLoading(fontFamily: string): void {
    // Add font-display: swap to CSS
    const style = document.createElement('style');
    style.textContent = `
      @font-face {
        font-family: '${fontFamily}';
        font-display: swap;
      }
    `;
    document.head.appendChild(style);

    // Adjust fallback font metrics
    const root = document.documentElement;
    root.style.fontSizeAdjust = '0.95';
  }
}

// Usage
const imageContainer = DynamicContentManager.createReservedContainer(
  'image',
  400,
  300,
  'hero-image'
);

document.querySelector('.hero')?.appendChild(imageContainer);

// Load image when ready
DynamicContentManager.loadImageInContainer(
  imageContainer,
  '/hero.jpg',
  'Hero image'
);

// Create ad container
const adContainer = DynamicContentManager.createReservedContainer(
  'ad',
  300,
  250,
  'sidebar-ad'
);

document.querySelector('.sidebar')?.appendChild(adContainer);

// Load ad
DynamicContentManager.loadAdInContainer(adContainer, 'ad-slot-id');
```

### Pattern 2: Layout Shift Detection and Monitoring

```typescript
/**
 * Detect and monitor layout shifts in real-time
 * Track which elements cause shifts and their impact
 */

class LayoutShiftMonitor {
  private shifts: LayoutShiftEntry[] = [];
  private maxShift: number = 0;
  private shiftsByElement: Map<Element, number> = new Map();

  constructor() {
    this.observeLayoutShifts();
  }

  private observeLayoutShifts(): void {
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries() as LayoutShiftEntry[]) {
        // Ignore shifts caused by user interaction
        if (entry.hadRecentInput) continue;

        this.shifts.push(entry);

        // Update total shift
        this.maxShift = Math.max(this.maxShift, entry.value);

        // Log shift details
        console.warn('Layout Shift Detected:', {
          value: entry.value,
          sources: entry.sources?.map((s) => ({
            element: s.node?.tagName,
            currentRect: s.currentRect,
            previousRect: s.previousRect,
          })),
        });

        // Track by source element
        if (entry.sources) {
          entry.sources.forEach((source) => {
            const element = source.node;
            if (element) {
              const currentShift = this.shiftsByElement.get(element) || 0;
              this.shiftsByElement.set(element, currentShift + entry.value);
            }
          });
        }
      }
    });

    observer.observe({ type: 'layout-shift', buffered: true });
  }

  /**
   * Get elements causing most shifts
   */
  getMostProblematicElements(limit: number = 10): Array<{
    element: Element;
    totalShift: number;
  }> {
    return Array.from(this.shiftsByElement.entries())
      .map(([element, shift]) => ({ element, totalShift: shift }))
      .sort((a, b) => b.totalShift - a.totalShift)
      .slice(0, limit);
  }

  /**
   * Get total CLS value
   */
  getTotalCLS(): number {
    return this.maxShift;
  }

  /**
   * Generate report
   */
  generateReport(): object {
    return {
      totalCLS: this.maxShift,
      shiftCount: this.shifts.length,
      averageShift: this.maxShift / Math.max(1, this.shifts.length),
      problematicElements: this.getMostProblematicElements(5).map((item) => ({
        tag: item.element.tagName,
        class: item.element.className,
        shift: item.totalShift.toFixed(4),
      })),
    };
  }
}

// Usage
const shiftMonitor = new LayoutShiftMonitor();

// Monitor for 10 seconds then report
setTimeout(() => {
  console.log('Layout Shift Report:', shiftMonitor.generateReport());
}, 10000);

// On page unload
window.addEventListener('beforeunload', () => {
  const report = shiftMonitor.generateReport();
  navigator.sendBeacon('/api/cls-report', JSON.stringify(report));
});
```

---

## Performance Monitoring Patterns

### Pattern 1: Comprehensive Metrics Dashboard

```typescript
/**
 * Real-time dashboard combining all Core Web Vitals
 * Visualizes performance metrics with visual indicators
 */

class PerformanceDashboard {
  private metrics: Map<string, PerformanceMetric> = new Map();

  constructor() {
    this.initializeMetrics();
    this.createDashboardUI();
  }

  private initializeMetrics(): void {
    // Initialize metric tracking
    onLCP((metric) => this.updateMetric('LCP', metric.value));
    onCLS((metric) => this.updateMetric('CLS', metric.value));
    onFID((metric) => this.updateMetric('FID', metric.value));
    onFCP((metric) => this.updateMetric('FCP', metric.value));
    onTTFB((metric) => this.updateMetric('TTFB', metric.value));
  }

  private updateMetric(name: string, value: number): void {
    const metric: PerformanceMetric = {
      name,
      value,
      timestamp: Date.now(),
      status: this.getStatus(name, value),
    };

    this.metrics.set(name, metric);
    this.updateDashboardUI();
  }

  private getStatus(name: string, value: number): 'good' | 'needs-improvement' | 'poor' {
    const thresholds: Record<string, [number, number]> = {
      LCP: [2500, 4000],
      CLS: [0.1, 0.25],
      FID: [100, 300],
      INP: [200, 500],
      FCP: [1800, 3000],
      TTFB: [800, 1800],
    };

    const [goodThreshold, needsImprovementThreshold] = thresholds[name] || [0, Infinity];

    if (value <= goodThreshold) return 'good';
    if (value <= needsImprovementThreshold) return 'needs-improvement';
    return 'poor';
  }

  private createDashboardUI(): void {
    const dashboard = document.createElement('div');
    dashboard.id = 'performance-dashboard';
    dashboard.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      background: white;
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 16px;
      font-family: monospace;
      font-size: 12px;
      z-index: 10000;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      max-width: 300px;
    `;

    document.body.appendChild(dashboard);
  }

  private updateDashboardUI(): void {
    const dashboard = document.getElementById('performance-dashboard');
    if (!dashboard) return;

    let html = '<strong>Core Web Vitals</strong><br><br>';

    const metricsOrder = ['LCP', 'CLS', 'FID', 'INP', 'FCP', 'TTFB'];
    metricsOrder.forEach((name) => {
      const metric = this.metrics.get(name);
      if (!metric) return;

      const statusColor = this.getStatusColor(metric.status);
      const unit = name === 'CLS' ? '' : 'ms';

      html += `
        <div style="color: ${statusColor}; margin: 4px 0;">
          ${name}: ${metric.value.toFixed(2)}${unit}
          <span style="font-size: 10px;">(${metric.status})</span>
        </div>
      `;
    });

    dashboard.innerHTML = html;
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'good':
        return '#0cce6b';
      case 'needs-improvement':
        return '#ffa400';
      case 'poor':
        return '#ff4e42';
      default:
        return '#000';
    }
  }
}

// Usage
new PerformanceDashboard();
```

These patterns provide production-ready implementations for optimizing all aspects of Core Web Vitals in real applications.
