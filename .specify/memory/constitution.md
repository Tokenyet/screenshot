<!--
SYNC IMPACT REPORT (Generated: 2025-12-03)
==============================================
Version Change: INITIAL → 1.0.0
Change Type: MAJOR (Initial constitution ratification)

Principles Defined:
  ✅ I. Clean Architecture Layers
  ✅ II. Federated Plugin Pattern
  ✅ III. Test-First Development (NON-NEGOTIABLE)
  ✅ IV. Platform Method Channel Contracts
  ✅ V. Type Safety & Data Models

Sections Added:
  ✅ Technology Stack
  ✅ Development Workflow

Templates Requiring Updates:
  ⚠ plan-template.md - Update constitution check gates
  ⚠ spec-template.md - Ensure architecture layer requirements
  ⚠ tasks-template.md - Add federated plugin task patterns

Follow-up TODOs:
  - None (all placeholders resolved)

==============================================
-->

# Screenshot Plugin Constitution

## Core Principles

### I. Clean Architecture Layers

**STRICT dependency order MUST be enforced**: `ui → presenter → usecase → repository → external`

- **UI Layer**: Flutter widgets, platform channels (method channel calls only)
- **Presenter Layer**: State management, UI logic, data formatting for display
- **UseCase Layer**: Business logic, orchestration of repository calls
- **Repository Layer**: Data source abstraction, platform interface implementations
- **External Layer**: Platform-specific native code (Windows C++, future Android/iOS)

**Rules**:
- NO layer may depend on layers above it in the hierarchy
- Each layer MUST define explicit interfaces for the layer below
- Cross-layer jumps (e.g., UI → Repository) are FORBIDDEN
- Platform code MUST only be accessed through Repository layer

**Rationale**: Clean separation prevents tight coupling, enables independent testing of each layer, and makes platform-specific code swappable without affecting business logic.

### II. Federated Plugin Pattern

**All platform implementations MUST follow Flutter's federated plugin architecture**:

- **Platform Interface Package** (`screenshot_platform_interface`):
  - Defines abstract `ScreenshotPlatform` class
  - Contains shared data models (`CapturedData`, `ScreenshotMode`, etc.)
  - Uses `plugin_platform_interface` package for verification
  - NO platform-specific code

- **Platform Implementation Packages** (`screenshot_windows`, future `screenshot_android`, etc.):
  - Implements platform interface for specific platform
  - Declares `implements: screenshot` in `pubspec.yaml`
  - Contains native code (C++, Kotlin, Swift, etc.)
  - Self-registers with platform interface

- **App-Facing Package** (`screenshot`):
  - Public API that apps depend on
  - Delegates to `ScreenshotPlatform.instance`
  - NO direct platform code
  - Version increments trigger platform package updates

**Rules**:
- Platform interface MUST NOT contain platform-specific dependencies
- Each platform implementation MUST be independently testable
- Breaking changes in interface require MAJOR version bump
- New platform support added as new package, not modifications to existing

**Rationale**: Federated pattern enables independent platform development, allows apps to depend only on needed platforms, and maintains clear boundaries between abstract contracts and concrete implementations.

### III. Test-First Development (NON-NEGOTIABLE)

**TDD is MANDATORY for all code changes**:

**Process**:
1. Write test(s) for desired functionality
2. Verify tests FAIL (red phase)
3. Get user/reviewer approval of test coverage
4. Implement minimum code to pass tests (green phase)
5. Refactor while keeping tests green
6. Commit only when all tests pass

**Rules**:
- NO production code without corresponding tests written FIRST
- Tests MUST fail before implementation begins
- Contract tests MUST be written for all platform channel method calls
- Integration tests REQUIRED for: UI → Native flow, platform interface changes
- Unit tests REQUIRED for: UseCase logic, data model transformations, repository abstractions
- Mock implementations REQUIRED for testing without native dependencies

**Coverage Requirements**:
- Minimum 80% code coverage for all layers
- 100% coverage for UseCase and Repository layers
- All public API methods MUST have tests

**Rationale**: Test-first ensures specifications are clear before implementation, prevents regression, validates clean architecture boundaries, and documents expected behavior.

### IV. Platform Method Channel Contracts

**All communication between Dart and native code MUST use explicit, versioned contracts**:

**Contract Definition**:
- Method name (e.g., `"capture"`)
- Input parameters with types (e.g., `{"mode": "region", "includeCursor": false}`)
- Return type structure (e.g., `{"width": int, "height": int, "bytes": Uint8List}`)
- Error codes and messages
- Version compatibility matrix

**Rules**:
- All method channel calls MUST be defined in `screenshot_platform_interface`
- Parameter maps MUST use strongly-typed data models (no raw `Map<String, dynamic>`)
- Native code MUST validate all incoming parameters
- Return values MUST match documented structure exactly
- Errors MUST use `PlatformException` with standard error codes
- Contract changes MUST follow semver (add = MINOR, change = MAJOR)

**Documentation**:
- Each method MUST document expected platform behavior
- Platform-specific limitations MUST be noted
- Example request/response MUST be provided

**Rationale**: Explicit contracts prevent runtime errors from type mismatches, enable safe evolution of platform code, and serve as executable documentation of platform requirements.

### V. Type Safety & Data Models

**ALL data MUST be represented by explicit, immutable, strongly-typed models**:

**Model Requirements**:
- Immutable classes (use `const` constructors where possible)
- NO `dynamic` types in public APIs or cross-layer boundaries
- Explicit validation in constructors or factory methods
- `toMap()` and `fromMap()` methods for serialization
- `copyWith()` method for modifications
- Override `==`, `hashCode`, and `toString()` for value semantics

**Examples**:
```dart
class CapturedData {
  const CapturedData({
    required this.width,
    required this.height,
    required this.bytes,
  }) : assert(width > 0), assert(height > 0);

  final int width;
  final int height;
  final Uint8List bytes;

  Map<String, Object> toMap() => {...};
  static CapturedData fromMap(Map<Object?, Object?> map) => {...};
}
```

**Rules**:
- NO primitive obsession (wrap primitives in domain types when they carry meaning)
- Enums MUST be used for fixed sets of values (e.g., `ScreenshotMode`)
- Nullable types MUST be explicit (`int?` not `int` with null checks)
- Validation MUST happen at model boundaries (constructor/factory)
- Models MUST be in separate files (`models/` directory in each layer)

**Rationale**: Strong typing catches errors at compile time, immutability prevents bugs from shared state, explicit models document data structure and enable IDE support.

## Technology Stack

**Required Technologies**:

- **Language**: Dart 3.7.2+, Flutter 3.3.0+ (as defined in `pubspec.yaml`)
- **Platform Interface**: `plugin_platform_interface: ^2.0.2`
- **Native Code**: Windows C++ (Win32 API for screenshot capture)
- **Testing**: `flutter_test` (SDK), `mockito` or `mocktail` for mocking
- **Linting**: `flutter_lints: ^5.0.0`

**Prohibited**:
- Direct platform channel usage in UI layer (MUST go through Repository)
- Third-party screenshot libraries (defeats federated plugin purpose)
- Mutable global state
- Reflection or code generation for core models (manual serialization REQUIRED for clarity)

**Future Platform Support**:
- macOS: Objective-C/Swift + Quartz framework
- Linux: C++ + X11/Wayland
- Android: Kotlin + MediaProjection API
- iOS: Swift + UIGraphicsImageRenderer

## Development Workflow

**Feature Development Process**:

1. **Specification** (`.specify/templates/spec-template.md`):
   - Define user stories with acceptance criteria
   - Identify affected architecture layers
   - List required data models and platform contracts

2. **Planning** (`.specify/templates/plan-template.md`):
   - Pass Constitution Check before proceeding
   - Define contract changes if platform interface affected
   - Identify test requirements per layer

3. **Tasks** (`.specify/templates/tasks-template.md`):
   - Phase 0: Write tests (contract, integration, unit)
   - Phase 1: Verify tests fail
   - Phase 2: Implement layer by layer (external → repository → usecase → presenter → ui)
   - Phase 3: Refactor with green tests

**Pull Request Requirements**:
- All tests MUST pass (CI enforced)
- No layer boundary violations (manual review)
- Contract documentation updated if platform interface changed
- Version bumped according to semver

**Code Review Checklist**:
- [ ] Tests written before implementation
- [ ] Clean architecture layers respected
- [ ] Platform interface changes properly versioned
- [ ] Data models immutable and strongly typed
- [ ] No direct platform code outside repository layer

## Governance

**This constitution is the SUPREME AUTHORITY for all development decisions.**

**Amendment Process**:
1. Propose change with rationale in issue/PR
2. Document impact on existing code and templates
3. Require approval from 2+ maintainers
4. Update constitution version following semver:
   - **MAJOR**: Principle removed or incompatible change (e.g., abandon clean architecture)
   - **MINOR**: New principle added or existing one expanded
   - **PATCH**: Clarification, typo fix, non-semantic change
5. Update all affected templates and documentation
6. Provide migration guide if breaking changes

**Compliance**:
- All PRs MUST verify compliance with constitution
- Violations MUST be justified and documented as technical debt
- Accumulated violations trigger mandatory refactoring sprint

**Version**: 1.0.0 | **Ratified**: 2025-12-03 | **Last Amended**: 2025-12-03
