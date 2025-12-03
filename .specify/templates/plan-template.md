# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] **Clean Architecture Layers**: Feature respects dependency order (ui → presenter → usecase → repository → external)
- [ ] **Federated Plugin Pattern**: Platform-specific code isolated in separate packages (if applicable)
- [ ] **Test-First Development**: Tests written before implementation, all tests pass
- [ ] **Platform Contracts**: Method channel contracts defined and versioned (if platform code involved)
- [ ] **Type Safety**: All data models are immutable, strongly-typed, with validation
- [ ] **Layer Boundaries**: No cross-layer jumps; each layer uses only the layer directly below
- [ ] **Platform Interface**: Changes follow semver (MAJOR for breaking, MINOR for additions)

**Constitution Version Checked Against**: 1.0.0

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]

# [REMOVE IF UNUSED] Option 4: Flutter Federated Plugin (Clean Architecture)
# Use this for Flutter plugins with platform-specific implementations

# App-facing package (public API)
screenshot/
├── lib/
│   ├── screenshot.dart              # Public API
│   ├── src/
│   │   ├── models/                  # Shared data models
│   │   └── screenshot_base.dart     # Delegates to platform interface
└── test/
    └── screenshot_test.dart

# Platform interface package (contracts)
screenshot_platform_interface/
├── lib/
│   ├── screenshot_platform_interface.dart  # Abstract platform class
│   └── src/
│       ├── models/                         # Shared models (CapturedData, etc.)
│       └── method_channel_screenshot.dart  # Default MethodChannel impl
└── test/

# Platform implementation packages (one per platform)
screenshot_windows/
├── lib/
│   └── screenshot_windows.dart      # Windows registration
├── windows/
│   └── screenshot_windows_plugin.cpp # Native C++ implementation
└── test/
    └── screenshot_windows_test.dart

screenshot_android/  # Future
screenshot_ios/      # Future
screenshot_macos/    # Future
screenshot_linux/    # Future

# Clean Architecture Layers (within each package where applicable):
# - ui/           : Flutter widgets, UI state
# - presenter/    : Presentation logic, formatters
# - usecase/      : Business logic orchestration
# - repository/   : Platform abstraction, data sources
# - external/     : Platform channels, native code
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
