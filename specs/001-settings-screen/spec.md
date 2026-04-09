# Feature Specification: Settings Screen

**Feature Branch**: `001-settings-screen`  
**Created**: 2025-12-22  
**Status**: Draft  
**Scope**: ONLY Settings root screen (menu navigation)

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Navigate to Language (Priority: P1)
Users can open Language settings from Settings screen.

**Independent Test**: Tap “Ngôn ngữ” tile → app navigates to `/settings/language`.

**Acceptance Scenarios**
1. **Given** user is on Settings screen, **When** user taps the “Ngôn ngữ” tile, **Then** app navigates to route `/settings/language`.  
2. **Given** Settings screen renders, **Then** the “Ngôn ngữ” tile label is localized via ARB (no hardcoded strings).  
3. **Given** Settings screen renders, **Then** the “Ngôn ngữ” tile has an accessible touch target (≥ 48x48 dp).

---

### User Story 2 — Navigate to Manage Categories (Priority: P1)
Users can open Manage Categories from Settings screen.

**Independent Test**: Tap “Quản lý thể loại” tile → app navigates to `/settings/categories`.

**Acceptance Scenarios**
1. **Given** user is on Settings screen, **When** user taps the “Quản lý thể loại” tile, **Then** app navigates to route `/settings/categories`.  
2. **Given** Settings screen renders, **Then** the “Quản lý thể loại” tile label is localized via ARB (no hardcoded strings).  
3. **Given** Settings screen renders, **Then** the “Quản lý thể loại” tile has an accessible touch target (≥ 48x48 dp).

---

### Edge Case (MVP)
- Rapid repeated taps on a tile MUST NOT crash the app (navigation may execute once or multiple times, but no crash).

## Requirements *(mandatory)*

### Functional Requirements
- **FR-SET-001**: Settings screen MUST display exactly two navigation options: “Ngôn ngữ” and “Quản lý thể loại”.
- **FR-SET-002**: “Ngôn ngữ” MUST be displayed as the first tile (top).
- **FR-SET-003**: “Quản lý thể loại” MUST be displayed as the second tile (below).
- **FR-SET-004**: Tapping “Ngôn ngữ” MUST navigate to `/settings/language`.
- **FR-SET-005**: Tapping “Quản lý thể loại” MUST navigate to `/settings/categories`.
- **FR-SET-006**: All visible texts on Settings MUST be sourced from ARB localization files.
- **FR-SET-007**: Each tile MUST have touch target ≥ 48x48 dp.

### Key Entities
- None (Settings is navigation-only)

## Success Criteria *(mandatory)*
- **SC-SET-001**: Settings shows exactly 2 tiles and both navigate to the correct routes.
- **SC-SET-002**: Settings labels are localized (EN/VI) via ARB with no hardcoded strings.
- **SC-SET-003**: Tiles satisfy minimum touch target accessibility guideline (≥ 48x48 dp).

## Assumptions & Decisions *(mandatory)*
1. App uses `go_router` and routes exist: `/settings`, `/settings/language`, `/settings/categories`.
2. Settings is a navigation-only screen (no Cubit/BLoC required).
3. UI layout follows provided mock: two large tappable tiles, stacked vertically.

## Out of Scope *(mandatory)*
- Any other settings options (profile, theme, backup, export, about, help…)
- Any inline toggle settings on this screen
- Version/build info on Settings screen
