---
name: dom-manipulation
description: Master DOM selection, manipulation, event handling, and dynamic content creation.
sasmp_version: "1.3.0"
bonded_agent: 01-fundamentals-agent
bond_type: SECONDARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  xss_prevention: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  performance_tracking: true
---

# DOM Manipulation

> **Purpose:** Efficiently interact with the browser DOM for dynamic, interactive web applications.

## Input/Output Schema

```typescript
interface DOMSkillInput {
  operation: 'select' | 'create' | 'modify' | 'event' | 'observe';
  selector?: string;
  eventType?: string;
}

interface DOMSkillOutput {
  code: string;
  performanceNotes: string[];
  a11yConsiderations: string[];
  securityNotes: string[];
}
```

## MANDATORY
- DOM selection (querySelector, querySelectorAll, getElementById)
- Element manipulation (innerHTML, textContent, setAttribute)
- Event handling (addEventListener, event delegation)
- Creating and removing elements
- Class manipulation (classList API)
- Form handling and validation

## OPTIONAL
- MutationObserver for DOM changes
- IntersectionObserver for visibility detection
- ResizeObserver for element sizing
- Custom events (CustomEvent)
- Template elements
- Shadow DOM basics

## ADVANCED
- Performance optimization (DocumentFragment, batch updates)
- Virtual scrolling implementation
- DOM diffing concepts
- Web Components
- Accessibility tree
- DOM sanitization (DOMPurify)

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `null reference` | Element not found | Check if element exists |
| `Memory leak` | Orphaned listeners | Remove listeners on cleanup |
| `XSS vulnerability` | innerHTML with user input | Use textContent or sanitize |
| `Layout thrashing` | Read/write interleave | Batch DOM operations |

## Test Template

```typescript
describe('DOMHelper', () => {
  beforeEach(() => {
    document.body.innerHTML = '<div id="app"></div>';
  });

  it('creates element correctly', () => {
    const el = createElement('button', { text: 'Click' });
    expect(el.textContent).toBe('Click');
  });

  it('handles events', () => {
    const handler = jest.fn();
    const button = document.createElement('button');
    button.addEventListener('click', handler);
    button.click();
    expect(handler).toHaveBeenCalled();
  });
});
```

## Best Practices
- Use event delegation for dynamic content
- Batch DOM reads and writes
- Clean up event listeners
- Never use innerHTML with untrusted content
- Use requestAnimationFrame for animations

## Resources
- [MDN DOM Guide](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model)
- [DOM Events Reference](https://developer.mozilla.org/en-US/docs/Web/Events)

---
**Status:** Active | **Version:** 2.0.0
