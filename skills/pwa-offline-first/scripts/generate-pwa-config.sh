#!/bin/bash
# PWA Configuration Generator - Creates production-ready PWA setup
# Generates manifest.json, service worker, offline page, and install prompt code

set -e

PROJECT_PATH="${1:-.}"
PUBLIC_DIR="$PROJECT_PATH/public"
SRC_DIR="$PROJECT_PATH/src"

echo "PWA Configuration Generator"
echo "============================"
echo "Target: $PROJECT_PATH"
echo ""

# Create directories if they don't exist
mkdir -p "$PUBLIC_DIR"
mkdir -p "$SRC_DIR"

# 1. Generate manifest.json
echo "📄 Generating manifest.json..."
cat > "$PUBLIC_DIR/manifest.json" << 'EOF'
{
  "name": "Progressive Web Application",
  "short_name": "PWA App",
  "description": "A production-ready Progressive Web App with offline support",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "orientation": "portrait-primary",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    {
      "src": "/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshot-540x720.png",
      "sizes": "540x720",
      "type": "image/png",
      "form_factor": "narrow"
    },
    {
      "src": "/screenshot-1280x720.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide"
    }
  ],
  "categories": ["productivity", "utilities"],
  "shortcuts": [
    {
      "name": "Create New",
      "short_name": "New",
      "description": "Create a new item",
      "url": "/new",
      "icons": [{ "src": "/icon-192x192.png", "sizes": "192x192" }]
    }
  ]
}
EOF
echo "✓ Created: public/manifest.json"

# 2. Generate Service Worker with caching strategies
echo "🔧 Generating service worker (src/sw.js)..."
cat > "$SRC_DIR/sw.js" << 'EOF'
// Service Worker with multiple caching strategies
// Implements: cache-first, network-first, stale-while-revalidate

const CACHE_VERSION = 'v1.0.0';
const CACHE_NAME = `pwa-cache-${CACHE_VERSION}`;
const OFFLINE_URL = '/offline.html';

// Assets to precache on install
const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/offline.html',
  '/styles.css',
  '/app.js',
  '/icon-192x192.png',
  '/icon-512x512.png'
];

// ============================================================================
// INSTALL EVENT - Precache critical assets
// ============================================================================
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Install event fired');

  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[Service Worker] Precaching assets...');
      return cache.addAll(PRECACHE_ASSETS);
    })
  );

  // Activate immediately without waiting for old clients to unload
  self.skipWaiting();
});

// ============================================================================
// ACTIVATE EVENT - Clean up old caches
// ============================================================================
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activate event fired');

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName.startsWith('pwa-cache-')) {
            console.log('[Service Worker] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      // Take control of all pages immediately
      return self.clients.claim();
    })
  );
});

// ============================================================================
// FETCH EVENT - Route to appropriate caching strategy
// ============================================================================
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Route to appropriate strategy
  if (isAsset(url.pathname)) {
    // Cache-first for assets (JS, CSS, images)
    event.respondWith(cacheFirst(request));
  } else if (isApiRequest(url.pathname)) {
    // Network-first for API calls
    event.respondWith(networkFirst(request));
  } else {
    // Stale-while-revalidate for HTML documents
    event.respondWith(staleWhileRevalidate(request));
  }
});

// ============================================================================
// CACHING STRATEGIES
// ============================================================================

/**
 * Cache-first strategy: Try cache first, fall back to network
 * Best for: Static assets (JS, CSS, images) that don't change often
 */
async function cacheFirst(request) {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);

  if (cached) {
    console.log('[SW Cache-First] Returning from cache:', request.url);
    return cached;
  }

  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.error('[SW Cache-First] Fetch failed:', error);
    return new Response('Asset not available offline', {
      status: 503,
      statusText: 'Service Unavailable',
      headers: new Headers({ 'Content-Type': 'text/plain' })
    });
  }
}

/**
 * Network-first strategy: Try network first, fall back to cache
 * Best for: API calls and dynamic content that should be fresh
 */
async function networkFirst(request) {
  const cache = await caches.open(CACHE_NAME);

  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.log('[SW Network-First] Network failed, using cache:', request.url);
    const cached = await cache.match(request);
    if (cached) {
      return cached;
    }
    return new Response('Service unavailable offline', {
      status: 503,
      statusText: 'Service Unavailable',
      headers: new Headers({ 'Content-Type': 'text/plain' })
    });
  }
}

/**
 * Stale-while-revalidate: Return cached copy immediately, update in background
 * Best for: HTML pages and documents where immediate response is important
 */
async function staleWhileRevalidate(request) {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);

  const fetchPromise = fetch(request).then((response) => {
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  }).catch((error) => {
    console.error('[SW SWR] Network request failed:', error);
    if (!cached) {
      return new Response(null, { status: 503 });
    }
    return cached;
  });

  return cached || fetchPromise;
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

function isAsset(pathname) {
  return /\.(js|css|png|jpg|jpeg|svg|webp|gif|woff2?|ttf|eot)$/i.test(pathname);
}

function isApiRequest(pathname) {
  return pathname.startsWith('/api/');
}

// ============================================================================
// BACKGROUND SYNC EVENT (optional)
// ============================================================================
self.addEventListener('sync', (event) => {
  console.log('[Service Worker] Background sync:', event.tag);

  if (event.tag === 'sync-data') {
    event.waitUntil(
      caches.open(CACHE_NAME).then((cache) => {
        // Implement sync logic here
        console.log('[Service Worker] Syncing offline data...');
      })
    );
  }
});

// ============================================================================
// PUSH EVENT (optional - for push notifications)
// ============================================================================
self.addEventListener('push', (event) => {
  console.log('[Service Worker] Push notification received');

  const data = event.data ? event.data.json() : {};
  const title = data.title || 'Notification';
  const options = {
    body: data.body || 'You have a new notification',
    icon: '/icon-192x192.png',
    badge: '/icon-192x192.png',
    tag: 'notification',
    ...data
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('[Service Worker] Notification clicked');
  event.notification.close();

  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      for (let client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
EOF
echo "✓ Created: src/sw.js (with all caching strategies)"

# 3. Generate offline fallback page
echo "📄 Generating offline fallback page..."
cat > "$PUBLIC_DIR/offline.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Offline - PWA</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }

    .offline-container {
      background: white;
      border-radius: 12px;
      padding: 40px 20px;
      max-width: 400px;
      text-align: center;
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    }

    .offline-icon {
      font-size: 64px;
      margin-bottom: 20px;
    }

    h1 {
      color: #333;
      margin-bottom: 10px;
      font-size: 28px;
    }

    p {
      color: #666;
      margin-bottom: 30px;
      line-height: 1.6;
      font-size: 16px;
    }

    .offline-actions {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    button {
      padding: 12px 24px;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
      transition: all 0.3s ease;
      font-weight: 600;
    }

    .btn-primary {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
    }

    .btn-secondary {
      background: #f0f0f0;
      color: #333;
    }

    .btn-secondary:hover {
      background: #e0e0e0;
    }

    .status {
      margin-top: 20px;
      padding-top: 20px;
      border-top: 1px solid #eee;
      font-size: 14px;
      color: #999;
    }
  </style>
</head>
<body>
  <div class="offline-container">
    <div class="offline-icon">📱</div>
    <h1>You're Offline</h1>
    <p>It looks like you've lost your internet connection. Some features may not be available until you reconnect.</p>

    <div class="offline-actions">
      <button class="btn-primary" onclick="retryConnection()">Try Again</button>
      <button class="btn-secondary" onclick="goHome()">Go Home</button>
    </div>

    <div class="status">
      <p id="connectionStatus">Checking connection...</p>
    </div>
  </div>

  <script>
    // Check connection status
    function checkConnection() {
      fetch('/ping', { method: 'HEAD', no_cors: true })
        .then(() => {
          document.getElementById('connectionStatus').textContent = '✓ You\'re back online! Reloading...';
          setTimeout(() => window.location.reload(), 1000);
        })
        .catch(() => {
          document.getElementById('connectionStatus').textContent = '⚠ Still offline';
        });
    }

    function retryConnection() {
      checkConnection();
    }

    function goHome() {
      window.location.href = '/';
    }

    // Check connection periodically
    setInterval(checkConnection, 5000);
  </script>
</body>
</html>
EOF
echo "✓ Created: public/offline.html"

# 4. Generate service worker registration code
echo "📝 Generating service worker registration code..."
cat > "$SRC_DIR/sw-register.js" << 'EOF'
/**
 * Service Worker Registration Module
 * Handles registration, update checking, and lifecycle events
 */

export async function registerServiceWorker() {
  if (!('serviceWorker' in navigator)) {
    console.log('Service Workers not supported in this browser');
    return null;
  }

  try {
    const registration = await navigator.serviceWorker.register('/sw.js', {
      scope: '/',
      updateViaCache: 'none' // Always check for updates
    });

    console.log('Service Worker registered successfully:', registration);

    // Listen for updates
    registration.addEventListener('updatefound', () => {
      const newWorker = registration.installing;
      console.log('New Service Worker found');

      newWorker.addEventListener('statechange', () => {
        if (
          newWorker.state === 'installed' &&
          navigator.serviceWorker.controller
        ) {
          console.log('New Service Worker installed, showing update prompt');
          showUpdatePrompt();
        }
      });
    });

    // Check for updates periodically
    setInterval(() => {
      registration.update();
    }, 60000); // Check every minute

    return registration;
  } catch (error) {
    console.error('Service Worker registration failed:', error);
    return null;
  }
}

/**
 * Show update notification to user
 */
function showUpdatePrompt() {
  if (document.getElementById('sw-update-prompt')) return;

  const prompt = document.createElement('div');
  prompt.id = 'sw-update-prompt';
  prompt.style.cssText = `
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    z-index: 9999;
    box-shadow: 0 -2px 10px rgba(0,0,0,0.2);
  `;

  prompt.innerHTML = `
    <span>A new version is available!</span>
    <div style="display: flex; gap: 8px;">
      <button id="sw-update-dismiss" style="
        background: transparent;
        border: 1px solid white;
        color: white;
        padding: 8px 16px;
        border-radius: 4px;
        cursor: pointer;
        font-weight: 600;
      ">Later</button>
      <button id="sw-update-install" style="
        background: white;
        border: none;
        color: #667eea;
        padding: 8px 16px;
        border-radius: 4px;
        cursor: pointer;
        font-weight: 600;
      ">Update</button>
    </div>
  `;

  document.body.appendChild(prompt);

  document.getElementById('sw-update-dismiss').onclick = () => {
    prompt.remove();
  };

  document.getElementById('sw-update-install').onclick = () => {
    navigator.serviceWorker.getRegistration().then((reg) => {
      if (reg && reg.waiting) {
        reg.waiting.postMessage({ type: 'SKIP_WAITING' });
        window.location.reload();
      }
    });
  };
}

/**
 * Handle install prompt for Add to Home Screen
 */
export function setupInstallPrompt() {
  let deferredPrompt = null;

  window.addEventListener('beforeinstallprompt', (e) => {
    console.log('Install prompt available');
    e.preventDefault();
    deferredPrompt = e;

    // Show install button
    const installBtn = document.getElementById('install-btn');
    if (installBtn) {
      installBtn.style.display = 'block';
      installBtn.onclick = async () => {
        if (deferredPrompt) {
          deferredPrompt.prompt();
          const { outcome } = await deferredPrompt.userChoice;
          console.log(`User response: ${outcome}`);
          deferredPrompt = null;
          installBtn.style.display = 'none';
        }
      };
    }
  });

  window.addEventListener('appinstalled', () => {
    console.log('App installed successfully');
    const installBtn = document.getElementById('install-btn');
    if (installBtn) {
      installBtn.style.display = 'none';
    }
  });
}
EOF
echo "✓ Created: src/sw-register.js"

# 5. Generate install prompt HTML example
echo "📄 Generating install prompt example..."
cat > "$PUBLIC_DIR/install-prompt-example.html" << 'EOF'
<!-- Install Prompt Button Example -->
<!-- Add this to your app's main navigation or header -->

<button id="install-btn" style="display: none;">
  <span>📱 Install App</span>
</button>

<script>
  // This example shows how to integrate the install prompt
  // Import the setupInstallPrompt function from your app

  import { setupInstallPrompt } from '../src/sw-register.js';

  // Call this when your app loads
  document.addEventListener('DOMContentLoaded', () => {
    setupInstallPrompt();
  });
</script>

<!-- Alternative: Styled install button -->
<style>
  #install-btn {
    padding: 8px 16px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.3s ease;
  }

  #install-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
  }

  #install-btn:active {
    transform: translateY(0);
  }
</style>
EOF
echo "✓ Created: public/install-prompt-example.html"

# 6. Generate push notification worker example
echo "🔔 Generating push notification handler..."
cat > "$SRC_DIR/push-notification-handler.js" << 'EOF'
/**
 * Push Notification Handler
 * Handles requesting permission and sending notifications
 */

export async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    console.log('Notifications not supported');
    return false;
  }

  if (Notification.permission === 'granted') {
    return true;
  }

  if (Notification.permission !== 'denied') {
    const permission = await Notification.requestPermission();
    return permission === 'granted';
  }

  return false;
}

/**
 * Subscribe to push notifications
 */
export async function subscribeToPushNotifications() {
  const registration = await navigator.serviceWorker.ready;

  if (!registration.pushManager) {
    console.log('Push notifications not supported');
    return null;
  }

  try {
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: process.env.REACT_APP_VAPID_PUBLIC_KEY
    });

    console.log('Push subscription successful:', subscription);

    // Send subscription to server
    await fetch('/api/subscribe', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(subscription)
    });

    return subscription;
  } catch (error) {
    console.error('Push subscription failed:', error);
    return null;
  }
}

/**
 * Show local notification
 */
export async function showLocalNotification(title, options = {}) {
  const registration = await navigator.serviceWorker.ready;

  return registration.showNotification(title, {
    icon: '/icon-192x192.png',
    badge: '/icon-192x192.png',
    ...options
  });
}

/**
 * Request background sync (for offline sync)
 */
export async function requestBackgroundSync() {
  const registration = await navigator.serviceWorker.ready;

  if (!registration.sync) {
    console.log('Background sync not supported');
    return false;
  }

  try {
    await registration.sync.register('sync-data');
    console.log('Background sync registered');
    return true;
  } catch (error) {
    console.error('Background sync failed:', error);
    return false;
  }
}
EOF
echo "✓ Created: src/push-notification-handler.js"

echo ""
echo "================================"
echo "✓ PWA Configuration Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Update public/index.html to include: <link rel=\"manifest\" href=\"/manifest.json\">"
echo "2. In your main JS file, register the service worker:"
echo "   import { registerServiceWorker, setupInstallPrompt } from './sw-register';"
echo "   registerServiceWorker();"
echo "   setupInstallPrompt();"
echo "3. Replace placeholder icons (192x192.png, 512x512.png)"
echo "4. Add your VAPID_PUBLIC_KEY for push notifications"
echo "5. Run: npm run build && npm start"
echo ""
