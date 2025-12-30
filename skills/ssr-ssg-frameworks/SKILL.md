---
name: ssr-ssg-frameworks
description: Master Next.js, Nuxt, and SSR/SSG patterns for server-side rendering and static generation.
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 07-advanced-topics-agent
bond_type: PRIMARY_BOND
category: rendering-strategies
tags: [ssr, ssg, nextjs, nuxt, isr, react-server-components, performance]
complexity: advanced
estimated_time: 5-8 hours
prerequisites:
  - React or Vue fundamentals
  - Node.js and npm/yarn
  - HTTP and web servers
  - SEO basics
---

# SSR/SSG Frameworks

Master server-side rendering and static site generation for optimal performance, SEO, and user experience.

## Input/Output Schema

### Input Requirements
```yaml
project_config:
  type: object
  required:
    - framework: enum           # nextjs|nuxt|remix|astro
    - rendering_strategy: enum  # ssr|ssg|isr|hybrid
    - pages: array              # List of pages/routes
    - data_sources: array       # APIs, CMS, databases
  optional:
    - target_deployment: enum   # vercel|netlify|aws|custom
    - i18n_config: object       # Internationalization
    - image_optimization: boolean
    - api_routes: array         # Serverless functions

data_fetching:
  type: object
  required:
    - method: enum              # getServerSideProps|getStaticProps|loader
    - endpoints: array          # Data source URLs
  optional:
    - revalidation: number      # ISR revalidation time
    - fallback: enum            # true|false|blocking
    - cache_strategy: string    # Cache configuration
```

### Output Deliverables
```yaml
application:
  - SSR/SSG configured application
  - Optimized page components
  - Data fetching implementations
  - API routes (if applicable)
  - Deployment configuration

performance_metrics:
  - Lighthouse score: >90
  - First Contentful Paint: <1.5s
  - Time to Interactive: <3.5s
  - Largest Contentful Paint: <2.5s
  - Cumulative Layout Shift: <0.1

seo_optimization:
  - Meta tags configured
  - Open Graph implemented
  - Sitemap generated
  - Robots.txt configured
```

## MANDATORY

### 1. Server-Side Rendering (SSR) Concepts

#### Next.js SSR
```javascript
// pages/product/[id].js
export async function getServerSideProps(context) {
  const { id } = context.params;
  const { req, res, query } = context;

  // Set cache headers
  res.setHeader(
    'Cache-Control',
    'public, s-maxage=10, stale-while-revalidate=59'
  );

  try {
    const response = await fetch(`https://api.example.com/products/${id}`);
    const product = await response.json();

    return {
      props: {
        product,
        timestamp: Date.now()
      }
    };
  } catch (error) {
    return {
      notFound: true
    };
  }
}

export default function Product({ product, timestamp }) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span>Rendered at: {new Date(timestamp).toISOString()}</span>
    </div>
  );
}
```

#### Nuxt SSR
```vue
<template>
  <div>
    <h1>{{ product.name }}</h1>
    <p>{{ product.description }}</p>
  </div>
</template>

<script setup>
const route = useRoute();

const { data: product } = await useFetch(
  `https://api.example.com/products/${route.params.id}`,
  {
    key: `product-${route.params.id}`,
    server: true,
    lazy: false
  }
);
</script>
```

### 2. Static Site Generation (SSG) Patterns

#### Next.js SSG
```javascript
// pages/blog/[slug].js
export async function getStaticPaths() {
  const response = await fetch('https://api.example.com/posts');
  const posts = await response.json();

  const paths = posts.map((post) => ({
    params: { slug: post.slug }
  }));

  return {
    paths,
    fallback: 'blocking' // or true, false
  };
}

export async function getStaticProps({ params }) {
  const response = await fetch(
    `https://api.example.com/posts/${params.slug}`
  );
  const post = await response.json();

  return {
    props: {
      post
    },
    revalidate: 60 // ISR - revalidate every 60 seconds
  };
}

export default function BlogPost({ post }) {
  return (
    <article>
      <h1>{post.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />
    </article>
  );
}
```

#### Nuxt SSG
```vue
<script setup>
const route = useRoute();

const { data: post } = await useAsyncData(
  `post-${route.params.slug}`,
  () => $fetch(`https://api.example.com/posts/${route.params.slug}`)
);
</script>
```

### 3. Data Fetching (getServerSideProps, getStaticProps)

```javascript
// Server-side props with error handling
export async function getServerSideProps(context) {
  const session = await getSession(context);

  if (!session) {
    return {
      redirect: {
        destination: '/login',
        permanent: false
      }
    };
  }

  try {
    const data = await fetchUserData(session.userId);

    return {
      props: {
        user: data,
        session
      }
    };
  } catch (error) {
    console.error('Data fetch error:', error);

    return {
      props: {
        error: 'Failed to load data'
      }
    };
  }
}

// Static props with revalidation
export async function getStaticProps() {
  const data = await fetch('https://api.example.com/data').then(r => r.json());

  return {
    props: { data },
    revalidate: 3600 // Revalidate every hour
  };
}
```

### 4. Dynamic Routes and Params

```javascript
// pages/category/[category]/[product].js
export async function getStaticPaths() {
  return {
    paths: [
      { params: { category: 'electronics', product: 'phone' } },
      { params: { category: 'books', product: 'novel' } }
    ],
    fallback: true
  };
}

export async function getStaticProps({ params }) {
  const { category, product } = params;

  const data = await fetchProduct(category, product);

  if (!data) {
    return { notFound: true };
  }

  return {
    props: { product: data },
    revalidate: 60
  };
}

export default function ProductPage({ product }) {
  const router = useRouter();

  // Show loading state for fallback pages
  if (router.isFallback) {
    return <div>Loading...</div>;
  }

  return <div>{product.name}</div>;
}
```

### 5. Head/Metadata Management

#### Next.js 13+ (App Router)
```javascript
// app/blog/[slug]/page.js
export async function generateMetadata({ params }) {
  const post = await fetchPost(params.slug);

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
      type: 'article',
      publishedTime: post.publishedAt,
      authors: [post.author.name]
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage]
    }
  };
}
```

#### Next.js Pages Router
```javascript
import Head from 'next/head';

export default function Page({ post }) {
  return (
    <>
      <Head>
        <title>{post.title} | Blog</title>
        <meta name="description" content={post.excerpt} />
        <meta property="og:title" content={post.title} />
        <meta property="og:description" content={post.excerpt} />
        <meta property="og:image" content={post.coverImage} />
        <meta name="twitter:card" content="summary_large_image" />
      </Head>
      <article>{/* content */}</article>
    </>
  );
}
```

#### Nuxt
```vue
<script setup>
useHead({
  title: 'Page Title',
  meta: [
    { name: 'description', content: 'Page description' },
    { property: 'og:title', content: 'Page Title' },
    { property: 'og:description', content: 'Page description' }
  ]
});

useSeoMeta({
  title: 'Page Title',
  ogTitle: 'Page Title',
  description: 'Page description',
  ogDescription: 'Page description',
  ogImage: 'https://example.com/image.jpg',
  twitterCard: 'summary_large_image'
});
</script>
```

### 6. Basic Deployment

#### Next.js Deployment (Vercel)
```json
// vercel.json
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"],
  "env": {
    "API_URL": "@api-url",
    "DATABASE_URL": "@database-url"
  }
}
```

#### Nuxt Deployment (Netlify)
```toml
# netlify.toml
[build]
  command = "npm run generate"
  publish = ".output/public"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[build.environment]
  NODE_VERSION = "18"
```

## OPTIONAL

### 1. Incremental Static Regeneration (ISR)

```javascript
// On-demand revalidation (Next.js 12.2+)
export async function getStaticProps() {
  const data = await fetchData();

  return {
    props: { data },
    revalidate: 60 // Background revalidation
  };
}

// API route for on-demand revalidation
// pages/api/revalidate.js
export default async function handler(req, res) {
  // Check for secret to confirm this is a valid request
  if (req.query.secret !== process.env.REVALIDATE_SECRET) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  try {
    // Revalidate specific path
    await res.revalidate(`/blog/${req.query.slug}`);

    return res.json({ revalidated: true });
  } catch (err) {
    return res.status(500).send('Error revalidating');
  }
}
```

### 2. API Routes

```javascript
// pages/api/users/[id].js
export default async function handler(req, res) {
  const { id } = req.query;
  const { method } = req;

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');

  switch (method) {
    case 'GET':
      try {
        const user = await fetchUser(id);
        res.status(200).json(user);
      } catch (error) {
        res.status(404).json({ error: 'User not found' });
      }
      break;

    case 'POST':
      try {
        const userData = req.body;
        const newUser = await createUser(userData);
        res.status(201).json(newUser);
      } catch (error) {
        res.status(500).json({ error: 'Failed to create user' });
      }
      break;

    default:
      res.setHeader('Allow', ['GET', 'POST']);
      res.status(405).end(`Method ${method} Not Allowed`);
  }
}

// Enable body parsing
export const config = {
  api: {
    bodyParser: {
      sizeLimit: '1mb'
    }
  }
};
```

### 3. Middleware

#### Next.js Middleware
```javascript
// middleware.js
import { NextResponse } from 'next/server';

export function middleware(request) {
  const { pathname } = request.nextUrl;

  // Authentication check
  const token = request.cookies.get('auth-token');

  if (pathname.startsWith('/dashboard') && !token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Add custom header
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'value');

  // Rewrite
  if (pathname.startsWith('/old-path')) {
    return NextResponse.rewrite(new URL('/new-path', request.url));
  }

  return response;
}

export const config = {
  matcher: ['/dashboard/:path*', '/old-path/:path*']
};
```

#### Nuxt Middleware
```javascript
// middleware/auth.js
export default defineNuxtRouteMiddleware((to, from) => {
  const auth = useAuth();

  if (!auth.isAuthenticated && to.path !== '/login') {
    return navigateTo('/login');
  }
});
```

### 4. Image Optimization

#### Next.js Image Component
```javascript
import Image from 'next/image';

export default function Gallery({ images }) {
  return (
    <div>
      {images.map((img) => (
        <Image
          key={img.id}
          src={img.url}
          alt={img.alt}
          width={800}
          height={600}
          quality={85}
          placeholder="blur"
          blurDataURL={img.blurDataURL}
          loading="lazy"
          sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
        />
      ))}
    </div>
  );
}

// next.config.js
module.exports = {
  images: {
    domains: ['example.com', 'cdn.example.com'],
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384]
  }
};
```

#### Nuxt Image
```vue
<template>
  <NuxtImg
    src="/image.jpg"
    width="800"
    height="600"
    quality="85"
    format="webp"
    loading="lazy"
    placeholder
  />
</template>
```

### 5. Internationalization (i18n)

#### Next.js i18n
```javascript
// next.config.js
module.exports = {
  i18n: {
    locales: ['en', 'fr', 'es'],
    defaultLocale: 'en',
    localeDetection: true
  }
};

// pages/index.js
import { useRouter } from 'next/router';

export default function Home({ translations }) {
  const router = useRouter();
  const { locale } = router;
  const t = translations[locale];

  return <h1>{t.welcome}</h1>;
}

export async function getStaticProps({ locale }) {
  const translations = await import(`../locales/${locale}.json`);

  return {
    props: {
      translations: translations.default
    }
  };
}
```

#### Nuxt i18n
```javascript
// nuxt.config.js
export default {
  modules: ['@nuxtjs/i18n'],

  i18n: {
    locales: [
      { code: 'en', file: 'en.json' },
      { code: 'fr', file: 'fr.json' }
    ],
    defaultLocale: 'en',
    lazy: true,
    langDir: 'locales/',
    strategy: 'prefix_except_default'
  }
};
```

### 6. Preview Mode

```javascript
// pages/api/preview.js
export default function handler(req, res) {
  const { secret, slug } = req.query;

  // Check secret
  if (secret !== process.env.PREVIEW_SECRET) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  // Enable Preview Mode
  res.setPreviewData({
    maxAge: 60 * 60 // 1 hour
  });

  // Redirect to the path from the query
  res.redirect(slug ? `/posts/${slug}` : '/');
}

// pages/api/exit-preview.js
export default function handler(req, res) {
  res.clearPreviewData();
  res.redirect('/');
}

// In getStaticProps
export async function getStaticProps({ preview = false, previewData }) {
  const data = await fetchData({ preview });

  return {
    props: { data, preview }
  };
}
```

## ADVANCED

### 1. Streaming SSR

```javascript
// app/page.js (Next.js 13+ App Router)
import { Suspense } from 'react';

async function SlowComponent() {
  const data = await fetchSlowData();
  return <div>{data}</div>;
}

export default function Page() {
  return (
    <div>
      <h1>Fast Content</h1>

      <Suspense fallback={<div>Loading slow content...</div>}>
        <SlowComponent />
      </Suspense>
    </div>
  );
}
```

### 2. React Server Components

```javascript
// app/posts/page.jsx (Server Component)
async function Posts() {
  const posts = await fetchPosts();

  return (
    <div>
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}

// app/posts/post-card.jsx (Client Component)
'use client';

import { useState } from 'react';

export default function PostCard({ post }) {
  const [liked, setLiked] = useState(false);

  return (
    <div>
      <h2>{post.title}</h2>
      <button onClick={() => setLiked(!liked)}>
        {liked ? '❤️' : '🤍'} Like
      </button>
    </div>
  );
}
```

### 3. Edge Runtime

```javascript
// pages/api/edge-function.js
export const config = {
  runtime: 'edge'
};

export default async function handler(req) {
  const geo = req.geo;

  return new Response(
    JSON.stringify({
      city: geo.city,
      country: geo.country,
      region: geo.region
    }),
    {
      headers: {
        'content-type': 'application/json'
      }
    }
  );
}

// middleware.js with Edge Runtime
export function middleware(request) {
  const country = request.geo.country;

  if (country === 'US') {
    return NextResponse.rewrite(new URL('/en-us', request.url));
  }

  return NextResponse.next();
}
```

### 4. Hybrid Rendering Strategies

```javascript
// next.config.js
module.exports = {
  experimental: {
    appDir: true
  }
};

// Mix of SSR, SSG, and ISR
// app/page.js - SSR
export const dynamic = 'force-dynamic';

// app/blog/page.js - SSG
export const dynamic = 'force-static';

// app/products/page.js - ISR
export const revalidate = 60;

// Per-page configuration
export default function Page() {
  return <div>Content</div>;
}
```

### 5. Multi-Zone Architecture

```javascript
// Primary app (next.config.js)
module.exports = {
  async rewrites() {
    return [
      {
        source: '/blog/:path*',
        destination: 'https://blog.example.com/:path*'
      },
      {
        source: '/shop/:path*',
        destination: 'https://shop.example.com/:path*'
      }
    ];
  }
};

// Blog zone (next.config.js)
module.exports = {
  basePath: '/blog',
  assetPrefix: 'https://blog.example.com'
};
```

### 6. Custom Server Implementation

```javascript
// server.js
const { createServer } = require('http');
const { parse } = require('url');
const next = require('next');

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  createServer((req, res) => {
    const parsedUrl = parse(req.url, true);
    const { pathname, query } = parsedUrl;

    // Custom routing
    if (pathname === '/custom') {
      app.render(req, res, '/custom-page', query);
    } else {
      handle(req, res, parsedUrl);
    }
  }).listen(3000, (err) => {
    if (err) throw err;
    console.log('> Ready on http://localhost:3000');
  });
});
```

## Error Handling

| Error Type | Cause | Solution | Recovery Strategy |
|-----------|-------|----------|-------------------|
| `ECONNREFUSED` | API server unreachable | Check API endpoint | Retry with exponential backoff |
| `404 Not Found` | Page/resource missing | Create fallback page | Return custom 404 page |
| `500 Internal Server Error` | Server-side error | Check logs | Show error page with retry |
| `Build Failed` | Compilation error | Check syntax/imports | Fix and rebuild |
| `Hydration Mismatch` | SSR/Client HTML mismatch | Fix conditional rendering | Ensure consistent output |
| `getStaticPaths Error` | Invalid paths returned | Validate path structure | Return empty paths array |
| `Data Fetch Timeout` | Slow API response | Implement timeout | Show loading state |
| `Memory Limit Exceeded` | Too many static pages | Use ISR instead of SSG | Reduce build concurrency |

### Error Handling Implementation
```javascript
// Global error handling
// pages/_error.js
function Error({ statusCode, message }) {
  return (
    <div>
      <h1>
        {statusCode
          ? `An error ${statusCode} occurred on server`
          : 'An error occurred on client'}
      </h1>
      {message && <p>{message}</p>}
    </div>
  );
}

Error.getInitialProps = ({ res, err }) => {
  const statusCode = res ? res.statusCode : err ? err.statusCode : 404;
  const message = err ? err.message : null;

  return { statusCode, message };
};

export default Error;

// App-level error boundary
// pages/_app.js
import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div role="alert">
      <p>Something went wrong:</p>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

function MyApp({ Component, pageProps }) {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onReset={() => {
        // Reset app state
        window.location.href = '/';
      }}
    >
      <Component {...pageProps} />
    </ErrorBoundary>
  );
}
```

## Test Templates

### Unit Tests
```javascript
import { render, screen } from '@testing-library/react';
import Home, { getStaticProps } from '../pages/index';

describe('Home Page', () => {
  it('renders homepage content', () => {
    render(<Home posts={mockPosts} />);

    expect(screen.getByRole('heading')).toHaveTextContent('Blog');
  });

  it('fetches posts in getStaticProps', async () => {
    const result = await getStaticProps({});

    expect(result.props.posts).toBeDefined();
    expect(result.revalidate).toBe(60);
  });
});
```

### Integration Tests
```javascript
import { createMocks } from 'node-mocks-http';
import handler from '../pages/api/posts';

describe('/api/posts', () => {
  it('returns posts array', async () => {
    const { req, res } = createMocks({
      method: 'GET'
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    expect(JSON.parse(res._getData())).toHaveProperty('posts');
  });
});
```

### E2E Tests (Playwright)
```javascript
test('homepage loads and displays content', async ({ page }) => {
  await page.goto('/');

  await expect(page.locator('h1')).toContainText('Welcome');
  await expect(page.locator('[data-testid="posts"]')).toBeVisible();
});

test('dynamic route works', async ({ page }) => {
  await page.goto('/blog/test-post');

  await expect(page.locator('article h1')).toBeVisible();
  await expect(page.locator('meta[property="og:title"]')).toHaveAttribute(
    'content',
    /.+/
  );
});
```

## Best Practices

### Performance
- Use appropriate rendering strategy per page
- Implement code splitting and lazy loading
- Optimize images with next/image or nuxt/image
- Minimize JavaScript bundle size
- Use ISR for frequently updated content

### SEO
- Generate sitemap.xml automatically
- Implement structured data (JSON-LD)
- Optimize meta tags and Open Graph
- Use semantic HTML
- Ensure proper canonical URLs

### Data Fetching
- Cache API responses appropriately
- Implement error boundaries
- Use SWR or React Query for client-side
- Minimize data fetching waterfalls
- Handle loading and error states

### Code Organization
- Separate components by responsibility
- Use TypeScript for type safety
- Implement consistent naming conventions
- Document complex data flows
- Keep API routes organized

## Production Configuration

### Next.js Configuration
```javascript
// next.config.js
module.exports = {
  reactStrictMode: true,
  swcMinify: true,
  compress: true,

  images: {
    domains: ['cdn.example.com'],
    formats: ['image/avif', 'image/webp']
  },

  env: {
    API_URL: process.env.API_URL
  },

  headers: async () => [
    {
      source: '/:path*',
      headers: [
        {
          key: 'X-DNS-Prefetch-Control',
          value: 'on'
        },
        {
          key: 'Strict-Transport-Security',
          value: 'max-age=31536000; includeSubDomains'
        }
      ]
    }
  ],

  redirects: async () => [
    {
      source: '/old-blog/:slug',
      destination: '/blog/:slug',
      permanent: true
    }
  ]
};
```

### Environment Variables
```bash
# .env.production
NEXT_PUBLIC_API_URL=https://api.production.com
DATABASE_URL=postgresql://user:pass@host:5432/db
REVALIDATE_SECRET=your-secret-key
PREVIEW_SECRET=preview-secret-key
```

### Deployment Scripts
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "export": "next export",
    "analyze": "ANALYZE=true next build",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  }
}
```

## Assets
- See `assets/ssr-ssg-config.yaml` for framework configurations

## Resources
- [Next.js Documentation](https://nextjs.org/docs)
- [Nuxt Documentation](https://nuxt.com/)
- [Remix Documentation](https://remix.run/docs)
- [Web.dev Performance](https://web.dev/performance/)
- [React Server Components](https://react.dev/blog/2023/03/22/react-labs-what-we-have-been-working-on-march-2023#react-server-components)

---
**Status:** Active | **Version:** 2.0.0 | **Complexity:** Advanced | **Estimated Time:** 5-8 hours
