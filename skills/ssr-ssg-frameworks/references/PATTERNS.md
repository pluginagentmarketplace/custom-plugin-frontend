# SSR/SSG Frameworks Patterns

Production patterns and real-world implementations for Next.js and Nuxt.

## Data Fetching Patterns

### Pattern 1: Unified Data Fetching Layer

Create a single data fetching abstraction for different rendering methods:

```typescript
// lib/data.ts - Single source of truth for data fetching
type RenderMode = 'ssr' | 'ssg' | 'isr' | 'csr';

interface FetchOptions {
  mode: RenderMode;
  revalidate?: number;
  tags?: string[];
}

class DataFetcher {
  async fetch(url: string, options: FetchOptions) {
    if (options.mode === 'ssg' || options.mode === 'isr') {
      return this.fetchStatic(url, options);
    } else if (options.mode === 'ssr') {
      return this.fetchServer(url);
    } else {
      return this.fetchClient(url);
    }
  }

  private async fetchStatic(url: string, options: FetchOptions) {
    return fetch(url, {
      next: {
        revalidate: options.revalidate,
        tags: options.tags
      }
    }).then(r => r.json());
  }

  private async fetchServer(url: string) {
    return fetch(url, {
      cache: 'no-store'
    }).then(r => r.json());
  }

  private async fetchClient(url: string) {
    return fetch(url).then(r => r.json());
  }
}

export const dataFetcher = new DataFetcher();
```

### Pattern 2: Hybrid Data Fetching

Combine multiple data sources with different strategies:

```javascript
export async function getStaticProps({ params }) {
  // Fetch static content (blog post)
  const post = await dataFetcher.fetch(
    `/api/posts/${params.slug}`,
    { mode: 'ssg', revalidate: 3600 }
  );

  // Fetch dynamic content separately (real-time stats)
  const stats = await dataFetcher.fetch(
    `/api/stats/${params.slug}`,
    { mode: 'ssg', revalidate: 60 } // More frequent updates
  );

  return {
    props: { post, stats },
    revalidate: 60 // Overall ISR interval
  };
}

export default function Post({ post, stats }) {
  // Post content is static, stats update every minute
  return (
    <>
      <article>{post.content}</article>
      <div>Views: {stats.views}</div>
    </>
  );
}
```

## ISR Implementation Patterns

### Pattern 1: Scalable ISR with On-Demand Revalidation

```typescript
// pages/api/revalidate.ts
export default async function handler(req, res) {
  // Validate secret to prevent abuse
  if (req.query.secret !== process.env.REVALIDATE_SECRET) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  const paths = Array.isArray(req.body.paths)
    ? req.body.paths
    : [req.body.path];

  try {
    const results = await Promise.all(
      paths.map(path => res.revalidate(path))
    );

    return res.json({
      revalidated: true,
      paths,
      count: results.length,
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('Revalidation error:', err);
    return res.status(500).json({
      message: 'Error revalidating',
      error: err.message
    });
  }
}

// Usage in CMS webhook:
async function notifyNextJsOfChanges(postId) {
  await fetch(
    `${process.env.SITE_URL}/api/revalidate?secret=${process.env.REVALIDATE_SECRET}`,
    {
      method: 'POST',
      body: JSON.stringify({
        paths: [
          `/blog/${postId}`,
          '/blog',
          '/'
        ]
      })
    }
  );
}
```

### Pattern 2: Fallback Pages During Generation

```javascript
export async function getStaticPaths() {
  // Pre-generate popular pages
  const popularPosts = await getPopularPosts();

  return {
    paths: popularPosts.map(post => ({
      params: { slug: post.slug }
    })),
    fallback: 'blocking' // Generate others on first request
  };
}

export async function getStaticProps({ params }) {
  try {
    const post = await getPost(params.slug);

    if (!post) {
      return {
        notFound: true,
        revalidate: 60
      };
    }

    return {
      props: { post },
      revalidate: 3600
    };
  } catch (error) {
    console.error('Error fetching post:', error);

    return {
      notFound: true,
      revalidate: 60 // Retry soon on error
    };
  }
}

// In component, show loading state while generating:
export default function Post({ post }) {
  const router = useRouter();

  if (router.isFallback) {
    return <div>Loading...</div>;
  }

  return <article>{post.content}</article>;
}
```

## Preview Mode Pattern

Allow editors to preview draft content:

```typescript
// pages/api/preview.ts
export default function handler(req, res) {
  // Verify preview token (from CMS)
  if (req.query.token !== process.env.PREVIEW_TOKEN) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  // Enable preview mode (sets preview cookies)
  res.setPreviewData({
    // Any data you want available in preview
    mode: 'preview'
  });

  // Redirect to preview page
  res.redirect(`/blog/${req.query.slug}`);
}

// pages/api/exit-preview.ts
export default function handler(req, res) {
  res.clearPreviewData();
  res.redirect('/');
}

// pages/blog/[slug].tsx
export async function getStaticProps({ params, preview }) {
  let post;

  if (preview) {
    // Fetch draft content from CMS API
    post = await getCMSPost(params.slug, { draft: true });
  } else {
    // Fetch published content normally
    post = await getPost(params.slug);
  }

  return {
    props: { post, preview },
    revalidate: preview ? 0 : 3600 // No caching in preview
  };
}

export default function Post({ post, preview }) {
  return (
    <>
      {preview && <div className="preview-banner">Preview Mode</div>}
      <article>{post.content}</article>
    </>
  );
}
```

## Error Handling and Fallbacks

### Pattern: Graceful Degradation

```javascript
export async function getStaticProps({ params, ...context }) {
  try {
    const post = await fetchPost(params.slug);

    if (!post) {
      return {
        notFound: true,
        revalidate: 60
      };
    }

    return {
      props: { post },
      revalidate: 3600
    };
  } catch (error) {
    console.error('Build error:', error);

    // Return cached post if available
    const cached = await getCachedPost(params.slug);
    if (cached) {
      return {
        props: { post: cached, stale: true },
        revalidate: 60 // Retry soon
      };
    }

    // Fall back to placeholder
    return {
      props: {
        post: {
          slug: params.slug,
          title: 'Temporarily Unavailable',
          content: 'This post will be available shortly.'
        },
        error: true
      },
      revalidate: 10 // Retry frequently
    };
  }
}
```

## Dynamic Routes at Scale

### Pattern: Efficient getStaticPaths

```javascript
// pages/products/[id].tsx

// For sites with 10,000+ products:
export async function getStaticPaths() {
  // Only pre-generate top 100 products
  const topProducts = await getTopProducts(100);

  return {
    paths: topProducts.map(p => ({
      params: { id: p.id }
    })),
    // Generate other products on first request
    fallback: 'blocking'
  };
}

// Alternative: Incremental generation
export async function getStaticPaths() {
  return {
    paths: [],
    // Generate ALL products on first request
    // Cache them for subsequent visitors
    fallback: 'blocking'
  };
}

export async function getStaticProps({ params }) {
  const product = await getProduct(params.id);

  return {
    props: { product },
    revalidate: 86400 // Regenerate daily
  };
}
```

## Performance Monitoring Pattern

```javascript
// middleware.ts - Monitor rendering performance
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const startTime = Date.now();

  // Track rendering time
  const response = NextResponse.next();

  const duration = Date.now() - startTime;

  // Log slow pages
  if (duration > 1000) {
    console.warn(`Slow page: ${request.nextUrl.pathname} (${duration}ms)`);
  }

  response.headers.set('X-Response-Time', `${duration}ms`);

  return response;
}

// pages/_app.tsx
export default function App({ Component, pageProps }) {
  useEffect(() => {
    // Web Vitals tracking
    const handleMetric = (metric) => {
      console.log(`${metric.name}: ${metric.value}ms`);

      // Send to analytics
      fetch('/api/metrics', {
        method: 'POST',
        body: JSON.stringify(metric)
      });
    };

    // Track Core Web Vitals
    reportWebVitals(handleMetric);
  }, []);

  return <Component {...pageProps} />;
}
```

## Cache Invalidation Pattern

```typescript
// lib/cache.ts
import { revalidateTag, revalidatePath } from 'next/cache';

export const cacheInvalidation = {
  // Invalidate by tag (fine-grained)
  invalidateByTag: (tag: string) => {
    revalidateTag(tag);
  },

  // Invalidate by path (broader)
  invalidateByPath: (path: string) => {
    revalidatePath(path);
  },

  // Cascade invalidation
  invalidatePost: (slug: string) => {
    revalidatePath(`/blog/${slug}`);
    revalidatePath('/blog');
    revalidatePath('/');
  },

  // Batch invalidation
  invalidateCategory: (categoryId: string) => {
    revalidateTag(`category-${categoryId}`);
    revalidateTag('categories');
  }
};

// In CMS webhook:
export async function handlePostPublished(postData) {
  // Database update
  await db.posts.update(postData);

  // Cache invalidation
  cacheInvalidation.invalidatePost(postData.slug);

  return { success: true };
}
```

These patterns provide production-ready approaches for implementing SSR/SSG with excellent performance and developer experience.
