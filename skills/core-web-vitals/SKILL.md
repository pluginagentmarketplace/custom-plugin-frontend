---
name: core-web-vitals
description: Master Core Web Vitals optimization - LCP, FID/INP, and CLS measurement and improvement strategies.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: performance
bond_type: PRIMARY_BOND
status: production
category: performance
tags:
  - web-vitals
  - lcp
  - inp
  - cls
  - performance-monitoring
  - user-experience
complexity: intermediate
estimated_time: 45-60min
prerequisites:
  - Basic understanding of web performance
  - Familiarity with Chrome DevTools
  - Knowledge of JavaScript
related_skills:
  - web-vitals-lighthouse
  - devtools-profiling
  - browser-devtools
production_config:
  monitoring_enabled: true
  alerting_thresholds:
    lcp_threshold_ms: 2500
    inp_threshold_ms: 200
    cls_threshold: 0.1
  reporting_interval: 300
  sample_rate: 1.0
---

# Core Web Vitals

Master Google's Core Web Vitals metrics and optimize for user experience.

## Input Schema

```yaml
context:
  project_type: string          # react, vue, next, angular, etc.
  current_metrics:
    lcp: number                 # Current LCP in ms
    inp: number                 # Current INP in ms
    cls: number                 # Current CLS score
  target_metrics:
    lcp: number                 # Target LCP in ms (default: 2500)
    inp: number                 # Target INP in ms (default: 200)
    cls: number                 # Target CLS (default: 0.1)
  environment: string           # development, staging, production
  monitoring_tool: string       # web-vitals, lighthouse, custom

options:
  enable_rum: boolean           # Enable Real User Monitoring
  enable_reporting: boolean     # Enable automatic reporting
  custom_thresholds: object     # Custom metric thresholds
  field_data_collection: boolean # Collect field data
```

## Output Schema

```yaml
analysis:
  lcp_analysis:
    current_value: number
    target_value: number
    status: string              # good, needs-improvement, poor
    bottlenecks: array
    recommendations: array
  inp_analysis:
    current_value: number
    target_value: number
    status: string
    long_tasks: array
    recommendations: array
  cls_analysis:
    current_value: number
    target_value: number
    status: string
    layout_shifts: array
    recommendations: array

implementation:
  web_vitals_setup:
    library_installed: boolean
    monitoring_code: string
    reporting_endpoint: string
  optimizations:
    - metric: string
      technique: string
      code_example: string
      expected_improvement: string

metrics:
  before: object
  after: object
  improvement_percentage: number

next_steps: array
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| CWV-001 | Web Vitals library not found | Missing web-vitals package | Install: `npm install web-vitals` |
| CWV-002 | Invalid metric threshold | Threshold outside valid range | Use valid ranges: LCP<2.5s, INP<200ms, CLS<0.1 |
| CWV-003 | No metric data available | Page not fully loaded or no user interaction | Wait for page load or user interaction |
| CWV-004 | PerformanceObserver not supported | Browser compatibility issue | Use polyfill or feature detection |
| CWV-005 | LCP element not found | LCP element removed or hidden | Check DOM for largest contentful element |
| CWV-006 | Layout shift detection failed | CLS observer not initialized | Verify PerformanceObserver setup |
| CWV-007 | Reporting endpoint failure | Network or endpoint error | Check endpoint URL and network connectivity |
| CWV-008 | Invalid environment config | Missing or incorrect configuration | Verify production config settings |

## MANDATORY

### Core Metrics
- **Largest Contentful Paint (LCP)**: Measure and optimize main content loading
  - Target: < 2.5 seconds
  - Monitor LCP element type and timing
  - Optimize resource loading and rendering

- **First Input Delay (FID) / Interaction to Next Paint (INP)**: Measure interactivity
  - FID Target: < 100ms (deprecated)
  - INP Target: < 200ms (current standard)
  - Identify and optimize long tasks
  - Break up blocking JavaScript

- **Cumulative Layout Shift (CLS)**: Prevent unexpected layout shifts
  - Target: < 0.1
  - Reserve space for dynamic content
  - Use size attributes on media elements

### Implementation
- Web-Vitals library integration
- Performance metrics measurement
- Thresholds and budgeting
- Real User Monitoring (RUM) setup

## OPTIONAL

### Enhanced Monitoring
- Custom performance metrics
- Third-party metric collection
- Synthetic monitoring
- Performance budgets
- Lighthouse integration
- Analytics integration

### Advanced Features
- Multi-region monitoring
- A/B testing performance impact
- User-centric performance analysis
- Custom metric definitions

## ADVANCED

### Enterprise Features
- Production monitoring systems
- Performance regression detection
- Multi-dimensional analysis
- Performance improvement workflows
- Alerting and notifications
- Historical trend analysis
- Automated performance testing
- CI/CD integration

### Custom Implementations
- Custom PerformanceObserver patterns
- Advanced attribution analysis
- Predictive performance modeling
- Machine learning-based optimization

## Test Templates

### Unit Tests
```javascript
// Test: Web Vitals reporting
import { getCLS, getFID, getLCP } from 'web-vitals';

describe('Core Web Vitals', () => {
  test('should report LCP metric', (done) => {
    getLCP((metric) => {
      expect(metric.name).toBe('LCP');
      expect(metric.value).toBeGreaterThan(0);
      expect(metric.rating).toMatch(/good|needs-improvement|poor/);
      done();
    });
  });

  test('should report CLS metric', (done) => {
    getCLS((metric) => {
      expect(metric.name).toBe('CLS');
      expect(metric.value).toBeGreaterThanOrEqual(0);
      done();
    });
  });

  test('should respect custom thresholds', () => {
    const customThresholds = { lcp: 2000, inp: 150, cls: 0.05 };
    const result = evaluateMetrics({ lcp: 1500, inp: 120, cls: 0.03 }, customThresholds);
    expect(result.allPassing).toBe(true);
  });
});
```

### Integration Tests
```javascript
// Test: End-to-end metric collection
describe('Web Vitals Integration', () => {
  test('should collect all metrics on page load', async () => {
    const metrics = await collectAllMetrics();
    expect(metrics).toHaveProperty('lcp');
    expect(metrics).toHaveProperty('inp');
    expect(metrics).toHaveProperty('cls');
    expect(metrics).toHaveProperty('ttfb');
  });

  test('should send metrics to analytics endpoint', async () => {
    const mockEndpoint = jest.fn();
    await sendMetrics(mockEndpoint);
    expect(mockEndpoint).toHaveBeenCalledWith(
      expect.objectContaining({
        lcp: expect.any(Number),
        inp: expect.any(Number),
        cls: expect.any(Number)
      })
    );
  });
});
```

### Performance Tests
```javascript
// Test: Metric thresholds
describe('Performance Budgets', () => {
  test('LCP should be under 2.5s', async () => {
    const lcp = await measureLCP();
    expect(lcp).toBeLessThan(2500);
  });

  test('INP should be under 200ms', async () => {
    const inp = await measureINP();
    expect(inp).toBeLessThan(200);
  });

  test('CLS should be under 0.1', async () => {
    const cls = await measureCLS();
    expect(cls).toBeLessThan(0.1);
  });
});
```

## Best Practices

### LCP Optimization
1. **Optimize Critical Resources**
   - Preload LCP resources: `<link rel="preload" as="image" href="hero.jpg">`
   - Use CDN for static assets
   - Implement proper caching strategies
   - Compress images and use modern formats (WebP, AVIF)

2. **Server Response Time**
   - Minimize TTFB (Time to First Byte)
   - Use edge caching and CDN
   - Optimize database queries
   - Implement server-side caching

3. **Render-Blocking Resources**
   - Defer non-critical CSS and JavaScript
   - Inline critical CSS
   - Use `async` or `defer` for scripts
   - Minimize CSS and JavaScript

### INP Optimization
1. **Break Up Long Tasks**
   - Split tasks > 50ms into smaller chunks
   - Use `setTimeout` or `requestIdleCallback`
   - Implement code splitting
   - Defer non-critical work

2. **Optimize Event Handlers**
   - Debounce and throttle input handlers
   - Use passive event listeners
   - Minimize DOM manipulation
   - Use efficient selectors

3. **JavaScript Execution**
   - Reduce JavaScript bundle size
   - Remove unused code
   - Use web workers for heavy computation
   - Implement lazy loading

### CLS Prevention
1. **Size Attributes**
   - Always include `width` and `height` on images and videos
   - Reserve space for ads and embeds
   - Use aspect-ratio CSS property

2. **Dynamic Content**
   - Reserve space before loading
   - Avoid inserting content above existing content
   - Use CSS transforms instead of layout properties
   - Implement skeleton screens

3. **Font Loading**
   - Use `font-display: swap` or `optional`
   - Preload critical fonts
   - Match fallback font metrics
   - Use variable fonts when possible

### Monitoring Best Practices
1. **Real User Monitoring**
   - Collect field data from actual users
   - Sample appropriately for scale
   - Track across different devices and networks
   - Monitor key user journeys

2. **Synthetic Testing**
   - Regular lab testing with Lighthouse
   - Test on multiple devices and connections
   - Automate performance testing in CI/CD
   - Track performance over time

3. **Reporting and Alerts**
   - Set up automated alerts for regressions
   - Create performance dashboards
   - Track 75th percentile (p75) values
   - Monitor by device type and geography

## Production Configuration

### Web Vitals Setup
```javascript
// web-vitals-config.js
import { onCLS, onINP, onLCP, onFCP, onTTFB } from 'web-vitals';

// Production configuration
const config = {
  reportAllChanges: false,  // Only report final values in production
  durationThreshold: 0,     // Report all durations
};

// Reporting function
function sendToAnalytics(metric) {
  const body = JSON.stringify({
    name: metric.name,
    value: metric.value,
    rating: metric.rating,
    delta: metric.delta,
    id: metric.id,
    navigationType: metric.navigationType,
  });

  // Use `navigator.sendBeacon()` for reliability
  if (navigator.sendBeacon) {
    navigator.sendBeacon('/analytics', body);
  } else {
    fetch('/analytics', { body, method: 'POST', keepalive: true });
  }
}

// Initialize monitoring
export function initWebVitals() {
  onCLS(sendToAnalytics, config);
  onINP(sendToAnalytics, config);
  onLCP(sendToAnalytics, config);
  onFCP(sendToAnalytics, config);
  onTTFB(sendToAnalytics, config);
}
```

### Custom Thresholds
```javascript
// custom-thresholds.js
export const CUSTOM_THRESHOLDS = {
  LCP: {
    good: 2000,        // More strict than default 2500
    poor: 3500,        // More strict than default 4000
  },
  INP: {
    good: 150,         // More strict than default 200
    poor: 400,         // More strict than default 500
  },
  CLS: {
    good: 0.08,        // More strict than default 0.1
    poor: 0.2,         // More strict than default 0.25
  },
};

export function evaluateMetric(metricName, value) {
  const thresholds = CUSTOM_THRESHOLDS[metricName];
  if (value <= thresholds.good) return 'good';
  if (value <= thresholds.poor) return 'needs-improvement';
  return 'poor';
}
```

### Attribution and Debugging
```javascript
// attribution.js
import { onLCP, onINP, onCLS } from 'web-vitals/attribution';

// Get detailed debug information
onLCP((metric) => {
  console.log('LCP Debug Info:', {
    element: metric.attribution.element,
    url: metric.attribution.url,
    renderTime: metric.attribution.renderTime,
    loadTime: metric.attribution.loadTime,
  });
}, { reportAllChanges: true });

onINP((metric) => {
  console.log('INP Debug Info:', {
    interactionType: metric.attribution.interactionType,
    interactionTarget: metric.attribution.interactionTarget,
    longAnimationFrameEntries: metric.attribution.longAnimationFrameEntries,
  });
});

onCLS((metric) => {
  console.log('CLS Debug Info:', {
    largestShiftTarget: metric.attribution.largestShiftTarget,
    largestShiftValue: metric.attribution.largestShiftValue,
    largestShiftTime: metric.attribution.largestShiftTime,
  });
});
```

## Scripts

See `scripts/README.md` for available tools:
- `measure-vitals.js` - Measure Core Web Vitals
- `generate-report.js` - Generate performance report
- `compare-metrics.js` - Compare before/after metrics
- `monitor-vitals.js` - Continuous monitoring script

## References

- See `references/GUIDE.md` for optimization techniques
- See `references/PATTERNS.md` for real-world patterns
- See `references/EXAMPLES.md` for implementation examples

## Resources

### Official Documentation
- [Web Vitals](https://web.dev/vitals/) - Official Google guide
- [web-vitals library](https://github.com/GoogleChrome/web-vitals) - Official JavaScript library
- [Lighthouse Performance Audits](https://developers.google.com/web/tools/lighthouse) - Automated testing

### Tools
- [PageSpeed Insights](https://pagespeed.web.dev/) - Field and lab data
- [Chrome UX Report](https://developers.google.com/web/tools/chrome-user-experience-report) - Real user data
- [Web Vitals Extension](https://chrome.google.com/webstore/detail/web-vitals/ahfhijdlegdabablpippeagghigmibma) - Chrome extension

### Learning Resources
- [Optimize LCP](https://web.dev/optimize-lcp/) - LCP optimization guide
- [Optimize INP](https://web.dev/optimize-inp/) - INP optimization guide
- [Optimize CLS](https://web.dev/optimize-cls/) - CLS optimization guide

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
