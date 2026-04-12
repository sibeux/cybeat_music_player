# Error Report: CYBEAT-ERR-001

## Problem Description

**ID:** `CYBEAT-ERR-001`  
**Error:** `setState() or markNeedsBuild() called during build`  
**Location:** `lib/features/splash_page/controllers/splash_controller.dart`

### Symptom

The application crashes during the splash screen or displays a red error screen. This happens because the `SplashController` attempts to navigate or update an observable state (`isLoading`) while Flutter is still building the initial widget tree (specifically inside the `onInit` lifecycle).

---

## Root Cause

In Flutter, you cannot trigger actions that modify the state or change the route during the `build` phase or synchronously within lifecycle methods like `onInit` if they execute immediately. Since `checkAuthentication` was called in `onInit`, if the logic finished fast enough (e.g., user already authenticated), `Get.offAndToNamed` was called before the frame was ready.

---

## Solution

Wrap the navigation and state update logic inside a `Future.microtask()`. This ensures the code is executed in the next cycle of the event loop, safely after the current build frame has finished.

### Code Fix

```dart
    } finally {
      // FIX [CYBEAT-ERR-001]: Wrap in microtask to avoid "setState() called during build"
      Future.microtask(() {
        Get.offAndToNamed('/home', id: 1);
        Get.delete<SplashController>();
        isLoading.value = false;
      });
    }
```

---

## Prevention

- Always use `Future.microtask` or `WidgetsBinding.instance.addPostFrameCallback` when navigating or updating state immediately upon controller initialization or during `initState`.
- Avoid synchronous heavy logic in `onInit` that triggers side effects affecting the UI layout.
