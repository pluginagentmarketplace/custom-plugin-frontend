---
name: web-vitals-lighthouse
description: Master Core Web Vitals (LCP, INP, CLS) and Lighthouse for measuring and optimizing user experience.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: performance
bond_type: PRIMARY_BOND
status: production
category: performance
tags:
  - web-vitals
  - lighthouse
  - performance-testing
  - user-experience
  - automated-auditing
complexity: intermediate
estimated_time: 50-70min
prerequisites:
  - Understanding of web performance metrics
  - Chrome DevTools familiarity
  - Basic JavaScript knowledge
related_skills:
  - core-web-vitals
  - devtools-profiling
  - browser-devtools
production_config:
  lighthouse_ci: true
  audit_frequency: daily
  performance_budget:
    performance: 90
    accessibility: 90
    best_practices: 90
    seo: 90
  thresholds:
    lcp: 2500
    inp: 200
    cls: 0.1
    fcp: 1800
    ttfb: 600
---

# Web Vitals & Lighthouse

User experience metrics and automated auditing for optimal web performance.

## Input Schema

```yaml
context:
  url: string                   # URL to audit
  environment: string           # production, staging, development
  audit_type: string            # desktop, mobile, both
  categories: array             # [performance, accessibility, best-practices, seo, pwa]
  throttling: object            # Network and CPU throttling settings

config:
  lighthouse_config:
    extends: string             # lighthouse:default
    settings:
      formFactor: string        # mobile, desktop
      throttling:
        rttMs: number
        throughputKbps: number
        cpuSlowdownMultiplier: number
      screenEmulation:
        mobile: boolean
        width: number
        height: number
      emulatedUserAgent: string

  web_vitals_config:
    report_all_changes: boolean
    duration_threshold: number
    custom_thresholds: object

options:
  run_multiple_times: number    # Number of audit runs for average
  collect_field_data: boolean   # Collect real user data
  compare_to_baseline: boolean  # Compare against baseline
  generate_report: boolean      # Generate HTML/JSON report
```

## Output Schema

```yaml
lighthouse_results:
  scores:
    performance: number         # 0-100
    accessibility: number       # 0-100
    best_practices: number      # 0-100
    seo: number                 # 0-100
    pwa: number                 # 0-100

  metrics:
    first_contentful_paint: number
    largest_contentful_paint: number
    total_blocking_time: number
    cumulative_layout_shift: number
    speed_index: number
    time_to_interactive: number

  opportunities:
    - id: string
      title: string
      description: string
      score: number
      savings_ms: number

  diagnostics:
    - id: string
      title: string
      description: string
      details: object

web_vitals_results:
  lcp:
    value: number
    rating: string              # good, needs-improvement, poor
    element: string
  inp:
    value: number
    rating: string
    interaction_type: string
  cls:
    value: number
    rating: string
    shift_sources: array
  fcp:
    value: number
    rating: string
  ttfb:
    value: number
    rating: string

analysis:
  passing_audits: array
  failing_audits: array
  warnings: array
  critical_issues: array
  recommendations: array
  budget_status: object

report:
  html_path: string
  json_path: string
  summary: string
  next_steps: array
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| LH-001 | Lighthouse not installed | Missing lighthouse package | Install: `npm install -g lighthouse` |
| LH-002 | Invalid URL format | Malformed or unreachable URL | Verify URL is accessible and properly formatted |
| LH-003 | Audit timeout | Page load exceeds timeout limit | Increase timeout or optimize page load time |
| LH-004 | Chrome not found | Chrome/Chromium not installed | Install Chrome or set CHROME_PATH environment variable |
| LH-005 | Invalid configuration | Malformed lighthouse config | Verify config JSON structure and values |
| LH-006 | Network error | Connection issues during audit | Check network connectivity and firewall settings |
| LH-007 | Performance budget exceeded | Metrics exceed defined budgets | Review failing metrics and optimize |
| LH-008 | Page crash during audit | JavaScript errors or memory issues | Debug JavaScript errors and memory leaks |
| WV-001 | Web Vitals library error | Missing or incompatible version | Install/update: `npm install web-vitals@latest` |
| WV-002 | Metric collection timeout | Metric not available within timeout | Extend timeout or check metric availability |
| WV-003 | Invalid metric value | Unexpected or null metric value | Verify page is fully loaded and interactive |

## MANDATORY

### Core Web Vitals
- **LCP (Largest Contentful Paint)**: Main content load time
  - Target: < 2.5s
  - Identify LCP element
  - Optimize resource delivery

- **INP (Interaction to Next Paint)**: Responsiveness to user input
  - Target: < 200ms
  - Monitor all interactions
  - Optimize event handlers

- **CLS (Cumulative Layout Shift)**: Visual stability
  - Target: < 0.1
  - Track layout shift sources
  - Reserve space for dynamic content

### Lighthouse Fundamentals
- Running Lighthouse audits (CLI, DevTools, CI)
- Understanding scoring categories
- Performance budgets setup
- Metrics interpretation
- Chrome DevTools integration
- Report generation and analysis

## OPTIONAL

### Advanced Metrics
- Field data vs lab data comparison
- Real User Monitoring (RUM) integration
- Web Vitals library implementation
- PageSpeed Insights integration
- Performance API utilization
- Custom metric thresholds
- Historical trend tracking

### Enhanced Auditing
- Custom audit configurations
- Multiple device/network profiles
- Competitive benchmarking
- Progressive Web App (PWA) audits
- Accessibility testing
- SEO optimization

## ADVANCED

### Enterprise Features
- Custom metrics definition
- Continuous monitoring setup
- A/B testing performance impact
- Third-party impact analysis
- Performance regression detection
- Enterprise monitoring solutions
- Automated alerting systems
- Multi-region testing

### Advanced Integrations
- Lighthouse CI/CD integration
- Custom plugin development
- Performance API monitoring
- Real-time dashboards
- Machine learning-based insights
- Predictive performance modeling

## Test Templates

### Lighthouse CLI Tests
```javascript
// lighthouse-test.js
const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');

async function runLighthouseAudit(url, options = {}) {
  const chrome = await chromeLauncher.launch({
    chromeFlags: ['--headless']
  });

  const config = {
    extends: 'lighthouse:default',
    settings: {
      formFactor: options.formFactor || 'mobile',
      throttling: {
        rttMs: 40,
        throughputKbps: 10240,
        cpuSlowdownMultiplier: 1,
      },
      screenEmulation: {
        mobile: options.formFactor === 'mobile',
        width: 412,
        height: 823,
      },
    },
  };

  const runnerResult = await lighthouse(url, {
    port: chrome.port,
    output: 'json',
  }, config);

  await chrome.kill();

  return runnerResult.lhr;
}

// Test suite
describe('Lighthouse Performance Audits', () => {
  test('should meet performance budget', async () => {
    const result = await runLighthouseAudit('https://example.com');
    expect(result.categories.performance.score).toBeGreaterThanOrEqual(0.9);
  });

  test('LCP should be under 2.5s', async () => {
    const result = await runLighthouseAudit('https://example.com');
    const lcp = result.audits['largest-contentful-paint'].numericValue;
    expect(lcp).toBeLessThan(2500);
  });

  test('should have no critical accessibility issues', async () => {
    const result = await runLighthouseAudit('https://example.com');
    expect(result.categories.accessibility.score).toBeGreaterThanOrEqual(0.9);
  });
});
```

### Web Vitals Integration Tests
```javascript
// web-vitals-test.js
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

describe('Web Vitals Monitoring', () => {
  test('should collect all core web vitals', async () => {
    const metrics = {};

    const collectMetric = (metric) => {
      metrics[metric.name] = metric.value;
    };

    onLCP(collectMetric);
    onINP(collectMetric);
    onCLS(collectMetric);
    onFCP(collectMetric);
    onTTFB(collectMetric);

    // Simulate page load
    await new Promise(resolve => setTimeout(resolve, 3000));

    expect(metrics).toHaveProperty('LCP');
    expect(metrics).toHaveProperty('CLS');
    expect(metrics).toHaveProperty('FCP');
    expect(metrics).toHaveProperty('TTFB');
  });

  test('should rate metrics correctly', () => {
    const ratings = {
      LCP: getRating('LCP', 2000),
      INP: getRating('INP', 150),
      CLS: getRating('CLS', 0.05),
    };

    expect(ratings.LCP).toBe('good');
    expect(ratings.INP).toBe('good');
    expect(ratings.CLS).toBe('good');
  });
});
```

### Performance Budget Tests
```javascript
// budget-test.js
describe('Performance Budgets', () => {
  const budgets = {
    performance: 90,
    lcp: 2500,
    inp: 200,
    cls: 0.1,
    fcp: 1800,
    ttfb: 600,
  };

  test('should meet all performance budgets', async () => {
    const metrics = await measureAllMetrics();

    expect(metrics.lcp).toBeLessThan(budgets.lcp);
    expect(metrics.inp).toBeLessThan(budgets.inp);
    expect(metrics.cls).toBeLessThan(budgets.cls);
    expect(metrics.fcp).toBeLessThan(budgets.fcp);
    expect(metrics.ttfb).toBeLessThan(budgets.ttfb);
  });

  test('should alert on budget violations', () => {
    const violations = checkBudgetViolations(metrics, budgets);
    expect(violations).toHaveLength(0);
  });
});
```

## Best Practices

### Running Lighthouse Audits

1. **CLI Usage**
   ```bash
   # Basic audit
   lighthouse https://example.com --view

   # Mobile audit with output
   lighthouse https://example.com \
     --preset=desktop \
     --output=json \
     --output=html \
     --output-path=./reports/lighthouse-report

   # Custom configuration
   lighthouse https://example.com \
     --config-path=./lighthouse-config.js \
     --chrome-flags="--headless"
   ```

2. **DevTools Integration**
   - Open Chrome DevTools (F12)
   - Navigate to Lighthouse tab
   - Select categories and device type
   - Click "Analyze page load"
   - Review opportunities and diagnostics

3. **Programmatic Usage**
   ```javascript
   const lighthouse = require('lighthouse');
   const chromeLauncher = require('chrome-launcher');

   async function runAudit() {
     const chrome = await chromeLauncher.launch();
     const result = await lighthouse('https://example.com', {
       port: chrome.port,
     });
     await chrome.kill();
     return result;
   }
   ```

### Web Vitals Implementation

1. **Basic Setup**
   ```javascript
   import { onCLS, onINP, onLCP } from 'web-vitals';

   function sendToAnalytics(metric) {
     const body = JSON.stringify(metric);
     navigator.sendBeacon('/analytics', body);
   }

   onCLS(sendToAnalytics);
   onINP(sendToAnalytics);
   onLCP(sendToAnalytics);
   ```

2. **Attribution and Debugging**
   ```javascript
   import { onLCP } from 'web-vitals/attribution';

   onLCP((metric) => {
     console.log('LCP element:', metric.attribution.element);
     console.log('LCP render time:', metric.attribution.renderTime);
     console.log('LCP load time:', metric.attribution.loadTime);
   });
   ```

3. **Custom Thresholds**
   ```javascript
   const THRESHOLDS = {
     LCP: { good: 2000, poor: 3500 },
     INP: { good: 150, poor: 400 },
     CLS: { good: 0.08, poor: 0.2 },
   };

   function evaluateMetric(name, value) {
     const threshold = THRESHOLDS[name];
     if (value <= threshold.good) return 'good';
     if (value <= threshold.poor) return 'needs-improvement';
     return 'poor';
   }
   ```

### Performance Budgets

1. **Define Budgets**
   ```javascript
   // budget.json
   {
     "budgets": [
       {
         "resourceSizes": [
           { "resourceType": "script", "budget": 300 },
           { "resourceType": "image", "budget": 500 },
           { "resourceType": "stylesheet", "budget": 100 }
         ],
         "resourceCounts": [
           { "resourceType": "third-party", "budget": 10 }
         ],
         "timings": [
           { "metric": "interactive", "budget": 3000 },
           { "metric": "first-contentful-paint", "budget": 1800 }
         ]
       }
     ]
   }
   ```

2. **Enforce in CI/CD**
   ```yaml
   # .github/workflows/performance.yml
   name: Performance Budget
   on: [pull_request]
   jobs:
     lighthouse:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v2
         - name: Run Lighthouse CI
           uses: treosh/lighthouse-ci-action@v8
           with:
             urls: |
               https://example.com
             budgetPath: ./budget.json
             uploadArtifacts: true
   ```

### Field vs Lab Data

1. **Lab Data (Lighthouse)**
   - Controlled environment
   - Consistent network conditions
   - Predictable results
   - Good for development and QA

2. **Field Data (Real Users)**
   - Real-world conditions
   - Varied networks and devices
   - Actual user experience
   - Good for production monitoring

3. **Combined Approach**
   ```javascript
   // Collect both lab and field data
   async function comprehensiveAudit(url) {
     // Lab data
     const labData = await runLighthouse(url);

     // Field data from CrUX
     const fieldData = await fetchCruxData(url);

     return {
       lab: labData,
       field: fieldData,
       comparison: compareResults(labData, fieldData)
     };
   }
   ```

## Production Configuration

### Lighthouse CI Configuration
```javascript
// lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: ['https://example.com'],
      numberOfRuns: 3,
      settings: {
        preset: 'desktop',
        throttling: {
          rttMs: 40,
          throughputKbps: 10240,
          cpuSlowdownMultiplier: 1,
        },
      },
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['warn', { minScore: 0.9 }],
        'first-contentful-paint': ['error', { maxNumericValue: 1800 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
      },
    },
    upload: {
      target: 'lhci',
      serverBaseUrl: 'https://lhci.example.com',
      token: process.env.LHCI_TOKEN,
    },
  },
};
```

### Web Vitals Production Setup
```javascript
// web-vitals-production.js
import { onCLS, onINP, onLCP, onFCP, onTTFB } from 'web-vitals';

const ANALYTICS_ENDPOINT = '/api/analytics';
const SAMPLE_RATE = 0.1; // 10% sampling

function shouldSample() {
  return Math.random() < SAMPLE_RATE;
}

function sendToAnalytics(metric) {
  if (!shouldSample()) return;

  const payload = {
    name: metric.name,
    value: metric.value,
    rating: metric.rating,
    delta: metric.delta,
    id: metric.id,
    navigationType: metric.navigationType,
    url: window.location.href,
    userAgent: navigator.userAgent,
    timestamp: Date.now(),
  };

  if (navigator.sendBeacon) {
    navigator.sendBeacon(ANALYTICS_ENDPOINT, JSON.stringify(payload));
  } else {
    fetch(ANALYTICS_ENDPOINT, {
      method: 'POST',
      body: JSON.stringify(payload),
      headers: { 'Content-Type': 'application/json' },
      keepalive: true,
    }).catch(console.error);
  }
}

// Initialize monitoring
export function initWebVitalsMonitoring() {
  try {
    onCLS(sendToAnalytics);
    onINP(sendToAnalytics);
    onLCP(sendToAnalytics);
    onFCP(sendToAnalytics);
    onTTFB(sendToAnalytics);
  } catch (error) {
    console.error('Failed to initialize Web Vitals monitoring:', error);
  }
}
```

### Custom Lighthouse Config
```javascript
// custom-lighthouse-config.js
module.exports = {
  extends: 'lighthouse:default',
  settings: {
    onlyCategories: ['performance', 'accessibility', 'best-practices'],
    skipAudits: ['uses-http2'],
    throttling: {
      rttMs: 40,
      throughputKbps: 10240,
      requestLatencyMs: 0,
      downloadThroughputKbps: 0,
      uploadThroughputKbps: 0,
      cpuSlowdownMultiplier: 1,
    },
    screenEmulation: {
      mobile: true,
      width: 412,
      height: 823,
      deviceScaleFactor: 2.625,
      disabled: false,
    },
    emulatedUserAgent: 'Mozilla/5.0 (Linux; Android 11; moto g power (2022)) AppleWebKit/537.36',
  },
  audits: [
    { path: 'lighthouse/audits/metrics/first-contentful-paint.js' },
    { path: 'lighthouse/audits/metrics/largest-contentful-paint.js' },
  ],
};
```

## Assets

See `assets/web-vitals-config.yaml` for monitoring patterns and configuration examples.

## Resources

### Official Documentation
- [Web Vitals Guide](https://web.dev/vitals/) - Complete Web Vitals documentation
- [Lighthouse Documentation](https://developers.google.com/web/tools/lighthouse) - Lighthouse official docs
- [PageSpeed Insights](https://pagespeed.web.dev/) - Online auditing tool

### Tools
- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) - Continuous integration
- [Web Vitals Extension](https://chrome.google.com/webstore/detail/web-vitals) - Chrome extension
- [Chrome UX Report](https://developers.google.com/web/tools/chrome-user-experience-report) - Field data

### Learning Resources
- [Lighthouse Performance Scoring](https://web.dev/performance-scoring/) - Understanding scores
- [Web Vitals Patterns](https://web.dev/patterns/web-vitals-patterns/) - Implementation patterns
- [Field vs Lab Data](https://web.dev/lab-and-field-data-differences/) - Data comparison guide

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
