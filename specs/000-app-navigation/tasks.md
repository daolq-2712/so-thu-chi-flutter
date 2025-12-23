# Tasks: App Navigation

**Feature Branch**: `000-app-navigation`  
**Date**: 2025-12-23  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

---

## Overview

This document breaks down the implementation of the App Navigation shell into small, ordered tasks with clear Definition of Done (DoD). Each task includes:
- File paths (from plan.md)
- Acceptance criteria mapping
- Verification method (WIDGET/MANUAL/CODE_REVIEW)

**Scope**: Bottom navigation with 2 tabs (Home, Settings) + center FAB (+) → Add Transaction. Active tab indication, return to previous tab, localized labels, accessibility compliance.

**Out of Scope**: Deep linking, tab state persistence, unsaved-changes warnings, tablet nav rail, custom transitions.

---

## Phase 1: Foundation Setup

### Task 1.1: Add Localization Keys

**File**: `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`

**What**: Add navigation-specific localization keys to existing ARB files.

**Implementation**:
- Add to `app_en.arb`:
  ```json
  "navHome": "Home",
  "navSettings": "Settings",
  "fabAddTransaction": "Add Transaction"
  ```
- Add to `app_vi.arb`:
  ```json
  "navHome": "Sổ giao dịch",
  "navSettings": "Cài đặt",
  "fabAddTransaction": "Giao dịch mới"
  ```

**DoD**:
- [ ] Keys added to both EN and VI ARB files
- [ ] Run `flutter gen-l10n` (or equivalent) to regenerate localization classes
- [ ] Verify no build errors after codegen
- [ ] Commit ARB changes

**Verification**: CODE_REVIEW  
**AC Mapping**: FR-NAV-008 (localized labels, no hardcoded strings)

---

### Task 1.2: Create Placeholder Pages

**Files**: 
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/transaction/presentation/pages/add_transaction_page.dart`

**What**: Create minimal placeholder pages for the 3 routes. These will be filled with real content by their respective feature specs.

**Implementation**:
- Each page is a `StatelessWidget` with a `Scaffold`
- Display page title in `AppBar` (localized if available, or simple text)
- Body shows centered `Text` widget with placeholder message (e.g., "Home Page - Coming Soon")
- No business logic, just enough to test navigation

**Example** (HomePage):
```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page - Content TBD')),
    );
  }
}
```

**DoD**:
- [ ] HomePage created at `lib/features/home/presentation/pages/home_page.dart`
- [ ] SettingsPage created at `lib/features/settings/presentation/pages/settings_page.dart`
- [ ] AddTransactionPage created at `lib/features/transaction/presentation/pages/add_transaction_page.dart`
- [ ] Each page compiles without errors
- [ ] Pages are importable and ready to use in router
- [ ] Commit placeholder pages

**Verification**: CODE_REVIEW  
**AC Mapping**: N/A (infrastructure for routing)

---

## Phase 2: Router Configuration

### Task 2.1: Configure go_router with StatefulShellRoute

**File**: `lib/core/router/app_router.dart`

**What**: Set up go_router with `StatefulShellRoute` to manage 2 shell branches (Home, Settings) and a standalone route for Add Transaction.

**Implementation**:
1. Create `GoRouter` instance:
   - `initialLocation: '/home'`
   - Define `StatefulShellRoute` with:
     - Builder: returns `ScaffoldWithNavBar` (to be created in Task 2.2)
     - Two branches:
       - Branch 1: `/home` → `HomePage`
       - Branch 2: `/settings` → `SettingsPage`
   - Define standalone `GoRoute` for `/add-transaction` → `AddTransactionPage`

2. Ensure router is provided to app via `MaterialApp.router`:
   - `routerConfig: router` in `main.dart` (or existing app setup)

**Key Points**:
- StatefulShellRoute preserves which branch (tab) was active
- When navigating to `/add-transaction` and back, router automatically returns to the previous branch
- No manual state management required for "previous tab" logic

**DoD**:
- [ ] `app_router.dart` created with go_router configuration
- [ ] StatefulShellRoute with 2 branches (Home, Settings) defined
- [ ] Standalone route `/add-transaction` defined (not wrapped in shell)
- [ ] Router integrated into `MaterialApp.router` in `main.dart`
- [ ] App compiles and launches (may crash if ScaffoldWithNavBar doesn't exist yet—that's Task 2.2)
- [ ] Commit router configuration

**Verification**: CODE_REVIEW  
**AC Mapping**: FR-NAV-003, FR-NAV-004, FR-NAV-005 (route navigation), FR-NAV-007 (return to previous tab via StatefulShellRoute)

---

### Task 2.2: Create ScaffoldWithNavBar Shell Widget

**File**: `lib/core/router/scaffold_with_nav_bar.dart`

**What**: Create the shell scaffold widget that wraps Home and Settings with bottom navigation and center FAB.

**Implementation**:
1. Create `ScaffoldWithNavBar` widget (StatelessWidget or StatefulWidget as needed)
2. Accept `StatefulNavigationShell navigationShell` parameter (from go_router)
3. Build a `Scaffold` with:
   - `body: navigationShell` (displays current branch content)
   - `bottomNavigationBar: NavigationBar` with:
     - `selectedIndex: _calculateSelectedIndex(navigationShell)` (get current branch index)
     - `destinations`: 2 items (Home, Settings) using localized labels from `AppLocalizations`
     - Icons: `Icons.home` for Home, `Icons.settings` for Settings
     - `onDestinationSelected`: call `navigationShell.goBranch(index)` to switch tabs
   - `floatingActionButton: FloatingActionButton` with:
     - `onPressed: () => context.push('/add-transaction')`
     - `child: Icon(Icons.add)`
     - `tooltip` or `semanticsLabel`: use localized `fabAddTransaction` string
   - `floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked` (or `.centerFloat` based on design preference)

4. Ensure Material 3 styling is applied (should be automatic with Material 3 theme)

**DoD**:
- [ ] `ScaffoldWithNavBar` widget created
- [ ] Bottom NavigationBar displays 2 tabs with localized labels (no hardcoded strings)
- [ ] Center FAB displays (+) icon and navigates to `/add-transaction` on tap
- [ ] Active tab is visually indicated (NavigationBar handles this automatically)
- [ ] FAB has semantic label from l10n
- [ ] App compiles and runs without errors
- [ ] Tapping tabs switches routes (manual smoke test)
- [ ] Tapping FAB navigates to Add Transaction page (manual smoke test)
- [ ] Commit shell widget

**Verification**: CODE_REVIEW + MANUAL (initial smoke test)  
**AC Mapping**: FR-NAV-001 (2 tabs), FR-NAV-002 (center FAB), FR-NAV-006 (active tab indication), FR-NAV-008 (localized labels), FR-NAV-009 (semantic labels)

---

## Phase 3: Widget Tests

### Task 3.1: Widget Test - Tab Switching

**File**: `test/core/router/scaffold_with_nav_bar_test.dart`

**What**: Test that tapping Home and Settings tabs navigates to the correct routes and shows correct selected state.

**Test Cases**:
1. **Initial state**: App launches to `/home`, Home tab is selected
2. **Tap Settings tab**: Route changes to `/settings`, Settings tab is selected
3. **Tap Home tab**: Route changes to `/home`, Home tab is selected

**Implementation**:
- Use `flutter_test` and `GoRouter.of(context)` or test helpers to verify current route
- Pump widget tree with router
- Find tab widgets by label or icon
- Tap and verify route change
- Verify `NavigationBar.selectedIndex` matches expected tab

**DoD**:
- [ ] Test file created at `test/core/router/scaffold_with_nav_bar_test.dart`
- [ ] Test case: Initial launch → `/home` and Home tab selected
- [ ] Test case: Tap Settings tab → `/settings` and Settings tab selected
- [ ] Test case: Tap Home tab → `/home` and Home tab selected
- [ ] All tests pass (`flutter test`)
- [ ] Commit test file

**Verification**: WIDGET  
**AC Mapping**: 
- User Story 1, Scenario 1 (2 tabs visible)
- User Story 1, Scenario 2 (Home tab → `/home` + selected state)
- User Story 1, Scenario 3 (Settings tab → `/settings` + selected state)
- FR-NAV-003, FR-NAV-004, FR-NAV-006
- SC-001 (reach routes via 1 tap)

---

### Task 3.2: Widget Test - FAB Navigation

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing file)

**What**: Test that tapping the center FAB navigates to `/add-transaction` from both Home and Settings.

**Test Cases**:
1. **From Home**: Start at `/home` → tap FAB → route is `/add-transaction`
2. **From Settings**: Navigate to `/settings` → tap FAB → route is `/add-transaction`

**Implementation**:
- Find FAB by icon (`Icons.add`) or semantic label
- Tap FAB
- Verify route changed to `/add-transaction`

**DoD**:
- [ ] Test case: From `/home`, tap FAB → `/add-transaction`
- [ ] Test case: From `/settings`, tap FAB → `/add-transaction`
- [ ] All tests pass (`flutter test`)
- [ ] Commit updated test file

**Verification**: WIDGET  
**AC Mapping**:
- User Story 2, Scenario 1 (FAB from Home)
- User Story 2, Scenario 2 (FAB from Settings)
- FR-NAV-005
- SC-002 (reach `/add-transaction` via 1 tap)

---

### Task 3.3: Widget Test - Return to Previous Tab

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing file)

**What**: Test that returning from `/add-transaction` navigates back to the previously active tab (Home or Settings).

**Test Cases**:
1. **From Home**: Start at `/home` → tap FAB → at `/add-transaction` → go back (pop) → returns to `/home`
2. **From Settings**: Navigate to `/settings` → tap FAB → at `/add-transaction` → go back (pop) → returns to `/settings`

**Implementation**:
- Navigate to starting tab
- Tap FAB to go to `/add-transaction`
- Simulate back navigation (`router.pop()` or back button)
- Verify route returned to starting tab (`/home` or `/settings`)

**DoD**:
- [ ] Test case: Home → FAB → back → Home
- [ ] Test case: Settings → FAB → back → Settings
- [ ] All tests pass (`flutter test`)
- [ ] Commit updated test file

**Verification**: WIDGET  
**AC Mapping**:
- User Story 2, Scenario 3 (return to previous tab)
- FR-NAV-007
- SC-003 (active tab consistent with route after return)

---

### Task 3.4: Widget Test - Bottom Nav Visibility

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing file)

**What**: Test that bottom navigation is visible on `/home` and `/settings`, but hidden on `/add-transaction`.

**Test Cases**:
1. **On `/home`**: Bottom NavigationBar is present in widget tree
2. **On `/settings`**: Bottom NavigationBar is present in widget tree
3. **On `/add-transaction`**: Bottom NavigationBar is NOT present (because `/add-transaction` is a standalone route outside the shell)

**Implementation**:
- Navigate to each route
- Use `find.byType(NavigationBar)` to check presence/absence
- For `/add-transaction`: verify shell scaffold is not rendered

**DoD**:
- [ ] Test case: `/home` → NavigationBar visible
- [ ] Test case: `/settings` → NavigationBar visible
- [ ] Test case: `/add-transaction` → NavigationBar NOT visible
- [ ] All tests pass (`flutter test`)
- [ ] Commit updated test file

**Verification**: WIDGET  
**AC Mapping**: Plan requirement (bottom nav hidden on `/add-transaction`)

---

### Task 3.5: Widget Test - Localization

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing file)

**What**: Test that tab labels and FAB semantics use localized strings, not hardcoded text.

**Test Cases**:
1. **English locale**: Tab labels are "Home" and "Settings", FAB semantic label is "Add Transaction"
2. **Vietnamese locale**: Tab labels are "Sổ giao dịch" and "Cài đặt", FAB semantic label is "Giao dịch mới"

**Implementation**:
- Set up widget test with specific locale (EN or VI)
- Verify `NavigationDestination.label` matches expected localized string
- Verify FAB semantic label (via `Semantics` widget or `tooltip`)

**DoD**:
- [ ] Test case: EN locale → correct English labels
- [ ] Test case: VI locale → correct Vietnamese labels
- [ ] All tests pass (`flutter test`)
- [ ] Commit updated test file

**Verification**: WIDGET  
**AC Mapping**:
- User Story 3, Scenario 1 (localized labels, no hardcoded strings)
- FR-NAV-008
- SC-003 (labels are localized)

---

## Phase 4: Manual Verification & Accessibility

### Task 4.1: Manual Accessibility Checklist

**What**: Perform manual checks for accessibility compliance (touch targets, screen reader support).

**Manual Checklist**:
- [ ] **Touch Targets**: Tap each tab and FAB on a physical device or emulator. Verify touch areas feel comfortable and are ≥48x48dp. (Material NavigationBar and FAB should meet this by default, but verify.)
- [ ] **Screen Reader (Android)**: Enable TalkBack → navigate to bottom nav → verify:
  - [ ] Home tab announces "Home" (or "Sổ giao dịch" in VI) + "selected" or "not selected"
  - [ ] Settings tab announces "Settings" (or "Cài đặt" in VI) + "selected" or "not selected"
  - [ ] FAB announces "Add Transaction" (or "Giao dịch mới" in VI)
- [ ] **Screen Reader (iOS)**: Enable VoiceOver → verify same announcements as above
- [ ] **Visual Indication**: Visually confirm active tab is distinguishable (color change, icon fill, or underline per Material 3 defaults)

**DoD**:
- [ ] All manual checklist items verified and documented (add notes if any issues found)
- [ ] If issues found: file tasks to fix, or document as acceptable (if Material defaults meet requirements)
- [ ] Update this checklist with results (pass/fail for each item)

**Verification**: MANUAL  
**AC Mapping**:
- User Story 3, Scenario 2 (touch target ≥48dp, semantic labels)
- FR-NAV-009
- SC-004 (accessibility requirements met)

---

### Task 4.2: Manual Visual & Interaction Checks

**What**: Perform end-to-end manual testing of navigation flows.

**Manual Checklist**:
- [ ] **Launch App**: App starts on `/home` with Home tab selected
- [ ] **Tab Switching**: Tap Settings tab → navigates to `/settings` and Settings tab is visually active
- [ ] **Tab Switching**: Tap Home tab → navigates to `/home` and Home tab is visually active
- [ ] **FAB from Home**: On `/home`, tap center (+) → navigates to `/add-transaction`
- [ ] **FAB from Settings**: On `/settings`, tap center (+) → navigates to `/add-transaction`
- [ ] **Return to Home**: From `/home` → FAB → Add Transaction screen → back button → returns to `/home`
- [ ] **Return to Settings**: From `/settings` → FAB → Add Transaction screen → back button → returns to `/settings`
- [ ] **Bottom Nav Visibility**: On `/home` and `/settings`, bottom nav is visible; on `/add-transaction`, bottom nav is hidden
- [ ] **Localization (EN)**: Set device language to English → verify tab labels "Home" / "Settings"
- [ ] **Localization (VI)**: Set device language to Vietnamese → verify tab labels "Sổ giao dịch" / "Cài đặt"
- [ ] **Rapid Tapping**: Rapidly tap between Home and Settings tabs 20+ times → no crashes, no incorrect state

**DoD**:
- [ ] All manual checklist items verified
- [ ] Any issues found are documented and tasks created if needed
- [ ] Mark checklist complete

**Verification**: MANUAL  
**AC Mapping**: All User Stories, all Success Criteria (comprehensive smoke test)

---

## Phase 5: Code Quality & PR Preparation

### Task 5.1: Code Formatting & Analysis

**What**: Ensure code meets Flutter quality standards.

**Steps**:
1. Run `dart format .` from project root
2. Run `flutter analyze` from project root
3. Fix any linter warnings/errors

**DoD**:
- [ ] `dart format .` executed (code auto-formatted)
- [ ] `flutter analyze` passes with zero issues
- [ ] Commit any formatting fixes

**Verification**: CODE_REVIEW  
**AC Mapping**: Constitution 3.6 (Code Quality), 4.5 (Definition of Done)

---

### Task 5.2: Run All Tests

**What**: Verify all widget tests pass.

**Steps**:
1. Run `flutter test` from project root
2. Ensure all tests pass (0 failures)

**DoD**:
- [ ] `flutter test` executed
- [ ] All tests pass (specifically, all tests from Task 3.1–3.5)
- [ ] If failures, fix and re-run until passing

**Verification**: WIDGET  
**AC Mapping**: Constitution 4.5 (Definition of Done for PR)

---

### Task 5.3: Final Sanity Check

**What**: Perform a final manual smoke test before submitting PR.

**Manual Checklist**:
- [ ] App builds successfully (`flutter build apk --debug` or `flutter run`)
- [ ] No runtime errors on app launch
- [ ] Tab switching works (Home ↔ Settings)
- [ ] FAB opens Add Transaction
- [ ] Back from Add Transaction returns to correct tab
- [ ] Bottom nav visible on Home/Settings, hidden on Add Transaction
- [ ] Labels are localized (spot check EN and VI)

**DoD**:
- [ ] All sanity checks pass
- [ ] Ready to create PR

**Verification**: MANUAL  
**AC Mapping**: Constitution 4.5 (Manual sanity check requirement)

---

## Phase 6: PR Checklist (Constitution Merge Gate)

### Task 6.1: PR Merge Gate Checklist

**What**: Verify PR meets all constitution merge gate requirements before requesting review.

**PR Checklist** (per Constitution 7, Merge Gate):
- [ ] `spec.md` / `plan.md` / `tasks.md` are in sync with code changes (no behavior/contract drift)
- [ ] `tasks.md` has AC → verification mapping (UNIT/WIDGET/MANUAL) for all changes ✅ (this file)
- [ ] `dart format .` has been run ✅ (Task 5.1)
- [ ] `flutter analyze` passes with zero issues ✅ (Task 5.1)
- [ ] `flutter test` passes (all widget tests green) ✅ (Task 5.2)
- [ ] No DB schema changes (N/A for this feature—navigation only)
- [ ] Manual sanity check on 4 main screens: Home, Settings, Add Transaction, and navigation flows ✅ (Task 5.3)
- [ ] No new "kitchen sink" dependencies added (no new packages for this feature; only go_router, which is constitution-approved)
- [ ] Commit messages follow convention (e.g., "feat: implement app navigation shell")
- [ ] PR description references spec.md and summarizes implementation

**DoD**:
- [ ] All checklist items verified
- [ ] PR created with checklist in description
- [ ] Request review

**Verification**: CODE_REVIEW  
**AC Mapping**: Constitution 7 (Workflow & Quality Gates)

---

## Summary: AC → Verification Mapping

| Acceptance Criteria / FR | Verification Method | Task(s) |
|--------------------------|---------------------|---------|
| FR-NAV-001 (2 tabs: Home, Settings) | WIDGET | 3.1 |
| FR-NAV-002 (center FAB) | CODE_REVIEW + WIDGET | 2.2, 3.2 |
| FR-NAV-003 (Home tab → `/home`) | WIDGET | 3.1 |
| FR-NAV-004 (Settings tab → `/settings`) | WIDGET | 3.1 |
| FR-NAV-005 (FAB → `/add-transaction`) | WIDGET | 3.2 |
| FR-NAV-006 (active tab indication) | WIDGET + MANUAL | 3.1, 4.2 |
| FR-NAV-007 (return to previous tab) | WIDGET | 3.3 |
| FR-NAV-008 (localized labels) | CODE_REVIEW + WIDGET | 1.1, 2.2, 3.5 |
| FR-NAV-009 (touch targets ≥48dp, semantics) | MANUAL | 4.1 |
| User Story 1 (tab switching) | WIDGET | 3.1 |
| User Story 2 (FAB navigation) | WIDGET | 3.2, 3.3 |
| User Story 3 (localization + a11y) | WIDGET + MANUAL | 3.5, 4.1 |
| SC-001 (reach routes via 1 tap) | WIDGET | 3.1, 3.2 |
| SC-002 (FAB access from main screens) | WIDGET | 3.2 |
| SC-003 (active tab indication) | WIDGET + MANUAL | 3.1, 4.2 |
| SC-004 (accessibility requirements) | MANUAL | 4.1 |
| Bottom nav visibility (plan requirement) | WIDGET | 3.4 |

---

## Notes

- **File Locations** (per plan.md):
  - Router: `lib/core/router/app_router.dart`, `lib/core/router/scaffold_with_nav_bar.dart`
  - Localization: `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`
  - Placeholders: `lib/features/home/presentation/pages/home_page.dart`, `lib/features/settings/presentation/pages/settings_page.dart`, `lib/features/transaction/presentation/pages/add_transaction_page.dart`
  - Tests: `test/core/router/scaffold_with_nav_bar_test.dart`

- **Verification Types**:
  - **CODE_REVIEW**: Check implementation matches plan/spec (no runtime test needed)
  - **WIDGET**: Automated widget tests cover the behavior
  - **MANUAL**: Human tester verifies (a11y, visual, edge cases)

- **Out of Scope Reminder**: Do NOT implement:
  - Deep linking behavior
  - Tab state persistence across app restarts
  - Unsaved-changes warnings
  - Tablet navigation rail
  - Custom transitions or animations
  - Performance timing metrics

**End of Tasks**
