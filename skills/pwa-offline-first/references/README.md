# PWA Offline-First References

Comprehensive documentation for Progressive Web App development with offline-first architecture.

## Documentation Files

### `GUIDE.md`
Complete technical guide covering:
- Service Worker registration and lifecycle (install, activate, fetch)
- Web App Manifest configuration and all required fields
- Offline-first strategies (cache-first, network-first, stale-while-revalidate)
- Push notifications implementation
- App installation and home screen setup
- HTTPS and security requirements

### `PATTERNS.md`
Enterprise patterns and real code examples:
- Service worker patterns (precaching, runtime caching, cache versioning)
- IndexedDB patterns for offline data storage
- Update strategies (skip waiting, clients claim)
- Push notification patterns
- Install prompt handling
- Background sync for offline-first data sync

## Quick Reference

### Caching Strategies

| Strategy | Use Case | Pros | Cons |
|----------|----------|------|------|
| Cache-first | Static assets (JS, CSS, images) | Fast, works offline | Stale content |
| Network-first | API calls, dynamic content | Always fresh | Requires network |
| Stale-while-revalidate | HTML pages | Fast + updated | Background network call |

### Service Worker Lifecycle

1. **Parse** - Check for updates
2. **Install** - Precache assets
3. **Activate** - Clean up old caches
4. **Fetch** - Intercept network requests

### Required Manifest Fields

```json
{
  "name": "Full app name",
  "short_name": "Short name",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [...]
}
```

## Key Topics Covered

- Service Worker events and lifecycle
- Manifest.json configuration
- Offline-first strategies
- Cache management and versioning
- Push notifications
- App installation
- IndexedDB for offline storage
- Update strategies
- Background synchronization
