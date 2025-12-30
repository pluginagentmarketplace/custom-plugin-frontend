---
name: learn_frameworks
description: Master frontend frameworks - React, Vue, Angular, and Svelte
allowed-tools: Read
version: "2.0.0"
agent: 03-frameworks-agent

# Command Configuration
input_validation:
  framework:
    type: string
    required: false
    allowed_values: [react, vue, angular, svelte]
  skill_name:
    type: string
    required: false

exit_codes:
  0: success
  1: invalid_framework
  2: invalid_skill
  3: agent_unavailable
---

# /frameworks

> Master frontend frameworks: React, Vue, Angular, and Svelte.

## Usage

```bash
/frameworks [framework] [skill-name]
```

## Available Frameworks & Skills

### React
| Skill | Description | Duration |
|-------|-------------|----------|
| `react-fundamentals` | Components, JSX, props, state | 5-6 hours |
| `react-hooks-patterns` | useState, useEffect, custom hooks | 4-5 hours |

### Vue
| Skill | Description | Duration |
|-------|-------------|----------|
| `vue-composition-api` | ref, reactive, composables | 4-5 hours |
| `vue-composition-api-advanced` | Advanced patterns, Pinia | 3-4 hours |

### Angular
| Skill | Description | Duration |
|-------|-------------|----------|
| `angular-dependency-injection` | Services, providers, RxJS | 4-5 hours |

### Svelte
| Skill | Description | Duration |
|-------|-------------|----------|
| `svelte-reactivity-stores` | Runes, stores, reactivity | 3-4 hours |

## Examples

```bash
# List all frameworks
/frameworks

# React skills
/frameworks react
/frameworks react react-hooks-patterns

# Vue skills
/frameworks vue vue-composition-api

# Angular skills
/frameworks angular angular-dependency-injection

# Svelte skills
/frameworks svelte svelte-reactivity-stores
```

## Framework Comparison

| Framework | Best For | Learning Curve |
|-----------|----------|----------------|
| **React** | Flexibility, large ecosystem | Medium |
| **Vue** | Progressive adoption, simplicity | Easy |
| **Angular** | Enterprise, full-featured | Steep |
| **Svelte** | Performance, minimal bundle | Easy |

## Description

Deep dive into modern frontend frameworks:

- **React** - Hooks, components, ecosystem
- **Vue** - Composition API, reactivity
- **Angular** - Dependency injection, RxJS
- **Svelte** - Compile-time reactivity

## Prerequisites

- Frontend Fundamentals (`/fundamentals`)
- JavaScript ES6+ knowledge
- Basic TypeScript (recommended)

## Next Steps

After mastering a framework:
- `/state-management` - Redux, Zustand, Pinia
- `/testing` - Unit and component testing
- `/performance` - Optimization techniques

---
**Command Version:** 2.0.0 | **Agent:** 03-frameworks-agent
