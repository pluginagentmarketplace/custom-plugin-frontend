# Core Web Vitals Scripts

Production-quality scripts for validating and implementing Core Web Vitals measurement and optimization.

## Available Scripts

### validate-vitals.sh
Real validation checking Core Web Vitals implementation in your project.

**Usage:**
```bash
./validate-vitals.sh [project-root]
```

**Checks:**
- LCP (Largest Contentful Paint) implementation
- FID/INP (First Input Delay / Interaction to Next Paint)
- CLS (Cumulative Layout Shift) prevention
- web-vitals library installation
- Lighthouse configuration
- Performance budget definition
- Measurement endpoints
- Thresholds definition
- Reporting setup
- Monitoring integration

**Output:**
- Console report with pass/fail/warn status
- JSON results file (`.vitals-validation.json`)
- Quality score (0-100%)

**Example:**
```bash
$ ./validate-vitals.sh ~/my-project

[1/10] Checking Largest Contentful Paint (LCP) implementation...
✓ PASS LCP implementation detected

[2/10] Checking First Input Delay (FID) / Interaction to Next Paint (INP)...
! WARN Limited FID/INP optimization found

...

Score: 75%
Results saved to: .vitals-validation.json
```

### generate-vitals-tracker.sh
Generate production-ready Web Vitals tracker with logging, thresholds, and reporting.

**Usage:**
```bash
./generate-vitals-tracker.sh [output-dir] [filename]
```

**Parameters:**
- `output-dir` - Target directory (default: current)
- `filename` - Output filename (default: vitals-tracker.ts)

**Features:**
- Comprehensive LCP, FID/INP, CLS, FCP, TTFB measurement
- Customizable thresholds aligned with Google standards
- Color-coded console logging (good/needs-improvement/poor)
- Batch reporting to analytics endpoint
- sendBeacon fallback for reliability
- React integration support
- TypeScript types included

**Output File:**
- `vitals-tracker.ts` - Ready-to-import TypeScript module

**Integration Examples:**

**Basic usage:**
```typescript
import { initWebVitalsTracking } from './vitals-tracker';

const tracker = initWebVitalsTracking();
tracker.printSummary();
```

**With custom reporting endpoint:**
```typescript
const tracker = initWebVitalsTracking(undefined, {
  endpoint: '/api/metrics/vitals',
  batch: true,
  batchSize: 5,
  batchTimeout: 10000,
});
```

**With custom logger:**
```typescript
const tracker = initWebVitalsTracking({
  error: (report) => {
    // Send to Sentry, Datadog, etc.
    captureException(new Error(`Web Vitals: ${report.name} failed`));
  },
});
```

**In React app:**
```typescript
// src/index.tsx
import { reportWebVitals } from './vitals-tracker';

ReactDOM.render(<App />, document.getElementById('root'));

// Report vitals to analytics
reportWebVitals((metric) => {
  if (metric.rating !== 'good') {
    console.warn(`${metric.name}: ${metric.value}ms`);
  }
});
```

## Performance Thresholds

Generated tracker includes Google-recommended thresholds:

| Metric | Good | Needs Improvement |
|--------|------|-------------------|
| LCP (ms) | ≤2500 | ≤4000 |
| INP (ms) | ≤200 | ≤500 |
| FID (ms) | ≤100 | ≤300 |
| CLS | ≤0.1 | ≤0.25 |
| TTFB (ms) | ≤800 | ≤1800 |

## Reporting

The generated tracker supports three reporting modes:

### 1. Batched Reporting (Recommended)
```typescript
const tracker = initWebVitalsTracking(undefined, {
  endpoint: '/api/metrics',
  batch: true,
  batchSize: 5,
  batchTimeout: 10000,
});
```
- Collects up to 5 metrics before sending
- Maximum 10 seconds between flushes
- Reduces network overhead

### 2. Real-time Reporting
```typescript
const tracker = initWebVitalsTracking(undefined, {
  endpoint: '/api/metrics',
  batch: false,
});
```
- Sends each metric immediately
- Higher network overhead
- Most current data

### 3. sendBeacon Fallback
- Automatically used for reliability
- Works even on page unload
- No CORS restrictions
- Recommended for production

## Integration with Monitoring Services

The generated tracker can feed metrics to:

**Google Analytics 4:**
```typescript
const tracker = initWebVitalsTracking(undefined, {
  endpoint: 'https://www.google-analytics.com/collect',
  headers: { 'Authorization': 'Bearer ...' }
});
```

**Datadog:**
```typescript
const tracker = initWebVitalsTracking(undefined, {
  endpoint: 'https://http-intake.logs.datadoghq.com/v1/input/',
  headers: { 'DD-API-KEY': 'your-api-key' }
});
```

**New Relic:**
```typescript
const tracker = initWebVitalsTracking(undefined, {
  endpoint: 'https://bam.nr-data.net/events',
  headers: { 'api-key': 'your-api-key' }
});
```

## Best Practices

1. **Initialize Early**: Call `initWebVitalsTracking()` in your app entry point
2. **Use Batching**: Reduce network calls with batch reporting
3. **Set Thresholds**: Customize for your application requirements
4. **Monitor Continuously**: Set up dashboards in your analytics service
5. **Act on Data**: Use results to drive performance optimization

## Troubleshooting

**No metrics being reported:**
- Verify web-vitals library is installed
- Check network tab for failed requests
- Verify endpoint is correct

**Metrics appear incorrect:**
- Clear browser cache and reload
- Check for third-party scripts blocking measurements
- Verify thresholds are set correctly

**Missing INP (Interaction to Next Paint):**
- INP is newer metric, requires latest browsers
- FID still reported for compatibility
- Both can be tracked simultaneously

## References

- See `references/GUIDE.md` for optimization techniques
- See `references/PATTERNS.md` for implementation patterns
