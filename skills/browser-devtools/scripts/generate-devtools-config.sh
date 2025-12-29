#!/bin/bash

################################################################################
# generate-devtools-config.sh
# Generate source maps config, debug utilities, performance helpers
################################################################################

OUTPUT_DIR="${1:-.}"
FILENAME="${2:-devtools-utils.ts}"

echo "Generating DevTools utilities configuration..."

cat > "${OUTPUT_DIR}/${FILENAME}" << 'DEVTOOLS_EOF'
/**
 * Browser DevTools Utilities
 * Source maps, debug logging, performance markers, memory utilities
 */

/**
 * Performance Marker Manager
 * Custom performance.mark/measure helpers
 */
class PerformanceMarker {
  private markers: Map<string, number> = new Map();

  /**
   * Start performance measurement
   */
  static start(name: string): void {
    performance.mark(`${name}-start`);
  }

  /**
   * End performance measurement and get duration
   */
  static end(name: string): number {
    performance.mark(`${name}-end`);
    performance.measure(name, `${name}-start`, `${name}-end`);

    const entries = performance.getEntriesByName(name);
    const lastEntry = entries[entries.length - 1];
    const duration = lastEntry?.duration || 0;

    console.log(`⏱️ ${name}: ${duration.toFixed(2)}ms`);
    return duration;
  }

  /**
   * Get all marks
   */
  static getAll(): PerformanceEntryList {
    return performance.getEntriesByType('measure');
  }

  /**
   * Clear marks
   */
  static clear(name?: string): void {
    if (name) {
      performance.clearMarks(name);
      performance.clearMeasures(name);
    } else {
      performance.clearMarks();
      performance.clearMeasures();
    }
  }
}

/**
 * Debug Logger
 * Structured logging with log levels
 */
enum LogLevel {
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
}

class DebugLogger {
  private context: string;
  private isDevelopment = process.env.NODE_ENV === 'development';

  constructor(context: string) {
    this.context = context;
  }

  debug(message: string, data?: any): void {
    this.log(LogLevel.DEBUG, message, data);
  }

  info(message: string, data?: any): void {
    this.log(LogLevel.INFO, message, data);
  }

  warn(message: string, data?: any): void {
    this.log(LogLevel.WARN, message, data);
  }

  error(message: string, error?: Error | any): void {
    this.log(LogLevel.ERROR, message, error);
  }

  private log(level: LogLevel, message: string, data?: any): void {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      context: this.context,
      level,
      message,
      data,
    };

    const color = this.getColorForLevel(level);
    const style = `color: ${color}; font-weight: bold;`;

    if (this.isDevelopment) {
      console.log(
        `%c[${level}] ${this.context}`,
        style,
        message,
        data || ''
      );
    }

    // Send to backend in production
    if (level === LogLevel.ERROR && !this.isDevelopment) {
      this.reportToBackend(logEntry);
    }
  }

  private getColorForLevel(level: LogLevel): string {
    switch (level) {
      case LogLevel.DEBUG:
        return '#666666';
      case LogLevel.INFO:
        return '#0066CC';
      case LogLevel.WARN:
        return '#FF9900';
      case LogLevel.ERROR:
        return '#CC0000';
    }
  }

  private reportToBackend(logEntry: any): void {
    // Send to error tracking service
    if ('navigator' in globalThis && 'sendBeacon' in navigator) {
      navigator.sendBeacon('/api/logs', JSON.stringify(logEntry));
    }
  }
}

/**
 * Memory Utilities
 * Monitor and detect memory leaks
 */
class MemoryMonitor {
  /**
   * Get current memory usage (Chrome only)
   */
  static getMemoryUsage(): MemoryInfo | null {
    if ((performance as any).memory) {
      const memory = (performance as any).memory;
      return {
        usedJSHeapSize: memory.usedJSHeapSize,
        totalJSHeapSize: memory.totalJSHeapSize,
        jsHeapSizeLimit: memory.jsHeapSizeLimit,
        percentageUsed: (memory.usedJSHeapSize / memory.jsHeapSizeLimit) * 100,
      };
    }
    return null;
  }

  /**
   * Log memory usage
   */
  static logMemoryUsage(): void {
    const memory = this.getMemoryUsage();
    if (memory) {
      console.table({
        'Used (MB)': (memory.usedJSHeapSize / 1024 / 1024).toFixed(2),
        'Total (MB)': (memory.totalJSHeapSize / 1024 / 1024).toFixed(2),
        'Limit (MB)': (memory.jsHeapSizeLimit / 1024 / 1024).toFixed(2),
        'Usage %': memory.percentageUsed.toFixed(2),
      });
    }
  }

  /**
   * Alert if memory usage exceeds threshold
   */
  static watchMemoryUsage(threshold: number = 0.9): () => void {
    const checkMemory = () => {
      const memory = this.getMemoryUsage();
      if (memory && memory.percentageUsed > threshold * 100) {
        console.warn(
          `⚠️ High memory usage: ${memory.percentageUsed.toFixed(2)}%`
        );
      }
    };

    const interval = setInterval(checkMemory, 5000);
    return () => clearInterval(interval);
  }
}

interface MemoryInfo {
  usedJSHeapSize: number;
  totalJSHeapSize: number;
  jsHeapSizeLimit: number;
  percentageUsed: number;
}

/**
 * Network Interceptor
 * Monitor and log network requests
 */
class NetworkInterceptor {
  private requestLog: RequestLog[] = [];
  private maxLogs = 100;

  constructor() {
    this.interceptFetch();
    this.interceptXHR();
  }

  private interceptFetch(): void {
    const originalFetch = window.fetch;

    window.fetch = async (...args: any[]) => {
      const [resource, config] = args;
      const startTime = performance.now();

      try {
        const response = await originalFetch(...args);
        const duration = performance.now() - startTime;

        this.logRequest({
          url: resource.toString(),
          method: config?.method || 'GET',
          status: response.status,
          duration,
          timestamp: new Date(),
        });

        return response;
      } catch (error) {
        const duration = performance.now() - startTime;

        this.logRequest({
          url: resource.toString(),
          method: config?.method || 'GET',
          status: 0,
          error: error instanceof Error ? error.message : String(error),
          duration,
          timestamp: new Date(),
        });

        throw error;
      }
    };
  }

  private interceptXHR(): void {
    const originalOpen = XMLHttpRequest.prototype.open;
    const originalSend = XMLHttpRequest.prototype.send;

    XMLHttpRequest.prototype.open = function (method: string, url: string) {
      this._startTime = performance.now();
      this._method = method;
      this._url = url;
      return originalOpen.apply(this, [method, url]);
    };

    XMLHttpRequest.prototype.send = function () {
      const onReadyStateChange = this.onreadystatechange;

      this.onreadystatechange = function () {
        if (this.readyState === 4) {
          const duration = performance.now() - this._startTime;

          ({
            url: this._url,
            method: this._method,
            status: this.status,
            duration,
            timestamp: new Date(),
          });
        }

        if (onReadyStateChange) {
          onReadyStateChange.call(this);
        }
      };

      return originalSend.apply(this);
    };
  }

  private logRequest(log: RequestLog): void {
    this.requestLog.push(log);

    if (this.requestLog.length > this.maxLogs) {
      this.requestLog.shift();
    }

    // Color code by status
    const statusColor = this.getStatusColor(log.status);
    console.log(
      `%c${log.method} ${log.url} ${log.status}`,
      `color: ${statusColor}`,
      `${log.duration.toFixed(2)}ms`
    );
  }

  private getStatusColor(status: number): string {
    if (status === 0) return '#FF0000'; // Error
    if (status < 200) return '#0066CC'; // Info
    if (status < 300) return '#00AA00'; // Success
    if (status < 400) return '#FF6600'; // Redirect
    if (status < 500) return '#FF9900'; // Client error
    return '#FF0000'; // Server error
  }

  getRequestLog(): RequestLog[] {
    return this.requestLog;
  }

  getStatistics(): NetworkStats {
    const requests = this.requestLog;
    const totalRequests = requests.length;
    const totalTime = requests.reduce((sum, req) => sum + req.duration, 0);
    const avgTime = totalTime / totalRequests;

    const byStatus: Record<number, number> = {};
    requests.forEach((req) => {
      byStatus[req.status] = (byStatus[req.status] || 0) + 1;
    });

    return {
      totalRequests,
      totalTime,
      avgTime,
      byStatus,
      slowestRequest: requests.reduce((max, req) =>
        req.duration > max.duration ? req : max
      ),
    };
  }
}

interface RequestLog {
  url: string;
  method: string;
  status: number;
  duration: number;
  timestamp: Date;
  error?: string;
}

interface NetworkStats {
  totalRequests: number;
  totalTime: number;
  avgTime: number;
  byStatus: Record<number, number>;
  slowestRequest: RequestLog;
}

/**
 * Console Utilities
 * Helper functions for console debugging
 */
const ConsoleUtils = {
  /**
   * Table formatter for DevTools
   */
  table: (data: any[], columns?: string[]): void => {
    console.table(data, columns);
  },

  /**
   * Tree formatter
   */
  tree: (label: string, obj: any): void => {
    console.group(label);
    console.log(obj);
    console.groupEnd();
  },

  /**
   * Performance summary
   */
  perfSummary: (): void => {
    const entries = performance.getEntriesByType('measure');
    const summary = entries.map((entry) => ({
      name: entry.name,
      duration: `${entry.duration.toFixed(2)}ms`,
    }));
    console.table(summary);
  },

  /**
   * Timeline analysis
   */
  timeline: (): void => {
    const marks = performance.getEntriesByType('mark');
    marks.forEach((mark) => {
      console.log(`${mark.name}: ${mark.startTime.toFixed(2)}ms`);
    });
  },
};

// Create global DevTools API
if (typeof window !== 'undefined') {
  (window as any).__DEVTOOLS__ = {
    PerformanceMarker,
    DebugLogger,
    MemoryMonitor,
    NetworkInterceptor,
    ConsoleUtils,
  };
}

export {
  PerformanceMarker,
  DebugLogger,
  MemoryMonitor,
  NetworkInterceptor,
  ConsoleUtils,
  LogLevel,
};

DEVTOOLS_EOF

echo "✓ Generated: ${OUTPUT_DIR}/${FILENAME}"
echo ""
echo "Global access: window.__DEVTOOLS__"
echo ""
echo "Usage:"
echo "  // Performance markers"
echo "  PerformanceMarker.start('operation');"
echo "  // ... do work ..."
echo "  PerformanceMarker.end('operation');"
echo ""
echo "  // Debug logging"
echo "  const logger = new DebugLogger('MyComponent');"
echo "  logger.info('Component mounted');"
echo ""
echo "  // Memory monitoring"
echo "  MemoryMonitor.logMemoryUsage();"
echo "  MemoryMonitor.watchMemoryUsage(0.9);"
echo ""
echo "  // Network interceptor"
echo "  new NetworkInterceptor();"
echo "  // All fetch/XHR logged to console"
