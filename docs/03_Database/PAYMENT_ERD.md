# Payment ERD Planning

Status: Draft
Last updated: 2026-08-07

## 1. Entities

### payments
- id (uuid, pk)
- payer_id (uuid, fk -> users.id)
- payee_id (uuid, fk -> users.id)
- amount_cents
- currency
- status
- provider_reference
- description
- created_at
- settled_at

### payment_events
- id (uuid, pk)
- payment_id (uuid, fk -> payments.id)
- event_type
- payload
- created_at

## 2. Relationships

- users 1:N payments as payer
- users 1:N payments as payee
- payments 1:N payment_events

## 3. Suggested Indexes

- idx_payments_status_created_at
- idx_payments_payer_id
- idx_payment_events_payment_id

## 4. RLS Planning

- Users can view their own payment records
- Finance admins can access settlement and reconciliation records
- Sensitive payment data should be limited and audited

## 5. Repository Interface

```text
interface PaymentRepository {
  Future<List<Payment>> listForUser(String userId);
  Future<Payment> create(CreatePaymentInput input);
  Future<Payment> updateStatus(String id, PaymentStatus status);
}
```
