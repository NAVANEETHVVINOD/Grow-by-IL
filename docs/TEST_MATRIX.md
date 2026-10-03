# Test Matrix

Status: Draft
Last updated: 2026-08-07

| Feature | Unit tests | Widget tests | Golden tests | Integration tests | Missing cases | Coverage estimate |
| --- | --- | --- | --- | --- | --- | --- |
| Authentication | Partial | Partial | No | Partial | Session refresh, passwordless recovery, role-based redirects | 60% |
| Profile onboarding | Partial | Partial | No | Partial | Offline resume, validation edge cases | 65% |
| Home dashboard | Partial | Partial | No | No | Empty states, error fallback, loading skeletons | 55% |
| Work requests | Partial | Partial | No | No | Multi-step validation, submission retry | 50% |
| Lab / booking flows | Partial | Partial | No | Partial | Double-booking and conflict handling | 55% |
| Notifications | Partial | Partial | No | No | Badge updates and deep-link flows | 45% |
| Shared RC5 widgets | Partial | Partial | No | No | Disabled states, long labels, dark/light variants | 60% |

## Recommended next tests
- Add widget tests for empty states, loading states, and error states
- Introduce integration tests for work-request creation and profile completion
- Add golden tests for shared RC5 cards, buttons, and chips
