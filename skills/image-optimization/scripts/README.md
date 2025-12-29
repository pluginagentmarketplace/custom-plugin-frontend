# Image Optimization Scripts

Production scripts for validating and implementing image optimization.

## validate-images.sh
Comprehensive validation of image optimization implementation.

**Usage:** `./validate-images.sh [project-root]`

**Checks:**
- Total image inventory (JPEG, PNG, GIF, WebP, AVIF, SVG)
- WebP format integration in HTML/CSS
- AVIF format usage
- Responsive images with srcset
- Lazy loading implementation
- Image compression setup
- Dimension specification
- Picture element usage

**Output:** `.image-validation.json` with detailed metrics

## generate-image-config.sh
Generate Sharp/ImageMin-based image optimization pipeline.

**Usage:** `./generate-image-config.sh [output-dir] [filename]`

**Generates:** Production-ready TypeScript module with:
- Multi-format image processing (AVIF, WebP, JPEG, PNG)
- Responsive image sizing
- Srcset definition generation
- Picture element HTML generation
- Next.js Image config
- React component helpers

## Key Concepts

### Image Formats
- **AVIF** - Best compression, newest format (~20% smaller than WebP)
- **WebP** - Modern format with great compression (~30% smaller than JPEG)
- **JPEG** - Fallback for universal compatibility
- **PNG** - For images requiring transparency

### Responsive Images
- **srcset** - Provides multiple size options for different viewports
- **sizes** - Tells browser which source to use based on viewport
- **picture** - Format negotiation with multiple sources

### Optimization Strategies
- Generate multiple sizes (640w, 1024w, 1440w, 1920w)
- Create all format variants
- Use picture element for progressive enhancement
- Implement lazy loading
- Reserve space with width/height or aspect-ratio
