# Core Web Vitals References

Complete technical documentation for understanding and optimizing Core Web Vitals metrics.

## Available References

### GUIDE.md
**Comprehensive Technical Guide** - 600+ words

In-depth explanation of each Core Web Vitals metric:
- **Largest Contentful Paint (LCP)** - Definition, measurement, optimization techniques
- **Interaction to Next Paint (INP) / First Input Delay (FID)** - Evolution from FID to INP, technical measurement
- **Cumulative Layout Shift (CLS)** - Prevention strategies and measurement
- **Measuring Core Web Vitals** - Using web-vitals library, Lighthouse, Real User Monitoring
- **Performance Budget Framework** - Setting realistic budgets and enforcing them in CI/CD

### PATTERNS.md
**Real-World Implementation Patterns** - 600+ words

Production-quality patterns for implementing Core Web Vitals optimization:
- **LCP Optimization Patterns**
  - Critical Resource Prioritization Pipeline
  - Adaptive Font Loading Strategy
  - Server-Side Rendering Optimization
- **INP/FID Optimization Patterns**
  - Event Handler Optimization Framework
  - JavaScript Task Chunking
- **CLS Prevention Patterns**
  - Dynamic Content Container Manager
  - Layout Shift Detection and Monitoring
- **Performance Monitoring Patterns**
  - Comprehensive Metrics Dashboard

## Key Concepts

### Core Web Vitals Metrics

| Metric | Definition | Good | Needs Improvement | Poor |
|--------|-----------|------|-------------------|------|
| **LCP** | Time until largest element renders | ≤2.5s | >2.5s, ≤4s | >4s |
| **INP** | Longest interaction latency | ≤200ms | >200ms, ≤500ms | >500ms |
| **CLS** | Sum of layout shift scores | ≤0.1 | >0.1, ≤0.25 | >0.25 |

### Measurement Tools

- **web-vitals Library** - Official Google library for accurate measurements
- **Lighthouse** - Chrome DevTools for performance audits
- **Real User Monitoring (RUM)** - Collect metrics from real users
- **Synthetic Monitoring** - Automated testing at regular intervals

### Optimization Principles

1. **LCP**: Optimize for fast content rendering through resource prioritization
2. **INP**: Minimize JavaScript blocking through task chunking and optimization
3. **CLS**: Reserve space for dynamic content to prevent visual instability

## Implementation Resources

### Scripts
- `validate-vitals.sh` - Comprehensive validation of Web Vitals implementation
- `generate-vitals-tracker.sh` - Production-ready tracker with thresholds and reporting

### Integration Guides
- Google Analytics 4 integration
- Datadog monitoring integration
- New Relic integration
- Custom backend reporting

## Best Practices Summary

1. **Measure First** - Understand current performance before optimizing
2. **Prioritize Resources** - Load critical resources early
3. **Optimize for Real Users** - Monitor RUM data, not just synthetic tests
4. **Set Budgets** - Define and enforce performance budgets in CI/CD
5. **Iterate** - Track trends over time and improve progressively

## Related Skills
- asset-optimization - Image optimization for better LCP
- devtools-profiling - Browser DevTools for performance analysis
- code-splitting-bundling - Reduce JavaScript for better INP
