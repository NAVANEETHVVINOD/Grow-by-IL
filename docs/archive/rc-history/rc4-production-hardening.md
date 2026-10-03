# Grow~ RC4 Production Hardening Audit

This document records the technical implementation, security enhancements, and reliability hardening of the **RC4 production-ready candidate** for the Grow~ platform.

---

## 1. Reliability & Observability Hardening

### 1.1 Firebase Crashlytics Integration
We integrated `firebase_crashlytics` to capture and report all runtime exceptions automatically in production builds:
* **Global Flutter Handlers**: Configured `FlutterError.onError` inside `lib/main.dart` to intercept and report UI/framework-level exceptions.
* **Platform/Async Handlers**: Configured `PlatformDispatcher.instance.onError` to capture asynchronous background tasks, stream leaks, or database connection failures.
* **User Context Binding**: Automatically logs non-fatal warnings and tags crash reports with anonymized user context when sessions initialize.

### 1.2 Centralized Network Timeout Wrapper
To prevent hanging operations on poor WiFi/cellular connections, we implemented a timeout utility:
* **Timeout Provider**: Added `lib/core/utils/query_helper.dart` providing a `withTimeout()` extension on `Future`.
* **Standardized Boundary**: Sets a strict 10-second request limit. If exceeded, throws a descriptive `TimeoutException`.
* **Repository Application**: Wrapped all high-traffic network requests in `AuthRepository`, `LabRepository`, `ToolRepository`, `ProjectRepository`, and `NotificationRepository`.

---

## 2. Route Gating & UX Hardening

### 2.1 Role-Aware Dynamic Route Protection
We hardened route security in the presentation layer:
* **Router Provider**: Refactored the global router configuration in `lib/core/router/app_router.dart` into a Riverpod `routerProvider` that dynamically reacts to user auth state and profile information.
* **Defense-in-Depth Admin Guard**: Gated direct deep-link entry to `/admin`. If a user attempts to navigate to `/admin` without possessing the `lab_admin` or `super_admin` role, the router redirects them to a dedicated `/unauthorized` view.
* **Unauthorized Screen UI**: Created `lib/features/auth/presentation/screens/unauthorized_screen.dart` with a premium Neo-brutalist theme layout warning of unauthorized access and providing a quick navigation button back home.

### 2.2 Global Tactile Error UI Standardization
* **Standard Neo Error Widget**: Implemented `lib/shared/widgets/neo_error_widget.dart` featuring a premium tactile error card, custom failure messages, and optional retry triggers.
* **Application**: Applied this widget to replace blank or infinite-shimmer states during query failures on `HomeScreen`, `ToolsScreen`, `ProjectListScreen`, and `LabScreen`.

---

## 3. Production CI/CD Build Pipeline Alignment

### 3.1 Google Services Gradle Integration Fix
* **Issue**: The Android Gradle release compile failed on GitHub Actions because the Google Services plugin requires `google-services.json` at build time. The previous dummy file creation used a multiline `echo` redirection which can fail or produce empty files in standard CI environments.
* **Resolution**: Replaced the multiline shell `echo` in `.github/workflows/ci.yml` with a standard Bash heredoc (`cat << 'EOF'`). Added a verification step (`ls -la android/app/google-services.json`) to confirm the file exists and has non-zero size before compiling the APK.

---

## 4. Verification & Testing Matrix

* **Static Analysis**: Verified using `flutter analyze` yielding **0 issues**.
* **Flow Test Coverage**: Added 6 mock-based integration flow tests (using Mocktail) in `test/auth_flow_test.dart` and `test/booking_flow_test.dart` covering sign-in, sign-up, slot-overlap booking failures, and successful booking state changes.
* **Test Suite Status**: Total test count is **57/57 tests passing**.
* **Local Release Compile**: Successfully generated release APK via `flutter build apk --release` locally.
