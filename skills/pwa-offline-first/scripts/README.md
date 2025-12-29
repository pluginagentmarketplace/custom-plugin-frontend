# PWA Offline-First Scripts

This directory contains validation and generation scripts for Progressive Web App development.

## Scripts

### `validate-pwa.sh`
Validates PWA implementation with real checks:
- Manifest.json structure and required fields
- Service worker registration and lifecycle
- Caching strategies (cache-first, network-first, stale-while-revalidate)
- Offline fallback pages
- HTTPS requirement verification
- Web app installation requirements

Usage:
```bash
./scripts/validate-pwa.sh /path/to/project
```

### `generate-pwa-config.sh`
Generates PWA configuration files and templates:
- Web app manifest (manifest.json)
- Service worker implementation with caching strategies
- Offline fallback HTML page
- Installation prompt code
- Push notification worker

Usage:
```bash
./scripts/generate-pwa-config.sh /path/to/project
```

## Implementation Checklist

- [ ] manifest.json created with required fields
- [ ] Service worker registered in main.js/index.js
- [ ] Offline page (/offline.html) created
- [ ] Cache strategies implemented
- [ ] HTTPS enabled
- [ ] Icons generated (192x192, 512x512)
- [ ] Install prompt handling added
- [ ] Cache versioning implemented
