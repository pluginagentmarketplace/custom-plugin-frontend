# code-splitting-optimization Scripts

This directory contains scripts for validating and generating bundle optimization and code-splitting configurations.

## Available Scripts

### validate-splitting.sh
Analyzes webpack/Vite bundle configuration and validates code-splitting setup.

**Usage:**
```bash
./scripts/validate-splitting.sh [PROJECT_DIR]
```

**Checks:**
- Webpack or Vite configuration detection
- Bundle entry points configuration
- Output configuration (filename patterns)
- Optimization.splitChunks configuration (webpack)
- Build output chunks and chunk names
- Lazy-loaded routes detection
- Dynamic imports usage
- Tree-shaking and minification setup
- Source maps configuration
- Bundle size analysis
- Module resolution optimization

**Example:**
```bash
./scripts/validate-splitting.sh /path/to/project
```

### generate-split-config.sh
Generates production-ready webpack or Vite code-splitting configuration.

**Usage:**
```bash
./scripts/generate-split-config.sh [OUTPUT_DIR] [BUNDLER]
```

**Bundler Options:**
- `webpack` (default)
- `vite`

**Generates:**
- webpack.config.js with optimized splitChunks strategy
- Vite config with chunk optimization
- Chunk naming patterns
- Vendor chunk separation
- UI framework separation
- Common dependencies extraction
- Async chunk patterns
- Prefetching hints

**Example:**
```bash
./scripts/generate-split-config.sh /path/to/project webpack
./scripts/generate-split-config.sh /path/to/project vite
```

## Script Features

### Validation Script
- Bundle configuration structure verification
- Chunk extraction strategy analysis
- Entry point validation
- Output pattern checking
- Tree-shaking enablement verification
- Minification settings validation
- Source map configuration review
- Bundle size information
- Module count analysis
- Optimization technique detection

### Generation Script
- Webpack configuration with:
  - Vendor chunk separation (node_modules)
  - UI framework chunk (React, Angular, Vue)
  - Common code extraction
  - Async chunk patterns
  - Filename hashing for cache-busting
  - Named chunks for debugging

- Vite configuration with:
  - Rollup optimization settings
  - Chunk size optimization
  - Async module patterns
  - Build output configuration
  - Terser minification options
  - CSS code-splitting

## Generated Configurations

### Webpack Config
- `splitChunks` strategy with vendor/ui/common separation
- `runtimeChunk` for webpack runtime
- `moduleIds: 'deterministic'` for stable chunk IDs
- Named chunks for debugging
- Production optimization settings

### Vite Config
- `rollupOptions` for code-splitting
- Manual chunk configuration
- Chunk size thresholds
- Asset filename patterns
- CSS splitting configuration
- Modern JavaScript output

## Best Practices

1. Validate before deploying to production
2. Monitor chunk sizes after each update
3. Set appropriate chunk size thresholds
4. Use named chunks for debugging
5. Enable source maps in staging environments
6. Test chunk loading in different network conditions
7. Monitor prefetch/preload impact on performance
8. Use bundle analysis tools to visualize chunks

## Output Files

Generated webpack config includes:
- Entry point configuration
- Multiple optimization chunks
- Asset output patterns
- Source map settings
- Plugin configuration

Generated Vite config includes:
- Build optimization settings
- Rollup input/output options
- CSS splitting strategies
- Asset naming patterns
