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

**Verification Types** (per constitution): **WIDGET / MANUAL / UNIT**  
> Note: Feature is UI/router only → **WIDGET + MANUAL** are primary.

---

## Phase 1 — Localization & Placeholders

### Task 1.1 — Add navigation localization keys (MUST)

**Files**:
- `lib/core/l10n/app_en.arb`
- `lib/core/l10n/app_vi.arb`

**What**:
Add keys used by navigation shell:

- EN:
  - `navHome`: "Home"
  - `navSettings`: "Settings"
  - `fabAddTransaction`: "Add Transaction"

- VI:
  - `navHome`: "Sổ giao dịch"
  - `navSettings`: "Cài đặt"
  - `fabAddTransaction`: "Giao dịch mới"

**DoD**:
- [ ] Keys added in both ARB files
- [ ] l10n codegen runs successfully (no build errors)
- [ ] No widget hardcodes these labels

**Verification**: WIDGET (covered in Task 3.5)  
**Mapping**: FR-008, SC-003, SC-010

---

### Task 1.2 — Create minimal placeholder pages (MUST, infra only)

**Files**:
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/transaction/presentation/pages/add_transaction_page.dart`

**What**:
Create placeholder pages used only to validate routing.  
**Rule**: No hardcoded visible strings. Use `Key()` for test identification.

**DoD**:
- [ ] HomePage exists with `Key('page_home')`
- [ ] SettingsPage exists with `Key('page_settings')`
- [ ] AddTransactionPage exists with `Key('page_add_transaction')`
- [ ] Pages compile and can be routed to

**Verification**: WIDGET (implicitly via navigation tests)  
**Mapping**: Supports FR-003/004/005 tests

---

## Phase 2 — Shell Scaffold & Router

### Task 2.1 — Implement `ScaffoldWithNavBar` shell widget (MUST)

**File**: `lib/core/router/scaffold_with_nav_bar.dart`

**What**:
Create shell scaffold wrapping `StatefulNavigationShell`:
- `body: navigationShell`
- `NavigationBar` with 2 destinations (Home/Settings) using l10n labels
- FAB (+) navigates to `/add-transaction`
- Ensure semantic label for FAB from l10n

**KISS choices**:
- `floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat`  
  (no notch requirement in spec)

**DoD**:
- [ ] Exactly 2 tabs shown (Home, Settings) using l10n labels
- [ ] `onDestinationSelected` uses `navigationShell.goBranch(index)`
- [ ] FAB uses l10n semantics label `fabAddTransaction`
- [ ] Active tab indication works via Material 3 NavigationBar defaults

**Verification**: WIDGET (Tasks 3.1–3.6) + MANUAL (Task 4.x)  
**Mapping**: FR-001, FR-002, FR-006, FR-008, FR-009, FR-010, FR-011

---

### Task 2.2 — Configure go_router with StatefulShellRoute (MUST)

**File**: `lib/core/router/app_router.dart` (+ wire in `main.dart` if needed)

**What**:
- `initialLocation: '/home'`
- `StatefulShellRoute` with 2 branches:
  - `/home` → HomePage
  - `/settings` → SettingsPage
- Standalone route `/add-transaction` → AddTransactionPage (outside shell → hides bottom nav)
- Ensure back from AddTransaction returns to previous shell location (default pop behavior)

**DoD**:
- [ ] Router compiles and app launches
- [ ] `/home` and `/settings` are inside shell
- [ ] `/add-transaction` is outside shell (no bottom nav)
- [ ] Returning from `/add-transaction` restores previous tab

**Verification**: WIDGET  
**Mapping**: FR-003, FR-004, FR-005, FR-007, FR-012

---

## Phase 3 — Widget Tests (MUST)

> Test strategy: verify by **widget presence + NavigationBar.selectedIndex**, not by reading route strings.

**File**: `test/core/router/app_navigation_test.dart`

### Task 3.1 — Tab switching + active state (MUST)

**Cases**:
- Launch → HomePage visible + selectedIndex = 0
- Tap Settings → SettingsPage visible + selectedIndex = 1
- Tap Home → HomePage visible + selectedIndex = 0

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: FR-001, FR-003, FR-004, FR-006, SC-001

---

### Task 3.2 — FAB navigation to Add Transaction (MUST)

**Cases**:
- From Home → tap FAB → AddTransactionPage visible
- From Settings → tap FAB → AddTransactionPage visible

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: FR-002, FR-005, SC-002

---

### Task 3.3 — Return to previous tab (MUST)

**Cases**:
- Home → FAB → AddTransaction → pop → returns Home (HomePage visible + selectedIndex 0)
- Settings → FAB → AddTransaction → pop → returns Settings (SettingsPage visible + selectedIndex 1)

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: FR-007, FR-012, SC-006

---

### Task 3.4 — Bottom nav visibility (MUST)

**Cases**:
- On Home: `find.byType(NavigationBar)` = 1
- On Settings: `find.byType(NavigationBar)` = 1
- On AddTransaction: `find.byType(NavigationBar)` = 0

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: Plan requirement (“bottom nav hidden on /add-transaction”)

---

### Task 3.5 — Localization labels (MUST)

**Cases**:
- Pump app with locale EN → labels show "Home" + "Settings"
- Pump app with locale VI → labels show "Sổ giao dịch" + "Cài đặt"

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: FR-008, SC-003, SC-010

---

### Task 3.6 — Accessibility semantics (MUST)

Use `SemanticsTester` to verify:
- Tabs announce label + selected state (Material handles selected state)
- FAB has semantics label from l10n (`fabAddTransaction`)

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: FR-010, FR-009 (partially), SC-007

---

### Task 3.7 — Rapid tab switching stability (SHOULD)

Loop taps 20+ times switching tabs; assert no exceptions and final page matches expected.

**DoD**:
- [ ] Tests pass

**Verification**: WIDGET  
**Mapping**: FR-013, SC-009

---

## Phase 4 — Manual Checks (SHOULD)

### Task 4.1 — Manual a11y check (SHOULD)

Checklist:
- [ ] Touch targets feel comfortable (≥48dp) for tabs + FAB
- [ ] TalkBack/VoiceOver announces tab labels and FAB label (EN/VI)

**Verification**: MANUAL  
**Mapping**: FR-009, FR-010, SC-004, SC-007

---

### Task 4.2 — Manual smoke navigation (SHOULD)

Checklist:
- [ ] Start at Home
- [ ] Switch Home ↔ Settings
- [ ] FAB opens AddTransaction
- [ ] Back returns to previous tab
- [ ] Bottom nav hidden on AddTransaction

**Verification**: MANUAL  
**Mapping**: All P1 stories smoke

---

## Phase 5 — Quality Gate (MUST)

### Task 5.1 — Format + Analyze (MUST)
- [ ] `dart format .`
- [ ] `flutter analyze` clean

**Verification**: MANUAL  
**Mapping**: Constitution Merge Gate

### Task 5.2 — Run tests (MUST)
- [ ] `flutter test` all green

**Verification**: WIDGET  
**Mapping**: Constitution Merge Gate

### Task 5.3 — PR checklist (MUST)
- [ ] tasks/spec/plan in sync with code
- [ ] No scope creep features added
- [ ] Manual smoke completed (Task 4.2)

**Verification**: MANUAL  
**Mapping**: Constitution Merge Gate

---

## AC/FR → Verification Summary

| Item | Verification | Covered By |
|------|-------------|------------|
| FR-001, FR-003, FR-004, FR-006 | WIDGET | 3.1 |
| FR-002, FR-005 | WIDGET | 3.2 |
| FR-007, FR-012 | WIDGET | 3.3 |
| Bottom nav hidden on AddTransaction | WIDGET | 3.4 |
| FR-008 | WIDGET | 3.5 |
| FR-010 (+ part of FR-009) | WIDGET | 3.6 |
| FR-013 | WIDGET | 3.7 |
| Touch target comfort | MANUAL | 4.1 |

**End of Tasks**
