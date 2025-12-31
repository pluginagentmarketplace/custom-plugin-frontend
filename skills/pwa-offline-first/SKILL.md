---
name: pwa-offline-first
description: Build Progressive Web Apps with offline support, service workers, push notifications, and installation.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: advanced-topics
bond_type: PRIMARY_BOND
category: advanced-web-features
tags: [pwa, service-worker, offline, caching, manifest, push-notifications]
complexity: advanced
estimated_time: 4-6 hours
prerequisites:
  - Modern JavaScript (ES6+)
  - Promises and async/await
  - Web APIs knowledge
  - Basic understanding of HTTP caching
---

# Progressive Web Apps & Offline-First

Build native app-like experiences for the web with offline support, installability, and progressive enhancement.

## Input/Output Schema

### Input Requirements
```yaml
project_context:
  type: object
  required:
    - app_name: string           # Application name
    - app_description: string    # Short description
    - target_browsers: array     # Target browser support
    - cache_strategy: enum       # cache-first|network-first|stale-while-revalidate
  optional:
    - theme_color: string        # Brand color (#RRGGBB)
    - background_color: string   # Background color
    - icon_paths: array          # App icon paths
    - push_notifications: boolean
    - offline_pages: array       # Pages to cache

service_worker_config:
  type: object
  required:
    - cache_name: string         # Cache identifier
    - static_assets: array       # Files to precache
    - runtime_caching: array     # Dynamic caching rules
  optional:
    - max_age: number            # Cache duration (seconds)
    - max_entries: number        # Max cached items
    - skip_waiting: boolean      # Auto-activate SW
```

### Output Deliverables
```yaml
files_generated:
  - manifest.json              # Web app manifest
  - service-worker.js          # Service worker implementation
  - sw-register.js             # Registration script
  - offline.html               # Offline fallback page

configuration:
  - Icons in sizes: [72, 96, 128, 144, 152, 192, 384, 512]
  - Caching strategies implemented
  - Install prompt handler
  - Update notification system

metrics:
  - Lighthouse PWA score: >90
  - Offline functionality: verified
  - Install success rate: tracked
  - Cache hit ratio: monitored
```

## MANDATORY

### 1. Web App Manifest Configuration
```json
{
  "name": "App Full Name",
  "short_name": "AppName",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

### 2. Service Worker Lifecycle
```javascript
// Install event - precache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate event - cleanup old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});
```

### 3. Basic Caching Strategies
- **Cache First**: Static assets (images, fonts, CSS)
- **Network First**: API calls, dynamic content
- **Stale While Revalidate**: Non-critical resources

### 4. Offline Fallback Pages
```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
      .catch(() => caches.match('/offline.html'))
  );
});
```

### 5. Install Prompt Handling
```javascript
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  showInstallButton();
});

installButton.addEventListener('click', async () => {
  if (deferredPrompt) {
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    console.log(`Install outcome: ${outcome}`);
    deferredPrompt = null;
  }
});
```

### 6. App Icons and Splash Screens
- Required sizes: 72x72, 96x96, 128x128, 144x144, 152x152, 192x192, 384x384, 512x512
- Maskable icons for adaptive support
- Platform-specific splash screens

## OPTIONAL

### 1. Push Notifications
```javascript
// Request permission
const permission = await Notification.requestPermission();

// Subscribe to push
const subscription = await registration.pushManager.subscribe({
  userVisibleOnly: true,
  applicationServerKey: urlBase64ToUint8Array(vapidPublicKey)
});

// Handle push events in SW
self.addEventListener('push', (event) => {
  const data = event.data.json();
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icons/icon-192.png',
      badge: '/icons/badge-72.png'
    })
  );
});
```

### 2. Background Sync
```javascript
// Register sync
await registration.sync.register('sync-data');

// Handle in SW
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-data') {
    event.waitUntil(syncDataWithServer());
  }
});
```

### 3. IndexedDB Storage
```javascript
const db = await openDB('app-store', 1, {
  upgrade(db) {
    db.createObjectStore('items', { keyPath: 'id' });
  }
});
```

### 4. Workbox Integration
```javascript
import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { CacheFirst, NetworkFirst } from 'workbox-strategies';

precacheAndRoute(self.__WB_MANIFEST);

registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({ cacheName: 'images' })
);
```

### 5. Cache Versioning
```javascript
const CACHE_VERSION = 'v1.2.0';
const CACHE_NAME = `app-cache-${CACHE_VERSION}`;
```

### 6. Network-First Strategies
```javascript
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    const cache = await caches.open(CACHE_NAME);
    cache.put(request, response.clone());
    return response;
  } catch (error) {
    return caches.match(request);
  }
}
```

## ADVANCED

### 1. Periodic Background Sync
```javascript
// Register periodic sync
await registration.periodicSync.register('content-sync', {
  minInterval: 24 * 60 * 60 * 1000 // 24 hours
});

self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'content-sync') {
    event.waitUntil(updateContent());
  }
});
```

### 2. Web Share Target API
```json
{
  "share_target": {
    "action": "/share",
    "method": "POST",
    "enctype": "multipart/form-data",
    "params": {
      "title": "title",
      "text": "text",
      "url": "url",
      "files": [
        {
          "name": "media",
          "accept": ["image/*", "video/*"]
        }
      ]
    }
  }
}
```

### 3. File Handling API
```json
{
  "file_handlers": [
    {
      "action": "/open-file",
      "accept": {
        "image/*": [".jpg", ".jpeg", ".png", ".webp"]
      }
    }
  ]
}
```

### 4. Protocol Handlers
```json
{
  "protocol_handlers": [
    {
      "protocol": "web+music",
      "url": "/music?track=%s"
    }
  ]
}
```

### 5. Badging API
```javascript
// Set badge
navigator.setAppBadge(5);

// Clear badge
navigator.clearAppBadge();
```

### 6. Multi-Tab Synchronization
```javascript
// Broadcast channel
const channel = new BroadcastChannel('app-channel');

channel.postMessage({ type: 'data-update', data: newData });

channel.addEventListener('message', (event) => {
  if (event.data.type === 'data-update') {
    updateUI(event.data.data);
  }
});
```

## Error Handling

| Error Type | Cause | Solution | Recovery Strategy |
|-----------|-------|----------|-------------------|
| `SecurityError` | HTTPS not enforced | Deploy with HTTPS | Use localhost for dev |
| `QuotaExceededError` | Storage quota exceeded | Clear old caches | Implement cache size limits |
| `NetworkError` | No internet connection | Serve from cache | Show offline indicator |
| `AbortError` | SW installation failed | Check SW syntax | Provide error feedback |
| `NotSupportedError` | Browser incompatibility | Feature detection | Graceful degradation |
| `InvalidStateError` | Registration timing issue | Check ready state | Retry registration |
| `NotFoundError` | Offline page missing | Ensure precached | Always cache offline.html |
| `DataCloneError` | Message passing failed | Serialize data | Use structured clone |

### Error Handling Implementation
```javascript
// SW Registration with error handling
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
    .then((registration) => {
      console.log('SW registered:', registration.scope);

      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing;
        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            showUpdateNotification();
          }
        });
      });
    })
    .catch((error) => {
      console.error('SW registration failed:', error);
      trackError('sw_registration', error);
    });
}

// Quota management
if ('storage' in navigator && 'estimate' in navigator.storage) {
  const { usage, quota } = await navigator.storage.estimate();
  const percentUsed = (usage / quota) * 100;

  if (percentUsed > 80) {
    await cleanOldCaches();
  }
}
```

## Test Templates

### Unit Tests
```javascript
describe('Service Worker', () => {
  it('should cache static assets on install', async () => {
    const event = new ExtendableEvent('install');
    await self.oninstall(event);

    const cache = await caches.open(CACHE_NAME);
    const cachedRequests = await cache.keys();

    expect(cachedRequests.length).toBeGreaterThan(0);
    expect(cachedRequests).toContain('/index.html');
  });

  it('should remove old caches on activate', async () => {
    await caches.open('old-cache-v1');
    const event = new ExtendableEvent('activate');
    await self.onactivate(event);

    const cacheNames = await caches.keys();
    expect(cacheNames).not.toContain('old-cache-v1');
  });

  it('should serve cached response', async () => {
    const request = new Request('/test.html');
    const cachedResponse = new Response('cached');

    const cache = await caches.open(CACHE_NAME);
    await cache.put(request, cachedResponse);

    const event = new FetchEvent('fetch', { request });
    const response = await self.onfetch(event);

    expect(await response.text()).toBe('cached');
  });
});
```

### Integration Tests
```javascript
describe('PWA Installation', () => {
  it('should trigger install prompt', async () => {
    const promptSpy = jest.fn();

    window.dispatchEvent(new Event('beforeinstallprompt', {
      prompt: promptSpy,
      userChoice: Promise.resolve({ outcome: 'accepted' })
    }));

    await installButton.click();
    expect(promptSpy).toHaveBeenCalled();
  });

  it('should register service worker', async () => {
    const registration = await navigator.serviceWorker.register('/sw.js');
    expect(registration.active).toBeTruthy();
  });
});
```

### E2E Tests (Playwright)
```javascript
test('PWA works offline', async ({ page, context }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');

  // Go offline
  await context.setOffline(true);

  await page.goto('/');
  await expect(page.locator('h1')).toBeVisible();

  // Verify offline indicator
  await expect(page.locator('.offline-indicator')).toBeVisible();
});

test('Install prompt appears', async ({ page }) => {
  await page.goto('/');

  // Trigger install prompt
  await page.evaluate(() => {
    window.dispatchEvent(new Event('beforeinstallprompt'));
  });

  await expect(page.locator('[data-testid="install-button"]')).toBeVisible();
});
```

### Lighthouse Audit
```bash
lighthouse https://app.example.com \
  --only-categories=pwa \
  --output=json \
  --output-path=./pwa-audit.json
```

## Best Practices

### Performance
- Precache critical assets only (< 50 items)
- Use cache versioning for updates
- Implement cache size limits (max 50MB)
- Lazy load non-critical resources
- Use compression (Brotli/Gzip)

### Security
- Always use HTTPS in production
- Validate message origins in postMessage
- Sanitize user input in notifications
- Implement CSP headers
- Regular dependency updates

### Reliability
- Test offline scenarios thoroughly
- Implement retry logic for failed requests
- Provide meaningful offline feedback
- Handle quota exceeded errors
- Monitor cache hit rates

### UX Guidelines
- Show install button at appropriate time
- Notify users of updates
- Provide offline indicators
- Optimize for mobile devices
- Smooth transitions between online/offline

### Code Organization
```
src/
├── service-worker/
│   ├── sw.js               # Main service worker
│   ├── strategies/         # Caching strategies
│   ├── handlers/           # Event handlers
│   └── utils/              # Helper functions
├── public/
│   ├── manifest.json       # Web app manifest
│   ├── offline.html        # Offline fallback
│   └── icons/              # App icons
└── scripts/
    └── sw-register.js      # Registration logic
```

## Production Configuration

### Webpack Configuration
```javascript
const WorkboxPlugin = require('workbox-webpack-plugin');

module.exports = {
  plugins: [
    new WorkboxPlugin.GenerateSW({
      clientsClaim: true,
      skipWaiting: true,
      maximumFileSizeToCacheInBytes: 5 * 1024 * 1024,
      runtimeCaching: [{
        urlPattern: /^https:\/\/api\./,
        handler: 'NetworkFirst',
        options: {
          cacheName: 'api-cache',
          expiration: {
            maxEntries: 50,
            maxAgeSeconds: 5 * 60
          }
        }
      }]
    })
  ]
};
```

### Vite Configuration
```javascript
import { VitePWA } from 'vite-plugin-pwa';

export default {
  plugins: [
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'robots.txt', 'apple-touch-icon.png'],
      manifest: {
        name: 'My App',
        short_name: 'App',
        theme_color: '#ffffff',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365
              }
            }
          }
        ]
      }
    })
  ]
};
```

### Environment Variables
```bash
# .env.production
VITE_APP_NAME="Production App"
VITE_VAPID_PUBLIC_KEY="your-vapid-public-key"
VITE_API_URL="https://api.production.com"
VITE_ENABLE_PUSH=true
VITE_CACHE_VERSION="v1.0.0"
```

### Monitoring & Analytics
```javascript
// Track PWA metrics
function trackPWAMetrics() {
  // Installation
  window.addEventListener('appinstalled', () => {
    analytics.track('pwa_installed');
  });

  // Update available
  registration.addEventListener('updatefound', () => {
    analytics.track('pwa_update_found');
  });

  // Cache performance
  const cacheHitRate = cacheHits / (cacheHits + cacheMisses);
  analytics.metric('cache_hit_rate', cacheHitRate);
}
```

## Assets
- See `assets/pwa-config.yaml` for configuration and strategies

## Resources
- [PWA Fundamentals](https://developers.google.com/web/progressive-web-apps)
- [Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Workbox](https://developers.google.com/web/tools/workbox)
- [Web App Manifest](https://web.dev/add-manifest/)
- [PWA Builder](https://www.pwabuilder.com/)

---
**Status:** Active | **Version:** 2.0.0 | **Complexity:** Advanced | **Estimated Time:** 4-6 hours
