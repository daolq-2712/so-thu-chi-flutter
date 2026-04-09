# Implementation Plan: App Navigation (Shell)

**Branch**: `000-app-navigation`  
**Date**: 2025-12-23  
**Spec**: [spec.md](spec.md)

## Summary

Implement the MVP navigation shell:
- Bottom navigation with exactly 2 tabs: Home (`/home`) and Settings (`/settings`)
- Center (+) action opens Add Transaction (`/add-transaction`)
- Active tab state matches current route
- Returning from `/add-transaction` returns to the previously active tab
- Bottom navigation is visible only on `/home` and `/settings` (hidden on `/add-transaction`)

## Technical Context

- **Flutter**: Material 3 UI
- **Routing**: go_router (constitution-approved)
- **Localization**: l10n/ARB (EN/VI)
- **Accessibility**: touch target ≥ 48dp, semantics labels

> Non-goals for this feature: deep links, session-persisted tab state, unsaved-changes warnings, custom transitions, tablet nav rail.

## Constitution Check (SDD gates)

- ✅ Scope control: only shell navigation behaviors
- ✅ KISS: minimal router + shell scaffold
- ✅ l10n: no hardcoded labels
- ✅ a11y: ≥48dp + semantics
- ✅ Testing: widget tests cover P1 acceptance scenarios

## In-Scope Routes

| Route | Screen | Bottom Nav Visible | Notes |
|------|--------|-------------------|------|
| `/home` | HomePage (placeholder) | ✅ | Shell tab 1 |
| `/settings` | SettingsPage (placeholder) | ✅ | Shell tab 2 |
| `/add-transaction` | AddTransactionPage (placeholder) | ❌ | Standalone page/modal |

## Referenced Routes (implemented by other features)

- `/settings/language`
- `/settings/categories`

## Router Structure (go_router)

### Recommended Structure

Use `StatefulShellRoute` with 2 branches (Home, Settings) and a standalone route for Add Transaction:

- Shell wraps `/home` and `/settings` → provides bottom navigation
- `/add-transaction` is outside the shell → bottom nav hidden
- `initialLocation`: `/home`

### Previous Tab Rule

Rely on `StatefulShellRoute` branch tracking:
- When user taps (+), navigate to `/add-transaction`
- When user pops/closes `/add-transaction`, router returns to the previous shell branch automatically
- No manual global state is required

## UI Composition

### Shell Widget: `ScaffoldWithNavBar`

Responsibilities:
- Render current shell branch content via `navigationShell`
- Render Material 3 bottom navigation with 2 destinations (Home, Settings)
- Render center (+) primary action that navigates to `/add-transaction`
- Ensure active tab indication matches current branch index

Notes:
- FAB placement should be centered and Material 3 compliant (exact layout can be chosen during implementation)
- If layout is customized, ensure touch target ≥48dp for tabs and (+)

## Localization

- Labels MUST come from l10n/ARB (no hardcoded strings):
  - `navHome`
  - `navSettings`
  - `fabAddTransaction` (semantics label)

## Accessibility (a11y)

- Tabs and (+) MUST have:
  - touch target ≥48x48dp
  - semantic labels (screen reader reads label + selected state where applicable)

## Testing Strategy

### Widget Tests (MUST)
Cover P1 behaviors:

1) Tab switching
- Tap Home tab → route `/home` and Home selected
- Tap Settings tab → route `/settings` and Settings selected

2) (+) navigation
- From `/home`: tap (+) → route `/add-transaction`
- From `/settings`: tap (+) → route `/add-transaction`

3) Return behavior
- From Home → (+) → back → returns to Home
- From Settings → (+) → back → returns to Settings

4) Shell visibility
- `/home` and `/settings`: bottom nav visible
- `/add-transaction`: bottom nav hidden

### Manual Checks (SHOULD)
- Active tab visually clear
- Screen reader announces labels for tabs and (+)
- Touch targets feel comfortable (≥48dp)

## Project Structure (minimal)

- `lib/core/router/app_router.dart` (go_router config)
- `lib/core/router/scaffold_with_nav_bar.dart` (shell scaffold)
- l10n ARB keys added to existing l10n folder
- Placeholder pages referenced by route table (real content implemented in their feature specs)

## Explicit Out of Scope

- Deep link requirements
- Persist active tab across app restarts
- Unsaved-changes warning flows
- Custom transitions/animations
- Tablet adaptive navigation
- Performance timing metrics
