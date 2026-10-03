# Work Request ERD Planning

Status: Draft
Last updated: 2026-08-07

## 1. Entities

### work_requests
- id (uuid, pk)
- created_by (uuid, fk -> users.id)
- title
- description
- category
- priority
- status
- due_at
- requested_by_org
- metadata
- created_at
- updated_at
- deleted_at

### work_request_items
- id (uuid, pk)
- work_request_id (uuid, fk -> work_requests.id)
- item_type
- quantity
- notes
- estimated_cost

### work_request_comments
- id (uuid, pk)
- work_request_id (uuid, fk -> work_requests.id)
- user_id (uuid, fk -> users.id)
- body
- created_at

### work_request_assignments
- id (uuid, pk)
- work_request_id (uuid, fk -> work_requests.id)
- assigned_to (uuid, fk -> users.id)
- role
- assigned_at
- status

## 2. Relationships

- users 1:N work_requests
- work_requests 1:N work_request_items
- work_requests 1:N work_request_comments
- work_requests 1:N work_request_assignments

## 3. Suggested Indexes

- idx_work_requests_status_priority
- idx_work_requests_created_by
- idx_work_request_items_work_request_id
- idx_work_request_comments_work_request_id

## 4. RLS Planning

- Users can create and view their own work requests
- Assigned users can view and update assigned requests
- Admin roles can manage all requests
- Soft delete via deleted_at is preferred

## 5. Repository Interface

```text
interface WorkRequestRepository {
  Future<List<WorkRequest>> list({filters});
  Future<WorkRequest> create(CreateWorkRequestInput input);
  Future<WorkRequest> getById(String id);
  Future<WorkRequest> update(String id, UpdateWorkRequestInput input);
  Future<void> delete(String id);
}
```
