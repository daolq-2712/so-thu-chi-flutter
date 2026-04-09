# Feature Specification: App Navigation (Shell)

**Feature Branch**: `000-app-navigation`  
**Created**: 2025-12-23  
**Status**: Draft  
**Scope**: App-level navigation shell only (Bottom Nav + Center (+) action)

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Switch between Home and Settings (P1)

Users need to move between the two main areas of the app: Home and Settings.

**Independent Test**: Launch app → tap tabs → verify correct screen/route and active state.

**Acceptance Scenarios**:
1. **Given** the bottom navigation is visible, **When** the user views it, **Then** it shows exactly 2 tabs: Home and Settings.
2. **Given** the user is on any screen where bottom navigation is visible, **When** the user taps Home tab, **Then** the app navigates to `/home` and Home tab shows selected state.
3. **Given** the user is on any screen where bottom navigation is visible, **When** the user taps Settings tab, **Then** the app navigates to `/settings` and Settings tab shows selected state.

---

### User Story 2 — Open Add Transaction via center (+) button (P1)

Users need a single, consistent entry point to create a new transaction from main screens.

**Independent Test**: From Home and Settings → tap (+) → verify `/add-transaction`.

**Acceptance Scenarios**:
1. **Given** the user is on `/home`, **When** the user taps center (+), **Then** the app navigates to `/add-transaction`.
2. **Given** the user is on `/settings`, **When** the user taps center (+), **Then** the app navigates to `/add-transaction`.
3. **Given** the user returns from `/add-transaction` (cancel or create), **When** the previous screen is shown, **Then** the app returns to the previously active tab (Home or Settings).

---

### User Story 3 — Localized labels & accessibility basics (P2)

Users need readable labels in their language and accessible touch targets for navigation.

**Acceptance Scenarios**:
1. **Given** the app is running, **When** the user views the bottom navigation, **Then** tab labels are localized (no hardcoded UI strings).
2. **Given** the bottom navigation is visible, **When** the user interacts with tabs and (+), **Then** each navigation element has a touch target ≥ 48x48dp and has semantic labels for screen readers.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-NAV-001**: System MUST display exactly 2 tabs in bottom navigation: Home and Settings.
- **FR-NAV-002**: System MUST provide a center (+) action button between the two tabs.
- **FR-NAV-003**: Tapping Home tab MUST navigate to `/home`.
- **FR-NAV-004**: Tapping Settings tab MUST navigate to `/settings`.
- **FR-NAV-005**: Tapping center (+) MUST navigate to `/add-transaction`.
- **FR-NAV-006**: System MUST visually indicate the active tab (selected state).
- **FR-NAV-007**: Returning from `/add-transaction` MUST return to the previously active tab.
- **FR-NAV-008**: Bottom navigation labels MUST be localized (l10n/ARB; no hardcoded UI strings).
- **FR-NAV-009**: Tabs and center (+) MUST have touch targets ≥ 48x48dp and provide semantic labels.

## Success Criteria *(mandatory)*
- **SC-001**: Users can reach `/home` and `/settings` via 1 tap on bottom navigation.
- **SC-002**: Users can reach `/add-transaction` via 1 tap on center (+) from Home and Settings.
- **SC-003**: Active tab is clearly indicated and consistent with current route.
- **SC-004**: Navigation elements meet minimum accessibility requirements (touch target + semantics).

## Assumptions & Decisions *(mandatory)*
- Routes exist in router config: `/home`, `/settings`, `/add-transaction`, `/settings/language`, `/settings/categories`.
- Bottom navigation is shown on main tabs (`/home`, `/settings`) in MVP.
- Localization infrastructure exists (EN/VI) and provides labels for Home/Settings and (+) semantics.

## Out of Scope *(mandatory)*
- Deep linking behavior requirements
- Persisting active tab across app restarts
- Unsaved-changes warning when leaving Add Transaction via tabs
- Tablet adaptive navigation (navigation rail)
- Custom animations/transitions beyond defaults
