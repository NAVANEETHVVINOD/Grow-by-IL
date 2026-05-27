# Grow~ Beta Test Notes (v0.9.0-beta)

Welcome to the Grow~ Beta Test! This guide outlines the key flows to test and how to report issues for tonight's beta build.

---

## 📲 How to Install
Install the provided `Grow-beta-v0.9.0.apk` file on your Android device (ensure "Install from Unknown Sources" is enabled in settings).

---

## 🧪 Key Flows to Test

Please systematically walk through the following features:

### 1. Authentication & Boot
- **Google Sign-In**: Attempt to sign in with your Google account.
- **Sign Out**: Log out via the Profile settings tab.
- **Re-Authentication**: Log back in and confirm it works.
- **Session Restoring**: Close the app completely (kill it from recents) and reopen it. Verify that you remain signed in and are routed directly to the Home screen without seeing the login screen.

### 2. Onboarding & Profile Setup (New Users)
- **First-Time Flow**: Walk through the step-by-step onboarding cards.
- **Draft Preservation**: Close the app in the middle of onboarding, reopen it, and confirm your draft progress is restored.
- **Field Validations**: Verify that invalid usernames or extremely short bios are properly flagged.
- **Avatar Upload**: Select and upload a profile picture.

### 3. Core Navigation & UI stability
- Switch between the primary tabs: **Home**, **Akathalam**, and **Profile**.
- Audit the UI for:
  - **No UI overflow errors** (yellow/black tape markers).
  - **No red error screens**.
  - **Smooth scrolling** without noticeable lag or dropped frame bursts.

### 4. Offline Synchronization (Stress Test)
- Turn **Airplane Mode ON** (disconnect from Wi-Fi and mobile data).
- Edit your profile details (e.g., bio, skills, or interests) and save the changes. Confirm the local cache updates instantly.
- **Force close the app** while offline.
- Reopen the app and confirm the edited data persists.
- Turn **Airplane Mode OFF** (reconnect to the internet).
- Verify that your updates are silently replayed and synchronized with the remote Supabase database.

### 5. Notifications
- Navigate to the notification center and verify that incoming updates load correctly.

---

## ⚠️ What to Report

If you run into any issues, please report them with details on:
- **Crashes**: Sudden app exits or freezes.
- **Lag**: Choppy transitions or stuttering animations.
- **UI Overflow**: Elements cut off, overlapping text, or layout warnings.
- **Broken Buttons**: Tap targets that do not respond.
- **Sync/Loading Issues**: Indefinite loaders or failure to sync changes offline.
