---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- **Flutter Federated Plugin**: 
  - `[package_name]/lib/` for Dart code
  - `[package_name]/test/` for tests
  - `[package_name]_platform_interface/lib/` for contracts
  - `[package_name]_[platform]/lib/` and `[package_name]_[platform]/[platform]/` for native
- **Clean Architecture**: Within each package: `lib/[layer]/` where layer = ui, presenter, usecase, repository, external
- Paths shown below assume single project - adjust based on plan.md structure

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Setup database schema and migrations framework
- [ ] T005 [P] Implement authentication/authorization framework
- [ ] T006 [P] Setup API routing and middleware structure
- [ ] T007 Create base models/entities that all stories depend on
- [ ] T008 Configure error handling and logging infrastructure
- [ ] T009 Setup environment configuration management

**For Flutter Federated Plugins**:

- [ ] T004 Create platform interface package with abstract `[PluginName]Platform` class
- [ ] T005 [P] Define shared data models in platform interface (immutable, strongly-typed)
- [ ] T006 [P] Setup method channel contract definitions with versioning
- [ ] T007 Create app-facing package that delegates to platform interface
- [ ] T008 [P] Setup platform implementation package(s) with native code scaffolding
- [ ] T009 Configure package dependency graph and version constraints

**For Clean Architecture Layers**:

- [ ] T010 Define layer directory structure (external → repository → usecase → presenter → ui)
- [ ] T011 [P] Create repository interfaces (abstract classes in repository layer)
- [ ] T012 [P] Create usecase interfaces and base classes
- [ ] T013 Implement dependency injection setup (manual or using get_it/provider)
- [ ] T014 Setup layer boundary validation (analyzer rules or manual review checklist)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (MANDATORY per Constitution) ⚠️

> **CONSTITUTION REQUIREMENT: Test-First Development (Principle III)**
> **All tests MUST be written FIRST, verified to FAIL, approved, then implementation begins**

- [ ] T015 [P] [US1] Contract test for platform method channel in [package]_platform_interface/test/
- [ ] T016 [P] [US1] Integration test for UI→Native flow in [package]/test/integration/
- [ ] T017 [P] [US1] Unit test for UseCase layer logic in [package]/test/unit/[usecase]_test.dart
- [ ] T018 [P] [US1] Unit test for Repository layer in [package]/test/unit/[repository]_test.dart
- [ ] T019 [P] [US1] Mock implementation for testing without native dependencies
- [ ] T020 [US1] **VERIFY ALL TESTS FAIL** (red phase) before proceeding to implementation

### Implementation for User Story 1 (Clean Architecture: External → Repository → UseCase → Presenter → UI)

**Step 1: External Layer (Platform-specific)**

- [ ] T021 [P] [US1] Implement native method handler in [package]_[platform]/[platform]/
- [ ] T022 [P] [US1] Add parameter validation in native code
- [ ] T023 [US1] Register platform implementation with platform interface

**Step 2: Repository Layer (Abstraction)**

- [ ] T024 [P] [US1] Create data models in [package]/lib/repository/models/
- [ ] T025 [US1] Implement repository concrete class using platform interface
- [ ] T026 [US1] Add error mapping (PlatformException → domain exceptions)

**Step 3: UseCase Layer (Business Logic)**

- [ ] T027 [P] [US1] Create usecase class in [package]/lib/usecase/
- [ ] T028 [US1] Implement business logic and validation
- [ ] T029 [US1] Handle orchestration of repository calls

**Step 4: Presenter Layer (Presentation Logic)**

- [ ] T030 [P] [US1] Create presenter/ViewModel in [package]/lib/presenter/
- [ ] T031 [US1] Implement state management for UI
- [ ] T032 [US1] Format data for display (dimensions, status messages)

**Step 5: UI Layer (Flutter Widgets)**

- [ ] T033 [P] [US1] Create UI widgets in [package]/lib/ui/
- [ ] T034 [US1] Connect UI to presenter via state management
- [ ] T035 [US1] Handle user interactions (buttons, gestures)

**Verification**:

- [ ] T036 [US1] **RUN ALL TESTS** - verify they now PASS (green phase)
- [ ] T037 [US1] Verify no layer boundary violations (use grep or analyzer)
- [ ] T038 [US1] **REFACTOR** while keeping tests green

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T018 [P] [US2] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T019 [P] [US2] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create [Entity] model in src/models/[entity].py
- [ ] T021 [US2] Implement [Service] in src/services/[service].py
- [ ] T022 [US2] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T023 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T024 [P] [US3] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T025 [P] [US3] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 3

- [ ] T026 [P] [US3] Create [Entity] model in src/models/[entity].py
- [ ] T027 [US3] Implement [Service] in src/services/[service].py
- [ ] T028 [US3] Implement [endpoint/feature] in src/[location]/[file].py

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests (if requested) in tests/unit/
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
