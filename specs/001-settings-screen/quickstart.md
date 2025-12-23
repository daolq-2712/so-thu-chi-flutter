# Quickstart: Settings Screen Implementation

**Feature**: Settings Screen  
**Date**: 2025-12-23  
**Target Audience**: Flutter developer (Middle level, ~1 year Flutter experience)

---

## Prerequisites

Before implementing Settings Screen, ensure:

1. ✅ **go_router is configured** in `lib/core/router/app_router.dart`
2. ✅ **flutter_localizations is enabled** in `pubspec.yaml` and `l10n.yaml` exists
3. ✅ **ARB files exist** in `lib/core/l10n/` (app_en.arb, app_vi.arb)
4. ✅ **Routes exist** for `/settings/language` and `/settings/categories` (stub pages are OK)

---

## Implementation Steps

### Step 1: Add ARB Keys (5 minutes)

Add the following keys to ARB files:

**`lib/core/l10n/app_en.arb`**:
```json
{
  "settings_language": "Language",
  "@settings_language": {
    "description": "Label for Language settings tile"
  },
  "settings_categories": "Manage Categories",
  "@settings_categories": {
    "description": "Label for Manage Categories settings tile"
  }
}
```

**`lib/core/l10n/app_vi.arb`**:
```json
{
  "settings_language": "Ngôn ngữ",
  "@settings_language": {
    "description": "Label for Language settings tile"
  },
  "settings_categories": "Quản lý thể loại",
  "@settings_categories": {
    "description": "Label for Manage Categories settings tile"
  }
}
```

**Regenerate localization files**:
```bash
flutter gen-l10n
```

---

### Step 2: Create SettingsTile Widget (10 minutes)

**File**: `lib/features/settings/presentation/widgets/settings_tile.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(route),
    );
  }
}
```

**Why ListTile?** 
- Automatically meets 48x48 dp touch target requirement
- Built-in Material Design styling
- Handles tap ripple effect

---

### Step 3: Create SettingsPage Widget (15 minutes)

**File**: `lib/features/settings/presentation/pages/settings_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),  // Or use localized key if available
      ),
      body: ListView(
        children: [
          SettingsTile(
            label: l10n.settings_language,
            icon: Icons.language,
            route: '/settings/language',
          ),
          SettingsTile(
            label: l10n.settings_categories,
            icon: Icons.category,
            route: '/settings/categories',
          ),
        ],
      ),
    );
  }
}
```

**Notes**:
- No Cubit/BLoC needed (stateless navigation)
- ListView allows scrolling if more tiles are added later
- AppBar title can be localized separately if needed

---

### Step 4: Register Route in go_router (5 minutes)

**File**: `lib/core/router/app_router.dart`

Add the Settings route to your existing router configuration:

```dart
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // ... existing routes (home, etc.)
    
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    
    // Ensure these routes exist (even as stub pages):
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => const LanguagePage(),  // Implement separately
    ),
    GoRoute(
      path: '/settings/categories',
      builder: (context, state) => const ManageCategoriesPage(),  // Implement separately
    ),
  ],
);
```

---

### Step 5: Verify Implementation (10 minutes)

#### Manual Testing

1. Run the app: `flutter run`
2. Navigate to Settings screen (e.g., from bottom navigation)
3. Verify:
   - ✅ Two tiles are displayed ("Language" and "Manage Categories" in EN)
   - ✅ Tapping "Language" navigates to `/settings/language`
   - ✅ Tapping "Manage Categories" navigates to `/settings/categories`
4. Change language to Vietnamese (if language feature is implemented)
5. Verify:
   - ✅ Tiles show "Ngôn ngữ" and "Quản lý thể loại"

#### Automated Testing (see Step 6 below)

---

### Step 6: Write Widget Tests (30 minutes)

**File**: `test/features/settings/presentation/pages/settings_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:your_app/features/settings/presentation/pages/settings_page.dart';
import 'package:your_app/features/settings/presentation/widgets/settings_tile.dart';

void main() {
  Widget makeTestableWidget(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('SettingsPage', () {
    testWidgets('renders exactly 2 SettingsTile widgets', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const SettingsPage()));
      expect(find.byType(SettingsTile), findsNWidgets(2));
    });

    testWidgets('displays localized labels in English', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const SettingsPage(),
        locale: const Locale('en'),
      ));
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Manage Categories'), findsOneWidget);
    });

    testWidgets('displays localized labels in Vietnamese', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const SettingsPage(),
        locale: const Locale('vi'),
      ));
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Quản lý thể loại'), findsOneWidget);
    });

    testWidgets('each tile has minimum 48dp touch target', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const SettingsPage()));
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final tile in tiles) {
        final size = tester.getSize(find.byWidget(tile));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });
  });

  group('SettingsPage Navigation', () {
    testWidgets('tapping Language tile navigates to /settings/language', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/language',
            builder: (_, __) => const Scaffold(body: Text('Language Page')),
          ),
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

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.text('Language Page'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/settings/language');
    });

    testWidgets('tapping Categories tile navigates to /settings/categories', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/categories',
            builder: (_, __) => const Scaffold(body: Text('Categories Page')),
          ),
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

      await tester.tap(find.text('Manage Categories'));
      await tester.pumpAndSettle();

      expect(find.text('Categories Page'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/settings/categories');
    });

    testWidgets('rapid taps do not crash app', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/settings/language', builder: (_, __) => const Scaffold()),
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

      // Tap rapidly 5 times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Language'));
      }
      await tester.pumpAndSettle();

      // Should not crash (test passes if no exception thrown)
      expect(tester.takeException(), isNull);
    });
  });
}
```

**Run tests**:
```bash
flutter test test/features/settings/presentation/pages/settings_page_test.dart
```

---

## Validation Checklist

Before marking this feature as complete:

- [ ] ARB keys `settings_language` and `settings_categories` exist in both EN and VI files
- [ ] `flutter gen-l10n` runs without errors
- [ ] SettingsTile widget uses ListTile (meets 48dp requirement)
- [ ] SettingsPage uses `AppLocalizations.of(context)!` (no hardcoded strings)
- [ ] Route `/settings` is registered in go_router
- [ ] All widget tests pass (`flutter test`)
- [ ] Manual testing confirms navigation works for both tiles
- [ ] Manual testing confirms localization works (EN/VI)
- [ ] `flutter analyze` reports no issues
- [ ] Code is formatted with `dart format .`

---

## Troubleshooting

### Issue: "AppLocalizations not found"

**Cause**: Localization files not generated.

**Fix**: Run `flutter gen-l10n` or restart IDE/Flutter process.

---

### Issue: "Route not found" error when tapping tile

**Cause**: Destination route (`/settings/language` or `/settings/categories`) not registered in go_router.

**Fix**: Add the missing route to `app_router.dart`:
```dart
GoRoute(
  path: '/settings/language',
  builder: (context, state) => const Placeholder(),  // Temporary stub
)
```

---

### Issue: Widget tests fail with "No MaterialLocalizations found"

**Cause**: Test widget tree missing localization delegates.

**Fix**: Ensure `makeTestableWidget` helper includes `localizationsDelegates` and `supportedLocales`:
```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
)
```

---

### Issue: Touch target test fails (height < 48dp)

**Cause**: Using custom widget instead of ListTile.

**Fix**: Replace custom tile implementation with Material `ListTile` component.

---

## Estimated Time

| Task | Time |
|------|------|
| Add ARB keys | 5 min |
| Create SettingsTile | 10 min |
| Create SettingsPage | 15 min |
| Register route | 5 min |
| Manual testing | 10 min |
| Write widget tests | 30 min |
| **Total** | **~75 minutes** |

---

## Next Steps

After completing Settings Screen:

1. Implement **Language Settings** screen (`/settings/language`)
2. Implement **Manage Categories** screen (`/settings/categories`)
3. Integrate Settings into bottom navigation bar (if not already done)
4. Run full integration test suite

---

## References

- [Feature Spec](spec.md)
- [Implementation Plan](plan.md)
- [Data Model](data-model.md)
- [Navigation Contract](contracts/navigation.md)
- [Localization Contract](contracts/localization.md)
- [Widget Contract](contracts/widgets.md)
- [Research Document](research.md)
- [Constitution](../../.specify/memory/constitution.md)
