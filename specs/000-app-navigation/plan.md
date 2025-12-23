# Implementation Plan: App Navigation

**Branch**: `000-app-navigation` | **Date**: 2025-12-23 | **Spec**: [spec.md](spec.md)

## Summary

App Navigation provides the foundational navigation shell for the MVP: a bottom navigation bar with 2 tabs (Home, Settings) and a center FAB (+) button. Tapping tabs navigates to `/home` or `/settings`; tapping (+) navigates to `/add-transaction`. The implementation uses go_router with a stateful shell route to preserve tab state when returning from Add Transaction. Bottom navigation is hidden on the Add Transaction screen. All labels are localized (EN/VI via ARB), and accessibility requirements (≥48dp touch targets, semantic labels) are met using Material 3 NavigationBar defaults.

## Technical Context

**Language/Version**: Dart/Flutter (Flutter SDK ≥3.0)  
**Primary Dependencies**: flutter, go_router, flutter_localizations, intl  
**Storage**: N/A (navigation state managed by go_router; no persistence across app restarts)  
**Testing**: flutter_test (widget tests for navigation flows, localization, accessibility)  
**Target Platform**: iOS/Android (mobile app)  
**Project Type**: Mobile (feature-based architecture)  
**Performance Goals**: Instant tab switching (<16ms frame time), smooth navigation transitions  
**Constraints**: Offline-capable, no network calls, meets accessibility touch target (≥48dp)  
**Scale/Scope**: 1 shell widget, 3 routes (/home, /settings, /add-transaction), 2 tabs + 1 FAB

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-Phase 0 Check

- ✅ **Spec-Driven**: spec.md exists with clear requirements (FR-NAV-001 through FR-NAV-009)
- ✅ **Scope Control**: Out of Scope explicitly excludes deep linking, state persistence, unsaved warnings, tablet nav, custom transitions
- ✅ **KISS**: StatefulShellRoute with NavigationBar = simplest go_router pattern for bottom nav
- ✅ **Maintainability**: Declarative routing with minimal state (current tab index only)
- ✅ **Data Integrity**: N/A (no data storage/mutation)
- ✅ **Reactive SSOT**: N/A (no data layer; navigation state managed by router)
- ✅ **Testing**: Widget tests planned for all acceptance scenarios
- ✅ **AC-Driven Verification**: All acceptance scenarios are testable (routes, active state, return behavior)

**Result**: ✅ **PASS** - No gate violations. Proceed to Phase 0.

---

### Post-Phase 1 Check

Re-evaluation after design artifacts (data-model.md, contracts/, quickstart.md) completed:

- ✅ **Architecture (3.1)**: Feature-based structure confirmed - Presentation-only (no Domain/Data layers needed for shell navigation)
- ✅ **State Management (3.2)**: Minimal state (current tab index) managed by StatefulWidget wrapper - simplest solution per KISS principle
- ✅ **Navigation (3.4)**: go_router with StatefulShellRoute - meets constitution requirement, preserves tab state
- ✅ **Localization (3.5)**: ARB files + flutter_localizations - meets constitution requirement
- ✅ **Code Quality (3.6)**: Contracts defined (navigation.md, widgets.md, localization.md) - testable and maintainable
- ✅ **Testing (4.1, 4.3)**: Widget tests cover all acceptance scenarios (tab switching, FAB navigation, return behavior)
- ✅ **Consistency Check**: Contracts align with spec requirements (routes, active state, localization)
- ✅ **Clarification Gate**: No ambiguities remain (behavior fully specified in spec.md)

**Design Decision Summary**:
- **Pattern**: StatefulShellRoute + NavigationBar (preserves tab state automatically)
- **State**: Current tab index (managed by go_router StatefulShellRoute)
- **Localization**: ARB-based with code generation (type-safe)
- **Accessibility**: Material NavigationBar + FloatingActionButton (48dp enforced by default)
- **Testing**: Widget tests (no unit tests needed - no business logic)

**Result**: ✅ **PASS** - All constitution checks satisfied. Design is spec-compliant, simple, and testable. Ready for Phase 2 (Tasks breakdown).

## Routes Table

| Route | Screen | Parent | Bottom Nav Visible | Purpose |
|-------|--------|--------|-------------------|---------|
| `/home` | HomePage | Shell | ✅ Yes (Home active) | Main transaction list screen |
| `/settings` | SettingsPage | Shell | ✅ Yes (Settings active) | Settings menu screen |
| `/add-transaction` | AddTransactionPage | Standalone | ❌ No | Create new transaction form |
| `/settings/language` | LanguagePage | N/A | Out of scope (other feature) | Language selection |
| `/settings/categories` | CategoriesPage | N/A | Out of scope (other feature) | Category management |

**Note**: Only `/home`, `/settings`, and `/add-transaction` are in scope for this feature. Child routes under `/settings` are referenced for context but implemented by other features.

## Router Structure

### go_router Configuration

```dart
// Simplified structure (not actual implementation code)
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) => ScaffoldWithNavBar(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/home', ...)],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/settings', ...)],
        ),
      ],
    ),
    GoRoute(
      path: '/add-transaction',
      // Standalone route (no shell)
    ),
  ],
);
```

**Key Decisions**:
- **StatefulShellRoute**: Preserves navigation state (current tab) when navigating to/from Add Transaction
- **Two branches**: One for Home, one for Settings (allows each tab to maintain its own navigation stack in future)
- **Standalone route for Add Transaction**: Not wrapped in shell, so bottom nav is hidden
- **initialLocation**: `/home` ensures app always starts on Home tab

### State Rule for "Previous Tab"

**Implementation**: StatefulShellRoute automatically tracks which branch (tab) was last active. When returning from `/add-transaction`:
- go_router's `pop()` returns to the previously active shell branch
- No manual state management required
- Tab index automatically reflects the active branch

**Edge Cases**:
- If user has never switched tabs (stayed on Home), returns to Home
- If user switched to Settings then tapped (+), returns to Settings
- Behavior is deterministic and requires no app-level state storage

## UI Composition

### ScaffoldWithNavBar Widget

**Purpose**: Wraps StatefulShellRoute children with bottom navigation bar and center FAB

**Structure**:
```dart
// Conceptual structure (not implementation)
Scaffold(
  body: navigationShell,  // Current tab content
  bottomNavigationBar: NavigationBar(
    selectedIndex: _calculateSelectedIndex(navigationShell),
    destinations: [
      NavigationDestination(icon: Icons.home, label: l10n.navHome),
      NavigationDestination(icon: Icons.settings, label: l10n.navSettings),
    ],
    onDestinationSelected: (index) => _onItemTapped(index, navigationShell),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () => context.push('/add-transaction'),
    child: Icon(Icons.add),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
)
```

**Responsibilities**:
- Render bottom NavigationBar with 2 tabs
- Render center FAB with (+) icon
- Handle tab tap → update go_router navigation
- Handle FAB tap → navigate to `/add-transaction`
- Display current tab content via `navigationShell`

### Accessibility Requirements

Per FR-NAV-009, all navigation elements must meet:
- **Touch target**: ≥48x48dp (Material NavigationBar and FAB defaults meet this)
- **Semantic labels**: 
  - NavigationDestination `label` provides text for screen readers
  - FAB requires explicit `semanticsLabel` for "Add Transaction" (localized)
  - NavigationBar automatically announces selected state

### Localization Requirements

Per FR-NAV-008, all labels must be localized via ARB:
- `navHome` / `navSettings`: Tab labels
- `fabAddTransaction`: FAB semantic label
- No hardcoded strings in UI

**ARB Keys**:
```json
// app_en.arb
{
  "navHome": "Home",
  "navSettings": "Settings",
  "fabAddTransaction": "Add Transaction"
}

// app_vi.arb
{
  "navHome": "Sổ giao dịch",
  "navSettings": "Cài đặt",
  "fabAddTransaction": "Giao dịch mới"
}
```

## Testing Strategy

### Widget Tests (Priority: MUST)

**File**: `test/core/router/scaffold_with_nav_bar_test.dart`

**Test Cases**:
1. **Tab switching**:
   - Tap Home tab → verify route is `/home` and Home tab is selected
   - Tap Settings tab → verify route is `/settings` and Settings tab is selected
2. **FAB navigation**:
   - From Home: tap FAB → verify route is `/add-transaction`
   - From Settings: tap FAB → verify route is `/add-transaction`
3. **Return to previous tab**:
   - Start on Home → tap FAB → go back → verify returned to Home
   - Switch to Settings → tap FAB → go back → verify returned to Settings
4. **Bottom nav visibility**:
   - On `/home` → verify bottom nav is visible
   - On `/settings` → verify bottom nav is visible
   - On `/add-transaction` → verify bottom nav is NOT visible (no Scaffold with nav bar)
5. **Localization**:
   - Set locale to EN → verify tab labels are "Home" / "Settings"
   - Set locale to VI → verify tab labels are "Sổ giao dịch" / "Cài đặt"
6. **Accessibility**:
   - Verify NavigationDestination widgets have `label` property set
   - Verify FAB has `semanticsLabel` property set
   - (Touch target size verification: trust Material defaults, manual review in quickstart.md)

**Verification Method**: WIDGET (automated)

### Manual Tests (Priority: SHOULD)

**Checklist in quickstart.md**:
- [ ] Visual: Active tab is clearly distinguished (color/icon fill)
- [ ] Visual: FAB is visually distinct (elevated, centered)
- [ ] Touch: All tabs and FAB are comfortable to tap (≥48dp)
- [ ] Screen Reader: Enable TalkBack/VoiceOver → verify announcements for tabs and FAB
- [ ] Rapid Tapping: Rapidly switch tabs 20+ times → no crashes or incorrect state

**Verification Method**: MANUAL (checklist-driven)

## Project Structure

### Documentation (this feature)

```text
specs/000-app-navigation/
├── plan.md              # This file
├── research.md          # Phase 0 output (go_router best practices, StatefulShellRoute pattern)
├── data-model.md        # Phase 1 output (N/A - no entities)
├── quickstart.md        # Phase 1 output (manual test checklist, visual verification)
├── contracts/           # Phase 1 output
│   ├── navigation.md    # Routes table, go_router config contract
│   ├── widgets.md       # ScaffoldWithNavBar widget contract
│   └── localization.md  # ARB keys for navigation labels
└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── router/
│   │   ├── app_router.dart                  # go_router config (StatefulShellRoute + routes)
│   │   └── scaffold_with_nav_bar.dart       # ScaffoldWithNavBar widget (shell wrapper)
│   └── l10n/
│       ├── app_en.arb                       # EN strings: navHome, navSettings, fabAddTransaction
│       └── app_vi.arb                       # VI strings: navHome, navSettings, fabAddTransaction
└── features/
    ├── home/
    │   └── presentation/
    │       └── pages/
    │           └── home_page.dart           # HomePage (placeholder for this feature)
    ├── settings/
    │   └── presentation/
    │       └── pages/
    │           └── settings_page.dart       # SettingsPage (out of scope, referenced)
    └── transaction/
        └── presentation/
            └── pages/
                └── add_transaction_page.dart # AddTransactionPage (out of scope, referenced)

test/
└── core/
    └── router/
        └── scaffold_with_nav_bar_test.dart  # Widget tests (all acceptance scenarios)
```

**Structure Decision**: 
- Navigation shell (`app_router.dart`, `ScaffoldWithNavBar`) lives in `core/router` (shared infrastructure)
- Localization strings in `core/l10n` (shared across features)
- Feature screens (HomePage, SettingsPage, AddTransactionPage) in their respective features
- Only HomePage placeholder is in scope for this feature; other screens are referenced but implemented elsewhere

## Complexity Tracking

N/A - No constitution violations detected.

## Out of Scope (Explicit)

Per spec.md and user requirements, the following are **OUT OF SCOPE** for this feature:

1. **Deep linking behavior**: No requirements for launching app via deep links to specific tabs
2. **Tab state persistence across app restarts**: App always launches to `/home` tab
3. **Unsaved changes warnings**: No warning when leaving Add Transaction via tab tap (handled by Add Transaction feature if needed)
4. **Tablet/adaptive navigation**: No navigation rail for tablets; bottom nav only
5. **Custom transitions/animations**: Use go_router defaults
6. **Orientation handling**: Trust Flutter's layout system; no custom orientation logic
7. **Performance metrics/targets**: No specific timing requirements beyond "smooth" (trust Material defaults)
8. **Rapid tap debouncing**: No custom debounce logic (trust go_router and Material tap handling)
9. **Language change logic**: Navigation only consumes locale; language switching is handled by Settings feature
10. **Screen content implementation**: HomePage, SettingsPage, AddTransactionPage content are out of scope (implemented by other features)

**Design Implication**: Keep implementation minimal. Use go_router's StatefulShellRoute pattern as-is. Use Material 3 NavigationBar and FAB with default styling. Add only what spec.md explicitly requires.
