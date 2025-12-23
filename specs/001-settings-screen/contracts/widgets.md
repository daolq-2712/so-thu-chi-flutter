# Widget Contract: Settings Screen Components

**Feature**: Settings Screen  
**Date**: 2025-12-23  
**Type**: Flutter Widget APIs

---

## Overview

Settings Screen consists of 2 public widgets with clearly defined interfaces. This contract ensures consistency and testability.

---

## 1. SettingsPage Widget

### Public API

```dart
class SettingsPage extends StatelessWidget {
  /// Creates the Settings screen with navigation tiles.
  ///
  /// This is a stateless widget that displays exactly 2 navigation options:
  /// - Language (navigates to /settings/language)
  /// - Manage Categories (navigates to /settings/categories)
  ///
  /// All text is localized via AppLocalizations.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context);
}
```

### Responsibilities

- Render `Scaffold` with AppBar (title from localization)
- Display 2 `SettingsTile` widgets in a scrollable list
- Provide localized labels via `AppLocalizations.of(context)`

### Dependencies

- `package:go_router` (for navigation context)
- `package:flutter_gen/gen_l10n/app_localizations.dart` (for localization)
- `SettingsTile` widget (internal component)

### Usage Example

```dart
// In go_router configuration
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsPage(),
)

// In bottom navigation
BottomNavigationBarItem(
  icon: Icon(Icons.settings),
  label: 'Settings',
  // Tapping navigates to /settings which renders SettingsPage
)
```

### Widget Tree Structure

```
SettingsPage (StatelessWidget)
└── Scaffold
    ├── AppBar
    │   └── Text (localized title)
    └── ListView
        ├── SettingsTile (Language)
        └── SettingsTile (Manage Categories)
```

---

## 2. SettingsTile Widget

### Public API

```dart
class SettingsTile extends StatelessWidget {
  /// Creates a navigation tile for Settings screen.
  ///
  /// The tile displays an icon, label, and trailing arrow.
  /// Tapping the tile navigates to [route] using go_router.
  ///
  /// The tile meets accessibility requirements (≥48x48 dp touch target)
  /// by using Material ListTile component.
  ///
  /// Example:
  /// ```dart
  /// SettingsTile(
  ///   label: 'Language',
  ///   icon: Icons.language,
  ///   route: '/settings/language',
  /// )
  /// ```
  const SettingsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.route,
  });

  /// The localized label text displayed on the tile.
  final String label;

  /// The leading icon displayed on the tile.
  final IconData icon;

  /// The destination route to navigate to when tapped.
  /// Must be a valid route registered in go_router.
  final String route;

  @override
  Widget build(BuildContext context);
}
```

### Responsibilities

- Render Material `ListTile` with icon, label, and trailing arrow
- Navigate to `route` on tap (using `context.go(route)`)
- Ensure touch target meets accessibility guidelines (≥48x48 dp)

### Dependencies

- `package:go_router` (for `context.go()`)
- `package:flutter/material.dart` (for ListTile)

### Usage Example

```dart
SettingsTile(
  label: AppLocalizations.of(context)!.settings_language,
  icon: Icons.language,
  route: '/settings/language',
)
```

### Implementation Constraints

- **MUST** use `ListTile` or equivalent Material widget (guarantees 48x48 dp)
- **MUST** call `context.go(route)` on tap (not `Navigator.push`)
- **SHOULD** include `trailing: Icon(Icons.chevron_right)` for visual affordance

### Widget Tree Structure

```
SettingsTile (StatelessWidget)
└── ListTile (Material component, ≥48x48 dp)
    ├── leading: Icon (provided via constructor)
    ├── title: Text (label from constructor)
    ├── trailing: Icon (chevron_right arrow)
    └── onTap: () => context.go(route)
```

---

## Testing Contracts

### SettingsPage Tests

**File**: `test/features/settings/presentation/pages/settings_page_test.dart`

```dart
group('SettingsPage', () {
  testWidgets('renders exactly 2 SettingsTile widgets', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const SettingsPage()));
    expect(find.byType(SettingsTile), findsNWidgets(2));
  });

  testWidgets('displays localized labels in EN', (tester) async {
    await tester.pumpWidget(makeTestableWidget(
      const SettingsPage(),
      locale: const Locale('en'),
    ));
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Manage Categories'), findsOneWidget);
  });

  testWidgets('displays localized labels in VI', (tester) async {
    await tester.pumpWidget(makeTestableWidget(
      const SettingsPage(),
      locale: const Locale('vi'),
    ));
    expect(find.text('Ngôn ngữ'), findsOneWidget);
    expect(find.text('Quản lý thể loại'), findsOneWidget);
  });
});
```

---

### SettingsTile Tests

**File**: `test/features/settings/presentation/widgets/settings_tile_test.dart`

```dart
group('SettingsTile', () {
  testWidgets('renders label and icon', (tester) async {
    await tester.pumpWidget(makeTestableWidget(
      SettingsTile(
        label: 'Test Label',
        icon: Icons.settings,
        route: '/test',
      ),
    ));
    expect(find.text('Test Label'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('has minimum touch target of 48x48 dp', (tester) async {
    await tester.pumpWidget(makeTestableWidget(
      SettingsTile(
        label: 'Test',
        icon: Icons.settings,
        route: '/test',
      ),
    ));
    final size = tester.getSize(find.byType(ListTile));
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('navigates to route on tap', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Placeholder()),
        GoRoute(path: '/test', builder: (_, __) => const Text('Test Page')),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => SettingsTile(
        label: 'Test',
        icon: Icons.settings,
        route: '/test',
      ),
    ));

    await tester.tap(find.byType(SettingsTile));
    await tester.pumpAndSettle();

    expect(find.text('Test Page'), findsOneWidget);
  });
});
```

---

## Acceptance Criteria Mapping

| Requirement | Widget | Verification |
|-------------|--------|--------------|
| FR-SET-001 | SettingsPage | Widget test: `find.byType(SettingsTile)` finds exactly 2 |
| FR-SET-002 | SettingsPage | Widget test: First tile label is `settings_language` |
| FR-SET-003 | SettingsPage | Widget test: Second tile label is `settings_categories` |
| FR-SET-004 | SettingsTile | Widget test: Tap language tile → navigation to `/settings/language` |
| FR-SET-005 | SettingsTile | Widget test: Tap categories tile → navigation to `/settings/categories` |
| FR-SET-006 | SettingsPage + SettingsTile | Widget test: No `find.text('Language')` hardcoded, only `l10n.settings_language` |
| FR-SET-007 | SettingsTile | Widget test: `tester.getSize(ListTile).height ≥ 48.0` |

---

## Dependencies

### Runtime Dependencies

- `flutter/material.dart` (Scaffold, ListTile, Icons)
- `go_router` (context.go for navigation)
- `flutter_gen/gen_l10n/app_localizations.dart` (localized strings)

### Test Dependencies

- `flutter_test` (WidgetTester, expect, findsOneWidget)
- `go_router` (for test router setup)

---

## Implementation Checklist

- [ ] Create `lib/features/settings/presentation/pages/settings_page.dart`
- [ ] Create `lib/features/settings/presentation/widgets/settings_tile.dart`
- [ ] Ensure ARB keys exist: `settings_language`, `settings_categories`
- [ ] Register route `/settings` in `app_router.dart`
- [ ] Write widget tests per contract above
- [ ] Verify accessibility: `flutter analyze` passes, touch targets ≥48 dp

---

## Future Enhancements (Out of Scope for MVP)

- Customizable tile height/padding
- Support for subtitle text on tiles
- Badge/notification indicator on tiles
- Swipe gestures on tiles
- Animations on tap (ripple effect already provided by ListTile)
