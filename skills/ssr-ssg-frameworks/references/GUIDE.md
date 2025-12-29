# SSR/SSG Frameworks Technical Guide

## Server-Side Rendering vs Client-Side Rendering

### Client-Side Rendering (CSR)
In CSR, the browser downloads a minimal HTML file and JavaScript bundle, then renders the page in JavaScript.

**Pros:**
- Fast subsequent navigations (SPA)
- Rich interactivity
- Lower server load
- Works well with real-time updates

**Cons:**
- Slow initial load (large JS bundle)
- Blank page while JS loads
- SEO challenges (crawlers struggle with JS)
- Requires JavaScript to display content

```javascript
// Traditional React app (CSR)
// Single HTML file, large JS bundle
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(<App />, document.getElementById('root'));
```

### Server-Side Rendering (SSR)
The server renders the page on each request and sends HTML to the browser.

**Pros:**
- Fast First Contentful Paint (FCP)
- Perfect SEO (full HTML with content)
- Works without JavaScript
- Better performance on slow devices

**Cons:**
- Slower Time To Interactive (TTI)
- Higher server load
- More complex deployment
- Session management needed

```javascript
// Server-Side Rendering with Next.js
export async function getServerSideProps(context) {
  // This runs on the server for every request
  const data = await fetchData();

  return {
    props: { data }
  };
}

export default function Page({ data }) {
  return <div>{data.title}</div>;
}
```

## Static Site Generation (SSG)

SSG pre-renders pages at build time and serves static HTML files. This is the fastest rendering method.

**Pros:**
- Fastest performance (CDN cacheable)
- Lowest server load (no servers needed)
- Best SEO (complete HTML)
- Highly scalable
- Works offline

**Cons:**
- Content is static (built at deploy time)
- Requires rebuild for content changes
- Not suitable for personalized content
- Build time scales with page count

### Static Generation Example

```javascript
// Generate static page at build time
export async function getStaticProps() {
  const posts = await getPosts();

  return {
    props: { posts },
    revalidate: 3600 // ISR: regenerate every hour
  };
}

export default function BlogIndex({ posts }) {
  return (
    <div>
      {posts.map(post => (
        <a key={post.id} href={`/blog/${post.slug}`}>
          {post.title}
        </a>
      ))}
    </div>
  );
}
```

## Incremental Static Regeneration (ISR)

ISR allows you to update static pages **without rebuilding the entire site**. Pages are regenerated on a schedule or on-demand.

### How ISR Works

1. **Initial Build**: Static pages generated at build time
2. **Request Comes In**: Serve cached page (fast)
3. **In Background**: Re-render the page if needed
4. **Cache Update**: New HTML replaces old version
5. **Next Request**: Serve fresh page

### ISR Implementation

```javascript
export async function getStaticProps() {
  const post = await getPost();

  return {
    props: { post },
    revalidate: 3600 // Regenerate every hour (background)
  };
}

// Every request before the hour expires: serve cached version
// After 1 hour: regenerate in background, serve cached version to user
// Next request after regeneration: serve fresh version
```

### On-Demand Revalidation

Manually trigger page regeneration when content changes:

```javascript
// API route to revalidate pages
export default async function handler(req, res) {
  // Verify secret to prevent abuse
  if (req.query.secret !== process.env.REVALIDATE_SECRET) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  try {
    // Revalidate specific path
    await res.revalidate('/blog/my-post');
    return res.json({ revalidated: true });
  } catch (err) {
    return res.status(500).send('Error revalidating');
  }
}

// Usage: POST /api/revalidate?secret=TOKEN
// Content management system calls this when article is published
```

## Dynamic Routes with Static Generation

Use `getStaticPaths` to tell Next.js which dynamic routes to pre-generate:

```javascript
// pages/blog/[slug].tsx
export async function getStaticPaths() {
  const posts = await getPosts();

  return {
    paths: posts.map(post => ({
      params: { slug: post.slug }
    })),
    fallback: 'blocking' // Generate new routes on first request
  };
}

export async function getStaticProps({ params }) {
  const post = await getPost(params.slug);

  return {
    props: { post },
    revalidate: 3600
  };
}

export default function BlogPost({ post }) {
  return (
    <>
      <h1>{post.title}</h1>
      <div>{post.content}</div>
    </>
  );
}
```

### Fallback Options

```javascript
// fallback: false
// Only pre-generated paths work, others return 404
// Best for: Sites with all paths known at build time

// fallback: 'blocking'
// Generate missing routes on first request (SSR)
// Then cache them
// Best for: Dynamic content with on-demand generation

// fallback: true
// Return skeleton page immediately, generate in background
// Best for: Many routes with non-critical content
paths: [/* ... */],
fallback: true // Page shell loads immediately
```

## Data Fetching Patterns in Next.js

### Server-Side Props (SSR)

```javascript
export async function getServerSideProps(context) {
  // Access request/response, cookies, query parameters
  const { params, query, req, res } = context;

  // Fetch data on every request
  const data = await fetch(`/api/user/${params.id}`);

  return {
    props: { data },
    revalidate: false // No caching
  };
}
```

### Static Props (SSG)

```javascript
export async function getStaticProps() {
  // Runs once at build time
  const products = await fetchAllProducts();

  return {
    props: { products },
    revalidate: 3600 // Regenerate hourly
  };
}
```

### Client-Side Fetching

```javascript
import { useEffect, useState } from 'react';

export default function Page() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('/api/data')
      .then(res => res.json())
      .then(data => setData(data));
  }, []);

  if (!data) return <div>Loading...</div>;
  return <div>{data.title}</div>;
}

// Use for: Non-critical data, real-time updates, personalized content
// SEO: No (content not in HTML)
```

## Performance Considerations

### Time to First Byte (TTFB)
- **SSG**: Fastest (static CDN)
- **ISR**: Fast (cached, regenerates in background)
- **SSR**: Slowest (server renders per request)
- **CSR**: Very slow (downloads large JS bundle)

### Time to Interactive (TTI)
- **SSG**: Fast (small HTML + hydration)
- **SSR**: Medium (server-rendered HTML + hydration)
- **CSR**: Very slow (waits for large bundle)

### Optimization Tips

```javascript
// 1. Use ISR for better performance than SSR
export const getStaticProps = async () => {
  return {
    props: { data },
    revalidate: 60 // Cache for 1 minute
  };
};

// 2. Use dynamic imports for large components
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('./Heavy'), {
  loading: () => <div>Loading...</div>
});

// 3. Use Image component for optimization
import Image from 'next/image';

<Image
  src="/image.png"
  alt="Description"
  width={800}
  height={600}
  priority // Load above fold
/>

// 4. Code splitting by default
// Each page is its own bundle
// Unused code not downloaded

// 5. Optimize dependencies
// Check bundle size: npm install -g webpack-bundle-analyzer
// Remove unused packages
```

## SEO Benefits of Server Rendering

Server-rendered pages are ideal for SEO:

```javascript
import Head from 'next/head';

export default function BlogPost({ post }) {
  return (
    <>
      <Head>
        <title>{post.title}</title>
        <meta name="description" content={post.excerpt} />
        {/* Open Graph for social sharing */}
        <meta property="og:title" content={post.title} />
        <meta property="og:description" content={post.excerpt} />
        <meta property="og:image" content={post.image} />
        <meta property="og:type" content="article" />
        {/* Structured data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              '@context': 'https://schema.org',
              '@type': 'BlogPosting',
              headline: post.title,
              description: post.excerpt,
              image: post.image,
              datePublished: post.publishedAt,
              author: {
                '@type': 'Person',
                name: post.author
              }
            })
          }}
        />
      </Head>
      <article>
        <h1>{post.title}</h1>
        <p>{post.content}</p>
      </article>
    </>
  );
}

export async function getStaticProps({ params }) {
  const post = await getPost(params.slug);
  return {
    props: { post },
    revalidate: 3600
  };
}
```

**SEO Advantages:**
- Full HTML content available to crawlers
- Meta tags rendered server-side
- Open Graph support for social previews
- Structured data (JSON-LD) included
- No JavaScript required to index content

## Comparing Next.js and Nuxt

### Next.js (React)
```javascript
// getServerSideProps for SSR
export async function getServerSideProps() {
  const data = await fetch('/api/data');
  return { props: { data } };
}

// getStaticProps for SSG
export async function getStaticProps() {
  const data = await fetch('/api/data');
  return { props: { data }, revalidate: 3600 };
}
```

### Nuxt (Vue)
```javascript
// Nuxt 3 with asyncData
export default definePageMeta({
  validate: async (route) => {
    return true;
  }
});

export default defineComponent({
  async asyncData() {
    const data = await fetch('/api/data');
    return { data };
  }
});

// Nuxt Content for content-driven sites
<template>
  <article>
    <ContentDoc />
  </article>
</template>
```

This comprehensive approach ensures your application has excellent performance, SEO, and user experience through intelligent rendering strategies.
