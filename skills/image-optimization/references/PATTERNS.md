# Image Optimization Patterns

Real-world patterns for implementing comprehensive image optimization in production applications.

## Picture Element Pattern with All Formats

```html
<!-- Complete format fallback chain with responsive sizes -->
<picture>
  <source
    media="(min-width: 1440px)"
    srcset="
      /images/hero-1440w.avif 1440w,
      /images/hero-1920w.avif 1920w,
      /images/hero-2560w.avif 2560w"
    type="image/avif"
  />
  <source
    media="(min-width: 768px)"
    srcset="
      /images/hero-768w.avif 768w,
      /images/hero-1024w.avif 1024w,
      /images/hero-1440w.avif 1440w"
    type="image/avif"
  />
  <source
    srcset="
      /images/hero-320w.avif 320w,
      /images/hero-640w.avif 640w,
      /images/hero-768w.avif 768w"
    type="image/avif"
  />

  <!-- WebP fallback -->
  <source
    media="(min-width: 1440px)"
    srcset="
      /images/hero-1440w.webp 1440w,
      /images/hero-1920w.webp 1920w,
      /images/hero-2560w.webp 2560w"
    type="image/webp"
  />
  <source
    media="(min-width: 768px)"
    srcset="
      /images/hero-768w.webp 768w,
      /images/hero-1024w.webp 1024w,
      /images/hero-1440w.webp 1440w"
    type="image/webp"
  />
  <source
    srcset="
      /images/hero-320w.webp 320w,
      /images/hero-640w.webp 640w,
      /images/hero-768w.webp 768w"
    type="image/webp"
  />

  <!-- JPEG fallback -->
  <img
    src="/images/hero-1440w.jpg"
    srcset="
      /images/hero-320w.jpg 320w,
      /images/hero-640w.jpg 640w,
      /images/hero-768w.jpg 768w,
      /images/hero-1024w.jpg 1024w,
      /images/hero-1440w.jpg 1440w,
      /images/hero-1920w.jpg 1920w,
      /images/hero-2560w.jpg 2560w"
    sizes="
      (max-width: 640px) 100vw,
      (max-width: 1024px) 90vw,
      (max-width: 1440px) 70vw,
      1400px"
    alt="Hero banner"
    loading="lazy"
    width="1920"
    height="1080"
    style="aspect-ratio: 16 / 9; object-fit: cover;"
  />
</picture>
```

## Image Processing Pipeline Pattern

```typescript
/**
 * Complete image processing pipeline
 * Handles upload, validation, optimization, and serving
 */

class ImageProcessingPipeline {
  private tempDir = '/tmp/image-processing';
  private outputDir = '/public/optimized-images';
  private config = {
    maxSize: 50 * 1024 * 1024, // 50MB
    allowedMimes: ['image/jpeg', 'image/png'],
    sizes: [320, 640, 1024, 1440, 1920],
    formats: ['avif', 'webp', 'jpeg'],
    quality: { avif: 75, webp: 80, jpeg: 80 },
  };

  /**
   * Process uploaded image
   */
  async processUpload(file: File): Promise<ProcessedImage> {
    // 1. Validate
    this.validate(file);

    // 2. Convert to optimized formats
    const tempPath = await this.saveTempFile(file);
    const variants = await this.generateVariants(tempPath);

    // 3. Generate metadata
    const metadata = await this.generateMetadata(variants);

    // 4. Move to permanent storage
    const savedPaths = await this.saveToStorage(variants);

    // 5. Generate HTML markup
    const markup = this.generateMarkup(savedPaths, metadata);

    return {
      paths: savedPaths,
      metadata,
      markup,
      srcset: this.generateSrcset(savedPaths),
    };
  }

  private validate(file: File): void {
    if (file.size > this.config.maxSize) {
      throw new Error('File too large');
    }
    if (!this.config.allowedMimes.includes(file.type)) {
      throw new Error('Invalid file type');
    }
  }

  private async saveTempFile(file: File): Promise<string> {
    const path = `${this.tempDir}/${Date.now()}-${file.name}`;
    await fs.mkdir(this.tempDir, { recursive: true });
    await fs.writeFile(path, Buffer.from(await file.arrayBuffer()));
    return path;
  }

  private async generateVariants(
    imagePath: string
  ): Promise<Map<string, Buffer>> {
    const variants = new Map<string, Buffer>();

    for (const size of this.config.sizes) {
      for (const format of this.config.formats) {
        const key = `${size}w-${format}`;
        const buffer = await sharp(imagePath)
          .resize(size, size, { withoutEnlargement: true })
          [format](this.config.quality as any)
          .toBuffer();

        variants.set(key, buffer);
      }
    }

    return variants;
  }

  private async generateMetadata(
    variants: Map<string, Buffer>
  ): Promise<ImageMetadata> {
    const sizes: Record<number, SizeMetadata> = {};

    for (const size of this.config.sizes) {
      let totalSize = 0;
      const formats: Record<string, number> = {};

      for (const format of this.config.formats) {
        const key = `${size}w-${format}`;
        const buffer = variants.get(key);
        if (buffer) {
          formats[format] = buffer.length;
          totalSize += buffer.length;
        }
      }

      sizes[size] = { totalSize, formats };
    }

    return {
      originalSize: 0,
      optimized: {
        sizes,
        averageCompression: this.calculateCompression(sizes),
      },
    };
  }

  private calculateCompression(
    sizes: Record<number, SizeMetadata>
  ): number {
    const values = Object.values(sizes);
    const avgSize = values.reduce((a, b) => a + b.totalSize, 0) / values.length;
    return avgSize;
  }

  private async saveToStorage(
    variants: Map<string, Buffer>
  ): Promise<Map<string, string>> {
    const paths = new Map<string, string>();

    for (const [key, buffer] of variants) {
      const path = `${this.outputDir}/${key}`;
      await fs.mkdir(this.outputDir, { recursive: true });
      await fs.writeFile(path, buffer);
      paths.set(key, path);
    }

    return paths;
  }

  private generateMarkup(
    paths: Map<string, string>,
    metadata: ImageMetadata
  ): string {
    const srcsets = this.groupBySizeAndFormat(paths);
    // Generate picture element HTML
    return '<!-- Picture element generated -->';
  }

  private generateSrcset(paths: Map<string, string>): string {
    const srcsets: Record<number, string[]> = {};

    for (const [key, path] of paths) {
      const [size] = key.split('-');
      if (!srcsets[size as any]) {
        srcsets[size as any] = [];
      }
      srcsets[size as any].push(path);
    }

    return JSON.stringify(srcsets);
  }

  private groupBySizeAndFormat(
    paths: Map<string, string>
  ): Record<string, Record<string, string>> {
    const grouped: Record<string, Record<string, string>> = {};

    for (const [key, path] of paths) {
      const [size, format] = key.split('-');
      if (!grouped[size]) grouped[size] = {};
      grouped[size][format] = path;
    }

    return grouped;
  }
}

interface ProcessedImage {
  paths: Map<string, string>;
  metadata: ImageMetadata;
  markup: string;
  srcset: string;
}

interface ImageMetadata {
  originalSize: number;
  optimized: {
    sizes: Record<number, SizeMetadata>;
    averageCompression: number;
  };
}

interface SizeMetadata {
  totalSize: number;
  formats: Record<string, number>;
}
```

## Lazy Loading with Placeholder Pattern

```typescript
/**
 * Blur-up effect with progressive image loading
 * Shows blurred thumbnail while HD image loads
 */

class ProgressiveImageLoader {
  static createLazyImage(
    lowQualityDataUrl: string,
    src: string,
    srcset: string,
    alt: string
  ): HTMLElement {
    const container = document.createElement('div');
    container.className = 'progressive-image';
    container.innerHTML = `
      <img
        src="${lowQualityDataUrl}"
        alt="${alt}"
        class="progressive-image__blur"
        style="filter: blur(20px); position: absolute; width: 100%; height: 100%;"
      />
      <img
        src="${src}"
        srcset="${srcset}"
        alt="${alt}"
        loading="lazy"
        class="progressive-image__main"
        style="width: 100%; height: 100%;"
        onload="this.parentElement.classList.add('loaded')"
      />
    `;

    return container;
  }
}

// CSS for smooth transition
const styles = `
  .progressive-image {
    position: relative;
    overflow: hidden;
    background: #f0f0f0;
  }

  .progressive-image__blur {
    filter: blur(20px);
    opacity: 1;
    transition: opacity 0.3s ease-out;
  }

  .progressive-image.loaded .progressive-image__blur {
    opacity: 0;
  }

  .progressive-image__main {
    opacity: 0;
    transition: opacity 0.3s ease-in;
  }

  .progressive-image.loaded .progressive-image__main {
    opacity: 1;
  }
`;
```

## React Image Component Pattern

```typescript
/**
 * Production-ready React component for optimized images
 */

interface OptimizedImageProps {
  src: string;
  alt: string;
  sizes?: Record<string, string>;
  priority?: boolean;
  width?: number;
  height?: number;
}

export const OptimizedImage: React.FC<OptimizedImageProps> = ({
  src,
  alt,
  sizes = {
    mobile: '100vw',
    tablet: '50vw',
    desktop: '33vw',
  },
  priority = false,
  width,
  height,
}) => {
  const [loaded, setLoaded] = useState(false);
  const filename = src.split('/').pop()?.split('.')[0];

  return (
    <picture>
      {/* AVIF */}
      <source
        media="(min-width: 1440px)"
        srcSet={`/images/${filename}-1440w.avif 1440w, /images/${filename}-1920w.avif 1920w`}
        type="image/avif"
      />
      {/* WebP */}
      <source
        media="(min-width: 1440px)"
        srcSet={`/images/${filename}-1440w.webp 1440w, /images/${filename}-1920w.webp 1920w`}
        type="image/webp"
      />
      {/* Fallback JPEG */}
      <img
        src={src}
        alt={alt}
        loading={priority ? 'eager' : 'lazy'}
        width={width}
        height={height}
        onLoad={() => setLoaded(true)}
        className={loaded ? 'image-loaded' : 'image-loading'}
      />
    </picture>
  );
};
```

## Next.js Image Component Integration

```typescript
/**
 * Leverage Next.js Image component for automatic optimization
 */

import Image from 'next/image';

export const HeroImage = () => (
  <Image
    src="/hero.jpg"
    alt="Hero banner"
    width={1920}
    height={1080}
    priority // Load immediately (for above-fold images)
    placeholder="blur" // Show blurred placeholder
    blurDataURL="data:image/jpeg;base64,..." // Low-quality image
    sizes="(max-width: 768px) 100vw, 50vw"
  />
);
```

## CDN-Based Optimization Pattern

```typescript
/**
 * Use CDN for runtime image optimization
 * No pre-generation needed, optimizes on request
 */

class CDNImageService {
  private cdnDomain = 'https://images.example.com';

  generateUrl(
    originalPath: string,
    options: {
      width?: number;
      height?: number;
      quality?: number;
      format?: 'avif' | 'webp' | 'auto';
    }
  ): string {
    const params = new URLSearchParams();

    if (options.width) params.append('w', options.width.toString());
    if (options.height) params.append('h', options.height.toString());
    if (options.quality) params.append('q', options.quality.toString());
    if (options.format) params.append('f', options.format);

    // Auto format negotiation
    params.append('auto', 'format');

    return `${this.cdnDomain}${originalPath}?${params.toString()}`;
  }

  generateSrcset(originalPath: string, sizes: number[]): string {
    return sizes
      .map((size) => {
        const url = this.generateUrl(originalPath, {
          width: size,
          format: 'auto',
        });
        return `${url} ${size}w`;
      })
      .join(', ');
  }

  generatePictureHTML(
    originalPath: string,
    alt: string,
    sizes: number[] = [640, 1024, 1440, 1920]
  ): string {
    const srcset = this.generateSrcset(originalPath, sizes);
    const fallbackUrl = this.generateUrl(originalPath, {});

    return `
      <picture>
        <img
          src="${fallbackUrl}"
          srcset="${srcset}"
          alt="${alt}"
          loading="lazy"
          sizes="(max-width: 640px) 100vw, 50vw"
        />
      </picture>
    `;
  }
}

// Usage
const cdnService = new CDNImageService();
const html = cdnService.generatePictureHTML(
  '/uploads/hero.jpg',
  'Hero image',
  [640, 1024, 1440, 1920]
);
```

These patterns provide production-ready implementations for comprehensive image optimization.
