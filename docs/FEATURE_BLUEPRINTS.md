# Feature Blueprints for Future Modules

Status: Draft
Last updated: 2026-08-07

## 1. Manufacturing
### Purpose
Support internal fabrication and manufacturing workflows with structured requests and approvals.
### User stories
- Submit manufacturing requests
- Track progress and status
- Review capacity and dependencies
### Models
- manufacturing_requests
- manufacturing_steps
- manufacturing_assignments
### Providers
- manufacturingRequestProvider
- manufacturingQueueProvider
### Services
- manufacturingService
### Routes
- /manufacturing
- /manufacturing/{id}
### Widgets
- ManufacturingCard, ManufacturingTimeline, ManufacturingSummary
### Permissions
- members, operators, admins
### Database
- request and assignment tables with audit columns
### RLS
- request owners see their own records; admins manage all
### API
- CRUD endpoints and status transitions
### Future integrations
- machine sensing, parts inventory, cost tracking

## 2. Inventory
### Purpose
Track shared tools, parts, and materials with reservation support.
### User stories
- View catalog and availability
- Reserve or borrow items
- Record movement history
### Models
- inventory_items, inventory_movements, inventory_reservations
### Providers
- inventoryProvider
- inventoryReservationProvider
### Services
- inventoryService
### Routes
- /inventory
- /inventory/{id}
### Widgets
- InventoryCard, InventoryStatusBadge, ReservationSheet
### Permissions
- members, admins
### Database
- inventory tables and audit trail
### RLS
- read access for members; update access for admins/operators
### API
- list, create, update, reserve
### Future integrations
- QR-based stock check, procurement workflows

## 3. Borrowing
### Purpose
Coordinate the borrowing lifecycle for equipment and consumables.
### User stories
- Request a borrow window
- Approve or reject requests
- Track current borrow state
### Models
- borrowing_requests, borrowing_approvals
### Providers
- borrowingProvider
### Services
- borrowingService
### Routes
- /borrowing
- /borrowing/{id}
### Widgets
- BorrowingRequestCard, ApprovalPanel
### Permissions
- requesters, approvers, admins
### Database
- request and approval tables
### RLS
- requesters see own requests; approvers see domain-scoped requests
### API
- create, approve, list
### Future integrations
- reminder notifications, overdue penalties

## 4. Payments
### Purpose
Support simple payment workflows for memberships, events, or equipment use.
### User stories
- Create payment intent
- Track payment status
- Reconcile settlement data
### Models
- payments, payment_events
### Providers
- paymentsProvider
### Services
- paymentService
### Routes
- /payments
- /payments/{id}
### Widgets
- PaymentCard, PaymentStatusChip
### Permissions
- users, finance admins
### Database
- payment and event tables
### RLS
- users access own payments; finance admins access broader records
### API
- create, status update, list
### Future integrations
- Stripe or local gateway integration

## 5. Machine Queue
### Purpose
Manage waitlists and active usage for shared machines.
### User stories
- Join a queue
- Advance or clear queue state
- See current machine status
### Models
- machine_queue_entries, machine_queue_events
### Providers
- machineQueueProvider
### Services
- machineQueueService
### Routes
- /machine-queue
### Widgets
- QueueEntryCard, QueueStatusBadge
### Permissions
- members, operators, admins
### Database
- queue tables and event logging
### RLS
- users manage own queue entries; operators/admins manage shared state
### API
- enqueue, advance, list active
### Future integrations
- real-time machine availability and notifications

## 6. Visitors
### Purpose
Support visitor check-in, guest management, and event access.
### User stories
- Register visitor arrival
- Track check-in history
- Link visitors to events or lab sessions
### Models
- visitors, visitor_checkins, visitor_badges
### Providers
- visitorsProvider
### Services
- visitorService
### Routes
- /visitors
### Widgets
- VisitorCard, CheckInPanel
### Permissions
- front desk, admins
### Database
- visitor and check-in tables
### RLS
- restricted to operational roles
### API
- check-in, list, export
### Future integrations
- QR badge scanning and visitor analytics
