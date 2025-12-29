#!/bin/bash

################################################################################
# generate-vitals-tracker.sh
# REAL script to generate web-vitals integration with logging, thresholds, reporting
################################################################################

set -e

OUTPUT_DIR="${1:-.}"
FILENAME="${2:-vitals-tracker.ts}"

echo "Generating Core Web Vitals tracker..."

cat > "${OUTPUT_DIR}/${FILENAME}" << 'VITALS_EOF'
/**
 * Core Web Vitals Tracker
 * Comprehensive measurement and reporting of LCP, FID/INP, CLS metrics
 * Integration with web-vitals library and custom thresholds
 */

import { getCLS, getFCP, getFID, getLCP, getTTFB, onCLS, onFCP, onFID, onLCP, onTTFB } from 'web-vitals';

/**
 * Performance thresholds aligned with Google's Core Web Vitals standards
 * Good: Target optimal user experience
 * NeedImprovement: Acceptable but should be optimized
 * Poor: Below standard, immediate action needed
 */
interface PerformanceThresholds {
  lcp: { good: number; needsImprovement: number }; // milliseconds
  inp: { good: number; needsImprovement: number }; // milliseconds (replaces FID)
  fid: { good: number; needsImprovement: number }; // milliseconds (legacy)
  cls: { good: number; needsImprovement: number }; // unitless score
  ttfb: { good: number; needsImprovement: number }; // milliseconds
}

/**
 * Standard thresholds as of 2024
 * LCP: <2.5s good, <4s needs improvement
 * INP: <200ms good, <500ms needs improvement
 * FID: <100ms good, <300ms needs improvement
 * CLS: <0.1 good, <0.25 needs improvement
 * TTFB: <800ms good, <1800ms needs improvement
 */
const THRESHOLDS: PerformanceThresholds = {
  lcp: { good: 2500, needsImprovement: 4000 },
  inp: { good: 200, needsImprovement: 500 },
  fid: { good: 100, needsImprovement: 300 },
  cls: { good: 0.1, needsImprovement: 0.25 },
  ttfb: { good: 800, needsImprovement: 1800 },
};

/**
 * Metric report with status classification
 */
interface MetricReport {
  name: string;
  value: number;
  rating: 'good' | 'needs-improvement' | 'poor';
  threshold: number;
  timestamp: number;
  url: string;
  userAgent: string;
  delta?: number;
  id?: string;
  entries?: PerformanceEntryList;
}

/**
 * Classify metric value against thresholds
 */
function classifyMetric(
  metricName: string,
  value: number,
  thresholds: PerformanceThresholds
): 'good' | 'needs-improvement' | 'poor' {
  const key = metricName.toLowerCase() as keyof PerformanceThresholds;
  const metric = thresholds[key];

  if (!metric) return 'poor';

  if (value <= metric.good) {
    return 'good';
  } else if (value <= metric.needsImprovement) {
    return 'needs-improvement';
  } else {
    return 'poor';
  }
}

/**
 * Create detailed metric report
 */
function createReport(metricName: string, value: number, metric?: any): MetricReport {
  const threshold = THRESHOLDS[metricName.toLowerCase() as keyof PerformanceThresholds]?.good || 0;

  return {
    name: metricName,
    value,
    rating: classifyMetric(metricName, value, THRESHOLDS),
    threshold,
    timestamp: Date.now(),
    url: typeof window !== 'undefined' ? window.location.href : '',
    userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : '',
    delta: metric?.delta,
    id: metric?.id,
    entries: metric?.entries,
  };
}

/**
 * Logger interface for custom reporting
 */
interface VitalsLogger {
  debug?: (report: MetricReport) => void;
  info?: (report: MetricReport) => void;
  warn?: (report: MetricReport) => void;
  error?: (report: MetricReport) => void;
  report?: (reports: MetricReport[]) => void;
}

/**
 * Default console logger
 */
const defaultLogger: VitalsLogger = {
  debug: (report) => {
    console.debug(`[Web Vitals] ${report.name}:`, {
      value: `${report.value.toFixed(2)}ms`,
      rating: report.rating,
      threshold: `${report.threshold}ms`,
    });
  },
  info: (report) => {
    const icon = report.rating === 'good' ? '✓' : report.rating === 'needs-improvement' ? '⚠' : '✗';
    console.info(`${icon} [Web Vitals] ${report.name}: ${report.value.toFixed(2)}ms (${report.rating})`);
  },
  warn: (report) => {
    console.warn(`[Web Vitals] ${report.name} needs improvement: ${report.value.toFixed(2)}ms`, {
      threshold: report.threshold,
      gap: (report.value - report.threshold).toFixed(2),
    });
  },
  error: (report) => {
    console.error(`[Web Vitals] ${report.name} is poor: ${report.value.toFixed(2)}ms`, {
      threshold: report.threshold,
      exceedance: (report.value - report.threshold).toFixed(2),
    });
  },
  report: (reports) => {
    console.table(
      reports.map((r) => ({
        Metric: r.name,
        Value: `${r.value.toFixed(2)}ms`,
        Rating: r.rating,
        Threshold: `${r.threshold}ms`,
      }))
    );
  },
};

/**
 * Reporter for sending metrics to analytics service
 */
interface VitalsReporter {
  endpoint?: string;
  batch?: boolean;
  batchSize?: number;
  batchTimeout?: number;
  headers?: Record<string, string>;
}

class VitalsReporterService {
  private reports: MetricReport[] = [];
  private batchTimer: NodeJS.Timeout | null = null;
  private config: VitalsReporter;

  constructor(config: VitalsReporter = {}) {
    this.config = {
      batch: true,
      batchSize: 5,
      batchTimeout: 10000,
      ...config,
    };
  }

  /**
   * Queue metric for reporting
   */
  async report(metricReport: MetricReport): Promise<void> {
    this.reports.push(metricReport);

    if (this.config.batch) {
      if (this.reports.length >= (this.config.batchSize || 5)) {
        await this.flush();
      } else if (!this.batchTimer) {
        this.batchTimer = setTimeout(() => this.flush(), this.config.batchTimeout || 10000);
      }
    } else {
      await this.send([metricReport]);
    }
  }

  /**
   * Send reports to endpoint
   */
  private async send(reports: MetricReport[]): Promise<void> {
    if (!this.config.endpoint) return;

    try {
      // Use sendBeacon for better delivery reliability
      if (navigator.sendBeacon && JSON.stringify(reports).length < 64000) {
        const blob = new Blob([JSON.stringify(reports)], { type: 'application/json' });
        navigator.sendBeacon(this.config.endpoint, blob);
      } else {
        // Fallback to fetch with no-cors
        await fetch(this.config.endpoint, {
          method: 'POST',
          body: JSON.stringify(reports),
          headers: {
            'Content-Type': 'application/json',
            ...this.config.headers,
          },
          keepalive: true,
        }).catch(() => {
          // Fail silently to not impact application
        });
      }
    } catch (error) {
      console.warn('[Web Vitals] Failed to send metrics:', error);
    }
  }

  /**
   * Flush remaining reports
   */
  async flush(): Promise<void> {
    if (this.reports.length === 0) return;

    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = null;
    }

    const toSend = [...this.reports];
    this.reports = [];

    await this.send(toSend);
  }
}

/**
 * Main Web Vitals Tracker
 */
class WebVitalsTracker {
  private logger: VitalsLogger;
  private reporter: VitalsReporterService;
  private reports: Map<string, MetricReport> = new Map();

  constructor(
    logger: VitalsLogger = defaultLogger,
    reporterConfig?: VitalsReporter
  ) {
    this.logger = logger;
    this.reporter = new VitalsReporterService(reporterConfig);
    this.initialize();
  }

  /**
   * Initialize all metric observers
   */
  private initialize(): void {
    // Largest Contentful Paint
    onLCP((metric) => this.handleMetric('LCP', metric));

    // First Input Delay (legacy)
    onFID((metric) => this.handleMetric('FID', metric));

    // Cumulative Layout Shift
    onCLS((metric) => this.handleMetric('CLS', metric));

    // First Contentful Paint
    onFCP((metric) => this.handleMetric('FCP', metric));

    // Time to First Byte
    onTTFB((metric) => this.handleMetric('TTFB', metric));
  }

  /**
   * Handle individual metric
   */
  private async handleMetric(name: string, metric: any): Promise<void> {
    const report = createReport(name, metric.value || metric.delta, metric);
    this.reports.set(name, report);

    // Log based on rating
    if (report.rating === 'good') {
      this.logger.debug?.(report);
    } else if (report.rating === 'needs-improvement') {
      this.logger.warn?.(report);
    } else {
      this.logger.error?.(report);
    }

    // Report to backend
    await this.reporter.report(report);
  }

  /**
   * Get all collected reports
   */
  getReports(): MetricReport[] {
    return Array.from(this.reports.values());
  }

  /**
   * Get specific metric report
   */
  getReport(metricName: string): MetricReport | undefined {
    return this.reports.get(metricName);
  }

  /**
   * Print summary table
   */
  printSummary(): void {
    const reports = this.getReports();
    this.logger.report?.(reports);
  }

  /**
   * Flush any pending reports
   */
  async flush(): Promise<void> {
    await this.reporter.flush();
  }

  /**
   * Update thresholds dynamically
   */
  updateThresholds(updates: Partial<PerformanceThresholds>): void {
    Object.assign(THRESHOLDS, updates);
  }
}

/**
 * Initialize Web Vitals tracking
 * @param loggerConfig - Custom logger configuration
 * @param reporterConfig - Reporter endpoint and options
 * @returns Tracker instance
 */
export function initWebVitalsTracking(
  loggerConfig?: VitalsLogger,
  reporterConfig?: VitalsReporter
): WebVitalsTracker {
  return new WebVitalsTracker(loggerConfig || defaultLogger, reporterConfig);
}

/**
 * Convenience function for React
 */
export function reportWebVitals(
  onMetric?: (metric: MetricReport) => void
): WebVitalsTracker {
  const tracker = new WebVitalsTracker();

  if (onMetric) {
    const reports = tracker.getReports();
    reports.forEach(onMetric);
  }

  return tracker;
}

export {
  WebVitalsTracker,
  VitalsReporterService,
  MetricReport,
  PerformanceThresholds,
  VitalsLogger,
  VitalsReporter,
  THRESHOLDS,
  classifyMetric,
  createReport,
};

VITALS_EOF

echo "✓ Generated: ${OUTPUT_DIR}/${FILENAME}"
echo ""
echo "Usage in your application:"
echo "  import { initWebVitalsTracking } from './vitals-tracker';"
echo "  const tracker = initWebVitalsTracking();"
echo ""
echo "With custom reporting:"
echo "  const tracker = initWebVitalsTracking(undefined, {"
echo "    endpoint: '/api/metrics',"
echo "    batch: true,"
echo "  });"
echo ""
echo "View metrics:"
echo "  tracker.printSummary();"
echo "  const reports = tracker.getReports();"
