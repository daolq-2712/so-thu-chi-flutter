# Navigation Contract: Settings Screen

**Feature**: Settings Screen  
**Date**: 2025-12-23  
**Type**: Navigation Routes & Parameters

---

## Overview

Settings Screen navigation contract defines the routes consumed and exposed by this feature. This feature is a **consumer-only** (it navigates TO other screens but is not navigated FROM within its own scope).

---

## Consumed Routes

Routes that SettingsPage navigates to (must be provided by go_router configuration):

### 1. Language Settings

**Route**: `/settings/language`  
**Method**: `context.go('/settings/language')`  
**Trigger**: User taps "Ngôn ngữ" tile  
**Parameters**: None  
**Returns**: Navigation (no return value)  
**Owner**: Language feature (separate spec)

---

### 2. Manage Categories

**Route**: `/settings/categories`  
**Method**: `context.go('/settings/categories')`  
**Trigger**: User taps "Quản lý thể loại" tile  
**Parameters**: None  
**Returns**: Navigation (no return value)  
**Owner**: Manage Categories feature (separate spec)

---

## Exposed Routes

Routes that external features can use to navigate TO SettingsPage:

### 1. Settings Screen

**Route**: `/settings`  
**Method**: `context.go('/settings')`  
**Widget**: `SettingsPage`  
**Parameters**: None  
**Trigger**: Typically from bottom navigation bar "Settings" tab  

---

## Route Configuration Example

**File**: `lib/core/router/app_router.dart`

```dart
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // ... other routes
    
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => const LanguagePage(),
    ),
    
    GoRoute(
      path: '/settings/categories',
      builder: (context, state) => const ManageCategoriesPage(),
    ),
  ],
);
```

---

## Error Handling

### Missing Route Scenario

**Problem**: User taps tile but destination route (`/settings/language` or `/settings/categories`) is not registered in go_router.

**Behavior**: go_router will navigate to error route or fallback route (defined in `GoRouter.errorBuilder`).

**Mitigation**: Integration tests must verify all consumed routes exist before release.

---

## Testing Contract

### Widget Test Verification

```dart
testWidgets('SettingsPage navigates to /settings/language on Language tap', (tester) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/settings/language', builder: (_, __) => const LanguagePage()),
    ],
    initialLocation: '/settings',
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );

  // Act: Tap Language tile
  await tester.tap(find.text('Language'));
  await tester.pumpAndSettle();

  // Assert: Verify navigation
  expect(find.byType(LanguagePage), findsOneWidget);
  expect(router.routerDelegate.currentConfiguration.uri.path, '/settings/language');
});
```

---

## Dependencies

- **go_router package** (^13.0.0 or compatible)
- **Parent router configuration** (app_router.dart) must register all routes listed above

---

## Backward Compatibility

N/A (first version of Settings screen)

---

## Future Considerations (Out of Scope for MVP)

- Deep linking support (e.g., `myapp://settings/language`)
- Route parameters for sub-settings (e.g., `/settings/language?highlight=selected`)
- Named routes with constants (e.g., `AppRoutes.settingsLanguage`)
