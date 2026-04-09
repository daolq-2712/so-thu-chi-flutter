# Spec Quality Checklist — App Navigation

**Purpose**: Validate spec completeness + scope discipline before `/speckit.plan`  
**Created**: 2025-12-23  
**Feature**: [spec.md](../spec.md)

## Content Quality (SDD-aligned)

- [ ] Requirements & Acceptance Scenarios are behavior-focused (no code/API/framework details)
- [ ] Any technical context (router/localization/material component names) appears ONLY in Assumptions/Dependencies
- [ ] Spec matches MVP scope for App Navigation shell ONLY (tabs + center (+) action)
- [ ] Avoids inventing new product behaviors not in constitution/mock (e.g., unsaved-changes warnings, deep link requirements)

## Requirement Completeness

- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous (route outcomes, selected state, presence of 2 tabs)
- [ ] Acceptance Scenarios cover the P1 flows:
  - tab switching (/home, /settings)
  - (+) opens /add-transaction
  - return from /add-transaction returns to previous tab
- [ ] Out of Scope section explicitly excludes:
  - deep linking requirements
  - session-persisted tab state
  - unsaved-changes warnings
  - tablet/adaptive navigation
- [ ] Dependencies/Assumptions are listed minimally (routes exist, l10n exists)

## Success Criteria Quality

- [ ] Success Criteria are binary/verifiable (avoid timing metrics like 100ms/200ms or “100% success rate”)
- [ ] Accessibility criteria are verifiable (touch target ≥48dp, semantics labels exist)

## Feature Readiness

- [ ] Spec is READY FOR PLANNING only if it does not include non-shell responsibilities (language change behavior, child screen behavior, deep link handling)
- [ ] FR set is minimal and maps cleanly to verification type (WIDGET/MANUAL/CODE_REVIEW)

---

## Validation Notes (Reviewer)

### What’s OK
- Shell navigation has clear P1 behaviors: 2 tabs + center (+).

### What must be removed or moved (if present)
- Timing/performance metrics in Success Criteria
- Deep link requirements
- Unsaved-changes warning behavior
- Framework-specific requirements in FR section (keep them in Assumptions/Dependencies)

---

## Final Status
- [ ] READY FOR PLANNING (`/speckit.plan`)
