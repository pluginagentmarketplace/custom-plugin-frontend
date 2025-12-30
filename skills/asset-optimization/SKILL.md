---
name: asset-optimization
description: Master image optimization, modern formats (WebP, AVIF), responsive images, and CDN strategies.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 06-performance-agent
bond_type: SECONDARY_BOND
status: production
category: performance
tags:
  - asset-optimization
  - images
  - fonts
  - videos
  - cdn
  - compression
complexity: intermediate
estimated_time: 45-60min
prerequisites:
  - Understanding of web assets
  - Knowledge of HTTP caching
  - Basic performance concepts
related_skills:
  - image-optimization
  - core-web-vitals
  - bundle-analysis-splitting
production_config:
  compression_enabled: true
  cdn_enabled: true
  cache_strategy: aggressive
  asset_types:
    images: [webp, avif, jpeg, png, svg]
    fonts: [woff2, woff]
    videos: [webm, mp4]
  optimization_level: balanced
---

# Asset Optimization

Optimize images and media for performance.

## Input Schema

```yaml
context:
  project_path: string          # Root project directory
  asset_types: array            # [images, fonts, videos, icons]
  build_environment: string     # development, production
  target_platforms: array       # [web, mobile, desktop]

config:
  images:
    formats: array              # [webp, avif, jpeg, png]
    quality: number             # 1-100
    responsive: boolean
    lazy_loading: boolean

  fonts:
    formats: array              # [woff2, woff, ttf]
    subsetting: boolean
    preload: boolean
    display_strategy: string    # swap, optional, fallback

  videos:
    formats: array              # [webm, mp4, hevc]
    compression_level: string   # high, medium, low
    streaming: boolean

  general:
    minify: boolean
    strip_metadata: boolean
    generate_hashes: boolean

  cdn:
    enabled: boolean
    provider: string            # cloudinary, cloudflare, custom
    transformations: object

options:
  preserve_originals: boolean
  generate_reports: boolean
  auto_optimize: boolean
  watch_mode: boolean
```

## Output Schema

```yaml
optimization_results:
  images:
    total_processed: number
    total_savings: number
    formats_generated: array
    average_reduction: number

  fonts:
    total_processed: number
    subset_savings: number
    formats_generated: array

  videos:
    total_processed: number
    compression_savings: number
    streaming_enabled: boolean

  general:
    total_original_size: number
    total_optimized_size: number
    total_savings_bytes: number
    savings_percentage: number

implementation:
  files_updated: array
  configuration_changes: array
  html_snippets: array
  css_snippets: array

recommendations:
  - category: string            # images, fonts, videos, general
    priority: string            # critical, high, medium, low
    description: string
    estimated_savings: string
    implementation_steps: array

cdn_setup:
  provider: string
  endpoints: array
  transformation_examples: array
  cache_config: object
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| AO-001 | Asset file not found | Invalid file path or missing asset | Verify file path and asset existence |
| AO-002 | Unsupported asset type | Attempting to optimize unsupported format | Check supported asset types in documentation |
| AO-003 | Optimization failed | Error during asset processing | Review asset integrity and optimization settings |
| AO-004 | Insufficient disk space | Not enough space for optimized files | Free up disk space or reduce output formats |
| AO-005 | Font subsetting error | Invalid font file or subsetting config | Verify font file format and subsetting configuration |
| AO-006 | Video encoding failed | Codec or encoding issue | Check video codec support and encoding settings |
| AO-007 | CDN configuration error | Invalid CDN credentials or endpoint | Verify CDN provider settings and credentials |
| AO-008 | Cache configuration error | Invalid cache headers or strategy | Review cache configuration and headers |
| AO-009 | Base64 encoding error | File too large for inline encoding | Use external file reference instead |
| AO-010 | SVG optimization error | Malformed SVG or invalid optimization | Check SVG structure and optimization settings |

## MANDATORY

### Modern Image Formats
- **WebP**: 25-35% smaller than JPEG
  - Wide browser support (>95%)
  - Supports transparency and animation
  - Quality range: 80-85 recommended

- **AVIF**: 50% smaller than JPEG
  - Superior compression
  - Growing browser support (>85%)
  - Quality range: 75-80 recommended

- **Format Fallbacks**: Always provide JPEG/PNG
  ```html
  <picture>
    <source srcset="hero.avif" type="image/avif">
    <source srcset="hero.webp" type="image/webp">
    <img src="hero.jpg" alt="Hero image">
  </picture>
  ```

### Image Compression
- **Lossy compression**: JPEG, WebP, AVIF
  - Remove unnecessary metadata
  - Use progressive encoding
  - Optimize color palette

- **Lossless compression**: PNG, WebP lossless
  - Reduce color depth when possible
  - Use appropriate compression level
  - Consider format conversion

### Responsive Images
- **srcset and sizes**: Serve appropriate sizes
  ```html
  <img
    srcset="small.webp 640w, medium.webp 1024w, large.webp 1536w"
    sizes="(max-width: 640px) 100vw, 50vw"
    src="medium.jpg"
    alt="Responsive"
    width="1024"
    height="768"
  >
  ```

- **Breakpoints**: Define logical size tiers
- **Art direction**: Use picture element for different crops
- **Image dimensions**: Always specify to prevent CLS

### Lazy Loading
- **Native lazy loading**: Use loading attribute
  ```html
  <img src="image.jpg" loading="lazy" alt="Lazy loaded">
  ```

- **Above-the-fold**: Don't lazy load critical images
- **Intersection Observer**: For advanced control
- **Placeholders**: Use LQIP or blur-up techniques

### Basic CDN Concepts
- **Content Delivery Networks**: Distribute assets globally
- **Edge caching**: Reduce latency
- **Automatic optimization**: Format and quality adaptation
- **URL-based transformations**: Resize and crop on-demand

## OPTIONAL

### Image CDN Services
- **Cloudinary**: Comprehensive image management
  ```html
  <img src="https://res.cloudinary.com/demo/image/upload/
            w_800,q_auto,f_auto/sample.jpg">
  ```

- **Imgix**: Real-time image processing
  ```html
  <img src="https://assets.imgix.net/image.jpg?
            w=800&auto=format,compress">
  ```

- **Cloudflare Images**: Edge-based optimization

### SVG Optimization
- **SVGO**: Automated SVG optimization
- **Remove unnecessary metadata**: IDs, comments
- **Inline critical SVGs**: Reduce HTTP requests
- **Sprite sheets**: Combine multiple SVGs

### Font Optimization
- **WOFF2 format**: 30% smaller than WOFF
- **Font subsetting**: Include only used characters
- **Preload critical fonts**: Reduce FOIT/FOUT
- **font-display**: Control font loading behavior

### Video Optimization
- **Modern codecs**: WebM (VP9), HEVC
- **Adaptive streaming**: HLS, DASH
- **Lazy loading**: Use Intersection Observer
- **Poster images**: Provide thumbnail

### Base64 Encoding Decisions
- **Small icons**: < 2KB inline as base64
- **Larger images**: Use external files
- **Trade-offs**: Increased HTML size vs HTTP requests

## ADVANCED

### Automated Image Pipelines
- Build-time optimization with Webpack/Vite
- CI/CD integration for continuous optimization
- Automatic format conversion
- Performance budgets enforcement

### Next-gen Format Detection
- Client hints for capability detection
- Progressive enhancement strategies
- Automatic fallback generation

### Adaptive Serving
- Network-aware loading
- Device-specific optimization
- User preference detection (reduced data mode)

### Edge Computing
- Edge-side transformations
- Dynamic image resizing
- Geo-specific routing
- Real-time optimization

### Build-time Optimization
- Asset fingerprinting
- Critical CSS extraction
- Tree shaking for unused assets
- Automatic sprite generation

### Performance Monitoring
- Asset load time tracking
- Cache hit rate monitoring
- CDN performance metrics
- User-centric metrics (LCP impact)

## Test Templates

### Asset Optimization Tests
```javascript
// asset-optimization.test.js
const { optimizeImage, optimizeFont, optimizeVideo } = require('./optimizer');

describe('Asset Optimization', () => {
  describe('Image Optimization', () => {
    test('should reduce image size', async () => {
      const result = await optimizeImage('test.jpg', {
        formats: ['webp', 'avif'],
        quality: 85
      });

      expect(result.savings).toBeGreaterThan(0);
      expect(result.formats).toContain('webp');
      expect(result.formats).toContain('avif');
    });

    test('should maintain aspect ratio', async () => {
      const original = await getImageDimensions('test.jpg');
      const optimized = await optimizeImage('test.jpg', { resize: 800 });

      const originalRatio = original.width / original.height;
      const optimizedRatio = optimized.width / optimized.height;

      expect(optimizedRatio).toBeCloseTo(originalRatio, 2);
    });
  });

  describe('Font Optimization', () => {
    test('should subset font correctly', async () => {
      const result = await optimizeFont('font.ttf', {
        subset: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      });

      expect(result.size).toBeLessThan(result.originalSize);
      expect(result.format).toBe('woff2');
    });
  });

  describe('Video Optimization', () => {
    test('should compress video', async () => {
      const result = await optimizeVideo('video.mp4', {
        codec: 'vp9',
        quality: 'medium'
      });

      expect(result.size).toBeLessThan(result.originalSize);
      expect(result.format).toBe('webm');
    });
  });
});
```

### CDN Integration Tests
```javascript
// cdn-integration.test.js
describe('CDN Integration', () => {
  test('should generate correct CDN URLs', () => {
    const cdnUrl = generateCDNUrl('image.jpg', {
      width: 800,
      format: 'webp',
      quality: 85
    });

    expect(cdnUrl).toContain('w_800');
    expect(cdnUrl).toContain('f_webp');
    expect(cdnUrl).toContain('q_85');
  });

  test('should handle responsive URLs', () => {
    const urls = generateResponsiveCDNUrls('image.jpg', {
      breakpoints: [640, 1024, 1536]
    });

    expect(urls).toHaveLength(3);
    expect(urls[0]).toContain('w_640');
  });
});
```

### Performance Budget Tests
```javascript
// performance-budget.test.js
describe('Performance Budgets', () => {
  const budgets = {
    images: 500 * 1024,      // 500KB
    fonts: 100 * 1024,       // 100KB
    videos: 2 * 1024 * 1024  // 2MB
  };

  test('should meet image budget', async () => {
    const totalImageSize = await getTotalAssetSize('**/*.{jpg,png,webp}');
    expect(totalImageSize).toBeLessThan(budgets.images);
  });

  test('should meet font budget', async () => {
    const totalFontSize = await getTotalAssetSize('**/*.{woff,woff2}');
    expect(totalFontSize).toBeLessThan(budgets.fonts);
  });
});
```

## Best Practices

### 1. Image Optimization Strategy

**Choose the right format:**
```javascript
const imageConfig = {
  photos: { format: 'webp', quality: 85 },
  illustrations: { format: 'avif', quality: 80 },
  logos: { format: 'svg', optimize: true },
  icons: { format: 'svg', sprite: true }
};
```

**Implement responsive images:**
```html
<picture>
  <source
    media="(min-width: 1024px)"
    srcset="large.avif 1536w, large.webp 1536w"
    type="image/avif"
  >
  <source
    media="(min-width: 640px)"
    srcset="medium.webp 1024w"
    type="image/webp"
  >
  <img src="small.jpg" alt="Responsive image" loading="lazy">
</picture>
```

### 2. Font Optimization

**Load fonts efficiently:**
```html
<!-- Preload critical fonts -->
<link rel="preload" href="/fonts/primary.woff2" as="font" type="font/woff2" crossorigin>

<!-- Use font-display -->
<style>
  @font-face {
    font-family: 'Primary';
    src: url('/fonts/primary.woff2') format('woff2');
    font-display: swap;
    font-weight: 400;
  }
</style>
```

**Subset fonts:**
```javascript
// Use tools like glyphhanger or fonttools
const subsetFont = require('subset-font');

const subset = await subsetFont(fontBuffer,
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
);
```

### 3. Video Optimization

**Provide multiple formats:**
```html
<video controls poster="thumbnail.jpg">
  <source src="video.webm" type="video/webm">
  <source src="video.mp4" type="video/mp4">
  Your browser doesn't support video.
</video>
```

**Lazy load videos:**
```javascript
const videoObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const video = entry.target;
      video.src = video.dataset.src;
      video.load();
      videoObserver.unobserve(video);
    }
  });
});

document.querySelectorAll('video[data-src]').forEach(v => {
  videoObserver.observe(v);
});
```

### 4. CDN Configuration

**Cloudinary setup:**
```javascript
// cloudinary.config.js
module.exports = {
  cloud_name: 'your-cloud',
  api_key: 'your-key',
  transformations: {
    thumbnail: 'w_200,h_200,c_fill,q_auto',
    hero: 'w_1920,h_1080,c_fill,q_auto,f_auto',
    responsive: 'w_auto,dpr_auto,q_auto,f_auto'
  }
};
```

**Imgix setup:**
```javascript
// imgix.config.js
const ImgixClient = require('@imgix/js-core');

const client = new ImgixClient({
  domain: 'your-domain.imgix.net',
  secureURLToken: 'your-token'
});

const url = client.buildURL('image.jpg', {
  w: 800,
  auto: ['format', 'compress'],
  q: 85
});
```

### 5. Caching Strategy

**HTTP cache headers:**
```nginx
# nginx configuration
location ~* \.(jpg|jpeg|png|webp|avif)$ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}

location ~* \.(woff|woff2)$ {
  expires 1y;
  add_header Cache-Control "public, immutable";
  add_header Access-Control-Allow-Origin "*";
}
```

## Production Configuration

### Build Tool Integration
```javascript
// vite.config.js
import { defineConfig } from 'vite';
import imagemin from 'vite-plugin-imagemin';

export default defineConfig({
  plugins: [
    imagemin({
      gifsicle: { optimizationLevel: 7 },
      mozjpeg: { quality: 80 },
      pngquant: { quality: [0.8, 0.9], speed: 4 },
      svgo: {
        plugins: [
          { name: 'removeViewBox', active: false },
          { name: 'removeEmptyAttrs', active: true }
        ]
      },
      webp: { quality: 85 },
      avif: { quality: 80 }
    })
  ],
  build: {
    rollupOptions: {
      output: {
        assetFileNames: 'assets/[name]-[hash][extname]'
      }
    }
  }
});
```

### Automated Optimization Script
```javascript
// optimize-assets.js
const sharp = require('sharp');
const { glob } = require('glob');
const path = require('path');

async function optimizeAssets() {
  const images = await glob('src/assets/**/*.{jpg,png}');

  for (const image of images) {
    const outputDir = path.dirname(image.replace('src/', 'dist/'));
    const basename = path.basename(image, path.extname(image));

    // WebP
    await sharp(image)
      .webp({ quality: 85 })
      .toFile(path.join(outputDir, `${basename}.webp`));

    // AVIF
    await sharp(image)
      .avif({ quality: 80 })
      .toFile(path.join(outputDir, `${basename}.avif`));

    // Optimized JPEG
    await sharp(image)
      .jpeg({ quality: 80, progressive: true })
      .toFile(path.join(outputDir, `${basename}.jpg`));
  }

  console.log(`Optimized ${images.length} images`);
}

optimizeAssets();
```

## Assets

See `assets/asset-optimization-config.yaml` for optimization patterns and configuration examples.

## Resources

### Official Documentation
- [Image Optimization](https://web.dev/image-optimization/) - Web.dev guide
- [Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images) - MDN docs
- [Font Best Practices](https://web.dev/font-best-practices/) - Font optimization

### Tools
- [Sharp](https://sharp.pixelplumbing.com/) - High-performance image processing
- [ImageOptim](https://imageoptim.com/) - Desktop image optimizer
- [Squoosh](https://squoosh.app/) - Web-based image compression
- [SVGO](https://github.com/svg/svgo) - SVG optimizer

### CDN Services
- [Cloudinary](https://cloudinary.com/) - Image and video management
- [Imgix](https://imgix.com/) - Real-time image processing
- [Cloudflare Images](https://www.cloudflare.com/products/cloudflare-images/) - Edge optimization

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
