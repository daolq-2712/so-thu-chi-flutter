# Tasks: App Navigation

**Feature Branch**: `000-app-navigation`  
**Date**: 2025-12-23  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

---

## Overview

Implement App Navigation shell for MVP:
- Bottom navigation with **exactly 2 tabs**: Home (`/home`) and Settings (`/settings`)
- **Center FAB (+)** navigates to Add Transaction (`/add-transaction`)
- Active tab is visually indicated
- Returning from `/add-transaction` returns to the **previously active tab**
- Bottom nav visible only on `/home` & `/settings`, hidden on `/add-transaction`
- Labels from l10n/ARB (no hardcoded strings)
- Accessibility: touch targets ≥48dp + semantic labels

**Out of Scope**: Deep linking requirements, tab persistence across restarts, unsaved warnings, tablet nav rail, custom transitions.

**Verification Types**: **WIDGET** (primary), **MANUAL** (a11y spot-checks), **CODE_REVIEW** (structure)

---

## Phase 1: Foundation (Localization + Placeholders)

### Task 1.1: Add Navigation Localization Keys

**Files**:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_vi.arb`

**What**: Add ARB keys for navigation labels (no hardcoded strings in UI).

**Implementation**:

Add to `app_en.arb`:
```json
"navHome": "Home",
"navSettings": "Settings",
"fabAddTransaction": "Add Transaction"
```

Add to `app_vi.arb`:
```json
"navHome": "Sổ giao dịch",
"navSettings": "Cài đặt",
"fabAddTransaction": "Giao dịch mới"
```

**DoD**:
- [X] Keys added to both EN and VI ARB files
- [X] Run `flutter gen-l10n` to regenerate AppLocalizations
- [X] Verify no build errors after codegen
- [X] Commit ARB changes

**Verification**: CODE_REVIEW + WIDGET (tested in Task 3.5)  
**Mapping**: FR-NAV-008 (localized labels), User Story 3 Scenario 1

---

### Task 1.2: Create Placeholder Pages with Keys

**Files**:
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/transaction/presentation/pages/add_transaction_page.dart`

**What**: Create minimal placeholder pages for routing validation. Use `Key()` for test identification. **No hardcoded visible text** to avoid interfering with localization tests.

**Implementation**:

HomePage example:
```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('page_home'),
      appBar: AppBar(title: Text(context.l10n.navHome)),
      body: const SizedBox.shrink(),
    );
  }
}
```

Apply same pattern for SettingsPage (`Key('page_settings')`) and AddTransactionPage (`Key('page_add_transaction')`).

**DoD**:
- [X] HomePage created with `Key('page_home')`
- [X] SettingsPage created with `Key('page_settings')`
- [X] AddTransactionPage created with `Key('page_add_transaction')`
- [X] No hardcoded visible strings (use l10n for AppBar titles)
- [X] All pages compile without errors
- [X] Commit placeholder pages

**Verification**: CODE_REVIEW  
**Mapping**: Infrastructure for FR-NAV-003, FR-NAV-004, FR-NAV-005 (routing targets)

---

## Phase 2: Router Configuration & Shell Scaffold

### Task 2.1: Configure go_router with StatefulShellRoute

**File**: `lib/core/router/app_router.dart`

**What**: Set up go_router with `StatefulShellRoute` for 2 shell branches (Home, Settings) and standalone `/add-transaction` route.

**Implementation**:
1. Create `GoRouter` instance:
   - `initialLocation: '/home'`
   - `StatefulShellRoute` with builder returning `ScaffoldWithNavBar`
   - Two branches:
     - Branch 1: `/home` → `HomePage`
     - Branch 2: `/settings` → `SettingsPage`
   - Standalone `GoRoute`: `/add-transaction` → `AddTransactionPage` (outside shell)

2. Integrate into `MaterialApp.router` in `main.dart`

**Key Design**:
- StatefulShellRoute automatically tracks active branch
- Returning from `/add-transaction` pops to previous branch (no manual state needed)

**DoD**:
- [X] `app_router.dart` created with go_router configuration
- [X] StatefulShellRoute with 2 branches (Home, Settings)
- [X] Standalone route `/add-transaction` defined (not wrapped in shell)
- [X] Router integrated into `MaterialApp.router`
- [X] App compiles (may crash if ScaffoldWithNavBar doesn't exist yet)
- [X] Commit router configuration

**Verification**: CODE_REVIEW  
**Mapping**: FR-NAV-003, FR-NAV-004, FR-NAV-005, FR-NAV-007 (routes + return behavior)

---

### Task 2.2: Implement ScaffoldWithNavBar Shell Widget

**File**: `lib/core/router/scaffold_with_nav_bar.dart`

**What**: Create shell scaffold that wraps Home and Settings with bottom navigation and center FAB.

**Implementation**:
1. Accept `StatefulNavigationShell navigationShell` parameter
2. Build `Scaffold` with:
   - `body: navigationShell` (displays current branch)
   - `bottomNavigationBar: NavigationBar`:
     - `selectedIndex`: `navigationShell.currentIndex`
     - `destinations`: 2 items using `AppLocalizations`:
       - Home: `NavigationDestination(icon: Icon(Icons.home), label: context.l10n.navHome)`
       - Settings: `NavigationDestination(icon: Icon(Icons.settings), label: context.l10n.navSettings)`
     - `onDestinationSelected`: `(index) => navigationShell.goBranch(index)`
   - `floatingActionButton: FloatingActionButton`:
     - `onPressed: () => context.push('/add-transaction')`
     - `child: const Icon(Icons.add)`
     - `tooltip: context.l10n.fabAddTransaction` (for semantics)
   - `floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat` (no notch requirement per spec)

3. Material 3 styling is automatic via theme

**DoD**:
- [X] `ScaffoldWithNavBar` widget created
- [X] Exactly 2 NavigationDestination items with l10n labels (no hardcoded strings)
- [X] FAB has `tooltip` with `fabAddTransaction` l10n key
- [X] `onDestinationSelected` calls `navigationShell.goBranch(index)`
- [X] FAB `onPressed` navigates to `/add-transaction` via `context.push('/add-transaction')`
- [X] Active tab automatically indicated by NavigationBar (uses `selectedIndex`)
- [X] App compiles and runs
- [X] Commit shell widget

**Verification**: CODE_REVIEW + WIDGET (tested in Phase 3)  
**Mapping**: FR-NAV-001, FR-NAV-002, FR-NAV-006, FR-NAV-008, FR-NAV-009 (shell structure + labels + semantics)

---

## Phase 3: Widget Tests

### Task 3.1: Widget Test - Initial State and Tab Switching

**File**: `test/core/router/scaffold_with_nav_bar_test.dart`

**What**: Test initial route, tab switching, and selected state indication.

**Test Cases**:
1. **Initial state**: App launches to Home, `NavigationBar.selectedIndex == 0`
2. **Tap Settings**: Tap Settings destination → `Key('page_settings')` visible, `selectedIndex == 1`
3. **Tap Home**: Tap Home destination → `Key('page_home')` visible, `selectedIndex == 0`

**Verification Method**: 
- Use `find.byKey(Key('page_home'))` / `find.byKey(Key('page_settings'))` to verify current page
- Use `tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex` to verify active tab
- **Do NOT rely on reading route strings** (use widget presence + selectedIndex)

**DoD**:
- [X] Test file created at `test/core/router/scaffold_with_nav_bar_test.dart`
- [X] Test: App launches → `Key('page_home')` visible, `selectedIndex == 0`
- [X] Test: Tap Settings destination → `Key('page_settings')` visible, `selectedIndex == 1`
- [X] Test: Tap Home destination → `Key('page_home')` visible, `selectedIndex == 0`
- [X] All tests pass (`flutter test`)
- [X] Commit test file

**Verification**: WIDGET  
**Mapping**:
- User Story 1, Scenarios 1-3 (2 tabs visible, tab switching, selected state)
- FR-NAV-001 (2 tabs), FR-NAV-003 (Home tab), FR-NAV-004 (Settings tab), FR-NAV-006 (active indication)
- SC-001 (reach routes via 1 tap), SC-003 (active tab indication)

---

### Task 3.2: Widget Test - FAB Navigation

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing)

**What**: Test FAB navigates to Add Transaction from both tabs.

**Test Cases**:
1. **From Home**: Start at Home → tap FAB → `Key('page_add_transaction')` visible
2. **From Settings**: Navigate to Settings → tap FAB → `Key('page_add_transaction')` visible

**Verification Method**:
- Find FAB by `find.byType(FloatingActionButton)`
- Tap FAB
- Verify `find.byKey(Key('page_add_transaction'))` is visible
- **Do NOT read route strings** (use widget presence)

**DoD**:
- [X] Test: From Home, tap FAB → `Key('page_add_transaction')` visible
- [X] Test: From Settings, tap FAB → `Key('page_add_transaction')` visible
- [X] All tests pass (`flutter test`)
- [X] Commit updated test

**Verification**: WIDGET  
**Mapping**:
- User Story 2, Scenarios 1-2 (FAB from Home, FAB from Settings)
- FR-NAV-005 (FAB → `/add-transaction`)
- SC-002 (reach Add Transaction via 1 tap)

---

### Task 3.3: Widget Test - Return to Previous Tab

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing)

**What**: Test returning from Add Transaction navigates back to previously active tab.

**Test Cases**:
1. **From Home**: Home (`selectedIndex == 0`) → FAB → AddTransaction → pop → `Key('page_home')` visible, `selectedIndex == 0`
2. **From Settings**: Settings (`selectedIndex == 1`) → FAB → AddTransaction → pop → `Key('page_settings')` visible, `selectedIndex == 1`

**Verification Method**:
- Navigate to starting tab (verify with `selectedIndex`)
- Tap FAB → verify `Key('page_add_transaction')` visible
- Call `tester.pageBack()` or `Navigator.pop()` to simulate back
- Verify returned to starting page (check Key presence + `selectedIndex`)
- **Do NOT read route strings** (use widget presence + selectedIndex)

**DoD**:
- [X] Test: Home → FAB → pop → returns to Home (`selectedIndex == 0`)
- [X] Test: Settings → FAB → pop → returns to Settings (`selectedIndex == 1`)
- [X] All tests pass (`flutter test`)
- [X] Commit updated test

**Verification**: WIDGET  
**Mapping**:
- User Story 2, Scenario 3 (return to previous tab)
- FR-NAV-007 (return to previously active tab)
- SC-003 (active tab consistent after return)

---

### Task 3.4: Widget Test - Bottom Nav Visibility

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing)

**What**: Test bottom navigation is visible on Home/Settings, hidden on Add Transaction.

**Test Cases**:
1. **On Home**: `find.byType(NavigationBar)` exists
2. **On Settings**: Navigate to Settings → `find.byType(NavigationBar)` exists
3. **On Add Transaction**: Navigate to Add Transaction → `find.byType(NavigationBar)` does NOT exist

**Verification Method**:
- Use `find.byType(NavigationBar)`
- For Home/Settings: `expect(find.byType(NavigationBar), findsOneWidget)`
- For Add Transaction: `expect(find.byType(NavigationBar), findsNothing)`

**DoD**:
- [X] Test: On Home → NavigationBar visible
- [X] Test: On Settings → NavigationBar visible
- [X] Test: On Add Transaction → NavigationBar NOT visible
- [X] All tests pass (`flutter test`)
- [X] Commit updated test

**Verification**: WIDGET  
**Mapping**: Plan requirement (bottom nav hidden on `/add-transaction`)

---

### Task 3.5: Widget Test - Localization

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing)

**What**: Test navigation labels use localized strings from ARB.

**Test Cases**:
1. **English locale**: Tab labels are "Home" and "Settings"
2. **Vietnamese locale**: Tab labels are "Sổ giao dịch" and "Cài đặt"

**Verification Method**:
- Set up widget test with specific `Locale` (EN or VI)
- Find `NavigationDestination` widgets
- Verify `label` property matches expected l10n string
- Use `tester.widget<NavigationDestination>(find.byType(NavigationDestination).at(0)).label`

**DoD**:
- [X] Test: EN locale → labels are "Home" / "Settings"
- [X] Test: VI locale → labels are "Sổ giao dịch" / "Cài đặt"
- [X] All tests pass (`flutter test`)
- [X] Commit updated test

**Verification**: WIDGET  
**Mapping**:
- User Story 3, Scenario 1 (localized labels, no hardcoded strings)
- FR-NAV-008 (localized labels)

---

### Task 3.6: Widget Test - Semantics and Accessibility

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing)

**What**: Test accessibility: FAB has semantic label, NavigationDestination widgets have labels for screen readers.

**Test Cases**:
1. **FAB semantic label**: FAB has `tooltip` matching `fabAddTransaction` l10n key
2. **NavigationDestination labels**: Each destination has `label` property set (for screen readers)

**Verification Method**:
- Use `SemanticsHandle handle = tester.ensureSemantics()`
- Find FAB: `tester.widget<FloatingActionButton>(find.byType(FloatingActionButton))`
- Verify `tooltip` property matches l10n string
- Find NavigationDestination widgets and verify `label` properties are set (not null/empty)
- Call `handle.dispose()` after test

**DoD**:
- [X] Test: FAB `tooltip` matches `context.l10n.fabAddTransaction`
- [X] Test: NavigationDestination widgets have non-empty `label` properties
- [X] All tests pass (`flutter test`)
- [X] Commit updated test

**Verification**: WIDGET  
**Mapping**:
- User Story 3, Scenario 2 (semantic labels for screen readers)
- FR-NAV-009 (semantic labels)
- SC-004 (accessibility: semantic labels)

---

### Task 3.7 (OPTIONAL): Widget Test - Rapid Tab Switching Stability

**File**: `test/core/router/scaffold_with_nav_bar_test.dart` (add to existing)

**What**: Test app stability under rapid tab switching (no crashes, correct state).

**Test Case**:
- Rapidly tap between Home and Settings tabs 20+ times
- Verify no exceptions thrown
- Verify final `selectedIndex` matches last tap

**Verification Method**:
- Loop 20 times: tap Home destination, pump, tap Settings destination, pump
- Wrap in try-catch or expect no exceptions
- Verify `selectedIndex` at end

**DoD**:
- [ ] Test: 20+ rapid taps between tabs → no exceptions, correct final state
- [ ] Test passes (`flutter test`)
- [ ] Commit updated test

**Verification**: WIDGET (optional robustness check)  
**Mapping**: Extra stability validation (not a specific FR, but good practice)

---

## Phase 4: Manual Verification

### Task 4.1: Manual Accessibility Checks

**What**: Verify touch targets and screen reader support on physical device or emulator.

**Manual Checklist**:
- [ ] **Touch Targets**: Tap each tab and FAB → all feel comfortable (≥48x48dp)
- [ ] **TalkBack (Android)**: Enable TalkBack:
  - [ ] Home tab announces "Home" (or "Sổ giao dịch" in VI) + selection state
  - [ ] Settings tab announces "Settings" (or "Cài đặt" in VI) + selection state
  - [ ] FAB announces "Add Transaction" (or "Giao dịch mới" in VI)
- [ ] **VoiceOver (iOS)**: Enable VoiceOver and verify same announcements as TalkBack
- [ ] **Visual Active State**: Active tab is clearly distinguishable (color/icon fill per Material 3 defaults)

**DoD**:
- [ ] All checklist items verified
- [ ] Document any issues found (create follow-up tasks if needed)
- [ ] Mark checklist complete

**Verification**: MANUAL  
**Mapping**:
- User Story 3, Scenario 2 (touch targets ≥48dp, screen reader support)
- FR-NAV-009 (touch targets + semantics)
- SC-004 (accessibility requirements)

---

### Task 4.2: Manual Visual and Interaction Checks

**What**: End-to-end manual smoke test of navigation flows.

**Manual Checklist**:
- [ ] **Launch**: App starts on Home with Home tab selected (visually active)
- [ ] **Tab Switching**: Tap Settings → navigates to Settings, Settings tab is visually active
- [ ] **Tab Switching**: Tap Home → navigates to Home, Home tab is visually active
- [ ] **FAB from Home**: On Home, tap FAB → navigates to Add Transaction
- [ ] **FAB from Settings**: On Settings, tap FAB → navigates to Add Transaction
- [ ] **Return to Home**: Home → FAB → Add Transaction → back button → returns to Home
- [ ] **Return to Settings**: Settings → FAB → Add Transaction → back button → returns to Settings
- [ ] **Bottom Nav Visibility**: On Home and Settings, bottom nav is visible; on Add Transaction, bottom nav is hidden
- [ ] **Localization (EN)**: Set device to English → tab labels "Home" / "Settings"
- [ ] **Localization (VI)**: Set device to Vietnamese → tab labels "Sổ giao dịch" / "Cài đặt"
- [ ] **FAB Visual**: FAB is visually distinct, centered, and prominent

**DoD**:
- [ ] All checklist items verified
- [ ] Any issues documented and follow-up tasks created if needed
- [ ] Mark checklist complete

**Verification**: MANUAL  
**Mapping**: Comprehensive smoke test covering all User Stories and Success Criteria

---

## Phase 5: Code Quality & PR Preparation

### Task 5.1: Code Formatting and Analysis

**What**: Ensure code meets Flutter quality standards.

**Steps**:
1. Run `dart format .` from project root
2. Run `flutter analyze` from project root
3. Fix any linter warnings/errors

**DoD**:
- [X] `dart format .` executed (code auto-formatted)
- [X] `flutter analyze` passes with zero issues
- [X] Commit any formatting fixes

**Verification**: CODE_REVIEW  
**Mapping**: Constitution 3.6 (Code Quality), 4.5 (Definition of Done)

---

### Task 5.2: Run All Tests

**What**: Verify all widget tests pass.

**Steps**:
1. Run `flutter test` from project root
2. Ensure all tests pass (0 failures)

**DoD**:
- [X] `flutter test` executed
- [X] All widget tests pass (Tasks 3.1-3.7)
- [X] If failures, fix and re-run until passing

**Verification**: WIDGET  
**Mapping**: Constitution 4.5 (Definition of Done)

---

### Task 5.3: Final Sanity Check

**What**: Final manual smoke test before PR submission.

**Manual Checklist**:
- [ ] App builds successfully (`flutter build apk --debug` or `flutter run`)
- [ ] No runtime errors on app launch
- [ ] Tab switching works (Home ↔ Settings)
- [ ] FAB opens Add Transaction from both tabs
- [ ] Back from Add Transaction returns to correct tab
- [ ] Bottom nav visibility correct (visible on Home/Settings, hidden on Add Transaction)
- [ ] Labels are localized (spot check EN and VI)

**DoD**:
- [ ] All sanity checks pass
- [ ] Ready to create PR

**Verification**: MANUAL  
**Mapping**: Constitution 4.5 (Manual sanity check requirement)

---

## Phase 6: PR Merge Gate

### Task 6.1: PR Merge Gate Checklist

**What**: Verify PR meets all constitution merge gate requirements (Section 7).

**PR Checklist** (Constitution Section 7, Merge Gate):
- [ ] `spec.md` / `plan.md` / `tasks.md` are in sync with code changes
- [ ] `tasks.md` has AC → verification mapping ✅ (see Summary table below)
- [ ] `dart format .` has been run ✅ (Task 5.1)
- [ ] `flutter analyze` passes ✅ (Task 5.1)
- [ ] `flutter test` passes ✅ (Task 5.2)
- [ ] No DB schema changes (N/A for navigation-only feature)
- [ ] Manual sanity check complete ✅ (Tasks 4.1, 4.2, 5.3)
- [ ] No new "kitchen sink" dependencies (only go_router, constitution-approved)
- [ ] Commit messages follow convention (e.g., "feat: implement app navigation shell")
- [ ] PR description references spec.md and summarizes implementation

**DoD**:
- [ ] All checklist items verified
- [ ] PR created with checklist in PR description
- [ ] Request review

**Verification**: CODE_REVIEW  
**Mapping**: Constitution Section 7 (Workflow & Quality Gates)

---

## Summary: FR/AC → Verification Mapping

| Requirement | Verification Method | Task(s) |
|-------------|---------------------|---------|
| **FR-NAV-001** (2 tabs: Home, Settings) | WIDGET | 3.1 |
| **FR-NAV-002** (center FAB) | CODE_REVIEW + WIDGET | 2.2, 3.2 |
| **FR-NAV-003** (Home tab → `/home`) | WIDGET | 3.1 |
| **FR-NAV-004** (Settings tab → `/settings`) | WIDGET | 3.1 |
| **FR-NAV-005** (FAB → `/add-transaction`) | WIDGET | 3.2 |
| **FR-NAV-006** (active tab indication) | WIDGET + MANUAL | 3.1, 4.2 |
| **FR-NAV-007** (return to previous tab) | WIDGET | 3.3 |
| **FR-NAV-008** (localized labels) | CODE_REVIEW + WIDGET | 1.1, 2.2, 3.5 |
| **FR-NAV-009** (touch targets ≥48dp, semantics) | WIDGET + MANUAL | 3.6, 4.1 |
| **User Story 1** (tab switching) | WIDGET | 3.1 |
| **User Story 2** (FAB navigation + return) | WIDGET | 3.2, 3.3 |
| **User Story 3** (localization + a11y) | WIDGET + MANUAL | 3.5, 3.6, 4.1 |
| **SC-001** (reach routes via 1 tap) | WIDGET | 3.1, 3.2 |
| **SC-002** (FAB access from main screens) | WIDGET | 3.2 |
| **SC-003** (active tab indication) | WIDGET + MANUAL | 3.1, 3.3, 4.2 |
| **SC-004** (accessibility requirements) | WIDGET + MANUAL | 3.6, 4.1 |
| **Bottom nav visibility** (plan requirement) | WIDGET | 3.4 |

---

## Implementation Notes

**File Paths** (consistent with plan.md):
- Router: `lib/core/router/app_router.dart`, `lib/core/router/scaffold_with_nav_bar.dart`
- Localization: `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`
- Placeholders: `lib/features/home/presentation/pages/home_page.dart`, etc.
- Tests: `test/core/router/scaffold_with_nav_bar_test.dart`

**Widget Test Verification Strategy**:
- Use `Key('page_home')`, `Key('page_settings')`, `Key('page_add_transaction')` to identify pages
- Use `NavigationBar.selectedIndex` to verify active tab
- **Do NOT read route strings** (unreliable in tests; use widget presence instead)
- Use `SemanticsTester` for a11y verification where needed

**Out of Scope** (MUST NOT implement):
- Deep linking behavior
- Tab state persistence across app restarts
- Unsaved-changes warnings
- Tablet navigation rail (adaptive navigation)
- Custom transitions/animations
- Performance timing metrics

**End of Tasks**
