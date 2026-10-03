# Grow Platform Product Backlog

Last updated: 2026-07-29

This backlog is architecture-level. It is not an implementation sprint board yet.

## Epic 1 - Identity And Access

### Feature: College Email Signup

- Story: Student signs up using an institution-approved email domain.
- Story: Admin manually approves exceptional accounts.
- Task: Define configurable allowed domain model.
- Task: Define alumni account state.

### Feature: Roles And Positions

- Story: User receives a base role and optional core team position.
- Story: Common dashboard shows additional widgets by role/position.
- Task: Define role hierarchy.
- Task: Define permission matrix.

## Epic 2 - Work Requests

### Feature: Work Request Submission

- Story: Student submits a Work Request with leader, members, reason, links, and notes.
- Story: Machine Head reviews and requests changes.
- Story: Student approves Machine Head edits before commitment.
- Task: Define Work Request lifecycle.
- Task: Define collaborator model.

### Feature: Manufacturing Tasks

- Story: Machine Head splits Work Request into tasks.
- Story: Task is assigned to machine/core member.
- Story: Task moves through queue and completion statuses.
- Task: Define task statuses.
- Task: Define queue behavior.

## Epic 3 - Payments And Quotations

### Feature: Quotation

- Story: Operation Head/Machine Head generates a quotation.
- Story: Student accepts quotation.
- Task: Define pricing template concepts.

### Feature: UPI Verification

- Story: Student submits transaction ID and optional screenshot.
- Story: Operation Head verifies payment.
- Task: Define payment status model.

## Epic 4 - Machines And Maintenance

- Story: Machine Head sees machine queue.
- Story: Runtime is recorded manually.
- Story: Maintenance history is recorded.
- Story: Machine status affects queue planning.

## Epic 5 - Inventory, Borrowing, And Assets

- Story: Operation Head imports inventory from Excel/CSV.
- Story: Operation Head maps columns before import.
- Story: Student borrows multiple items.
- Story: Overdue borrowing blocks future borrowing.
- Story: Assets track serial number, warranty, maintenance, and assigned lab.

## Epic 6 - Visitors

- Story: Logged-in user checks into lab with reason.
- Story: Visitor log stores time in/time out and purpose.
- Story: Operation Head exports visitor logs.

## Epic 7 - Events And Workshops

- Story: Events Head creates event/workshop.
- Story: Students register and attendance is recorded.
- Story: Certificate eligibility may be tracked per event.

## Epic 8 - Reports And Analytics

- Story: Operation Head exports weekly reports.
- Story: Admin views machine usage, revenue, inventory, visitors, and attendance.

## Epic 9 - Knowledge Base

- Story: Users search SOPs, machine manuals, safety notes, and FAQs.
- Status: Future-ready module, not MVP.

## Epic 10 - Administration And Audit

- Story: Super Admin configures master data.
- Story: Important actions create append-only audit records.
- Story: Admin reviews changes, payments, role assignments, and inventory activity.
