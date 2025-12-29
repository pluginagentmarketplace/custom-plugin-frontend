# Image Optimization Technical Guide

Comprehensive guide to modern image formats, responsive images, lazy-loading, and CDN strategies for web performance.

## Table of Contents
1. [Modern Image Formats](#modern-image-formats)
2. [Responsive Images](#responsive-images)
3. [Lazy Loading](#lazy-loading)
4. [Image Compression](#image-compression)
5. [CDN Integration](#cdn-integration)
6. [Performance Metrics](#performance-metrics)

---

## Modern Image Formats

### AVIF (AV1 Image Format)
AVIF is the newest image format offering exceptional compression ratios. It's based on the AV1 video codec and provides approximately 20% better compression than WebP.

**Characteristics:**
- Best compression ratio (20-30% smaller than WebP)
- Modern format with excellent quality
- Browser support: Chrome 85+, Firefox 93+, Safari 16+
- Typical file sizes: 30-50KB for hero images

**When to use AVIF:**
- Hero images and large media assets
- When maximum compression is critical
- For performance-first applications

**HTML Implementation:**
```html
<picture>
  <source srcset="/image.avif" type="image/avif">
  <source srcset="/image.webp" type="image/webp">
  <img src="/image.jpg" alt="Description">
</picture>
```

**Quality settings (Sharp):**
```typescript
image
  .avif({ quality: 75 }) // 75 recommended for AVIF
  .toFile('output.avif');
```

### WebP Format
WebP provides approximately 25-35% better compression than JPEG while maintaining quality. It's widely supported in modern browsers.

**Characteristics:**
- 25-35% smaller than JPEG
- Excellent quality preservation
- Widespread browser support (92%+)
- Typical sizes: 40-70KB for hero images

**HTML Implementation:**
```html
<picture>
  <source srcset="/image.webp" type="image/webp">
  <img src="/image.jpg" alt="Description">
</picture>

<!-- Or in CSS -->
<img srcset="/image.webp, /image.jpg" alt="Description">
```

**Quality settings (Sharp):**
```typescript
image
  .webp({ quality: 80 })
  .toFile('output.webp');
```

### JPEG Format (Fallback)
JPEG remains the universal fallback format with excellent browser compatibility.

**Optimization techniques:**
```typescript
image
  .jpeg({
    quality: 80, // 80 is good balance
    progressive: true // Progressive JPEG for perceived performance
  })
  .toFile('output.jpg');
```

Progressive JPEG displays content gradually as it loads, improving perceived performance.

### PNG Format
PNG supports transparency and is ideal for icons, logos, and graphics with solid colors.

**Optimization:**
```typescript
image
  .png({ compressionLevel: 9 }) // Maximum compression
  .toFile('output.png');
```

### Format Selection Decision Tree

```
Does image have transparency?
├─ YES → PNG (or APNG for animation)
└─ NO → Does file size matter?
    ├─ CRITICAL → AVIF (modern browsers), with WebP fallback
    └─ IMPORTANT → WebP with JPEG fallback
```

---

## Responsive Images

### srcset Attribute
The srcset attribute allows specifying multiple image options for different viewport sizes and device pixel densities.

**Width descriptors (most common):**
```html
<img
  src="/image-1920w.jpg"
  srcset="
    /image-640w.jpg 640w,
    /image-1024w.jpg 1024w,
    /image-1440w.jpg 1440w,
    /image-1920w.jpg 1920w"
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  alt="Description"
/>
```

**How browsers select:**
1. Browser evaluates `sizes` attribute to determine layout size
2. Looks for corresponding source in `srcset` that matches or exceeds CSS width
3. Loads selected image

**Pixel density descriptors:**
```html
<img
  src="/image.jpg"
  srcset="/image.jpg 1x, /image@2x.jpg 2x, /image@3x.jpg 3x"
  alt="Description"
/>
```
Used for high-DPI displays (Retina). Less common with modern CSS.

### sizes Attribute
The sizes attribute tells the browser what size the image will be displayed at, enabling proper source selection.

**Common patterns:**
```html
<!-- Full width until tablet breakpoint, then 50% width -->
<img
  sizes="(max-width: 768px) 100vw, 50vw"
  ...
/>

<!-- Complex responsive design -->
<img
  sizes="
    (max-width: 480px) 100vw,
    (max-width: 768px) 90vw,
    (max-width: 1024px) 70vw,
    50vw"
  ...
/>

<!-- Content width constraint -->
<img
  sizes="min(100vw, 1200px)"
  ...
/>
```

### Picture Element
The picture element enables format negotiation, allowing the browser to choose the best format.

**Format fallback chain:**
```html
<picture>
  <!-- AVIF: Best compression -->
  <source srcset="/image-640w.avif 640w, /image-1024w.avif 1024w" type="image/avif">

  <!-- WebP: Good compression -->
  <source srcset="/image-640w.webp 640w, /image-1024w.webp 1024w" type="image/webp">

  <!-- JPEG: Universal fallback -->
  <img
    src="/image-1024w.jpg"
    srcset="/image-640w.jpg 640w, /image-1024w.jpg 1024w"
    alt="Description"
    loading="lazy"
  />
</picture>
```

**Media query usage:**
```html
<picture>
  <!-- Art direction: different image for mobile -->
  <source media="(max-width: 768px)" srcset="/image-mobile.jpg">
  <source media="(min-width: 769px)" srcset="/image-desktop.jpg">
  <img src="/image-desktop.jpg" alt="Description">
</picture>
```

---

## Lazy Loading

### Native Loading Attribute
The simplest approach, supported natively in modern browsers.

```html
<img
  src="/image.jpg"
  alt="Description"
  loading="lazy"
  width="400"
  height="300"
/>
```

**How it works:**
- Browser defers loading until image is near viewport
- Typically loads when 50-100px from viewport edge
- Zero JavaScript required

**Supported in:** Chrome 76+, Firefox 75+, Safari 15.1+

### IntersectionObserver API
For more control, use IntersectionObserver for custom lazy loading.

```typescript
const imageElements = document.querySelectorAll('img[data-src]');

const imageObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      const img = entry.target as HTMLImageElement;
      img.src = img.dataset.src || '';
      img.addEventListener('load', () => {
        img.classList.add('loaded');
      });
      imageObserver.unobserve(img);
    }
  });
});

imageElements.forEach((img) => imageObserver.observe(img));
```

**HTML:**
```html
<img
  data-src="/image.jpg"
  src="/placeholder.jpg"
  alt="Description"
  loading="lazy"
/>
```

### Library-Based Lazy Loading
For older browser support, consider libraries like lozad.js or react-lazyload.

```typescript
// lozad.js example
import lozad from 'lozad';

const observer = lozad();
observer.observe();
```

**HTML:**
```html
<img class="lozad" data-src="/image.jpg" alt="Description">
```

---

## Image Compression

### Sharp Library Configuration
Sharp is the most performant Node.js image processing library.

```typescript
import sharp from 'sharp';

// Basic optimization
async function optimizeImage(inputPath: string) {
  return sharp(inputPath)
    .resize(1920, 1440, { withoutEnlargement: true })
    .webp({ quality: 80 })
    .toFile('output.webp');
}

// Multi-format with sizes
async function generateResponsiveImages(inputPath: string) {
  const sizes = [640, 1024, 1440, 1920];
  const formats = ['avif', 'webp', 'jpeg'];

  for (const size of sizes) {
    for (const format of formats) {
      await sharp(inputPath)
        .resize(size, size, { fit: 'inside' })
        [format]({ quality: format === 'avif' ? 75 : 80 })
        .toFile(`output-${size}w.${format}`);
    }
  }
}
```

### ImageMagick (Command-line)
For system-level image processing:

```bash
# Convert to WebP
magick convert input.jpg -quality 80 output.webp

# Create multiple sizes
magick convert input.jpg -resize 640x480 -quality 80 output-640w.jpg

# Optimize PNG
magick convert input.png -strip -quality 95 output.png
```

### Image Quality Recommendations
- **JPEG**: 75-85 quality (diminishing returns above 85)
- **WebP**: 75-85 quality
- **AVIF**: 60-75 quality (AVIF tolerates lower quality better)
- **PNG**: Maximum compression (9)

---

## CDN Integration

### CDN-Based Image Optimization
Modern CDNs (Cloudinary, Imgix, AWS CloudFront) provide runtime image optimization.

**Cloudinary example:**
```html
<img
  src="https://res.cloudinary.com/demo/image/fetch/w_auto,q_auto/https://example.com/image.jpg"
  alt="Description"
/>
```

**Imgix example:**
```html
<img
  src="https://demo.imgix.net/image.jpg?w=500&q=80&auto=format"
  srcset="
    https://demo.imgix.net/image.jpg?w=640&q=80&auto=format 640w,
    https://demo.imgix.net/image.jpg?w=1024&q=80&auto=format 1024w"
  alt="Description"
/>
```

### Static CDN Configuration
For serving pre-optimized images:

```typescript
// Configuration for CloudFront or similar
const cdnConfig = {
  domain: 'images.example.com',
  paths: {
    optimized: '/optimized/',
    originals: '/originals/',
  },
  formats: ['avif', 'webp', 'jpeg'],
  caching: {
    maxAge: 31536000, // 1 year for versioned assets
  },
};

function getCDNUrl(filename: string, size: number, format: string) {
  return `${cdnConfig.domain}${cdnConfig.paths.optimized}${filename}-${size}w.${format}`;
}
```

---

## Performance Metrics

### Key Image Performance Metrics
- **LCP (Largest Contentful Paint)** - Often an image
- **First Contentful Paint** - Impacted by image loading
- **Total Page Size** - Image optimization reduces this significantly

### Measuring Impact
```typescript
// Monitor image loading performance
const imageMetrics = {
  count: 0,
  totalSize: 0,
  avgLoadTime: 0,
};

document.querySelectorAll('img').forEach((img) => {
  const entry = performance.getEntriesByName(img.src)[0];
  if (entry) {
    imageMetrics.totalSize += entry.transferSize || 0;
  }
});

console.log(`Total image size: ${(imageMetrics.totalSize / 1024 / 1024).toFixed(2)}MB`);
```

### Target Metrics
- **Total image payload**: <50% of page size
- **Largest image**: <200KB (optimized)
- **Image LCP element**: <2.5s load time
- **Format support**: AVIF/WebP for 90%+ of images

This comprehensive guide covers modern image optimization techniques for production web applications.
