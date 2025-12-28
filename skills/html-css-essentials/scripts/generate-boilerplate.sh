#!/bin/bash
# HTML5 Boilerplate Generator
# Part of html-css-essentials skill - Golden Format E703 Compliant

set -e

OUTPUT_FILE="${1:-index.html}"

cat > "$OUTPUT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Page description for SEO">
    <title>Page Title</title>

    <!-- Preconnect to external resources -->
    <link rel="preconnect" href="https://fonts.googleapis.com">

    <!-- CSS -->
    <link rel="stylesheet" href="styles.css">

    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="/favicon.svg">
</head>
<body>
    <header>
        <nav aria-label="Main navigation">
            <ul>
                <li><a href="/">Home</a></li>
                <li><a href="/about">About</a></li>
                <li><a href="/contact">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <article>
            <h1>Main Heading</h1>
            <p>Your content goes here.</p>
        </article>
    </main>

    <footer>
        <p>&copy; 2025 Your Name. All rights reserved.</p>
    </footer>

    <!-- Scripts at end of body for performance -->
    <script src="app.js" defer></script>
</body>
</html>
EOF

echo "✓ Generated HTML5 boilerplate: $OUTPUT_FILE"
echo ""
echo "Features included:"
echo "  - HTML5 DOCTYPE"
echo "  - Proper meta tags (charset, viewport, description)"
echo "  - Semantic HTML structure (header, main, footer, nav, article)"
echo "  - Accessibility attributes (aria-label)"
echo "  - Performance optimizations (preconnect, defer)"
echo "  - SEO-friendly structure"
