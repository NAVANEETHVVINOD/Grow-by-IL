# API Specification Planning

Status: Draft
Last updated: 2026-08-07

## 1. Work Requests

### POST /work_requests
Request
- title: string
- description: string
- category: string
- priority: string
- requested_by_org: string?
- items: array

Response
- id
- status
- created_at

Errors
- 400 invalid payload
- 401 unauthorized
- 403 forbidden

Permissions
- Members can create their own requests
- Admins can review all requests

RLS
- Insert allowed only for authenticated users with organization scope

Repository interface
- createWorkRequest(input)

### GET /work_requests
Response
- list of work requests scoped to current user or admin visibility

### PATCH /work_requests/{id}
Response
- updated work request

### DELETE /work_requests/{id}
Response
- 204 no content

## 2. Inventory

### POST /inventory
Request
- name
- category
- quantity
- location

Response
- created inventory item

## 3. Machine Queue

### POST /machine_queue
Request
- machine_id
- user_id
- notes

Response
- queue entry object

## 4. Notifications

### GET /notifications
Response
- list of notification items with unread counts

## 5. Repository Pattern

```text
interface ApiRepository<TInput, TEntity> {
  Future<List<TEntity>> list();
  Future<TEntity> create(TInput input);
  Future<TEntity> getById(String id);
  Future<TEntity> update(String id, TInput input);
  Future<void> delete(String id);
}
```
