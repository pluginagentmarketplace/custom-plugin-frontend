# HTML/CSS Design Patterns

## Layout Patterns

### Holy Grail Layout

Classic 3-column layout with header and footer:

```css
.holy-grail {
    display: grid;
    grid-template-areas:
        "header header header"
        "nav    main   aside"
        "footer footer footer";
    grid-template-columns: 200px 1fr 200px;
    grid-template-rows: auto 1fr auto;
    min-height: 100vh;
}

.header { grid-area: header; }
.nav    { grid-area: nav; }
.main   { grid-area: main; }
.aside  { grid-area: aside; }
.footer { grid-area: footer; }
```

### Sticky Footer

Footer always at bottom, even with little content:

```css
body {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

main {
    flex: 1;
}

footer {
    margin-top: auto;
}
```

### Centered Container

```css
.container {
    width: min(90%, 1200px);
    margin-inline: auto;
    padding-inline: 1rem;
}
```

## Component Patterns

### Responsive Image

```html
<picture>
    <source media="(min-width: 1024px)" srcset="large.jpg">
    <source media="(min-width: 768px)" srcset="medium.jpg">
    <img src="small.jpg" alt="Description" loading="lazy">
</picture>
```

### Aspect Ratio Box

```css
.aspect-ratio-16-9 {
    aspect-ratio: 16 / 9;
    width: 100%;
}

/* Fallback for older browsers */
@supports not (aspect-ratio: 16 / 9) {
    .aspect-ratio-16-9 {
        position: relative;
        padding-top: 56.25%;
    }

    .aspect-ratio-16-9 > * {
        position: absolute;
        inset: 0;
    }
}
```

### Skip Link (Accessibility)

```html
<a href="#main-content" class="skip-link">Skip to main content</a>
```

```css
.skip-link {
    position: absolute;
    top: -40px;
    left: 0;
    padding: 8px;
    background: #000;
    color: #fff;
    z-index: 100;
}

.skip-link:focus {
    top: 0;
}
```

## Animation Patterns

### Fade In

```css
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.fade-in {
    animation: fadeIn 0.3s ease-in;
}
```

### Slide Up

```css
@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.slide-up {
    animation: slideUp 0.3s ease-out;
}
```

### Reduced Motion

Always respect user preferences:

```css
@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

## Form Patterns

### Accessible Form Field

```html
<div class="form-field">
    <label for="email">Email Address</label>
    <input
        type="email"
        id="email"
        name="email"
        required
        aria-describedby="email-hint"
    >
    <span id="email-hint" class="hint">We'll never share your email</span>
</div>
```

```css
.form-field {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
}

.form-field label {
    font-weight: 500;
}

.form-field input {
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 4px;
}

.form-field input:focus {
    outline: 2px solid #0066cc;
    outline-offset: 2px;
}

.hint {
    font-size: 0.875rem;
    color: #666;
}
```

## CSS Reset/Normalize

Modern CSS reset:

```css
*,
*::before,
*::after {
    box-sizing: border-box;
}

* {
    margin: 0;
}

body {
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
}

img, picture, video, canvas, svg {
    display: block;
    max-width: 100%;
}

input, button, textarea, select {
    font: inherit;
}

p, h1, h2, h3, h4, h5, h6 {
    overflow-wrap: break-word;
}
```
