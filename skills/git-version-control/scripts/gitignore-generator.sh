#!/bin/bash
# .gitignore Generator for Frontend Projects
# Part of git-version-control skill - Golden Format E703 Compliant

set -e

PROJECT_TYPE="${1:-react}"
OUTPUT_FILE="${2:-.gitignore}"

echo "Generating .gitignore for: $PROJECT_TYPE"

cat > "$OUTPUT_FILE" << 'EOF'
# Dependencies
node_modules/
.pnp/
.pnp.js

# Build outputs
dist/
build/
.next/
out/
.nuxt/
.output/
.svelte-kit/

# Testing
coverage/
.nyc_output/
*.lcov

# IDE & Editors
.idea/
.vscode/
*.swp
*.swo
*~
.project
.classpath
.settings/

# OS Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Thumbs.db
ehthumbs.db

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
*.local

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# Cache
.cache/
.parcel-cache/
.eslintcache
.stylelintcache
*.tsbuildinfo

# Misc
*.pem
.vercel
.turbo
EOF

# Add framework-specific entries
case "$PROJECT_TYPE" in
    react)
        cat >> "$OUTPUT_FILE" << 'EOF'

# React specific
.react-router/
EOF
        ;;
    vue)
        cat >> "$OUTPUT_FILE" << 'EOF'

# Vue specific
*.local
.vitepress/cache
EOF
        ;;
    angular)
        cat >> "$OUTPUT_FILE" << 'EOF'

# Angular specific
.angular/
EOF
        ;;
    next)
        cat >> "$OUTPUT_FILE" << 'EOF'

# Next.js specific
.next/
out/
.contentlayer/
EOF
        ;;
    svelte)
        cat >> "$OUTPUT_FILE" << 'EOF'

# Svelte specific
.svelte-kit/
EOF
        ;;
esac

echo "✓ Generated $OUTPUT_FILE for $PROJECT_TYPE project"
echo ""
echo "Included patterns for:"
echo "  - Dependencies (node_modules)"
echo "  - Build outputs"
echo "  - IDE/Editor files"
echo "  - Environment files"
echo "  - Logs and caches"
echo "  - Framework-specific files ($PROJECT_TYPE)"
