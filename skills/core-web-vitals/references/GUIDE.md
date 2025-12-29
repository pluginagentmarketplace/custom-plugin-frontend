# Core Web Vitals Optimization Guide

Comprehensive technical guide to understanding, measuring, and optimizing Google's Core Web Vitals metrics: Largest Contentful Paint (LCP), First Input Delay (FID) / Interaction to Next Paint (INP), and Cumulative Layout Shift (CLS).

## Table of Contents

1. [Largest Contentful Paint (LCP)](#largest-contentful-paint-lcp)
2. [Interaction to Next Paint (INP) / First Input Delay (FID)](#interaction-to-next-paint-inp--first-input-delay-fid)
3. [Cumulative Layout Shift (CLS)](#cumulative-layout-shift-cls)
4. [Measuring Core Web Vitals](#measuring-core-web-vitals)
5. [Performance Budget Framework](#performance-budget-framework)

---

## Largest Contentful Paint (LCP)

### Definition and Importance

Largest Contentful Paint measures when the largest content element in the viewport becomes visible. It represents when the page's main content has loaded and is ready for user interaction. LCP is critical because:

- **User Perception**: Users perceive page load speed based on when the main content appears
- **Business Impact**: Better LCP correlates with higher conversion rates and lower bounce rates
- **Core Web Vitals**: LCP is one of Google's three primary performance metrics affecting search ranking

### Target Thresholds

- **Good**: ≤ 2.5 seconds
- **Needs Improvement**: > 2.5s and ≤ 4.0s
- **Poor**: > 4.0 seconds

At 2.5s, most users perceive the page as useful. Beyond 4 seconds, users commonly abandon the page.

### Technical Measurement

LCP is measured using the Performance Observer API with the `largest-contentful-paint` entry type:

```typescript
const observer = new PerformanceObserver((list) => {
  const entries = list.getEntries();
  const lastEntry = entries[entries.length - 1];
  console.log('LCP:', lastEntry.renderTime || lastEntry.loadTime);
});

observer.observe({ entryTypes: ['largest-contentful-paint'] });
```

The `renderTime` is used when available (resource is rendered from cache or cross-origin). Otherwise, `loadTime` is used.

### LCP Optimization Techniques

#### 1. Critical Resource Preloading

Preload resources that are essential for LCP:

```html
<!-- Preload critical fonts -->
<link rel="preload" as="font" href="/fonts/critical-font.woff2" crossorigin>

<!-- Preload critical stylesheets -->
<link rel="preload" as="style" href="/css/critical.css">

<!-- Prefetch DNS for external domains -->
<link rel="dns-prefetch" href="https://cdn.example.com">

<!-- Preconnect to critical origins -->
<link rel="preconnect" href="https://api.example.com">
```

Preloading reduces time spent discovering and downloading critical resources.

#### 2. Font Loading Optimization

Fonts significantly impact LCP, especially for text-heavy pages:

```css
/* Use font-display: swap for better performance */
@font-face {
  font-family: 'CustomFont';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: swap; /* Show fallback while loading */
}
```

Font strategies:
- **swap**: Show fallback immediately, replace when custom loads (best for LCP)
- **block**: Wait up to 3s for custom font, then use fallback
- **fallback**: Wait 100ms, use fallback if not ready, swap later
- **optional**: Use custom if available, otherwise fallback

#### 3. Image Optimization for LCP

Images are the most common LCP element:

```html
<!-- Load priority images as critical -->
<img
  src="/hero.jpg"
  fetchpriority="high"
  width="800"
  height="600"
/>

<!-- Use WebP with fallback for better compression -->
<picture>
  <source srcset="/image.webp" type="image/webp">
  <source srcset="/image.jpg" type="image/jpeg">
  <img src="/image.jpg" alt="Description">
</picture>

<!-- Use next-gen formats (AVIF) -->
<picture>
  <source srcset="/image.avif" type="image/avif">
  <source srcset="/image.webp" type="image/webp">
  <img src="/image.jpg" alt="Description">
</picture>
```

#### 4. Server-Side Optimization

Backend performance directly impacts LCP:

```typescript
// Node.js/Express example
app.use((req, res, next) => {
  // Measure response time
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    if (duration > 1000) {
      console.warn(`Slow response: ${req.path} - ${duration}ms`);
    }
  });
  next();
});

// Implement caching headers
app.use((req, res, next) => {
  res.set('Cache-Control', 'public, max-age=3600');
  next();
});

// Enable compression
const compression = require('compression');
app.use(compression());
```

#### 5. Critical CSS Inlining

Inline critical above-the-fold CSS to avoid render-blocking:

```html
<head>
  <style>
    /* Critical CSS for above-the-fold content */
    body { margin: 0; font-family: -apple-system, BlinkMacSystemFont; }
    .hero { height: 100vh; background: linear-gradient(...); }
    .hero h1 { font-size: 3rem; color: white; }
  </style>
  <link rel="stylesheet" href="/non-critical.css" media="print" onload="this.media='all'">
</head>
```

#### 6. Code Splitting and Lazy Loading

Reduce JavaScript that blocks rendering:

```typescript
// webpack.config.js
module.exports = {
  entry: './src/index.js',
  output: { filename: '[name].[contenthash].js' },
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10,
        },
        common: {
          minChunks: 2,
          priority: 5,
        },
      },
    },
  },
};

// React lazy loading
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

export function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  );
}
```

#### 7. CDN and Caching Strategy

Use Content Delivery Networks to serve content from locations closer to users:

```typescript
// CloudFlare Workers example
addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Cache successful responses for 1 hour
        if (response.status === 200) {
          return new Response(response.body, {
            status: response.status,
            headers: {
              ...response.headers,
              'Cache-Control': 'public, max-age=3600',
            },
          });
        }
        return response;
      })
  );
});
```

---

## Interaction to Next Paint (INP) / First Input Delay (FID)

### Definition and Evolution

**First Input Delay (FID)** was the original metric measuring the time from user input to browser response. It only measured the first interaction.

**Interaction to Next Paint (INP)** replaces FID as of 2024, measuring the longest interaction latency across all user interactions during a session. INP is more comprehensive:

- Measures multiple interactions (not just the first)
- Includes response time AND visual feedback time
- Better represents overall page responsiveness

### Target Thresholds

**INP (Current Standard):**
- **Good**: ≤ 200 milliseconds
- **Needs Improvement**: > 200ms and ≤ 500ms
- **Poor**: > 500 milliseconds

**FID (Legacy, still tracked for compatibility):**
- **Good**: ≤ 100 milliseconds
- **Needs Improvement**: > 100ms and ≤ 300ms
- **Poor**: > 300 milliseconds

Users expect visual response to input within 100ms. Beyond 300ms, the interaction feels sluggish.

### Technical Measurement

#### INP Measurement

```typescript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log('Interaction:', {
      name: entry.name,
      duration: entry.duration,
      startTime: entry.startTime,
      processingDuration: entry.processingDuration,
      presentationDelay: entry.presentationDelay,
    });
  }
});

observer.observe({ entryTypes: ['interaction'] });

// Get current INP (select worst interaction)
let maxDuration = 0;
const observer2 = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.duration > maxDuration) {
      maxDuration = entry.duration;
      console.log('Current INP:', maxDuration);
    }
  }
});
observer2.observe({ entryTypes: ['interaction'] });
```

#### FID Measurement (Legacy)

```typescript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    // FID is first-input-delay in navigation timing
    console.log('FID:', entry.processingStart - entry.startTime);
  }
});

observer.observe({ entryTypes: ['first-input'] });
```

### INP Optimization Techniques

#### 1. Break Up Long JavaScript Tasks

The primary cause of input delay is JavaScript execution blocking the main thread:

```typescript
// BEFORE: Long-running task blocks UI
function processLargeDataset(data) {
  const results = data.map(item => complexCalculation(item));
  updateDOM(results);
}

// AFTER: Break into chunks
async function processLargeDatasetOptimized(data) {
  const chunkSize = 100;
  const results = [];

  for (let i = 0; i < data.length; i += chunkSize) {
    const chunk = data.slice(i, i + chunkSize);
    results.push(...chunk.map(item => complexCalculation(item)));

    // Yield to main thread between chunks
    await new Promise(resolve => setTimeout(resolve, 0));
  }

  updateDOM(results);
}
```

#### 2. Use requestIdleCallback for Non-Critical Work

Execute work during browser idle time:

```typescript
function scheduleDeferredWork(work) {
  if ('requestIdleCallback' in window) {
    requestIdleCallback(work, { timeout: 5000 });
  } else {
    // Fallback for browsers without requestIdleCallback
    setTimeout(work, 0);
  }
}

// Usage
scheduleDeferredWork(() => {
  // This runs when the browser is idle
  analyzeUserBehavior();
  preloadImages();
  syncAnalytics();
});
```

#### 3. Debounce and Throttle Event Handlers

Limit how often handlers execute:

```typescript
// Debounce: Wait for user to stop interacting
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

const handleSearch = debounce((query) => {
  fetchSearchResults(query);
}, 300);

document.addEventListener('input', (e) => {
  if (e.target.id === 'search') {
    handleSearch(e.target.value);
  }
});

// Throttle: Limit execution frequency
function throttle(func, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

const handleScroll = throttle(() => {
  updateScrollIndicator();
}, 100);

document.addEventListener('scroll', handleScroll);
```

#### 4. Passive Event Listeners

Mark event listeners as passive when you won't call preventDefault():

```typescript
// BEFORE: Browser must wait to see if handler calls preventDefault
element.addEventListener('scroll', (e) => {
  updateScrollPosition();
});

// AFTER: Browser knows handler won't call preventDefault
element.addEventListener('scroll', (e) => {
  updateScrollPosition();
}, { passive: true });

// Touch events especially benefit from passive: true
document.addEventListener('touchstart', handleTouch, { passive: true });
document.addEventListener('touchmove', handleTouchMove, { passive: true });
```

#### 5. Optimize Third-Party Scripts

Third-party scripts (analytics, ads, social widgets) often cause input delay:

```typescript
// Load third-party scripts asynchronously
const script = document.createElement('script');
script.src = 'https://analytics.example.com/tracker.js';
script.async = true;
script.defer = true;
document.body.appendChild(script);

// Use Web Workers for heavy computations
// main.js
const worker = new Worker('heavy-computation.worker.js');
worker.postMessage({ data: largeDataset });
worker.onmessage = (e) => {
  const results = e.data;
  updateDOM(results);
};

// heavy-computation.worker.js
self.onmessage = (e) => {
  const results = e.data.map(item => complexCalculation(item));
  self.postMessage(results);
};
```

#### 6. React-Specific Optimizations

```typescript
// Use useCallback to prevent unnecessary re-renders
function SearchInput() {
  const [query, setQuery] = useState('');
  const handleChange = useCallback((e) => {
    setQuery(e.target.value);
    // Debounced search
    debouncedSearch(e.target.value);
  }, []);

  return <input onChange={handleChange} />;
}

// Use React.memo for expensive components
const ItemList = React.memo(({ items }) => {
  return (
    <ul>
      {items.map(item => <Item key={item.id} item={item} />)}
    </ul>
  );
}, (prevProps, nextProps) => prevProps.items === nextProps.items);

// Use useDeferredValue for non-urgent updates
function FilterableList({ items, searchTerm }) {
  const deferredSearchTerm = useDeferredValue(searchTerm);
  const filtered = items.filter(i => i.name.includes(deferredSearchTerm));

  return <ItemList items={filtered} />;
}
```

---

## Cumulative Layout Shift (CLS)

### Definition and Impact

Cumulative Layout Shift measures the sum of all layout shift scores during the page's lifetime. A layout shift occurs when any element changes its position in the viewport without explicit user interaction.

CLS is critical because:
- **User Experience**: Unexpected layout shifts are jarring and confusing
- **Accidental Clicks**: Shifting layouts cause users to click wrong elements
- **Accessibility**: Users with motor difficulties suffer more from shifting layouts
- **Perception**: Pages feel janky and poorly built

### Target Thresholds

- **Good**: ≤ 0.1
- **Needs Improvement**: > 0.1 and ≤ 0.25
- **Poor**: > 0.25

A shift score of 0.1 means a small element moved. Complex shifts from ad/image loading can easily exceed 0.25.

### Technical Measurement

```typescript
let clsValue = 0;

const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (!entry.hadRecentInput) { // Ignore shifts after user input
      const firstSessionEntry = clsValue + entry.value;
      if (firstSessionEntry > clsValue) {
        clsValue = firstSessionEntry;
        console.log('CLS updated:', clsValue);
      }
    }
  }
});

observer.observe({ type: 'layout-shift', buffered: true });

// Get final CLS
window.addEventListener('beforeunload', () => {
  console.log('Final CLS:', clsValue);
});
```

### CLS Optimization Techniques

#### 1. Reserve Space for Dynamic Content

Pre-allocate space for images, ads, and dynamic content:

```html
<!-- BEFORE: Image causes layout shift -->
<img src="/lazy-image.jpg" alt="Photo">

<!-- AFTER: Reserved space prevents shift -->
<img
  src="/lazy-image.jpg"
  alt="Photo"
  width="400"
  height="300"
  style="aspect-ratio: 4 / 3"
/>

<!-- For responsive images, use aspect-ratio -->
<div class="image-container" style="aspect-ratio: 16 / 9;">
  <img src="/image.jpg" alt="Video thumbnail" loading="lazy">
</div>
```

#### 2. Avoid Inserting Content Above Existing Content

Never insert content in the middle of the page without user action:

```typescript
// BEFORE: Insert message at top, shifts all content
function showNotification(message) {
  const notification = document.createElement('div');
  notification.textContent = message;
  document.body.insertBefore(notification, document.body.firstChild);
}

// AFTER: Append to bottom or fixed position
function showNotificationOptimized(message) {
  const notification = document.createElement('div');
  notification.textContent = message;
  notification.style.position = 'fixed';
  notification.style.bottom = '0';
  notification.style.left = '0';
  notification.style.right = '0';
  document.body.appendChild(notification);
}
```

#### 3. Avoid Changing Font Dimensions

Web fonts loading cause layout shift. Use font-display: swap:

```css
@font-face {
  font-family: 'CustomFont';
  src: url('/font.woff2') format('woff2');
  font-display: swap; /* Swap to custom when ready */
  font-size-adjust: 0.9; /* Adjust fallback font metrics */
}
```

#### 4. Use CSS Transforms Instead of Layout-Affecting Properties

Transforms don't cause layout recalculation:

```css
/* BEFORE: Changes layout */
.element {
  position: relative;
  left: 10px; /* Causes layout shift */
}

/* AFTER: Transform doesn't trigger reflow */
.element {
  transform: translateX(10px); /* Smoother, no shift */
}

/* Animate position changes with transform */
@keyframes slideIn {
  from { transform: translateX(-100%); }
  to { transform: translateX(0); }
}
```

#### 5. Use contain CSS Property

The `contain` property tells browser to isolate element's rendering:

```css
/* Optimize iframe/ad containers */
.ad-container {
  contain: layout style paint; /* Prevents cascading layout shift */
}

/* Use size containment for known dimensions */
.image-wrapper {
  contain: layout;
  width: 400px;
  height: 300px;
}
```

#### 6. Manage Ads and Embedded Content

Ads are a primary CLS culprit:

```html
<!-- Reserve space for ad -->
<div class="ad-slot" style="width: 300px; height: 250px;">
  <script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
  <ins class="adsbygoogle"
       style="display:inline-block;width:300px;height:250px"
       data-ad-client="ca-pub-xxxxxxxxxxxxxxxx"
       data-ad-slot="xxxxxxxxxx"></ins>
  <script>
    (adsbygoogle = window.adsbygoogle || []).push({});
  </script>
</div>
```

---

## Measuring Core Web Vitals

### web-vitals Library

Google's official library provides accurate measurements:

```typescript
import { getCLS, getFCP, getFID, getLCP, getTTFB } from 'web-vitals';

// Callback when metrics are available
getCLS(console.log);  // CLS updates as page goes idle
getFCP(console.log);  // FCP available after rendering
getFID(console.log);  // FID available after first interaction
getLCP(console.log);  // LCP available after largest element renders
getTTFB(console.log); // TTFB available after response starts
```

### Lighthouse Integration

Use Lighthouse for local testing:

```bash
# Install globally
npm install -g lighthouse

# Audit a URL
lighthouse https://example.com --view

# Audit local app on port 3000
lighthouse http://localhost:3000 --view
```

### Real User Monitoring (RUM)

Collect metrics from real users:

```typescript
import { onCLS, onFCP, onFID, onLCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  // Only send critical metrics
  if (metric.value > metric.delta * 2) {
    navigator.sendBeacon('/api/metrics', JSON.stringify(metric));
  }
}

onLCP(sendToAnalytics);
onCLS(sendToAnalytics);
onFID(sendToAnalytics);
```

---

## Performance Budget Framework

### Setting Realistic Budgets

Based on your application type and target audience:

```json
{
  "performance_budgets": [
    {
      "type": "LCP",
      "budget": 2500,
      "threshold": 3000,
      "critical": true
    },
    {
      "type": "INP",
      "budget": 200,
      "threshold": 300,
      "critical": true
    },
    {
      "type": "CLS",
      "budget": 0.1,
      "threshold": 0.15,
      "critical": true
    },
    {
      "type": "JavaScript",
      "budget": 170,
      "threshold": 250,
      "critical": false
    },
    {
      "type": "CSS",
      "budget": 50,
      "threshold": 100,
      "critical": false
    }
  ]
}
```

### Enforcing Budgets in CI/CD

```bash
#!/bin/bash
# ci/performance-budget.sh

LIGHTHOUSE_RESULT=$(lighthouse https://example.com --output=json)

LCP=$(echo $LIGHTHOUSE_RESULT | jq '.lighthouseResult.audits."largest-contentful-paint".numericValue')
CLS=$(echo $LIGHTHOUSE_RESULT | jq '.lighthouseResult.audits."cumulative-layout-shift".numericValue')

if (( $(echo "$LCP > 3000" | bc -l) )); then
  echo "❌ LCP budget exceeded: ${LCP}ms"
  exit 1
fi

if (( $(echo "$CLS > 0.15" | bc -l) )); then
  echo "❌ CLS budget exceeded: ${CLS}"
  exit 1
fi

echo "✓ Performance budget check passed"
```

### Progressive Performance Improvement

Set incremental targets:

```json
{
  "performance_roadmap": {
    "Q1": { "LCP": 3500, "INP": 300, "CLS": 0.15 },
    "Q2": { "LCP": 3000, "INP": 250, "CLS": 0.12 },
    "Q3": { "LCP": 2500, "INP": 200, "CLS": 0.1 },
    "Q4": { "LCP": 2000, "INP": 150, "CLS": 0.08 }
  }
}
```

This comprehensive guide provides the technical foundation for optimizing Core Web Vitals across all three critical metrics.
