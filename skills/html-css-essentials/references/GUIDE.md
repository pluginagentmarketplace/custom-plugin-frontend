# HTML & CSS Essentials Guide

## Quick Reference

### HTML5 Semantic Elements

```html
<header>   - Page/section header
<nav>      - Navigation links
<main>     - Main content (one per page)
<article>  - Self-contained content
<section>  - Thematic grouping
<aside>    - Sidebar content
<footer>   - Page/section footer
```

### CSS Box Model

```
+---------------------------+
|         margin            |
|  +---------------------+  |
|  |      border         |  |
|  |  +---------------+  |  |
|  |  |    padding    |  |  |
|  |  |  +---------+  |  |  |
|  |  |  | content |  |  |  |
|  |  |  +---------+  |  |  |
|  |  +---------------+  |  |
|  +---------------------+  |
+---------------------------+
```

### Flexbox Cheatsheet

```css
/* Container properties */
.container {
    display: flex;
    flex-direction: row | column;
    justify-content: flex-start | center | space-between | space-around;
    align-items: stretch | center | flex-start | flex-end;
    flex-wrap: nowrap | wrap;
    gap: 1rem;
}

/* Item properties */
.item {
    flex: 1;           /* grow: 1, shrink: 1, basis: 0% */
    flex-grow: 1;      /* How much item grows */
    flex-shrink: 0;    /* How much item shrinks */
    flex-basis: 200px; /* Initial size */
    align-self: center; /* Override align-items */
}
```

### CSS Grid Cheatsheet

```css
/* Container */
.grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    grid-template-rows: auto 1fr auto;
    gap: 1rem;
}

/* Item placement */
.item {
    grid-column: 1 / 3;     /* Span 2 columns */
    grid-row: 1 / 2;        /* Single row */
    grid-area: header;      /* Named area */
}
```

### Media Queries

```css
/* Mobile first approach */
.container { width: 100%; }

/* Tablet */
@media (min-width: 768px) {
    .container { width: 750px; }
}

/* Desktop */
@media (min-width: 1024px) {
    .container { width: 960px; }
}

/* Large screens */
@media (min-width: 1280px) {
    .container { width: 1200px; }
}
```

## Best Practices

### Accessibility

1. **Always use alt text for images**
   ```html
   <img src="photo.jpg" alt="Description of the image">
   ```

2. **Use semantic HTML**
   - Prefer `<button>` over `<div onclick>`
   - Use heading hierarchy (h1 → h2 → h3)

3. **Provide focus states**
   ```css
   button:focus {
       outline: 2px solid #0066cc;
       outline-offset: 2px;
   }
   ```

### Performance

1. **Minimize CSS specificity**
   ```css
   /* ✗ Bad - high specificity */
   div#header nav ul li a.active { }

   /* ✓ Good - low specificity */
   .nav-link.active { }
   ```

2. **Use CSS custom properties**
   ```css
   :root {
       --primary-color: #0066cc;
       --spacing-unit: 8px;
   }

   .button {
       background: var(--primary-color);
       padding: var(--spacing-unit);
   }
   ```

## Common Patterns

### Responsive Navigation

```css
.nav {
    display: flex;
    flex-direction: column;
}

@media (min-width: 768px) {
    .nav {
        flex-direction: row;
        justify-content: space-between;
    }
}
```

### Card Component

```css
.card {
    display: flex;
    flex-direction: column;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    overflow: hidden;
}

.card-image {
    aspect-ratio: 16 / 9;
    object-fit: cover;
}

.card-content {
    padding: 1rem;
    flex: 1;
}
```
