# Localization Contract: Settings Screen

**Feature**: Settings Screen  
**Date**: 2025-12-23  
**Type**: ARB (Application Resource Bundle) Keys

---

## Overview

Settings Screen requires 2 localized strings for the navigation tiles. All strings must be defined in both EN and VI locales per constitution requirement (3.5).

---

## Required ARB Keys

### English (EN) Locale

**File**: `lib/core/l10n/app_en.arb`

```json
{
  "settings_language": "Language",
  "@settings_language": {
    "description": "Label for Language settings tile on Settings screen"
  },
  
  "settings_categories": "Manage Categories",
  "@settings_categories": {
    "description": "Label for Manage Categories settings tile on Settings screen"
  }
}
```

---

### Vietnamese (VI) Locale

**File**: `lib/core/l10n/app_vi.arb`

```json
{
  "settings_language": "Ngôn ngữ",
  "@settings_language": {
    "description": "Label for Language settings tile on Settings screen"
  },
  
  "settings_categories": "Quản lý thể loại",
  "@settings_categories": {
    "description": "Label for Manage Categories settings tile on Settings screen"
  }
}
```

---

## Usage in Code

### Import Generated Localization Class

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Access Localized Strings

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),  // Note: settings_title defined elsewhere
      body: ListView(
        children: [
          SettingsTile(
            label: l10n.settings_language,      // "Language" or "Ngôn ngữ"
            icon: Icons.language,
            route: '/settings/language',
          ),
          SettingsTile(
            label: l10n.settings_categories,    // "Manage Categories" or "Quản lý thể loại"
            icon: Icons.category,
            route: '/settings/categories',
          ),
        ],
      ),
    );
  }
}
```

---

## Configuration

### pubspec.yaml

```yaml
flutter:
  generate: true
  
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
```

### l10n.yaml

```yaml
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

---

## Build Process

### Generate Localization Files

```bash
flutter gen-l10n
```

**Output**: `lib/generated/l10n/app_localizations.dart` (and locale-specific classes)

**Note**: This command runs automatically during `flutter build` or `flutter run`, but can be invoked manually for verification.

---

## Testing Contract

### Widget Test Setup

```dart
testWidgets('Settings displays localized labels', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),  // or 'vi' for Vietnamese
      home: const SettingsPage(),
    ),
  );

  // Verify EN locale
  expect(find.text('Language'), findsOneWidget);
  expect(find.text('Manage Categories'), findsOneWidget);
});

testWidgets('Settings displays Vietnamese labels', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      home: const SettingsPage(),
    ),
  );

  // Verify VI locale
  expect(find.text('Ngôn ngữ'), findsOneWidget);
  expect(find.text('Quản lý thể loại'), findsOneWidget);
});
```

---

## Error Handling

### Missing Key

**Scenario**: ARB key is accessed but not defined in ARB file.

**Build-time Error**: 
```
Error: The getter 'settings_language' isn't defined for the type 'AppLocalizations'.
```

**Prevention**: Run `flutter gen-l10n` after adding/modifying ARB files to catch errors before runtime.

### Missing Locale

**Scenario**: App runs with locale not in `supportedLocales`.

**Behavior**: Flutter fallback to closest supported locale (EN in this case, as template-arb-file is app_en.arb).

---

## Acceptance Criteria Mapping

- **FR-SET-006**: "All visible texts on Settings MUST be sourced from ARB localization files"
  - ✅ Verified by: Widget tests check `find.text(l10n.settings_language)` (no hardcoded strings)

- **AC 2.2**: "Settings screen renders → the 'Ngôn ngữ' tile label is localized via ARB (no hardcoded strings)"
  - ✅ Verified by: Widget test with `locale: Locale('vi')` finds text "Ngôn ngữ"

---

## Dependencies

- **flutter_localizations** (SDK package)
- **intl** (^0.18.0 or compatible)
- **flutter gen-l10n** (build tool, no runtime dependency)

---

## Future Considerations (Out of Scope for MVP)

- Pluralization (e.g., "1 category" vs "N categories")
- Interpolation (e.g., "Welcome, {userName}")
- RTL (Right-to-Left) locale support (e.g., Arabic)
- Context-specific translations (formal vs informal)
