# SSR/SSG Frameworks Scripts

Server-Side Rendering and Static Site Generation implementation scripts.

## Scripts

### `validate-ssr.sh`
Validates SSR/SSG implementation:
- Next.js pages structure and data fetching methods
- getServerSideProps vs getStaticProps configuration
- Incremental Static Regeneration (ISR) setup
- API routes implementation
- Dynamic routing patterns
- Build output and performance metrics

Usage:
```bash
./scripts/validate-ssr.sh /path/to/nextjs-project
```

### `generate-ssr-app.sh`
Generates production-ready SSR/SSG structure:
- Next.js pages with getServerSideProps
- Static pages with getStaticProps
- Dynamic routes with getStaticPaths
- API routes and handlers
- Middleware configuration
- Data fetching utilities

Usage:
```bash
./scripts/generate-ssr-app.sh /path/to/nextjs-project
```

## Framework Comparison

| Aspect | SSR | SSG | Hybrid |
|--------|-----|-----|--------|
| Build Time | Fast | Slow | Medium |
| Update Speed | Instant | Rebuild needed | ISR (minutes) |
| Dynamic Content | Yes | No | Limited |
| Best For | Real-time | Static content | Mixed |

## Rendering Modes

- **SSR**: Server renders on each request (dynamic)
- **SSG**: Built at build time (static)
- **ISR**: Incremental Static Regeneration (rebuild selected pages)
- **CSR**: Client-Side Rendering (browser)

## Key Patterns

- Data fetching: getServerSideProps, getStaticProps, getStaticPaths
- Incremental Static Regeneration (ISR)
- Hybrid rendering (SSG + ISR)
- Preview mode for drafts
- Fallback pages and on-demand ISR
