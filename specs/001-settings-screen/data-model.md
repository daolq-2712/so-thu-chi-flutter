# Data Model: Settings Screen

**Feature**: Settings Screen  
**Date**: 2025-12-23  
**Purpose**: Define entities, relationships, and state for Settings feature

---

## Overview

Settings Screen is a **navigation-only** feature with **no domain entities** and **no data persistence**. The screen displays static UI elements (tiles) that trigger navigation actions.

---

## Entities

**None**. Settings Screen does not create, read, update, or delete any domain entities. It is a pure presentation layer feature.

---

## State Management

### Presentation State

**Type**: Stateless (no Cubit/BLoC)

**Rationale**: 
- No local state to manage (no form inputs, no async operations)
- Navigation is handled by go_router (external to widget)
- Localization is reactive (rebuilds on locale change via MaterialApp)
- Per Constitution 1.2 (KISS): simplest solution is best

### State Diagram

```
┌──────────────┐
│ SettingsPage │  (StatelessWidget)
└──────────────┘
       │
       ├─> User taps "Ngôn ngữ" → go_router navigates to /settings/language
       │
       └─> User taps "Quản lý thể loại" → go_router navigates to /settings/categories
```

**Note**: No state transitions. Each tap triggers a navigation action (fire-and-forget).

---

## Validation Rules

**None**. Settings Screen has no user input fields, therefore no validation is required.

---

## Dependencies

### From Other Features

Settings Screen depends on:
1. **go_router** (core/router): Routes `/settings/language` and `/settings/categories` must exist
2. **AppLocalizations** (core/l10n): ARB keys `settings_language` and `settings_categories` must be defined

### Consumed By Other Features

None. Settings Screen is a leaf node in the feature graph (it navigates to other screens but is not consumed by them).

---

## Data Flow

```
User Action (Tap)
       ↓
SettingsTile.onTap()
       ↓
context.go('/settings/[route]')  ← go_router handles navigation
       ↓
New Page renders (LanguagePage or ManageCategoriesPage)
```

**Key Points**:
- No data mutations
- No asynchronous operations
- No repository calls
- Pure navigation logic

---

## Contracts

### Public API (Presentation Layer)

#### SettingsPage Widget

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context);
}
```

**Purpose**: Root widget for Settings screen  
**Responsibilities**: 
- Render Scaffold with title
- Display 2 SettingsTile widgets (Language, Manage Categories)
- Localize all text via AppLocalizations

---

#### SettingsTile Widget

```dart
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;      // Localized label text
  final IconData icon;     // Leading icon
  final String route;      // Destination route (e.g., '/settings/language')

  @override
  Widget build(BuildContext context);
}
```

**Purpose**: Reusable navigation tile component  
**Responsibilities**: 
- Render ListTile with icon, label, and trailing arrow
- Navigate to `route` on tap
- Ensure ≥48x48 dp touch target (via ListTile default)

---

### Localization Contract (ARB Keys)

**File**: `lib/core/l10n/app_en.arb`

```json
{
  "settings_language": "Language",
  "settings_categories": "Manage Categories"
}
```

**File**: `lib/core/l10n/app_vi.arb`

```json
{
  "settings_language": "Ngôn ngữ",
  "settings_categories": "Quản lý thể loại"
}
```

**Contract**: These keys must exist in both ARB files. Any missing key will cause runtime error when accessing `AppLocalizations.of(context)!.<key>`.

---

### Navigation Contract (go_router Routes)

**File**: `lib/core/router/app_router.dart`

Required routes:
- `/settings` → SettingsPage
- `/settings/language` → LanguagePage (implemented in separate feature)
- `/settings/categories` → ManageCategoriesPage (implemented in separate feature)

**Contract**: SettingsPage assumes these routes exist. If a route is missing, `context.go()` will navigate to error/fallback route.

---

## Testing Strategy

### Widget Tests

**File**: `test/features/settings/presentation/pages/settings_page_test.dart`

**Test Cases** (per Acceptance Scenarios in spec.md):

1. **Navigation to Language**
   - Tap "Ngôn ngữ" tile → verify navigation to `/settings/language`
   - Verify LanguagePage renders after navigation

2. **Navigation to Manage Categories**
   - Tap "Quản lý thể loại" tile → verify navigation to `/settings/categories`
   - Verify ManageCategoriesPage renders after navigation

3. **Localization**
   - Render with locale=EN → verify text "Language" and "Manage Categories"
   - Render with locale=VI → verify text "Ngôn ngữ" and "Quản lý thể loại"

4. **Accessibility**
   - Verify each tile has height ≥48 dp (using `tester.getSize()`)
   - Verify tiles have semantic labels for screen readers

5. **Edge Case**
   - Rapid tap on same tile → verify no crash (navigation may execute multiple times)

---

## Summary

- **Entities**: None
- **State Management**: Stateless (no Cubit/BLoC)
- **Validation**: None
- **Data Flow**: User tap → go_router navigation → new page
- **Public API**: SettingsPage + SettingsTile widgets
- **Contracts**: ARB keys + go_router routes
- **Testing**: Widget tests for navigation + localization + accessibility
