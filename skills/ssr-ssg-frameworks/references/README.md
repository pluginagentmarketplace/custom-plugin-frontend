# SSR/SSG Frameworks References

Server-Side Rendering and Static Site Generation technical documentation.

## Documentation Files

### `GUIDE.md`
Complete technical guide covering:
- SSR (Server-Side Rendering) vs CSR (Client-Side Rendering)
- SSG (Static Site Generation) and pre-rendering
- Next.js data fetching (getServerSideProps, getStaticProps, getStaticPaths)
- Nuxt equivalent patterns (asyncData, fetch)
- Incremental Static Regeneration (ISR)
- SEO benefits of server rendering
- Performance tradeoffs and optimization

### `PATTERNS.md`
Production patterns and real examples:
- Data fetching patterns (Server, Static, Client)
- ISR implementation for scalability
- Dynamic routing with static generation
- Hybrid rendering (SSG + ISR)
- Preview mode for draft content
- API integration patterns
- Error handling and fallbacks
- Performance monitoring

## Rendering Strategy Comparison

| Feature | SSR | SSG | ISR | CSR |
|---------|-----|-----|-----|-----|
| Time to First Byte | Slow | Fast | Fast | Slow |
| Update Frequency | Real-time | Manual rebuild | Scheduled | Real-time |
| Build Time | N/A | Long | Medium | N/A |
| SEO Quality | Excellent | Excellent | Excellent | Fair |
| Server Load | High | None | Low | None |
| Best For | Real-time | Static | Mixed | Interactive |

## Data Fetching Methods

### getServerSideProps
- Runs on every request
- Server-side only
- Best for: Personalized, real-time content
- Performance: Slower (rendered per request)

### getStaticProps
- Runs at build time
- Can be cached
- Best for: Static, SEO content
- Performance: Fastest (static file)

### getStaticPaths
- Define which dynamic routes to pre-generate
- Works with getStaticProps
- Best for: Blog, product pages with limited variants

### Incremental Static Regeneration (ISR)
- Rebuild selected pages at interval
- Background revalidation
- Best for: Large sites with frequent updates
- Revalidate time: seconds, minutes, or hours

## Key Concepts

- **Prerendering**: Generating HTML at build time
- **Revalidation**: Refreshing cached pages
- **On-demand ISR**: Manual page rebuilds
- **Preview Mode**: Draft content viewing
- **Fallback Pages**: Loading states while generating
