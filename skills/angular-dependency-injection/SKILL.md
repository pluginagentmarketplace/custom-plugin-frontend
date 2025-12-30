---
name: angular-dependency-injection
description: Master Angular's dependency injection system, services, and RxJS patterns.
sasmp_version: "1.3.0"
bonded_agent: 03-frameworks-agent
bond_type: SECONDARY_BOND

# Production Configuration
validation:
  input_schema: true
  output_schema: true
  di_validation: true

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  level: INFO
  observability: true
  service_tracking: true
---

# Angular Dependency Injection & Services

> **Purpose:** Master enterprise Angular development with proper DI patterns.

## Input/Output Schema

```typescript
interface AngularDIInput {
  topic: 'service' | 'provider' | 'injector' | 'rxjs';
  scope: 'root' | 'module' | 'component';
  useCase?: string;
}

interface AngularDIOutput {
  serviceCode: string;
  providerConfig: string;
  usageExample: string;
  testExample: string;
}
```

## MANDATORY
- Dependency Injection basics
- Service creation with @Injectable()
- Providers and injectors
- Hierarchical injection
- providedIn: 'root' vs module
- Constructor injection

## OPTIONAL
- RxJS Observables with Angular
- HTTP Client with Observables
- Custom injection tokens
- Factory providers
- Value providers
- Multi providers

## ADVANCED
- Hierarchical injector tree
- Lazy-loaded module injectors
- Platform injector
- Resolution modifiers (@Optional, @Self, @SkipSelf)
- Forward references
- Abstract class tokens

## Error Handling

| Error | Root Cause | Solution |
|-------|------------|----------|
| `NullInjectorError` | Missing provider | Add to providers array |
| `Circular dependency` | A needs B needs A | Refactor or use forwardRef |
| `Multiple instances` | Wrong providedIn | Check module hierarchy |
| `Observable not completing` | Missing unsubscribe | Use takeUntil or async pipe |

## Test Template

```typescript
import { TestBed } from '@angular/core/testing';
import { UserService } from './user.service';
import { HttpClientTestingModule } from '@angular/common/http/testing';

describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService]
    });
    service = TestBed.inject(UserService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
```

## Best Practices
- Use providedIn: 'root' for singletons
- Prefer constructor injection
- Use interfaces with InjectionToken
- Unsubscribe from Observables
- Use async pipe when possible

## Resources
- [Angular DI Guide](https://angular.dev/guide/di)
- [RxJS Documentation](https://rxjs.dev/)

---
**Status:** Active | **Version:** 2.0.0
