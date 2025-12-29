# PWA Offline-First Patterns

Enterprise-level patterns and real-world implementation approaches for Progressive Web Apps.

## Service Worker Patterns

### Precaching Pattern

Precaching critical assets on service worker install ensures they're available offline immediately.

```javascript
// Define which assets to precache
const PRECACHE_VERSION = 'v1.0.0';
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/styles/main.css',
  '/scripts/app.js',
  '/scripts/vendor.js',
  '/offline.html',
  '/icon-192x192.png',
  '/fonts/roboto.woff2'
];

self.addEventListener('install', (event) => {
  // Create versioned cache for precached assets
  event.waitUntil(
    caches.open(`precache-${PRECACHE_VERSION}`).then((cache) => {
      return cache.addAll(PRECACHE_URLS);
    })
  );

  self.skipWaiting(); // Take control immediately
});

self.addEventListener('activate', (event) => {
  // Clean up old precache versions
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName.startsWith('precache-') &&
              cacheName !== `precache-${PRECACHE_VERSION}`) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );

  self.clients.claim(); // Claim all clients
});
```

### Runtime Caching Pattern

Cache assets as they're requested during runtime for better resource efficiency.

```javascript
// Runtime cache for images and fonts
const RUNTIME_CACHE = 'runtime-cache-v1';
const CACHE_EXPIRY_HOURS = 24;

self.addEventListener('fetch', (event) => {
  const { request } = event;

  // Cache images with runtime caching
  if (isImage(request.url)) {
    event.respondWith(runtimeCache(request, RUNTIME_CACHE));
  }

  // Cache API responses with network-first
  if (isApiRequest(request.url)) {
    event.respondWith(networkFirstWithTimeout(request));
  }
});

async function runtimeCache(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  if (cached) {
    return cached;
  }

  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    // Return placeholder image if offline
    return new Response(defaultImageBlob, {
      headers: { 'Content-Type': 'image/png' }
    });
  }
}

async function networkFirstWithTimeout(request) {
  const cache = await caches.open('api-cache-v1');

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000); // 5s timeout

    const response = await fetch(request, {
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    // Return cached response if network fails
    const cached = await cache.match(request);
    return cached || new Response('Offline', { status: 503 });
  }
}

function isImage(url) {
  return /\.(png|jpg|jpeg|gif|svg|webp)$/i.test(url);
}

function isApiRequest(url) {
  return url.includes('/api/');
}
```

## IndexedDB Patterns for Offline Storage

IndexedDB provides a large local database for storing complex data structures offline.

```javascript
// IndexedDB wrapper for offline data storage
class OfflineDatabase {
  constructor(dbName, version) {
    this.dbName = dbName;
    this.version = version;
    this.db = null;
  }

  // Open or create database
  async open() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, this.version);

      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve(this.db);
      };

      request.onupgradeneeded = (event) => {
        const db = event.target.result;

        // Create object stores
        if (!db.objectStoreNames.contains('tasks')) {
          const tasksStore = db.createObjectStore('tasks', { keyPath: 'id' });
          tasksStore.createIndex('status', 'status', { unique: false });
          tasksStore.createIndex('createdAt', 'createdAt', { unique: false });
        }

        if (!db.objectStoreNames.contains('syncQueue')) {
          db.createObjectStore('syncQueue', { keyPath: 'id', autoIncrement: true });
        }
      };
    });
  }

  // Add item to store
  async add(storeName, data) {
    const transaction = this.db.transaction([storeName], 'readwrite');
    const store = transaction.objectStore(storeName);
    return new Promise((resolve, reject) => {
      const request = store.add(data);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  // Get all items
  async getAll(storeName) {
    const transaction = this.db.transaction([storeName], 'readonly');
    const store = transaction.objectStore(storeName);
    return new Promise((resolve, reject) => {
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  // Query by index
  async queryByIndex(storeName, indexName, value) {
    const transaction = this.db.transaction([storeName], 'readonly');
    const store = transaction.objectStore(storeName);
    const index = store.index(indexName);

    return new Promise((resolve, reject) => {
      const request = index.getAll(value);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  // Update item
  async update(storeName, data) {
    const transaction = this.db.transaction([storeName], 'readwrite');
    const store = transaction.objectStore(storeName);
    return new Promise((resolve, reject) => {
      const request = store.put(data);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  // Delete item
  async delete(storeName, key) {
    const transaction = this.db.transaction([storeName], 'readwrite');
    const store = transaction.objectStore(storeName);
    return new Promise((resolve, reject) => {
      const request = store.delete(key);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  // Clear entire store
  async clear(storeName) {
    const transaction = this.db.transaction([storeName], 'readwrite');
    const store = transaction.objectStore(storeName);
    return new Promise((resolve, reject) => {
      const request = store.clear();
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }
}

// Usage
const offlineDB = new OfflineDatabase('MyAppDB', 1);

// Store data when offline
async function saveTaskOffline(task) {
  await offlineDB.open();
  await offlineDB.add('tasks', {
    id: Date.now(),
    ...task,
    synced: false,
    createdAt: new Date()
  });
}

// Query offline data
async function getUnfinishedTasks() {
  await offlineDB.open();
  return offlineDB.queryByIndex('tasks', 'status', 'pending');
}
```

## Cache Versioning and Update Strategy

Implement robust cache versioning to manage updates gracefully.

```javascript
const CURRENT_VERSION = 'v2.0.0';
const CACHE_PREFIX = 'app-cache';

// Initialize versioned caches
const CACHES_TO_KEEP = {
  `${CACHE_PREFIX}-precache-${CURRENT_VERSION}`: PRECACHE_URLS,
  `${CACHE_PREFIX}-runtime-images`: 'unlimited',
  `${CACHE_PREFIX}-api-v2`: 'unlimited'
};

// Cleanup old versions on activation
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          // Keep only current version and named caches
          if (!Object.keys(CACHES_TO_KEEP).includes(cacheName)) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Update service worker when new version available
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
```

On the client side:

```javascript
// Detect service worker updates
function monitorServiceWorkerUpdates() {
  const registration = navigator.serviceWorker.controller;

  navigator.serviceWorker.oncontrollerchange = () => {
    console.log('Service worker updated');
    showUpdateNotification();
  };

  // Check for updates periodically
  if (registration) {
    setInterval(() => {
      registration.update();
    }, 60000); // Check every minute
  }
}

function showUpdateNotification() {
  const notification = document.createElement('div');
  notification.innerHTML = `
    <p>An update is available!</p>
    <button onclick="location.reload()">Reload</button>
  `;
  notification.style.cssText = `
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #667eea;
    color: white;
    padding: 16px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    z-index: 9999;
  `;
  document.body.appendChild(notification);
}
```

## Push Notification Patterns

### Subscription Management

```javascript
class PushNotificationManager {
  constructor(vapidPublicKey) {
    this.vapidKey = vapidPublicKey;
    this.subscription = null;
  }

  async subscribe() {
    // Request notification permission
    if ('Notification' in window && Notification.permission === 'default') {
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        return null;
      }
    }

    const registration = await navigator.serviceWorker.ready;

    try {
      this.subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidKey)
      });

      // Send subscription to server
      await this.sendSubscriptionToServer(this.subscription);

      return this.subscription;
    } catch (error) {
      console.error('Push subscription failed:', error);
      return null;
    }
  }

  async unsubscribe() {
    if (this.subscription) {
      await this.subscription.unsubscribe();
      this.subscription = null;

      // Notify server
      await fetch('/api/unsubscribe', {
        method: 'POST',
        body: JSON.stringify({ endpoint: this.subscription.endpoint })
      });
    }
  }

  async sendSubscriptionToServer(subscription) {
    return fetch('/api/subscribe', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(subscription)
    });
  }

  async sendNotification(title, options) {
    const registration = await navigator.serviceWorker.ready;
    return registration.showNotification(title, options);
  }

  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/');

    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }

    return outputArray;
  }
}

// Usage
const pushManager = new PushNotificationManager(process.env.REACT_APP_VAPID_KEY);
await pushManager.subscribe();
```

## Install Prompt Pattern with Custom UI

```javascript
class InstallPromptManager {
  constructor() {
    this.deferredPrompt = null;
    this.installButton = null;
  }

  initialize(buttonSelector) {
    this.installButton = document.querySelector(buttonSelector);

    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      this.deferredPrompt = e;
      this.showInstallButton();
    });

    window.addEventListener('appinstalled', () => {
      console.log('App installed');
      this.hideInstallButton();
      this.deferredPrompt = null;
    });

    // Hide button if app is already installed
    if (window.matchMedia('(display-mode: standalone)').matches) {
      this.hideInstallButton();
    }
  }

  async promptInstall() {
    if (!this.deferredPrompt) return false;

    this.deferredPrompt.prompt();
    const { outcome } = await this.deferredPrompt.userChoice;

    console.log(`User response: ${outcome}`);

    if (outcome === 'accepted') {
      this.hideInstallButton();
    }

    this.deferredPrompt = null;
    return outcome === 'accepted';
  }

  showInstallButton() {
    if (this.installButton) {
      this.installButton.style.display = 'block';
      this.installButton.addEventListener('click', () => this.promptInstall());
    }
  }

  hideInstallButton() {
    if (this.installButton) {
      this.installButton.style.display = 'none';
    }
  }

  isInstalled() {
    return window.matchMedia('(display-mode: standalone)').matches ||
           navigator.standalone === true;
  }
}

// Usage
const installManager = new InstallPromptManager();
installManager.initialize('#install-btn');
```

## Background Sync Pattern

Queue actions to sync when connection returns.

```javascript
class BackgroundSyncQueue {
  constructor(dbName = 'SyncQueueDB') {
    this.dbName = dbName;
    this.db = null;
  }

  async open() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, 1);

      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (!db.objectStoreNames.contains('queue')) {
          db.createObjectStore('queue', { keyPath: 'id', autoIncrement: true });
        }
      };

      request.onsuccess = () => {
        this.db = request.result;
        resolve(this.db);
      };

      request.onerror = () => reject(request.error);
    });
  }

  async add(action, payload) {
    const transaction = this.db.transaction(['queue'], 'readwrite');
    const store = transaction.objectStore('queue');

    return new Promise((resolve, reject) => {
      const request = store.add({
        action,
        payload,
        timestamp: Date.now(),
        retries: 0
      });

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  async sync() {
    await navigator.serviceWorker.ready;

    try {
      await navigator.serviceWorker.ready.then((registration) => {
        return registration.sync.register('background-sync');
      });
    } catch (error) {
      console.error('Background sync registration failed:', error);
    }
  }
}

// In service worker
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    event.waitUntil(processSyncQueue());
  }
});

async function processSyncQueue() {
  const db = await openSyncDatabase();
  const queue = await getQueueItems(db);

  for (const item of queue) {
    try {
      const response = await fetch(`/api/${item.action}`, {
        method: 'POST',
        body: JSON.stringify(item.payload)
      });

      if (response.ok) {
        await removeQueueItem(db, item.id);
      }
    } catch (error) {
      console.error('Sync failed:', error);
    }
  }
}
```

These patterns provide production-ready approaches for building robust PWAs with comprehensive offline support, smooth updates, and excellent user experience.
