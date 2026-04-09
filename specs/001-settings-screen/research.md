# Research: Settings Screen

**Feature**: Settings Screen (Navigation-only)  
**Date**: 2025-12-23  
**Purpose**: Resolve all NEEDS CLARIFICATION items from Technical Context

---

## Research Tasks & Findings

### 1. Flutter Navigation with go_router (Best Practices)

**Task**: Find best practices for go_router navigation in a feature-based Flutter architecture.

**Decision**: Use declarative routing with named routes in a centralized AppRouter configuration.

**Rationale**: 
- go_router is the recommended navigation solution for Flutter (official Flutter team endorsement)
- Declarative routing makes routes testable and maintainable
- Named routes prevent hardcoded strings throughout the codebase
- Supports deep linking and navigation stack management out of the box

**Implementation Approach**:
```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  routes: [
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

**Alternatives Considered**:
- **Navigator 1.0 (imperative)**: Rejected - too verbose, difficult to test, no deep linking support
- **Navigator 2.0 (manual)**: Rejected - overly complex for MVP, requires custom RouteInformationParser
- **auto_route**: Rejected - adds build_runner complexity, go_router is simpler for this scope

**Sources**:
- [go_router official documentation](https://pub.dev/packages/go_router)
- [Flutter navigation best practices](https://docs.flutter.dev/ui/navigation)

---

### 2. Flutter Localization with ARB (Best Practices)

**Task**: Find best practices for ARB-based localization in Flutter without hardcoded strings.

**Decision**: Use flutter_localizations + intl with ARB files and generate type-safe AppLocalizations class.

**Rationale**:
- ARB (Application Resource Bundle) is the official Flutter localization format
- Code generation ensures compile-time safety (no runtime key errors)
- Supports pluralization and interpolation out of the box
- IDE autocomplete for localization keys reduces errors

**Implementation Approach**:
```yaml
# pubspec.yaml
flutter:
  generate: true

# l10n.yaml
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

```json
// app_en.arb
{
  "settings_language": "Language",
  "settings_categories": "Manage Categories"
}

// app_vi.arb
{
  "settings_language": "Ngôn ngữ",
  "settings_categories": "Quản lý thể loại"
}
```

```dart
// Usage in widget
Text(AppLocalizations.of(context)!.settings_language)
```

**Alternatives Considered**:
- **easy_localization**: Rejected - runtime string lookups (not type-safe), extra dependency
- **intl (manual)**: Rejected - requires manual message extraction, error-prone
- **Hardcoded ternaries (`languageCode == 'vi' ? 'Ngôn ngữ' : 'Language'`)**: Rejected - violates FR-SET-006, not maintainable

**Sources**:
- [Flutter internationalization guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [ARB specification](https://github.com/google/app-resource-bundle)

---

### 3. Accessibility Touch Targets in Flutter (48x48 dp)

**Task**: Find best practices for ensuring ≥48x48 dp touch targets for accessibility.

**Decision**: Use Material Design components (ListTile) which enforce minimum touch target by default, or wrap custom widgets in SizedBox/Container with explicit constraints.

**Rationale**:
- Material Design spec mandates 48x48 dp minimum for touch targets
- Flutter's Material widgets (ListTile, InkWell) respect this by default
- Easy to verify in widget tests using `tester.getSize()`

**Implementation Approach**:
```dart
// Option 1: ListTile (recommended - built-in accessibility)
ListTile(
  leading: Icon(icon),
  title: Text(label),
  onTap: () => context.go(route),
)

// Option 2: Custom tile with SizedBox constraint
SizedBox(
  height: 56, // > 48 dp
  child: InkWell(
    onTap: () => context.go(route),
    child: Row(children: [...]),
  ),
)
```

**Verification in Tests**:
```dart
final tileFinder = find.byType(ListTile).first;
final size = tester.getSize(tileFinder);
expect(size.height, greaterThanOrEqualTo(48.0));
```

**Alternatives Considered**:
- **GestureDetector without size constraints**: Rejected - no visual feedback, no enforced sizing
- **Custom padding calculations**: Rejected - error-prone, ListTile handles it correctly

**Sources**:
- [Material Design touch targets](https://m2.material.io/design/usability/accessibility.html#layout-and-typography)
- [Flutter accessibility guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)

---

### 4. Stateless Navigation Screen Pattern (Flutter Best Practices)

**Task**: Confirm best practices for navigation-only screens (no Cubit/BLoC).

**Decision**: Use StatelessWidget for navigation-only screens; no state management needed.

**Rationale**:
- Navigation logic is handled by go_router (external to widget)
- No local state to manage (no form inputs, no async operations)
- Localization is reactive (rebuilds on locale change via MaterialApp)
- Stateless widgets are simpler, faster, and easier to test

**Implementation Approach**:
```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings_title)),
      body: ListView(
        children: [
          SettingsTile(
            label: AppLocalizations.of(context)!.settings_language,
            icon: Icons.language,
            route: '/settings/language',
          ),
          SettingsTile(
            label: AppLocalizations.of(context)!.settings_categories,
            icon: Icons.category,
            route: '/settings/categories',
          ),
        ],
      ),
    );
  }
}
```

**Alternatives Considered**:
- **StatefulWidget with local state**: Rejected - no state to manage, unnecessary complexity
- **BLoC/Cubit for navigation**: Rejected - overkill for static navigation, violates KISS principle

**Sources**:
- [Flutter widget lifecycle](https://docs.flutter.dev/ui/widgets-intro)
- [When to use StatelessWidget vs StatefulWidget](https://docs.flutter.dev/ui/interactivity#stateful-and-stateless-widgets)

---

### 5. Widget Testing for Navigation (Flutter)

**Task**: Find best practices for testing navigation behavior in Flutter widget tests.

**Decision**: Use WidgetTester with MockGoRouter or test actual navigation with GoRouter.mock.

**Rationale**:
- Widget tests can verify navigation calls without full integration test overhead
- go_router supports mocking via `GoRouter.routerDelegate` inspection
- Can verify both navigation trigger (tap) and destination route

**Implementation Approach**:
```dart
testWidgets('Tapping Language tile navigates to /settings/language', (tester) async {
  // Arrange
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

  // Act
  final languageTile = find.text('Language');
  await tester.tap(languageTile);
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(LanguagePage), findsOneWidget);
  expect(router.routerDelegate.currentConfiguration.uri.path, '/settings/language');
});
```

**Alternatives Considered**:
- **Manual Navigator.push mocking**: Rejected - fragile, doesn't test real routing logic
- **Integration tests only**: Rejected - slower, widget tests provide faster feedback

**Sources**:
- [Flutter testing guide](https://docs.flutter.dev/testing/overview)
- [go_router testing examples](https://github.com/flutter/packages/tree/main/packages/go_router/test)

---

## Summary

All technical unknowns resolved:
1. ✅ **Navigation**: go_router with declarative routes
2. ✅ **Localization**: ARB files + flutter_localizations (generated AppLocalizations)
3. ✅ **Accessibility**: Material ListTile (48x48 dp enforced by default)
4. ✅ **State Management**: StatelessWidget (no Cubit/BLoC needed)
5. ✅ **Testing**: Widget tests with go_router + AppLocalizations

**Ready for Phase 1 (Design & Contracts)**.
