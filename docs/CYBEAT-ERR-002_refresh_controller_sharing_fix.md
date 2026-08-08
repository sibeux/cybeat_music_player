# Error Report: CYBEAT-ERR-002

## Problem Description

**ID:** `CYBEAT-ERR-002`  
**Error:** `Don't use one refreshController to multiple SmartRefresher`  
**Location:** Multiple (Home, Album Search)

### Symptom

Unexpected behavior in scrolling, refreshing, or loading more. In some cases, the app may crash or fail to complete the refresh/load animation because the `RefreshController` is attached to multiple `SmartRefresher` widgets simultaneously or reused improperly across screen transitions.

---

## Root Cause

The `RefreshController` from the `pull_to_refresh` package is designed to have a 1-to-1 mapping with a `SmartRefresher`.
Storing it inside a `GetxController` (which is often long-lived or shared) causes issues when:

1. Navigating between screens that share the same controller.
2. Using nested navigators where old screens are kept in memory.
3. Re-instantiating a screen while the previous one hasn't fully disposed.

---

## Solution

Move the `RefreshController` instance into the `State` of the `StatefulWidget` (the View) instead of the `GetxController`. Keep the business logic in the `GetxController` but pass the local `RefreshController` as an argument to the refresh/load methods.

### Implementation Pattern

1. **In the Controller:**

```dart
void onRefresh(RefreshController controller) async {
  // logic...
  controller.refreshCompleted();
}
```

1. **In the Screen (View):**

```dart
class _MyScreenState extends State<MyScreen> {
  final _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => controller.onRefresh(_refreshController),
      child: ...
    );
  }
}
```

---

## Prevention

- Never share a `RefreshController` instance across different widgets or screens.
- Always dispose of `RefreshController` in the `State.dispose` method.
- Use named routes (`Get.toNamed`) to ensure GetX handles controller lifecycles correctly.
