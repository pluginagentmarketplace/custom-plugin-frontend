---
name: learn_fundamentals
description: Learn frontend fundamentals - HTML, CSS, JavaScript, Git, DOM, and web basics
allowed-tools: Read
version: "2.0.0"
agent: 01-fundamentals-agent

# Command Configuration
input_validation:
  skill_name:
    type: string
    required: false
    allowed_values:
      - internet-basics
      - html-css-essentials
      - javascript-fundamentals
      - git-version-control
      - dom-manipulation

exit_codes:
  0: success
  1: invalid_skill
  2: skill_not_found
  3: agent_unavailable
---

# /fundamentals

> Learn frontend fundamentals: HTML, CSS, JavaScript, Git, DOM, and web basics.

## Usage

```bash
/fundamentals [skill-name]
```

## Available Skills

| Skill | Description | Duration |
|-------|-------------|----------|
| `internet-basics` | TCP/IP, HTTP/HTTPS, DNS, browsers | 2-3 hours |
| `html-css-essentials` | HTML5 semantics, CSS Flexbox/Grid | 4-5 hours |
| `javascript-fundamentals` | ES6+, async/await, modules | 6-8 hours |
| `git-version-control` | Branching, merging, workflows | 3-4 hours |
| `dom-manipulation` | Selection, events, dynamic content | 3-4 hours |

## Examples

```bash
# List all available skills
/fundamentals

# Learn specific skill
/fundamentals internet-basics
/fundamentals html-css-essentials
/fundamentals javascript-fundamentals
/fundamentals git-version-control
/fundamentals dom-manipulation
```

## Description

Start your frontend journey with core technologies:

- **Web Fundamentals** - How the internet works
- **HTML5** - Semantic markup and structure
- **CSS** - Layouts with Flexbox and Grid
- **JavaScript** - Modern ES6+ programming
- **DOM** - Manipulation and events
- **Git** - Version control essentials

## Learning Path

```
Week 1: Internet Basics → HTML/CSS Essentials
Week 2: JavaScript Fundamentals
Week 3: DOM Manipulation → Git Version Control
```

## Prerequisites

- Basic computer literacy
- Code editor installed (VS Code recommended)
- Modern browser (Chrome, Firefox, Edge)

## Next Steps

After completing fundamentals, proceed to:
- `/build-tools` - Package managers and bundlers
- `/frameworks` - React, Vue, Angular, Svelte

---
**Command Version:** 2.0.0 | **Agent:** 01-fundamentals-agent
