# Grow~ Trust Boundary: Camera And Device Sensor Use

Status: Draft (Pending Review)
Owner: Security Owner / Lead Architect
Version: 1.0
Last updated: 2026-09-01
Depends on: `docs/04_Security/security_policy.md`, `/SECURITY.md`
Referenced by: `docs/00_Project_Management/MASTER_INDEX.md`

> **Authoritative Version Pointer**: RLS, secrets, and storage-bucket policy
> remain owned by `docs/04_Security/security_policy.md` — this doc covers
> device-sensor trust boundary only, which that doc doesn't currently
> address.

## 1. Scope Of This Document

This exists specifically to answer: what does Grow do with a device camera
or microphone, and what's the trust boundary around that. Written because a
prior planning input for this repo assumed a "camera/audio trust boundary"
in the sense of an ML measurement pipeline (recording and analyzing camera/
audio data) — **that does not exist in Grow**. Confirmed by repository grep
(no matches for `camera` used beyond QR scanning, no audio capture code, no
model/inference code anywhere in `lib/`).

## 2. What Grow Actually Does With The Camera

- **QR scanning only**, for lab check-in/check-out and tool booking
  (`lib/features/lab/`). The camera feed is used live, on-device, purely to
  decode a QR code payload (a short string identifying a lab/tool/session).
- No camera frame, image, or video is uploaded, stored, or persisted by the
  app as part of this flow — the frame is decoded locally and discarded.
- No audio capture exists anywhere in the app.

## 3. Trust Boundary

- **Untrusted input**: the decoded QR string. It is treated as untrusted
  user input — validated and matched against known records server-side
  (Supabase) before any check-in/booking state changes, not trusted at face
  value from the client.
- **Trust boundary edge**: the camera plugin (device OS) hands raw frames to
  the Flutter QR-decode layer; nothing past the decode step (the frame
  itself) crosses into application state, network calls, or storage.
- **No secondary use**: camera permission is requested only for the
  check-in/booking screens that need it; it is not held or used for any
  other feature (e.g. no profile-photo-via-live-camera capture is implemented
  as of this writing — profile avatar upload, where it exists, is a file
  picker, see `docs/04_Security/security_policy.md` Section 3 for the
  storage-side controls on that upload).

## 4. Explicitly Not Applicable

The following, present in an unrelated project's doc template that this
file's structure was originally drafted against, do not apply to Grow and
are intentionally omitted rather than force-filled:

- Audio capture trust boundary — no audio capture exists.
- Biometric/measurement data handling — Grow does not measure or infer
  anything from camera input beyond decoding a QR payload.
- Model inference trust boundary — Grow has no on-device or server-side ML
  model.

## 5. Future Boundary Changes

Per `/SYSTEM_BOUNDARIES.md` "Future Boundary Changes": any feature that
would start using the camera for something beyond QR decode (e.g. document
scanning, photo capture inside a flow, live video) requires an approved
requirement, architecture decision, security review, and storage/cost
review before implementation — same gate as any other boundary change.
