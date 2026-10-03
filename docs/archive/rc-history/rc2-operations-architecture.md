# Grow~ RC2 Operations Architecture

This document defines the operational governance, security model, and administrative infrastructure for the Grow~ platform.

## 1. System Governance Model
The platform transitions from an open MVP to a **Managed Innovation Lab Ecosystem**. 

- **Authority Source**: `public.users.role` (PostgreSQL column).
- **Enforcement Level**: Database-level Row Level Security (RLS) + Frontend Route Guarding.
- **Data Integrity**: Audit logging for all non-student state changes.

---

## 2. Final Role Definitions

| Role | Label | Purpose |
| :--- | :--- | :--- |
| **student** | User | Default access. Consume lab resources, participate in projects/events. |
| **mentor** | Advisor | Guidance and review. View private project metrics and team progress. |
| **event_manager** | Staff | Logistics. Manage the lifecycle of lab events and RSVPs. |
| **lab_admin** | Manager | Resource Ops. Manage tools, inventory stock, and lab session safety. |
| **super_admin** | Governor | Full Control. User role management, global overrides, and system config. |

---

## 3. Permission Matrix

| Resource | Student | Mentor | Event Mgr | Lab Admin | Super Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Tools** | Read | Read | Read | **CRUD** | **CRUD** |
| **Events** | RSVP | Read | **CRUD** | Read | **CRUD** |
| **Projects** | **CRUD (Own)** | Review | Read | Read | **CRUD** |
| **Inventory** | Read | Read | Read | **CRUD** | **CRUD** |
| **Lab Sessions** | Check-in | Read | Read | **Manage** | **CRUD** |
| **User Roles** | None | None | None | None | **Manage** |

---

## 4. Row Level Security (RLS) Design

### Security Helper Function
To maintain performance and prevent JWT bloat, we use a cached SQL helper:
```sql
CREATE OR REPLACE FUNCTION auth.get_user_role() 
RETURNS TEXT AS $$
  -- Checks public.users for the role of the current authenticated user
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```

### Policy Patterns
- **Resource Management**: `USING (auth.get_user_role() IN ('lab_admin', 'super_admin'))`
- **Ownership**: `USING (auth.uid() = owner_id OR auth.get_user_role() = 'super_admin')`

---

## 5. Administrative Dashboard Structure

The Admin Dashboard is a unified mobile interface located at `/admin`.

### A. Dashboard Overview
- **Active Traffic**: Number of students currently checked into the lab.
- **Alerts**: Low inventory warnings, flagged projects, pending tool reports.

### B. Inventory & Resources (`lab_admin`)
- **Tool Status**: Toggle tool availability (Available / Maintenance / Inactive).
- **Consumables**: Track PLA, Resin, Acrylic sheet levels. Manual stock adjustments.

### C. Event Hub (`event_manager`)
- **Event Lifecycle**: Create new workshops, edit details, or cancel events.
- **Attendance**: View attendee lists and manage waitlists.

### D. Governance (`super_admin`)
- **User Directory**: Search by Roll Number or Name.
- **Role Manager**: Promote/Demote users (e.g., Student -> Lab Admin).
- **Moderation**: Archive projects or suspend users.

---

## 6. Audit & Moderation

### Audit Logging
A dedicated `audit_logs` table records the following actions:
- User role promotions/demotions.
- Manual inventory subtractions (theft/loss tracking).
- Deletion of tools or events.
- Forceful termination of active lab sessions.

### Moderation Flow
1. **Report**: User reports a broken tool or offensive project.
2. **Review**: `lab_admin` (tools) or `super_admin` (projects) receives notification.
3. **Action**: Resource is set to `status = 'suspended'` or `hidden = true`.
4. **Logging**: Action and reason are persisted in `audit_logs`.

---

## 7. Database Requirements (RC2)

### New Tables
- `audit_logs`: (id, actor_id, action, target, metadata, created_at)
- `inventory_transactions`: (id, item_id, change_amount, reason, created_by)

### Schema Extensions
- `users`: Add `role` (enum/text), `is_active` (bool), `last_seen_at` (timestamp).
- `tools`: Add `status_notes` (text) for maintenance logs.

---

## 8. Implementation Strategy
Implementation follows a **"Core First, UI Last"** approach:
1. **DB Hardening**: Deploy RLS and Audit triggers.
2. **Role Provider**: Update Flutter `UserModel` and auth synchronization.
3. **Route Guards**: Secure `/admin` routes using GoRouter.
4. **Module Delivery**: Deliver Inventory, then Events, then User Management.

---
*This document defines the Production Baseline for Grow~ RC2. Approved and Frozen for Implementation.*
