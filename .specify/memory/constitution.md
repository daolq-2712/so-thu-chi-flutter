<!--
SYNC IMPACT REPORT - Constitution Update
================================================================================
Version Change: INITIAL → 1.0.0
Change Type: MAJOR (Initial constitution ratification)
Date: 2025-12-18

Principles Established:
  ✓ I. Code Quality Standards (NEW)
  ✓ II. Testing Standards (NEW)
  ✓ III. User Experience Consistency (NEW)
  ✓ IV. Performance Requirements (NEW)

Sections Added:
  ✓ Flutter Technology Stack
  ✓ Development Workflow & Quality Gates

Template Validation Status:
  ✅ plan-template.md - Compatible (standard structure supports Flutter projects)
  ✅ spec-template.md - Compatible (user story format aligns with UX principle)
  ✅ tasks-template.md - Compatible (TDD approach aligns with testing principle)

Follow-Up Actions:
  - All templates validated and compatible with new constitution
  - No template modifications required
  - Ready for feature development following these principles

================================================================================
-->

# Sổ Thu Chi Constitution

## Core Principles

### I. Code Quality Standards

**MUST Requirements**:
- **Clean Architecture**: Separation of concerns across presentation (UI), business logic (BLoC/Cubit), and data layers (repositories, data sources)
- **SOLID Principles**: Single responsibility per widget/class; dependency injection via constructor; prefer composition over inheritance
- **Dart Best Practices**: Null-safety enforced; explicit typing for public APIs; const constructors where applicable; effective linting (flutter_lints)
- **Code Organization**: Feature-based folder structure; maximum 300 lines per file; clear naming conventions (verb+noun for methods, noun for classes)
- **Documentation**: Public APIs must have dartdoc comments; complex business logic requires inline explanations; README per feature module

**Rationale**: Flutter apps grow complex quickly. Clean architecture prevents technical debt, ensures testability, and enables team scalability. Consistent code quality reduces bugs and accelerates feature development.

---

### II. Testing Standards

**MUST Requirements**:
- **Test-First Development**: Write widget tests BEFORE implementing UI; write unit tests BEFORE implementing business logic
- **Coverage Targets**: Minimum 80% code coverage for business logic (BLoC/Cubit); minimum 70% for data layer; critical user flows must have integration tests
- **Test Categories**:
  - **Unit Tests**: All BLoC states/events, repository methods, utility functions, validators
  - **Widget Tests**: All screens and reusable widgets with user interaction scenarios
  - **Integration Tests**: Critical user journeys (e.g., add transaction → save → display in list)
  - **Golden Tests**: Key UI components to detect visual regressions
- **Test Pyramid**: Majority unit tests (fast), moderate widget tests, minimal integration tests (slow but comprehensive)
- **CI/CD Gates**: All tests MUST pass before merge; coverage cannot decrease; performance tests for large lists (1000+ items)

**Rationale**: Flutter's hot reload encourages rapid iteration but can hide bugs. Test-first ensures features work as specified and prevents regressions. High coverage builds confidence for refactoring.

---

### III. User Experience Consistency

**MUST Requirements**:
- **Design System**: Single source of truth for colors, typography, spacing (define in theme); use Material Design 3 components consistently
- **Responsive Design**: Support phone (portrait/landscape), tablet, and foldable devices; test on smallest (320x568) and largest common screens
- **Accessibility**: Semantic labels for screen readers; minimum touch target 48x48 dp; color contrast ratio ≥4.5:1; support system font scaling
- **User Feedback**: Loading states (shimmer/skeleton screens), error messages (user-friendly + actionable), success confirmations (snackbars), empty states (illustrations + CTAs)
- **Navigation**: Consistent patterns (bottom nav for main sections, tabs for categories, modal sheets for forms); predictable back button behavior
- **Offline Support**: Local-first approach; sync when online; clear indicators for offline mode; queue failed operations for retry

**Rationale**: Expense tracking is a daily habit app. Consistent UX builds trust and reduces cognitive load. Accessibility ensures inclusivity. Offline support is critical for financial apps used anywhere.

---

### IV. Performance Requirements

**MUST Requirements**:
- **Rendering**: 60 fps (16ms per frame) for scrolling lists and animations; 120 fps on ProMotion displays
- **Startup Time**: Cold start <2s on mid-range devices (e.g., Pixel 6); warm start <500ms
- **Memory**: <150 MB baseline; <250 MB peak with 1000 transactions loaded; no memory leaks (test with DevTools)
- **Database Operations**: Queries <100ms for <10K records; batch inserts for bulk operations; indexed fields for frequent queries
- **Asset Optimization**: Images compressed (WebP preferred); use svg for icons; lazy load images; cache network images
- **Build Size**: APK <20 MB (before split-apks); use code splitting for non-critical features; tree-shaking enabled
- **Profiling**: Profile BEFORE implementing optimizations; measure impact; use DevTools for timeline, memory, and network analysis

**Rationale**: Financial apps must be fast and reliable. Users expect instant response when adding expenses. Poor performance damages trust. Flutter's performance capabilities are wasted without discipline.

---

## Flutter Technology Stack

**Framework**: Flutter 3.x (stable channel); Dart 3.x with null-safety  
**State Management**: BLoC pattern (flutter_bloc) for complex state; Cubit for simple screens; Provider for dependency injection  
**Storage**: 
- Local: sqflite (relational data), hive (key-value cache), shared_preferences (settings)
- Remote: Firebase Firestore (real-time sync) OR REST API + Dio (http client)

**Navigation**: go_router (declarative routing with deep linking support)  
**Testing**: 
- flutter_test (widget/unit), integration_test (e2e)
- mocktail (mocking), golden_toolkit (screenshot tests)

**Code Quality**: 
- flutter_lints (official lint rules)
- dart format (auto-formatting)
- import_sorter (organize imports)

**CI/CD**: GitHub Actions (run tests, check coverage, build APK/IPA)  
**Analytics**: Firebase Analytics (user behavior), Crashlytics (crash reporting)  
**Performance**: Firebase Performance Monitoring OR custom metrics

---

## Development Workflow & Quality Gates

**Feature Development Flow**:
1. **Specification**: Use `/speckit.specify` to create detailed spec with user scenarios
2. **Planning**: Use `/speckit.plan` to design architecture (layers, entities, state flows)
3. **Test Creation**: Write tests for acceptance scenarios BEFORE implementation
4. **Implementation**: Implement feature incrementally (TDD: red → green → refactor)
5. **Review**: Code review checks constitution compliance (checklist below)
6. **Validation**: Run full test suite + manual testing on physical devices

**Quality Gates** (MUST pass before merge):
- [ ] All tests pass (unit, widget, integration)
- [ ] Code coverage meets minimums (80% business logic, 70% data layer)
- [ ] Linting passes with zero warnings
- [ ] Performance profiling shows no regressions (if UI/data-heavy feature)
- [ ] Accessibility audit passes (screen reader, contrast, touch targets)
- [ ] Code review approved by minimum 1 peer
- [ ] Responsive design tested on 3+ screen sizes
- [ ] Offline behavior tested (if feature uses network)

**Versioning & Releases**:
- **Semantic Versioning**: MAJOR.MINOR.PATCH (e.g., 1.2.3)
- **MAJOR**: Breaking changes to data models (requires migration)
- **MINOR**: New features, non-breaking improvements
- **PATCH**: Bug fixes, performance optimizations
- **Build Number**: Auto-increment on each release (e.g., 1.2.3+42)

---

## Governance

**Authority**: This constitution supersedes all informal practices. When conflicts arise, constitution principles win.

**Amendment Process**:
1. Propose change via `/speckit.constitution` command with rationale
2. Document impact on existing features and templates
3. Update version following semantic rules (see Versioning section)
4. Propagate changes to affected templates and documentation
5. Announce to team with migration guidance if backward-incompatible

**Compliance Review**:
- All feature specs (spec.md) MUST reference relevant principles
- All implementation plans (plan.md) include "Constitution Check" gate
- All pull requests verify compliance via quality gates checklist
- Quarterly audits of codebase for principle adherence

**Version**: 1.0.0 | **Ratified**: 2025-12-18 | **Last Amended**: 2025-12-18
