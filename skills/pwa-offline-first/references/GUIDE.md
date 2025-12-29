# PWA Offline-First Technical Guide

## Service Worker Registration and Lifecycle

A Service Worker is a JavaScript file that runs in the background, separate from the main browser thread. It acts as a proxy between your web app and the network, enabling offline functionality.

### Registration Process

Service Workers must be registered from your main application:

```javascript
// In your app's main entry point
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js', {
    scope: '/',
    updateViaCache: 'none'  // Always check for updates
  }).then((registration) => {
    console.log('Service Worker registered:', registration);

    // Check for updates periodically
    setInterval(() => {
      registration.update();
    }, 60000); // Every minute
  }).catch((error) => {
    console.error('Service Worker registration failed:', error);
  });
}
```

### Service Worker Lifecycle

The Service Worker goes through several states:

**1. Parsing**: Browser downloads and parses the service worker file.
**2. Installation**: `install` event fires - precache critical assets.
**3. Activation**: `activate` event fires - clean up old caches, take control of clients.
**4. Fetch Interception**: `fetch` events are handled to implement caching strategies.

```javascript
// Install event - runs once when first registered
self.addEventListener('install', (event) => {
  console.log('Service Worker installing...');

  event.waitUntil(
    caches.open('v1').then((cache) => {
      // Precache essential files
      return cache.addAll([
        '/',
        '/index.html',
        '/styles.css',
        '/app.js',
        '/offline.html'
      ]);
    })
  );

  // Take control immediately
  self.skipWaiting();
});

// Activate event - runs when becoming active
self.addEventListener('activate', (event) => {
  console.log('Service Worker activating...');

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      // Delete old cache versions
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== 'v1') {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      // Claim all open pages
      return self.clients.claim();
    })
  );
});

// Fetch event - intercept network requests
self.addEventListener('fetch', (event) => {
  // Implement caching strategies here
  event.respondWith(handleRequest(event.request));
});
```

## Web App Manifest Configuration

The Web App Manifest (manifest.json) is a JSON file that tells the browser about your web application and how it should behave when installed on a device.

### Required Fields

```json
{
  "name": "My Progressive Web App",
  "short_name": "MyPWA",
  "description": "A production-ready progressive web app",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    {
      "src": "/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    }
  ]
}
```

### Field Explanations

- **name**: Full application name (displayed on install prompt)
- **short_name**: Abbreviated name (shown on home screen when space is limited)
- **start_url**: Page to load when app is launched
- **display**: How the app should be displayed (standalone = full screen, no URL bar)
- **background_color**: Splash screen background color
- **theme_color**: Status bar and browser UI color
- **icons**: Array of app icons at various sizes (192x192 and 512x512 minimum)
- **categories**: App categories for app store discoverability
- **screenshots**: App screenshots for app installation UI
- **orientation**: Portrait or landscape mode preference

### Example with All Optional Fields

```json
{
  "name": "Enterprise Task Manager",
  "short_name": "Tasks",
  "description": "Manage tasks offline with sync",
  "start_url": "/dashboard",
  "scope": "/",
  "display": "standalone",
  "orientation": "portrait-primary",
  "background_color": "#ffffff",
  "theme_color": "#667eea",
  "categories": ["productivity", "utilities"],
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/screen-540.png",
      "sizes": "540x720",
      "type": "image/png",
      "form_factor": "narrow"
    },
    {
      "src": "/screenshots/screen-1280.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide"
    }
  ],
  "shortcuts": [
    {
      "name": "Create Task",
      "short_name": "New",
      "description": "Create a new task",
      "url": "/new-task",
      "icons": [{ "src": "/icons/new-192.png", "sizes": "192x192" }]
    }
  ]
}
```

### Link Manifest in HTML

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="manifest" href="/manifest.json">
  <meta name="theme-color" content="#667eea">
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
  <!-- Your app -->
</body>
</html>
```

## Offline-First Strategies

Offline-first architecture prioritizes making your app work without a network connection, then syncing data when connection returns.

### Cache-First Strategy

Best for: Static assets (JavaScript, CSS, images, fonts)

```javascript
async function cacheFirst(request) {
  const cache = await caches.open('v1');
  const cached = await cache.match(request);

  if (cached) {
    return cached; // Return from cache immediately
  }

  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    return new Response('Asset offline', { status: 503 });
  }
}
```

**Pros**: Instant loading, works fully offline
**Cons**: May serve stale content until cache expires

### Network-First Strategy

Best for: API calls, dynamic content that needs to be fresh

```javascript
async function networkFirst(request) {
  const cache = await caches.open('v1');

  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response; // Return fresh data
  } catch (error) {
    const cached = await cache.match(request);
    return cached || new Response('Offline', { status: 503 });
  }
}
```

**Pros**: Always serves fresh data when available
**Cons**: Slow if network is slow or down

### Stale-While-Revalidate Strategy

Best for: HTML pages and content where immediate response is important

```javascript
async function staleWhileRevalidate(request) {
  const cache = await caches.open('v1');
  const cached = await cache.match(request);

  const fetchPromise = fetch(request).then((response) => {
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  }).catch(() => cached || new Response('Offline', { status: 503 }));

  return cached || fetchPromise; // Return cached immediately, update in background
}
```

**Pros**: Fast + always shows something + updates in background
**Cons**: Initial load is cached version, not the latest

## Push Notifications

Push notifications enable your app to send messages to users even when they're not using the app.

### Requesting Permission

```javascript
async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    console.log('Browser does not support notifications');
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
```

### Subscribing to Push

```javascript
async function subscribeToPush(registration) {
  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(publicKey)
  });

  // Send subscription to your server
  await fetch('/api/subscribe', {
    method: 'POST',
    body: JSON.stringify(subscription)
  });

  return subscription;
}

// Convert VAPID key to proper format
function urlBase64ToUint8Array(base64String) {
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
```

### Handling Push Events

```javascript
self.addEventListener('push', (event) => {
  const data = event.data.json();
  const title = data.title;
  const options = {
    body: data.body,
    icon: '/icon-192x192.png',
    badge: '/badge-72x72.png',
    tag: 'notification',
    requireInteraction: false
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      for (let i = 0; i < clientList.length; i++) {
        if (clientList[i].url === '/' && 'focus' in clientList[i]) {
          return clientList[i].focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
```

## App Installation

Users can install your PWA on their home screen for a native-like experience.

### Install Prompt Handling

```javascript
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault(); // Prevent automatic browser prompt
  deferredPrompt = e;

  // Show custom install button
  document.getElementById('install-btn').style.display = 'block';
});

document.getElementById('install-btn').addEventListener('click', async () => {
  if (deferredPrompt) {
    deferredPrompt.prompt(); // Show install dialog
    const { outcome } = await deferredPrompt.userChoice;
    console.log(`User response: ${outcome}`);
    deferredPrompt = null;
    document.getElementById('install-btn').style.display = 'none';
  }
});

window.addEventListener('appinstalled', () => {
  console.log('PWA was installed');
  deferredPrompt = null;
});
```

### Detecting if App is Installed

```javascript
// Check if running as installed app
if (window.navigator.standalone === true) {
  console.log('Running as installed app');
} else if (window.matchMedia('(display-mode: standalone)').matches) {
  console.log('App is running in standalone mode');
}
```

## HTTPS Requirement

Service Workers only work over HTTPS (or localhost for development). This is a security requirement.

### Development Setup

```bash
# Create self-signed certificate for local development
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes

# Run Node server with HTTPS
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};

https.createServer(options, app).listen(3000);
```

### Production

Always deploy with valid SSL certificate (Let's Encrypt is free).

```javascript
// Detect HTTPS and warn in development
if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
  console.warn('Service Workers require HTTPS');
}
```

## Complete PWA Implementation Checklist

- [ ] Web app manifest created with all required fields
- [ ] Service worker registered and lifecycle implemented
- [ ] Offline fallback page (/offline.html) created
- [ ] Caching strategies implemented (cache-first, network-first, SWR)
- [ ] HTTPS enabled (production) or localhost (development)
- [ ] Icons generated (192x192, 512x512 minimum)
- [ ] Theme color set in manifest and HTML
- [ ] Install prompt handling implemented
- [ ] Cache versioning and cleanup implemented
- [ ] Push notifications configured (if needed)
- [ ] Background sync setup (if needed)
- [ ] Update strategy for new versions implemented
- [ ] App installation tested on Android and iOS
- [ ] Offline functionality tested
- [ ] Performance optimized (Lighthouse PWA score > 90)

This comprehensive approach ensures your PWA is production-ready with full offline support, installability, and push notification capability.
