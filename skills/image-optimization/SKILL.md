---
name: image-optimization
description: Master modern image formats (WebP, AVIF), responsive images, lazy-loading, compression, and CDN strategies.
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 06-performance-agent
bond_type: SECONDARY_BOND
status: production
category: performance
tags:
  - image-optimization
  - webp
  - avif
  - lazy-loading
  - responsive-images
  - compression
complexity: intermediate
estimated_time: 40-55min
prerequisites:
  - Understanding of HTML image elements
  - Basic knowledge of image formats
  - Familiarity with responsive design
related_skills:
  - asset-optimization
  - core-web-vitals
  - bundle-analysis-splitting
production_config:
  default_format: webp
  fallback_format: jpg
  quality_settings:
    webp: 85
    avif: 80
    jpeg: 80
  lazy_loading: true
  responsive_breakpoints: [640, 768, 1024, 1280, 1536]
  cdn_enabled: true
---

# Image Optimization

Optimize images and media for maximum performance and quality.

## Input Schema

```yaml
context:
  images: array                 # List of image paths to optimize
  project_type: string          # web, mobile, static-site, etc.
  target_formats: array         # [webp, avif, jpeg, png]
  optimization_level: string    # aggressive, balanced, quality-first

config:
  compression:
    quality: number             # 1-100 (default: 85)
    progressive: boolean        # Progressive JPEG
    strip_metadata: boolean     # Remove EXIF data

  responsive:
    breakpoints: array          # [640, 768, 1024, 1280, 1536]
    sizes: string               # Sizes attribute value
    generate_srcset: boolean    # Auto-generate srcset

  formats:
    webp:
      enabled: boolean
      quality: number
    avif:
      enabled: boolean
      quality: number
    fallback: string            # jpeg or png

  lazy_loading:
    enabled: boolean
    threshold: string           # Distance from viewport
    placeholder: string         # blur, lqip, none

  cdn:
    enabled: boolean
    provider: string            # cloudinary, imgix, custom
    base_url: string

options:
  preserve_originals: boolean   # Keep original files
  generate_thumbnails: boolean  # Create thumbnail versions
  optimize_svg: boolean         # Optimize SVG files
  generate_placeholders: boolean # Generate blur placeholders
```

## Output Schema

```yaml
optimized_images:
  - original_path: string
    original_size: number       # Bytes
    formats:
      - type: string            # webp, avif, jpeg
        path: string
        size: number
        quality: number
    responsive:
      srcset: string
      sizes: string
      breakpoints: array
    lazy_loading:
      enabled: boolean
      placeholder_url: string
    savings:
      bytes: number
      percentage: number

summary:
  total_original_size: number
  total_optimized_size: number
  total_savings: number
  savings_percentage: number
  images_processed: number
  formats_generated: array

implementation:
  html_snippets: array
  css_snippets: array
  javascript_snippets: array

recommendations:
  - category: string
    description: string
    priority: string            # high, medium, low
    implementation: string

cdn_config:
  provider: string
  transformation_urls: array
  example_usage: string
```

## Error Handling

| Error Code | Description | Cause | Resolution |
|------------|-------------|-------|------------|
| IMG-001 | Image file not found | Invalid file path | Verify file path exists and is accessible |
| IMG-002 | Unsupported format | Attempting to convert to unsupported format | Use supported formats: WebP, AVIF, JPEG, PNG |
| IMG-003 | Compression failed | Error during image compression | Check image integrity and try lower quality setting |
| IMG-004 | WebP encoder not available | Missing WebP library | Install: `npm install sharp` or configure encoder |
| IMG-005 | AVIF encoder not available | Missing AVIF library | Install latest sharp with AVIF support |
| IMG-006 | Invalid quality setting | Quality value out of range | Use quality value between 1-100 |
| IMG-007 | Insufficient memory | Large image processing | Reduce image size or increase memory limit |
| IMG-008 | CDN configuration error | Invalid CDN settings | Verify CDN provider credentials and endpoint |
| IMG-009 | Responsive breakpoint error | Invalid breakpoint values | Use valid pixel values in ascending order |
| IMG-010 | Lazy loading script error | Missing intersection observer support | Use polyfill for older browsers |

## MANDATORY

### Modern Image Formats
- **WebP**: Modern format with excellent compression
  - 25-35% smaller than JPEG
  - Supports transparency and animation
  - Wide browser support (>95%)

- **AVIF**: Next-generation format
  - 50% smaller than JPEG for same quality
  - Superior compression
  - Growing browser support (>85%)

- **Format Fallbacks**: Always provide JPEG/PNG fallback
  ```html
  <picture>
    <source srcset="image.avif" type="image/avif">
    <source srcset="image.webp" type="image/webp">
    <img src="image.jpg" alt="Description">
  </picture>
  ```

### Responsive Images
- **srcset and sizes attributes**: Serve appropriate image sizes
  ```html
  <img
    srcset="small.jpg 640w, medium.jpg 1024w, large.jpg 1536w"
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
    src="medium.jpg"
    alt="Responsive image"
  >
  ```

- **Picture element**: Art direction and format selection
- **Breakpoint strategy**: Define logical size breakpoints
- **Density descriptors**: Support high-DPI displays

### Lazy Loading
- **Native lazy loading**: Use loading="lazy" attribute
  ```html
  <img src="image.jpg" loading="lazy" alt="Lazy loaded image">
  ```

- **Intersection Observer**: For advanced control
- **Placeholder strategies**: LQIP, blur-up, skeleton screens
- **Critical images**: Don't lazy load above-the-fold content

### Image Compression
- **Lossy compression**: JPEG, WebP, AVIF (80-85% quality recommended)
- **Lossless compression**: PNG optimization, WebP lossless
- **Metadata stripping**: Remove EXIF data in production
- **Progressive loading**: Enable progressive JPEG

## OPTIONAL

### Advanced Optimization
- **Image CDN services**: Cloudinary, Imgix, Cloudflare Images
- **Adaptive image serving**: Based on device, network, viewport
- **Blur-up and progressive loading effects**
- **Thumbnail generation**: Multiple sizes for different uses
- **Sprite sheets**: Combine small icons
- **SVG optimization**: SVGO, remove unnecessary data

### Performance Enhancements
- **Preloading critical images**: LCP images
- **Priority hints**: fetchpriority attribute
- **Image dimensions**: Prevent layout shift
- **Aspect ratio boxes**: CSS aspect-ratio property

## ADVANCED

### Automated Pipelines
- Build-time image optimization
- CI/CD integration
- Automatic format conversion
- Dynamic resizing based on usage analytics
- Performance monitoring and alerts

### Edge Computing Integration
- Edge-side image transformations
- Adaptive quality based on network conditions
- Device-specific optimization
- Geo-specific CDN routing

### Advanced Techniques
- Client hints for adaptive serving
- Machine learning for quality optimization
- Perceptual quality metrics
- Advanced caching strategies

## Test Templates

### Image Optimization Tests
```javascript
// image-optimization.test.js
const sharp = require('sharp');
const fs = require('fs').promises;

describe('Image Optimization', () => {
  test('should convert JPEG to WebP', async () => {
    const input = 'test-image.jpg';
    const output = 'test-image.webp';

    await sharp(input)
      .webp({ quality: 85 })
      .toFile(output);

    const inputStats = await fs.stat(input);
    const outputStats = await fs.stat(output);

    expect(outputStats.size).toBeLessThan(inputStats.size);
  });

  test('should generate responsive image set', async () => {
    const breakpoints = [640, 1024, 1536];
    const results = await Promise.all(
      breakpoints.map(width =>
        sharp('test-image.jpg')
          .resize(width)
          .webp({ quality: 85 })
          .toFile(`test-image-${width}w.webp`)
      )
    );

    expect(results).toHaveLength(breakpoints.length);
  });

  test('should maintain quality above threshold', async () => {
    const quality = 85;
    const metadata = await sharp('test-image.jpg')
      .webp({ quality })
      .toBuffer({ resolveWithObject: true });

    expect(metadata.info.format).toBe('webp');
  });
});
```

### Lazy Loading Tests
```javascript
// lazy-loading.test.js
describe('Lazy Loading', () => {
  test('should lazy load images below fold', () => {
    const images = document.querySelectorAll('img[loading="lazy"]');

    images.forEach(img => {
      const rect = img.getBoundingClientRect();
      const isAboveFold = rect.top < window.innerHeight;

      if (!isAboveFold) {
        expect(img.getAttribute('loading')).toBe('lazy');
      }
    });
  });

  test('should not lazy load LCP image', () => {
    const lcpImage = document.querySelector('.hero-image');
    expect(lcpImage.getAttribute('loading')).not.toBe('lazy');
  });
});
```

### Format Support Tests
```javascript
// format-support.test.js
describe('Image Format Support', () => {
  test('should provide WebP with JPEG fallback', () => {
    const picture = document.querySelector('picture');
    const webpSource = picture.querySelector('source[type="image/webp"]');
    const fallbackImg = picture.querySelector('img');

    expect(webpSource).toBeTruthy();
    expect(fallbackImg.src).toContain('.jpg');
  });

  test('should serve AVIF when supported', async () => {
    const supportsAVIF = await checkAVIFSupport();
    const picture = document.querySelector('picture');
    const avifSource = picture.querySelector('source[type="image/avif"]');

    if (supportsAVIF) {
      expect(avifSource).toBeTruthy();
    }
  });
});
```

## Best Practices

### 1. Choose the Right Format

**WebP for general use:**
```javascript
// Convert to WebP with Sharp
const sharp = require('sharp');

await sharp('input.jpg')
  .webp({ quality: 85 })
  .toFile('output.webp');
```

**AVIF for maximum compression:**
```javascript
await sharp('input.jpg')
  .avif({ quality: 80 })
  .toFile('output.avif');
```

**Always provide fallbacks:**
```html
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Description" width="800" height="600">
</picture>
```

### 2. Implement Responsive Images

**Basic srcset:**
```html
<img
  srcset="
    image-320w.jpg 320w,
    image-640w.jpg 640w,
    image-1024w.jpg 1024w,
    image-1536w.jpg 1536w
  "
  sizes="(max-width: 640px) 100vw,
         (max-width: 1024px) 50vw,
         33vw"
  src="image-640w.jpg"
  alt="Responsive image"
  width="1024"
  height="768"
>
```

**With picture element for art direction:**
```html
<picture>
  <source
    media="(max-width: 640px)"
    srcset="mobile-image.webp"
    type="image/webp"
  >
  <source
    media="(max-width: 640px)"
    srcset="mobile-image.jpg"
  >
  <source
    srcset="desktop-image.webp"
    type="image/webp"
  >
  <img src="desktop-image.jpg" alt="Art directed image">
</picture>
```

### 3. Lazy Loading Implementation

**Native lazy loading:**
```html
<!-- Don't lazy load above-the-fold images -->
<img src="hero.jpg" alt="Hero" fetchpriority="high">

<!-- Lazy load below-the-fold images -->
<img src="feature.jpg" alt="Feature" loading="lazy">
```

**Intersection Observer for advanced control:**
```javascript
const imageObserver = new IntersectionObserver((entries, observer) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const img = entry.target;
      img.src = img.dataset.src;
      img.srcset = img.dataset.srcset;
      img.classList.remove('lazy');
      observer.unobserve(img);
    }
  });
}, {
  rootMargin: '50px 0px',
  threshold: 0.01
});

document.querySelectorAll('img.lazy').forEach(img => {
  imageObserver.observe(img);
});
```

**Blur-up placeholder:**
```html
<div class="image-wrapper">
  <img
    src="placeholder-blur.jpg"
    data-src="full-image.jpg"
    class="lazy blur"
    alt="Image with blur-up effect"
  >
</div>

<style>
  .blur {
    filter: blur(20px);
    transition: filter 0.3s;
  }
  .blur.loaded {
    filter: blur(0);
  }
</style>
```

### 4. Compression Best Practices

**Quality settings by format:**
```javascript
const compressionConfig = {
  jpeg: {
    quality: 80,
    progressive: true,
    mozjpeg: true
  },
  webp: {
    quality: 85,
    effort: 4
  },
  avif: {
    quality: 80,
    effort: 4
  },
  png: {
    compressionLevel: 9,
    palette: true
  }
};
```

**Automated batch optimization:**
```javascript
const imagemin = require('imagemin');
const imageminWebp = require('imagemin-webp');
const imageminAvif = require('imagemin-avif');

async function optimizeImages() {
  await imagemin(['images/*.{jpg,png}'], {
    destination: 'images/optimized',
    plugins: [
      imageminWebp({ quality: 85 }),
      imageminAvif({ quality: 80 })
    ]
  });
}
```

### 5. Prevent Layout Shift

**Always specify dimensions:**
```html
<img
  src="image.jpg"
  alt="Image"
  width="1024"
  height="768"
  loading="lazy"
>
```

**Use aspect-ratio CSS:**
```css
.image-container {
  aspect-ratio: 16 / 9;
  overflow: hidden;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
```

### 6. CDN Integration

**Cloudinary transformation:**
```html
<img
  src="https://res.cloudinary.com/demo/image/upload/
       w_800,q_auto,f_auto/sample.jpg"
  alt="Cloudinary optimized"
>
```

**Imgix transformation:**
```html
<img
  src="https://assets.imgix.net/image.jpg?
       w=800&auto=format,compress&q=85"
  alt="Imgix optimized"
>
```

## Production Configuration

### Sharp Image Processing
```javascript
// image-processor.js
const sharp = require('sharp');
const path = require('path');

class ImageProcessor {
  constructor(config = {}) {
    this.quality = {
      webp: config.webpQuality || 85,
      avif: config.avifQuality || 80,
      jpeg: config.jpegQuality || 80
    };
    this.breakpoints = config.breakpoints || [640, 768, 1024, 1280, 1536];
  }

  async optimizeImage(inputPath, outputDir) {
    const image = sharp(inputPath);
    const metadata = await image.metadata();
    const basename = path.basename(inputPath, path.extname(inputPath));

    const results = [];

    // Generate responsive sizes
    for (const width of this.breakpoints) {
      if (width <= metadata.width) {
        // WebP
        await image
          .clone()
          .resize(width)
          .webp({ quality: this.quality.webp })
          .toFile(path.join(outputDir, `${basename}-${width}w.webp`));

        // AVIF
        await image
          .clone()
          .resize(width)
          .avif({ quality: this.quality.avif })
          .toFile(path.join(outputDir, `${basename}-${width}w.avif`));

        // JPEG fallback
        await image
          .clone()
          .resize(width)
          .jpeg({ quality: this.quality.jpeg, progressive: true })
          .toFile(path.join(outputDir, `${basename}-${width}w.jpg`));

        results.push({ width, formats: ['avif', 'webp', 'jpg'] });
      }
    }

    return results;
  }

  generateSrcset(basename, widths, format) {
    return widths
      .map(w => `${basename}-${w}w.${format} ${w}w`)
      .join(', ');
  }
}

module.exports = ImageProcessor;
```

### Lazy Loading Implementation
```javascript
// lazy-loader.js
class LazyLoader {
  constructor(options = {}) {
    this.rootMargin = options.rootMargin || '50px';
    this.threshold = options.threshold || 0.01;
    this.loadingClass = options.loadingClass || 'loading';
    this.loadedClass = options.loadedClass || 'loaded';

    this.observer = new IntersectionObserver(
      this.handleIntersection.bind(this),
      {
        rootMargin: this.rootMargin,
        threshold: this.threshold
      }
    );
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        this.loadImage(entry.target);
        this.observer.unobserve(entry.target);
      }
    });
  }

  loadImage(img) {
    img.classList.add(this.loadingClass);

    const tempImg = new Image();
    tempImg.onload = () => {
      if (img.dataset.srcset) {
        img.srcset = img.dataset.srcset;
      }
      img.src = img.dataset.src;
      img.classList.remove(this.loadingClass);
      img.classList.add(this.loadedClass);
    };

    tempImg.src = img.dataset.src;
  }

  observe(images) {
    images.forEach(img => this.observer.observe(img));
  }
}

// Usage
const lazyLoader = new LazyLoader({
  rootMargin: '100px',
  threshold: 0.01
});

const lazyImages = document.querySelectorAll('img[data-src]');
lazyLoader.observe(lazyImages);
```

### Build Tool Integration
```javascript
// webpack.config.js
const ImageMinimizerPlugin = require('image-minimizer-webpack-plugin');

module.exports = {
  module: {
    rules: [
      {
        test: /\.(jpe?g|png)$/i,
        type: 'asset',
        generator: {
          filename: 'images/[name]-[hash][ext]'
        }
      }
    ]
  },
  plugins: [
    new ImageMinimizerPlugin({
      minimizer: {
        implementation: ImageMinimizerPlugin.sharpMinify,
        options: {
          encodeOptions: {
            webp: { quality: 85 },
            avif: { quality: 80 },
            jpeg: { quality: 80, progressive: true },
            png: { compressionLevel: 9 }
          }
        }
      },
      generator: [
        {
          preset: 'webp',
          implementation: ImageMinimizerPlugin.sharpGenerate,
          options: {
            encodeOptions: {
              webp: { quality: 85 }
            }
          }
        }
      ]
    })
  ]
};
```

## Scripts

See `scripts/README.md` for available tools:
- `optimize-images.js` - Batch image optimization
- `generate-responsive.js` - Generate responsive image sets
- `convert-format.js` - Convert between image formats
- `analyze-images.js` - Analyze image usage and sizes

## References

- See `references/GUIDE.md` for optimization techniques
- See `references/PATTERNS.md` for real-world patterns
- See `references/EXAMPLES.md` for implementation examples

## Resources

### Official Documentation
- [Image Optimization Guide](https://web.dev/image-optimization/) - Comprehensive guide
- [Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images) - MDN documentation
- [WebP Format](https://developers.google.com/speed/webp) - Google WebP docs

### Tools
- [Sharp](https://sharp.pixelplumbing.com/) - High-performance image processing
- [Squoosh](https://squoosh.app/) - Online image compression
- [ImageOptim](https://imageoptim.com/) - Desktop image optimizer

### Services
- [Cloudinary](https://cloudinary.com/) - Image CDN and transformation
- [Imgix](https://imgix.com/) - Real-time image processing
- [Cloudflare Images](https://www.cloudflare.com/products/cloudflare-images/) - Edge image optimization

---
**Status:** Active | **Version:** 2.0.0 | **Last Updated:** 2025-12-30
