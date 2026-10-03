# ADR-0004 - Separate Assets, Borrowables, And Consumables

Date: 2026-07-29

Status: Approved

## Context

The labs contain consumable stock, borrowable components/tools, and fixed assets.
These have different lifecycles and reporting needs.

## Decision

Separate:

- Consumables
- Borrowable items
- Assets

## Rationale

Filament and acrylic are quantity-managed stock. ESP32 boards and tools may be
borrowed and returned. Laser cutters, printers, laptops, UPS units, and cameras
are fixed assets with serial numbers, warranty, maintenance, and assigned labs.

## Alternatives Considered

- Store all items in one inventory table.
- Store machines separately but mix consumables and borrowables.

## Consequences

Benefits:

- Cleaner audits.
- Better maintenance tracking.
- Better borrowing rules.

Risks:

- Requires careful UI design so users do not feel the separation as complexity.

## Related Documents

- `../PROJECT_DECISIONS.md`
