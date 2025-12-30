---
name: html-css-essentials
description: Master HTML5 semantic markup and CSS layouts (Flexbox, Grid) for responsive, accessible web development.
sasmp_version: "1.3.0"
bonded_agent: 01-fundamentals-agent
bond_type: PRIMARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  accessibility_check: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  performance_tracking: true
---

# HTML & CSS Essentials

> **Purpose:** Build semantic, accessible, and responsive web layouts with modern HTML5 and CSS.

## Input/Output Schema

```typescript
interface HTMLCSSInput {
  topic: 'semantic' | 'layout' | 'responsive' | 'accessibility' | 'animation';
  targetBrowsers?: string[];
  designSystem?: boolean;
}

interface HTMLCSSOutput {
  htmlMarkup: string;
  cssStyles: string;
  a11yNotes: string[];
  browserSupport: string[];
}
```

## MANDATORY
- HTML5 semantic elements (header, nav, main, article, section, footer)
- CSS Box Model and display properties
- Flexbox layout system
- CSS Grid layout system
- Responsive design with media queries
- Mobile-first development approach

## OPTIONAL
- CSS Custom Properties (variables)
- CSS animations and transitions
- ARIA accessibility attributes
- Form validation and styling
- CSS pseudo-classes and pseudo-elements
- Web fonts and typography

## ADVANCED
- CSS Container Queries
- CSS Subgrid
- CSS Cascade Layers (@layer)
- View Transitions API
- CSS Scroll-driven animations
- CSS Nesting (native)

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| Layout breaking | Missing box-sizing | Add `box-sizing: border-box` |
| Grid not working | Browser support | Check caniuse, add fallback |
| Accessibility issues | Missing semantics | Use proper HTML elements |
| Responsive failure | Missing viewport meta | Add viewport meta tag |

## Test Template

```typescript
describe('Layout Component', () => {
  it('is accessible', async () => {
    const { container } = render(<Layout />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('is responsive', () => {
    render(<Layout />);
    // Test at different viewport sizes
  });
});
```

## Best Practices
- Use semantic HTML elements
- Mobile-first responsive design
- Use CSS custom properties for theming
- Test accessibility with screen readers
- Avoid `!important` unless necessary

## Resources
- [MDN HTML Guide](https://developer.mozilla.org/en-US/docs/Learn/HTML)
- [MDN CSS Guide](https://developer.mozilla.org/en-US/docs/Learn/CSS)
- [CSS-Tricks](https://css-tricks.com/)

---
**Status:** Active | **Version:** 2.0.0
