# Borrowing ERD Planning

Status: Draft
Last updated: 2026-08-07

## 1. Entities

### borrowing_requests
- id (uuid, pk)
- requester_id (uuid, fk -> users.id)
- item_id (uuid, fk -> inventory_items.id)
- requested_from
- start_at
- end_at
- status
- reason
- created_at

### borrowing_approvals
- id (uuid, pk)
- borrowing_request_id (uuid, fk -> borrowing_requests.id)
- approved_by (uuid, fk -> users.id)
- decision
- note
- created_at

## 2. Relationships

- users 1:N borrowing_requests
- inventory_items 1:N borrowing_requests
- borrowing_requests 1:N borrowing_approvals

## 3. Suggested Indexes

- idx_borrowing_requests_status_dates
- idx_borrowing_requests_requester_id

## 4. RLS Planning

- Requesters can view and update their own requests
- Approvers can manage requests for their assigned domain
- Admins can review across the platform

## 5. Repository Interface

```text
interface BorrowingRepository {
  Future<List<BorrowingRequest>> listForUser(String userId);
  Future<BorrowingRequest> create(CreateBorrowingRequestInput input);
  Future<BorrowingRequest> approve(String id, ApprovalInput input);
}
```
