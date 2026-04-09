# Tasks: Settings Screen

**Input**: Design documents from `/specs/001-settings-screen/`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `contracts/` (optional), `research.md` (optional), `data-model.md` (optional)

**Tests**: Included because spec defines explicit acceptance scenarios and independent tests.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependency)
- **[Story]**: User story label (`[US1]`, `[US2]`)
- Every task includes exact file path(s)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare localization and test baseline for Settings screen.

- [X] T001 Validate required dependencies in `source/pubspec.yaml` (`go_router`, `flutter_localizations`, `intl`)
- [X] T002 Ensure localization generation config in `source/l10n.yaml` is available for ARB updates
- [X] T003 [P] Add settings keys in `source/lib/l10n/app_en.arb` and `source/lib/l10n/app_vi.arb` (`settingsLanguage`, `settingsCategories`)
- [X] T004 Generate localization outputs referenced by `source/lib/l10n/app_localizations.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build reusable UI and router baseline required by both user stories.

**⚠️ CRITICAL**: User story work starts only after this phase completes.

- [X] T005 Create reusable navigation tile widget in `source/lib/features/settings/presentation/widgets/settings_tile.dart`
- [X] T006 Create base Settings page scaffold in `source/lib/features/settings/presentation/pages/settings_page.dart`
- [X] T007 Register `/settings` route and verify dependencies for `/settings/language` and `/settings/categories` in `source/lib/core/router/app_router.dart`
- [X] T008 Create widget test harness and router test app in `source/test/features/settings/presentation/pages/settings_page_test.dart`

**Checkpoint**: Foundation completed; user stories can proceed.

---

## Phase 3: User Story 1 - Navigate to Language (Priority: P1) 🎯 MVP

**Goal**: User can open Language screen from Settings.

**Independent Test**: Tap "Ngôn ngữ" tile and verify navigation to `/settings/language`.

### Tests for User Story 1

- [X] T009 [P] [US1] Add navigation test for tapping Language tile in `source/test/features/settings/presentation/pages/settings_page_test.dart`
- [X] T010 [P] [US1] Add localization test for Language tile label (EN/VI) in `source/test/features/settings/presentation/pages/settings_page_test.dart`
- [X] T011 [US1] Add touch-target accessibility test (>=48x48dp) for Language tile in `source/test/features/settings/presentation/pages/settings_page_test.dart`

### Implementation for User Story 1

- [X] T012 [US1] Implement Language tile as first item in `source/lib/features/settings/presentation/pages/settings_page.dart`
- [X] T013 [US1] Bind Language tile text to ARB localization in `source/lib/features/settings/presentation/pages/settings_page.dart`
- [X] T014 [US1] Wire Language tile tap to `/settings/language` in `source/lib/features/settings/presentation/pages/settings_page.dart`

**Checkpoint**: US1 independently functional and testable.

---

## Phase 4: User Story 2 - Navigate to Manage Categories (Priority: P1)

**Goal**: User can open Manage Categories screen from Settings.

**Independent Test**: Tap "Quản lý thể loại" tile and verify navigation to `/settings/categories`.

### Tests for User Story 2

- [X] T015 [P] [US2] Add navigation test for tapping Manage Categories tile in `source/test/features/settings/presentation/pages/settings_page_test.dart`
- [X] T016 [P] [US2] Add localization test for Manage Categories label (EN/VI) in `source/test/features/settings/presentation/pages/settings_page_test.dart`
- [X] T017 [US2] Add touch-target accessibility test (>=48x48dp) for Manage Categories tile in `source/test/features/settings/presentation/pages/settings_page_test.dart`

### Implementation for User Story 2

- [X] T018 [US2] Implement Manage Categories tile as second item in `source/lib/features/settings/presentation/pages/settings_page.dart`
- [X] T019 [US2] Bind Manage Categories tile text to ARB localization in `source/lib/features/settings/presentation/pages/settings_page.dart`
- [X] T020 [US2] Wire Manage Categories tile tap to `/settings/categories` in `source/lib/features/settings/presentation/pages/settings_page.dart`

**Checkpoint**: US2 independently functional and testable.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening and verification across stories.

- [X] T021 [P] Add rapid-repeated-tap no-crash test in `source/test/features/settings/presentation/pages/settings_page_test.dart`
- [X] T022 Fix analyzer/test issues in `source/lib/features/settings/presentation/pages/settings_page.dart`, `source/lib/features/settings/presentation/widgets/settings_tile.dart`, and `source/test/features/settings/presentation/pages/settings_page_test.dart`
- [X] T023 [P] Update manual verification checklist and AC mapping in `specs/001-settings-screen/tasks.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Starts immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1; blocks all user stories.
- **Phase 3 (US1)**: Depends on Phase 2.
- **Phase 4 (US2)**: Depends on Phase 2; can proceed after or alongside US1, but same page file suggests sequence to reduce conflicts.
- **Phase 5 (Polish)**: Depends on selected user stories being complete.

### User Story Dependencies

- **US1 (P1)**: Independent after foundational phase.
- **US2 (P1)**: Independent after foundational phase; shares `settings_page.dart` with US1.

### Within Each User Story

- Tests first (fail), then implementation, then pass.
- Validate independent test criteria before moving on.

---

## Parallel Opportunities

- Setup: `T003` and `T004` can run in parallel after `T001-T002`.
- US1: `T009` and `T010` are parallelizable.
- US2: `T015` and `T016` are parallelizable.
- Polish: `T021` and `T023` are parallelizable.

## Parallel Example: User Story 1

```bash
Task: T009 [US1] Add Language navigation test in source/test/features/settings/presentation/pages/settings_page_test.dart
Task: T013 [US1] Bind Language tile localization in source/lib/features/settings/presentation/pages/settings_page.dart
```

## Parallel Example: User Story 2

```bash
Task: T015 [US2] Add Categories navigation test in source/test/features/settings/presentation/pages/settings_page_test.dart
Task: T019 [US2] Bind Categories tile localization in source/lib/features/settings/presentation/pages/settings_page.dart
```

---

## Implementation Strategy

### MVP First (P1 Stories)

1. Complete Phase 1 and Phase 2.
2. Deliver US1 and validate independently.
3. Deliver US2 and validate independently.
4. Stop and demo once both P1 stories pass.

### Incremental Delivery

1. Setup + Foundational baseline.
2. Add US1 (Language navigation).
3. Add US2 (Manage Categories navigation).
4. Finalize with polish phase.

### Team Strategy

1. Dev A: implementation in `settings_page.dart` and `settings_tile.dart`.
2. Dev B: tests in `settings_page_test.dart`.
3. Merge at phase checkpoints to avoid same-file conflicts.

---

## Manual Verification Checklist

- [X] Open Settings screen and verify exactly 2 tiles are shown
- [X] Verify first tile is Language and second tile is Manage Categories
- [X] Tap Language tile and verify navigation to `/settings/language`
- [X] Tap Manage Categories tile and verify navigation to `/settings/categories`
- [X] Switch locale EN/VI and verify both labels are localized
- [X] Confirm each tile touch target is at least 48dp high
- [X] Rapidly tap tiles multiple times and verify app does not crash

## AC to Verification Mapping

- [X] AC-US1-1 (`/settings/language` navigation): WIDGET (`settings_page_test.dart` navigation test)
- [X] AC-US1-2 (Language label localized): WIDGET (`settings_page_test.dart` localization test)
- [X] AC-US1-3 (Language tile >=48x48): WIDGET (`settings_page_test.dart` touch target test)
- [X] AC-US2-1 (`/settings/categories` navigation): WIDGET (`settings_page_test.dart` navigation test)
- [X] AC-US2-2 (Categories label localized): WIDGET (`settings_page_test.dart` localization test)
- [X] AC-US2-3 (Categories tile >=48x48): WIDGET (`settings_page_test.dart` touch target test)
- [X] Edge Case (rapid repeated taps no crash): WIDGET (`settings_page_test.dart` rapid tap test)
