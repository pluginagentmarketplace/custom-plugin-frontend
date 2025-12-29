# Image Optimization References

Complete technical documentation for modern image optimization.

## GUIDE.md
**600+ word technical guide** covering:
- Modern image formats (AVIF, WebP, JPEG, PNG)
- Responsive images with srcset and sizes
- Lazy loading (native and IntersectionObserver)
- Image compression tools and settings
- CDN integration strategies
- Performance metrics and measurement

## PATTERNS.md
**600+ word real-world patterns** including:
- Complete picture element with format fallback chain
- Full image processing pipeline (upload → optimize → serve)
- Lazy loading with blur-up placeholder effect
- React optimized image component
- Next.js Image component integration
- CDN-based runtime optimization

## Key Topics

### Image Formats

| Format | Compression | Use Case | Browser Support |
|--------|-------------|----------|-----------------|
| AVIF | 20% smaller than WebP | Modern browsers, maximum compression | 85%+ |
| WebP | 25-35% smaller than JPEG | Good modern support | 92%+ |
| JPEG | Universal | Fallback, universal compatibility | 100% |
| PNG | Lossless | Transparency, graphics | 100% |

### Responsive Image Sizes
- 320px - Mobile phones
- 640px - Small tablets
- 1024px - Large tablets
- 1440px - Desktop
- 1920px - Large desktop / 2x display

### Optimization Checklist
- [ ] Images in AVIF format (with fallbacks)
- [ ] Responsive images with srcset
- [ ] Lazy loading on below-fold images
- [ ] Picture element for format negotiation
- [ ] Dimensions specified (aspect-ratio)
- [ ] Compressed to recommended quality levels
- [ ] CDN caching configured
- [ ] Performance metrics monitored

### Quality Settings
- AVIF: 60-75 quality
- WebP: 75-85 quality
- JPEG: 75-85 quality
- PNG: Maximum compression (9)

### Tools Referenced
- Sharp - Node.js image processing
- ImageMagick - System-level processing
- Cloudinary - Cloud-based CDN
- Imgix - Runtime image optimization
- Next.js Image - Built-in React optimization
