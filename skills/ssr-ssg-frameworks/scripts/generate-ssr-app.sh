#!/bin/bash
# SSR/SSG App Generator - Creates production-ready Next.js pages structure

set -e

PROJECT_PATH="${1:-.}"
PAGES_DIR="$PROJECT_PATH/pages"
API_DIR="$PROJECT_PATH/pages/api"
LIB_DIR="$PROJECT_PATH/lib"

mkdir -p "$PAGES_DIR" "$API_DIR" "$LIB_DIR"

echo "SSR/SSG App Generator"
echo "===================="
echo ""

# 1. Generate data fetching utilities
echo "📝 Generating data fetching utilities..."
cat > "$LIB_DIR/api.ts" << 'EOF'
/**
 * Data Fetching Utilities
 * Shared functions for server-side and static data fetching
 */

export interface FetchOptions {
  revalidate?: number | false; // ISR revalidation time in seconds
  tags?: string[]; // Cache tags for on-demand revalidation
}

/**
 * Fetch data for static page generation
 * Use in getStaticProps
 */
export async function fetchDataStatic(
  url: string,
  options: FetchOptions = {}
) {
  const revalidate = options.revalidate !== undefined ? options.revalidate : 3600;

  try {
    const response = await fetch(url, {
      next: {
        revalidate,
        tags: options.tags
      }
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    return response.json();
  } catch (error) {
    console.error('Data fetch error:', error);
    return null;
  }
}

/**
 * Fetch data for server-side rendering
 * Use in getServerSideProps
 */
export async function fetchDataServer(
  url: string,
  context: any = {}
) {
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };

    // Forward cookies from client request
    if (context.req?.headers.cookie) {
      headers['Cookie'] = context.req.headers.cookie;
    }

    const response = await fetch(url, {
      headers,
      // Don't cache server-side fetches
      cache: 'no-store'
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    return response.json();
  } catch (error) {
    console.error('Server data fetch error:', error);
    return null;
  }
}

/**
 * Client-side data fetching with caching
 */
export async function fetchDataClient(url: string) {
  try {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    return response.json();
  } catch (error) {
    console.error('Client fetch error:', error);
    throw error;
  }
}

/**
 * Prefetch data for hydration
 * Returns data for initial page load
 */
export async function prefetchData(keys: string[]): Promise<Record<string, any>> {
  const data: Record<string, any> = {};

  for (const key of keys) {
    try {
      const response = await fetch(`/api/prefetch?key=${key}`);
      data[key] = await response.json();
    } catch (error) {
      console.error(`Prefetch error for ${key}:`, error);
    }
  }

  return data;
}

/**
 * Handle on-demand revalidation
 * Trigger this to rebuild specific pages
 */
export async function revalidatePage(path: string) {
  try {
    const response = await fetch('/api/revalidate', {
      method: 'POST',
      body: JSON.stringify({ path })
    });

    return response.ok;
  } catch (error) {
    console.error('Revalidation error:', error);
    return false;
  }
}
EOF
echo "✓ Created: lib/api.ts"

# 2. Generate static page example
echo "📝 Generating static page example..."
cat > "$PAGES_DIR/blog/\[slug\].tsx" << 'EOF'
/**
 * Dynamic Static Page with getStaticProps and getStaticPaths
 * Great for blog posts, documentation, product pages
 */

import { GetStaticProps, GetStaticPaths } from 'next';
import Head from 'next/head';
import { fetchDataStatic } from '@/lib/api';

interface BlogPost {
  id: string;
  slug: string;
  title: string;
  content: string;
  excerpt: string;
  publishedAt: string;
  author: string;
}

interface BlogPageProps {
  post: BlogPost;
  relatedPosts: BlogPost[];
}

export default function BlogPage({ post, relatedPosts }: BlogPageProps) {
  return (
    <>
      <Head>
        <title>{post.title}</title>
        <meta name="description" content={post.excerpt} />
        <meta property="og:title" content={post.title} />
        <meta property="og:description" content={post.excerpt} />
      </Head>

      <article>
        <header>
          <h1>{post.title}</h1>
          <p>{new Date(post.publishedAt).toLocaleDateString()}</p>
          <p>By {post.author}</p>
        </header>

        <div dangerouslySetInnerHTML={{ __html: post.content }} />

        <aside>
          <h3>Related Posts</h3>
          <ul>
            {relatedPosts.map((p) => (
              <li key={p.id}>
                <a href={`/blog/${p.slug}`}>{p.title}</a>
              </li>
            ))}
          </ul>
        </aside>
      </article>
    </>
  );
}

/**
 * getStaticPaths - Define which dynamic routes to pre-generate
 * Runs at build time
 */
export const getStaticPaths: GetStaticPaths = async () => {
  try {
    const posts = await fetchDataStatic(
      `${process.env.API_URL}/blog/posts`
    );

    const paths = posts.map((post) => ({
      params: { slug: post.slug }
    }));

    return {
      paths,
      // Enable ISR for new posts
      fallback: 'blocking' // Generate on first request, then cache
    };
  } catch (error) {
    console.error('getStaticPaths error:', error);
    return {
      paths: [],
      fallback: 'blocking'
    };
  }
};

/**
 * getStaticProps - Generate static page at build time
 * Regenerates every 3600 seconds (ISR)
 */
export const getStaticProps: GetStaticProps<BlogPageProps> = async ({
  params
}) => {
  const slug = params?.slug as string;

  try {
    // Fetch blog post
    const post = await fetchDataStatic(
      `${process.env.API_URL}/blog/${slug}`,
      { revalidate: 3600 } // Revalidate every hour
    );

    if (!post) {
      return { notFound: true };
    }

    // Fetch related posts
    const relatedPosts = await fetchDataStatic(
      `${process.env.API_URL}/blog/${slug}/related`,
      { revalidate: 3600 }
    );

    return {
      props: {
        post,
        relatedPosts: relatedPosts || []
      },
      revalidate: 3600 // ISR: regenerate every hour
    };
  } catch (error) {
    console.error('getStaticProps error:', error);
    return {
      notFound: true,
      revalidate: 60 // Retry after 1 minute on error
    };
  }
};
EOF
echo "✓ Created: pages/blog/[slug].tsx"

# 3. Generate server-side rendering page
echo "📝 Generating SSR page example..."
cat > "$PAGES_DIR/dashboard.tsx" << 'EOF'
/**
 * Server-Side Rendering (SSR) Page
 * Use for dynamic, personalized content that changes per request
 */

import { GetServerSideProps } from 'next';
import Head from 'next/head';
import { fetchDataServer } from '@/lib/api';

interface DashboardData {
  userId: string;
  username: string;
  stats: {
    posts: number;
    followers: number;
    views: number;
  };
  recentActivity: Array<{
    id: string;
    type: string;
    timestamp: string;
  }>;
}

interface DashboardPageProps {
  data: DashboardData;
  error?: string;
}

export default function DashboardPage({ data, error }: DashboardPageProps) {
  if (error) {
    return <div>Error loading dashboard: {error}</div>;
  }

  return (
    <>
      <Head>
        <title>Dashboard - {data.username}</title>
      </Head>

      <div className="dashboard">
        <h1>Welcome, {data.username}!</h1>

        <section className="stats">
          <div className="stat">
            <h3>{data.stats.posts}</h3>
            <p>Posts</p>
          </div>
          <div className="stat">
            <h3>{data.stats.followers}</h3>
            <p>Followers</p>
          </div>
          <div className="stat">
            <h3>{data.stats.views}</h3>
            <p>Total Views</p>
          </div>
        </section>

        <section className="activity">
          <h2>Recent Activity</h2>
          <ul>
            {data.recentActivity.map((activity) => (
              <li key={activity.id}>
                {activity.type} - {new Date(activity.timestamp).toLocaleString()}
              </li>
            ))}
          </ul>
        </section>
      </div>
    </>
  );
}

/**
 * getServerSideProps - Fetch data on every request
 * Good for: Personalized content, real-time data, authenticated pages
 * Bad for: Performance (renders on every request)
 */
export const getServerSideProps: GetServerSideProps<DashboardPageProps> =
  async ({ req, res, query }) => {
    // Set cache headers
    res.setHeader(
      'Cache-Control',
      'private, no-cache, no-store, must-revalidate'
    );

    try {
      // Get user ID from session/auth
      const userId = req.headers.cookie?.match(/userId=([^;]+)/)?.[1];

      if (!userId) {
        return {
          redirect: {
            destination: '/login',
            permanent: false
          }
        };
      }

      // Fetch user-specific data
      const data = await fetchDataServer(
        `${process.env.API_URL}/dashboard/${userId}`,
        { req }
      );

      if (!data) {
        return {
          notFound: true
        };
      }

      return {
        props: { data },
        revalidate: false // No ISR for SSR pages
      };
    } catch (error) {
      console.error('getServerSideProps error:', error);

      return {
        props: {
          data: null,
          error: 'Failed to load dashboard'
        }
      };
    }
  };
EOF
echo "✓ Created: pages/dashboard.tsx"

# 4. Generate hybrid rendering page
echo "📝 Generating hybrid (SSG + ISR) page..."
cat > "$PAGES_DIR/products/index.tsx" << 'EOF'
/**
 * Hybrid Page - Static generation with ISR
 * Good for: Product listings, category pages, user profiles
 */

import { GetStaticProps } from 'next';
import { fetchDataStatic } from '@/lib/api';

interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
}

interface ProductsPageProps {
  products: Product[];
  totalCount: number;
}

export default function ProductsPage({ products, totalCount }: ProductsPageProps) {
  return (
    <div>
      <h1>Products ({totalCount})</h1>

      <div className="grid">
        {products.map((product) => (
          <div key={product.id} className="product-card">
            <img src={product.image} alt={product.name} />
            <h3>{product.name}</h3>
            <p>${product.price}</p>
            <button>Add to Cart</button>
          </div>
        ))}
      </div>
    </div>
  );
}

export const getStaticProps: GetStaticProps<ProductsPageProps> = async () => {
  try {
    const response = await fetchDataStatic(
      `${process.env.API_URL}/products`,
      {
        revalidate: 60 * 5 // Revalidate every 5 minutes
      }
    );

    return {
      props: {
        products: response.items,
        totalCount: response.total
      },
      revalidate: 60 * 5 // ISR: regenerate every 5 minutes
    };
  } catch (error) {
    return {
      notFound: true,
      revalidate: 60 // Retry after 1 minute
    };
  }
};
EOF
echo "✓ Created: pages/products/index.tsx"

# 5. Generate API route example
echo "📝 Generating API route example..."
cat > "$API_DIR/data.ts" << 'EOF'
/**
 * API Route Example
 * Use for data fetching, mutations, webhooks
 */

import type { NextApiRequest, NextApiResponse } from 'next';

interface ResponseData {
  success: boolean;
  message?: string;
  data?: any;
  error?: string;
}

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<ResponseData>
) {
  // Handle different HTTP methods
  switch (req.method) {
    case 'GET':
      return handleGet(req, res);
    case 'POST':
      return handlePost(req, res);
    case 'PUT':
      return handlePut(req, res);
    case 'DELETE':
      return handleDelete(req, res);
    default:
      res.setHeader('Allow', ['GET', 'POST', 'PUT', 'DELETE']);
      return res.status(405).json({
        success: false,
        error: `Method ${req.method} Not Allowed`
      });
  }
}

function handleGet(req: NextApiRequest, res: NextApiResponse<ResponseData>) {
  const { id } = req.query;

  // Fetch and return data
  res.status(200).json({
    success: true,
    data: {
      id,
      name: 'Sample Data',
      timestamp: new Date().toISOString()
    }
  });
}

function handlePost(req: NextApiRequest, res: NextApiResponse<ResponseData>) {
  const { name, email } = req.body;

  // Validate input
  if (!name || !email) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields'
    });
  }

  // Process data
  res.status(201).json({
    success: true,
    message: 'Data created successfully',
    data: { name, email }
  });
}

function handlePut(req: NextApiRequest, res: NextApiResponse<ResponseData>) {
  const { id } = req.query;

  // Update data
  res.status(200).json({
    success: true,
    message: 'Data updated',
    data: { id, ...req.body }
  });
}

function handleDelete(req: NextApiRequest, res: NextApiResponse<ResponseData>) {
  const { id } = req.query;

  // Delete data
  res.status(200).json({
    success: true,
    message: 'Data deleted',
    data: { id }
  });
}
EOF
echo "✓ Created: pages/api/data.ts"

# 6. Generate revalidation API route
echo "📝 Generating on-demand revalidation API..."
cat > "$API_DIR/revalidate.ts" << 'EOF'
/**
 * On-Demand Revalidation API
 * Allows manual ISR revalidation of specific pages
 */

import type { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Verify revalidation token (CRITICAL for security!)
  if (req.query.token !== process.env.REVALIDATE_TOKEN) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  const { path } = req.body;

  if (!path) {
    return res.status(400).json({ message: 'Missing path' });
  }

  try {
    // Revalidate the path
    await res.revalidate(path);

    return res.json({ revalidated: true, path });
  } catch (err) {
    console.error('Revalidation error:', err);
    return res.status(500).json({ message: 'Error revalidating' });
  }
}
EOF
echo "✓ Created: pages/api/revalidate.ts"

# 7. Generate next.config.js
echo "📝 Generating Next.js configuration..."
cat > "$PROJECT_PATH/next.config.js" << 'EOF'
/**
 * Next.js Configuration
 * Production-ready setup with image optimization, headers, redirects
 */

/** @type {import('next').NextConfig} */
const nextConfig = {
  // React strict mode for development warnings
  reactStrictMode: true,

  // Enable SWC minification (faster builds)
  swcMinify: true,

  // Image optimization
  images: {
    // Use next/image for optimal performance
    formats: ['image/avif', 'image/webp'],
    // Specify allowed domains for external images
    domains: [
      'example.com',
      'cdn.example.com'
    ],
    // Cache optimized images
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384]
  },

  // Security headers
  headers: async () => {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          }
        ]
      }
    ];
  },

  // Redirects
  redirects: async () => {
    return [
      {
        source: '/old-page',
        destination: '/new-page',
        permanent: true // HTTP 301
      }
    ];
  },

  // Rewrites (internal routing)
  rewrites: async () => {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'http://backend:3000/:path*'
        }
      ]
    };
  },

  // Environment variables
  env: {
    API_URL: process.env.API_URL
  },

  // Build optimization
  productionBrowserSourceMaps: false,
  optimizeFonts: true,

  // ESLint during build
  eslint: {
    dirs: ['pages', 'components', 'lib']
  },

  // Experimental features (use carefully!)
  experimental: {
    optimizePackageImports: {
      lodash: {
        transform: 'lodash/{{member}}'
      }
    }
  }
};

module.exports = nextConfig;
EOF
echo "✓ Created: next.config.js"

echo ""
echo "===================="
echo "✓ App Generation Complete!"
echo "===================="
echo ""
echo "Generated files:"
echo "  ✓ lib/api.ts - Data fetching utilities"
echo "  ✓ pages/blog/[slug].tsx - Static generation with ISR"
echo "  ✓ pages/dashboard.tsx - Server-side rendering"
echo "  ✓ pages/products/index.tsx - Hybrid rendering"
echo "  ✓ pages/api/data.ts - API route example"
echo "  ✓ pages/api/revalidate.ts - On-demand ISR"
echo "  ✓ next.config.js - Production configuration"
echo ""
echo "Next steps:"
echo "1. npm install next react react-dom"
echo "2. Update API_URL in environment variables"
echo "3. npm run dev"
echo "4. npm run build && npm start"
echo ""
