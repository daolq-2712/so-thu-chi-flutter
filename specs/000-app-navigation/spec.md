# Feature Specification: App Navigation

**Feature Branch**: `000-app-navigation`  
**Created**: 2025-12-23  
**Status**: Draft  
**Input**: User description: "Bottom navigation with 2 tabs (Home at /home, Settings at /settings) and center FAB (+) button to navigate to /add-transaction. Must support Material 3, localization EN/VI, accessibility with 48x48dp touch targets, and proper visual indication of active tab."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Switch Between Main Screens (Priority: P1)

As a user, I need to navigate between the two main areas of the app (Home and Settings) to access different functionality. This is the core navigation pattern that enables users to move through the application.

**Why this priority**: This is the foundation of the app structure. Without it, users cannot access any features. The bottom navigation provides the primary app structure that all other features depend on.

**Independent Test**: Can be fully tested by launching the app, tapping the Home tab to verify navigation to `/home`, tapping the Settings tab to verify navigation to `/settings`, and confirming the active tab is visually indicated. Delivers basic app navigation structure.

**Acceptance Scenarios**:

1. **Given** the app is launched, **When** the user views the bottom navigation, **Then** exactly 2 tabs are displayed (Home and Settings)
2. **Given** the user is on any screen, **When** the user taps the Home tab, **Then** the app navigates to `/home` route and the Home tab is visually highlighted
3. **Given** the user is on any screen, **When** the user taps the Settings tab, **Then** the app navigates to `/settings` route and the Settings tab is visually highlighted
4. **Given** the user is on the Home tab, **When** they view the bottom bar, **Then** the Home tab shows active state (highlighted/selected indicator)
5. **Given** the user is on the Settings tab, **When** they view the bottom bar, **Then** the Settings tab shows active state (highlighted/selected indicator)

---

### User Story 2 - Create New Transaction via FAB (Priority: P1)

As a user, I need quick access to add a new transaction from anywhere in the app. The center FAB provides this persistent action that is the primary user workflow for recording financial data.

**Why this priority**: Adding transactions is the primary action in a finance tracking app. This must be easily accessible from all main screens to reduce friction in the core user workflow.

**Independent Test**: Can be fully tested by tapping the center (+) FAB button from any main screen and verifying navigation to `/add-transaction`. Delivers the critical "add transaction" entry point.

**Acceptance Scenarios**:

1. **Given** the user is on any main screen (Home or Settings), **When** they tap the center FAB (+) button, **Then** the app navigates to `/add-transaction` route
2. **Given** the bottom navigation is displayed, **When** the user views it, **Then** the center FAB button is visually distinct (elevated, prominent) from the tabs
3. **Given** the user completes or cancels the transaction form, **When** they return from `/add-transaction`, **Then** they return to the previously active tab (Home or Settings maintains state)

---

### User Story 3 - Localized Navigation Labels (Priority: P2)

As a user, I need to see navigation labels in my preferred language (English or Vietnamese) so I can understand and use the app in my native language.

**Why this priority**: Supports the bilingual user base requirement. While critical for non-English speakers, the navigation structure itself (icons + layout) provides basic usability even without labels in the correct language.

**Independent Test**: Can be fully tested by changing the app language setting between EN and VI, then verifying all navigation labels (tab names, FAB semantics) update immediately without restart. Delivers complete localization support.

**Acceptance Scenarios**:

1. **Given** the app language is set to English, **When** the user views the bottom navigation, **Then** tabs display "Home" and "Settings" in English
2. **Given** the app language is set to Vietnamese, **When** the user views the bottom navigation, **Then** tabs display "Sổ giao dịch" and "Cài đặt" in Vietnamese
3. **Given** the user changes language from English to Vietnamese, **When** the navigation is displayed, **Then** all labels update immediately (no app restart required)
4. **Given** the user changes language from Vietnamese to English, **When** the navigation is displayed, **Then** all labels update immediately (no app restart required)

---

### User Story 4 - Accessible Navigation (Priority: P2)

As a user with accessibility needs, I need properly sized touch targets and semantic labels so I can navigate the app comfortably and with assistive technologies.

**Why this priority**: Ensures inclusive design and compliance with accessibility standards. While important for all users, particularly critical for users with motor or visual impairments.

**Independent Test**: Can be fully tested by measuring touch targets (≥48x48dp), verifying semantic labels exist for screen readers, and testing navigation with TalkBack/VoiceOver enabled. Delivers WCAG-compliant navigation.

**Acceptance Scenarios**:

1. **Given** the bottom navigation is displayed, **When** measured, **Then** each tab has a touch target of at least 48x48dp
2. **Given** the bottom navigation is displayed, **When** measured, **Then** the center FAB has a touch target of at least 48x48dp
3. **Given** a screen reader is enabled, **When** the user focuses on the Home tab, **Then** the screen reader announces the tab name and current state (selected/not selected)
4. **Given** a screen reader is enabled, **When** the user focuses on the Settings tab, **Then** the screen reader announces the tab name and current state (selected/not selected)
5. **Given** a screen reader is enabled, **When** the user focuses on the center FAB, **Then** the screen reader announces "Add Transaction" or localized equivalent

---

### Edge Cases

- **Deep linking to specific tabs**: What happens when the app is launched via a deep link directly to `/settings`? The Settings tab should be active and visually indicated.
- **Back button from Add Transaction**: When the user navigates to `/add-transaction` from Home, then presses the system back button, they should return to Home (not exit the app).
- **Rapid tab switching**: When the user rapidly taps between Home and Settings tabs, the app should maintain stability without crashes or incorrect state.
- **Navigation during transaction creation**: When the user is on the Add Transaction screen and taps a bottom tab (Home or Settings), the current screen should either warn about unsaved changes or dismiss the transaction form.
- **Language change while navigating**: When the user changes language while on a specific tab, the navigation labels update but the current route/tab remains active.
- **Orientation change**: When the device orientation changes, the bottom navigation layout adapts appropriately and maintains the active tab state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display exactly 2 tabs in the bottom navigation bar labeled "Home" (Sổ giao dịch) and "Settings" (Cài đặt)
- **FR-002**: System MUST provide a center FAB button marked with a (+) icon positioned between the two tabs
- **FR-003**: System MUST navigate to `/home` route when the Home tab is tapped
- **FR-004**: System MUST navigate to `/settings` route when the Settings tab is tapped
- **FR-005**: System MUST navigate to `/add-transaction` route when the center FAB button is tapped
- **FR-006**: System MUST visually indicate the currently active tab with distinct styling (e.g., color change, icon fill, underline, or other Material 3 active state)
- **FR-007**: System MUST maintain the active tab state when returning from the Add Transaction screen
- **FR-008**: System MUST update all navigation labels when the app language is changed between English (EN) and Vietnamese (VI)
- **FR-009**: System MUST provide touch targets of at least 48x48dp for all navigation elements (both tabs and FAB)
- **FR-010**: System MUST provide semantic labels for accessibility (screen readers) for each tab and the FAB button
- **FR-011**: System MUST follow Material 3 design specifications for bottom navigation bars and floating action buttons
- **FR-012**: System MUST preserve navigation state across screen transitions within the app
- **FR-013**: System MUST handle rapid tab switching without crashes or state corruption
- **FR-014**: System MUST integrate with go_router for declarative routing

### Key Entities *(include if feature involves data)*

This feature is primarily UI/navigation and does not introduce new domain entities. It works with:

- **NavigationState**: The current active tab/route (managed by go_router)
- **LocaleSettings**: Language preference (EN/VI) stored in shared_preferences (referenced from existing architecture)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can switch between Home and Settings tabs with a single tap, with visual feedback within 100ms
- **SC-002**: Users can access the Add Transaction screen from any main screen with a single tap of the FAB button
- **SC-003**: 100% of navigation labels display correctly in both English and Vietnamese based on user's language preference
- **SC-004**: All navigation touch targets meet or exceed 48x48dp minimum size for comfortable interaction
- **SC-005**: The active tab is clearly distinguishable from inactive tabs through visual styling (verified through user testing or design review)
- **SC-006**: Navigation state is preserved when users navigate to Add Transaction and return, maintaining their previous context
- **SC-007**: Navigation functions correctly with screen readers enabled, with all elements properly announced
- **SC-008**: Tab switching completes without perceptible lag (< 200ms) under normal device conditions
- **SC-009**: Zero crashes or incorrect state after rapid tab switching (tested with 20+ rapid taps)
- **SC-010**: Language change reflects in navigation labels immediately without requiring app restart

## Assumptions *(mandatory)*

1. **Router Configuration**: The go_router package is already configured with routes for `/home`, `/settings`, and `/add-transaction` as specified in the constitution (section 3.4)

2. **Localization Infrastructure**: The app already has flutter_localizations and intl configured with ARB files for English and Vietnamese, as mandated by constitution section 3.5

3. **Material 3 Theme**: A Material 3 theme is already configured in the app, providing standard colors, typography, and component styles (constitution section 5)

4. **Language Persistence**: Language preference is already being stored in shared_preferences and accessible throughout the app (constitution sections 2.1.D and 3.3)

5. **Navigation Bar Style**: The bottom navigation follows Material 3 NavigationBar component pattern with standard styling (icons above labels for tabs, standard FAB positioning)

6. **FAB Placement**: The FAB is positioned in the center cutout of the bottom bar, creating a notched effect typical of Material Design patterns

7. **Default Route**: The app launches to `/home` route by default, making Home the initial active tab

8. **Icon Assets**: Standard Material Icons are available for Home and Settings tabs. The icon keys will be specified during planning phase

9. **Screen Reader Support**: Flutter's default Semantics widgets provide adequate accessibility labels when properly configured

10. **Navigation Persistence**: Tab state persistence across app sessions is NOT required for MVP - the app always starts at Home tab regardless of which tab was active when previously closed

11. **Transition Animations**: Standard route transitions provided by go_router are acceptable; custom animations are out of scope for MVP

12. **Tablet/Large Screen**: Bottom navigation layout is acceptable for tablets; adaptive navigation (navigation rail) is out of scope for MVP

## Decisions *(mandatory)*

### Navigation Pattern Choice

**Decision**: Use bottom navigation bar with 2 tabs + center FAB instead of drawer, top tabs, or other patterns.

**Rationale**: 
- Aligns with constitution section 2.1.A requirement
- Material 3 bottom navigation is ideal for 2-5 primary destinations
- Center FAB emphasizes the primary action (add transaction) 
- Thumb-reachable on mobile devices
- Consistent with modern mobile finance app patterns

### Route Structure

**Decision**: Use flat routes (`/home`, `/settings`, `/add-transaction`) rather than nested routes.

**Rationale**:
- Simplifies routing configuration for MVP
- Each screen is a top-level destination
- Add Transaction is modal-like (returns to previous tab, not nested under it)
- Matches go_router best practices for bottom navigation

### Active Tab Indication

**Decision**: Use Material 3 NavigationBar's built-in active state styling (colored icon + label) rather than custom indicators.

**Rationale**:
- Consistent with Material 3 design system
- Reduces custom code and maintenance
- Automatically handles color theming
- Meets accessibility contrast requirements

### FAB Behavior During Navigation

**Decision**: FAB remains visible and accessible on both Home and Settings screens; it is hidden when navigating to Add Transaction screen.

**Rationale**:
- Provides consistent access to primary action from main screens
- Prevents duplicate/confusing CTAs on Add Transaction form
- Standard Material Design pattern

### Language Change Behavior

**Decision**: Language changes apply immediately to navigation labels without app restart, but rely on existing language change mechanism from Settings screen.

**Rationale**:
- Constitution section 3.5 mandates immediate language updates
- Navigation feature doesn't implement language switching logic itself
- Reactive to existing locale provider/state management

### Tab State Across Sessions

**Decision**: Do NOT persist which tab was active across app restarts; always launch to Home tab.

**Rationale**:
- Simplifies state management for MVP
- Home is the primary entry point for transaction viewing
- Reduces complexity and potential edge cases
- Can be enhanced post-MVP if user testing shows need

### Back Button Behavior

**Decision**: System back button from Add Transaction returns to the previously active tab (Home or Settings). System back button on Home tab exits the app.

**Rationale**:
- Standard Android/iOS navigation pattern
- Maintains user context
- go_router handles this automatically with proper configuration
