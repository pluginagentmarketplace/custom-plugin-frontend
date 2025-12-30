---
name: learn_state_management
description: Master state management - Redux, Context API, Zustand, and architectural patterns
allowed-tools: Read
version: "2.0.0"
agent: 04-state-management-agent

# Command Configuration
input_validation:
  skill_name:
    type: string
    required: false
    allowed_values:
      - redux-fundamentals
      - redux-state-management
      - context-api-patterns
      - context-api-hooks
      - zustand-minimalist
      - zustand-lightweight-state
      - state-patterns-architecture
      - architectural-patterns

exit_codes:
  0: success
  1: invalid_skill
  2: skill_not_found
  3: agent_unavailable
---

# /state-management

> Master state management: Redux, Context API, Zustand, and architectural patterns.

## Usage

```bash
/state-management [skill-name]
```

## Available Skills

| Skill | Description | Duration |
|-------|-------------|----------|
| `redux-fundamentals` | Actions, reducers, store | 4-5 hours |
| `redux-state-management` | RTK, async, middleware | 4-5 hours |
| `context-api-patterns` | React Context patterns | 2-3 hours |
| `context-api-hooks` | Context with hooks | 2-3 hours |
| `zustand-minimalist` | Lightweight state | 2-3 hours |
| `zustand-lightweight-state` | Advanced Zustand | 2-3 hours |
| `state-patterns-architecture` | CQRS, Event Sourcing | 3-4 hours |
| `architectural-patterns` | Flux, MVC, Clean | 3-4 hours |

## Examples

```bash
# List all state management skills
/state-management

# Redux skills
/state-management redux-fundamentals
/state-management redux-state-management

# Context API
/state-management context-api-patterns

# Zustand
/state-management zustand-minimalist

# Architecture
/state-management state-patterns-architecture
```

## State Solution Comparison

| Library | Bundle Size | Use Case |
|---------|------------|----------|
| **Redux Toolkit** | 11KB | Complex global state |
| **Zustand** | 1.2KB | Simple-medium apps |
| **Context API** | 0KB | Prop drilling fix |
| **TanStack Query** | 13KB | Server state |

## Description

Learn to architect scalable applications with proper state management:

- **Redux** - Predictable state container
- **Context API** - React's built-in solution
- **Zustand** - Lightweight alternative
- **Patterns** - CQRS, Event Sourcing, Flux

## State Categories

| Type | Solution |
|------|----------|
| UI State | useState, Zustand |
| Server State | TanStack Query |
| Form State | React Hook Form |
| URL State | Router |

## Prerequisites

- Frameworks Agent (`/frameworks`)
- React or Vue experience
- JavaScript async patterns

## Next Steps

After mastering state management:
- `/testing` - Testing stores and state
- `/performance` - Optimizing re-renders
- `/advanced-topics` - Micro-frontend state sharing

---
**Command Version:** 2.0.0 | **Agent:** 04-state-management-agent
