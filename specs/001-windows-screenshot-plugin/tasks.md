---
description: "Task list for Windows Screenshot Plugin implementation"
---

# Tasks: Windows Screenshot Plugin

**Input**: Design documents from `/specs/001-windows-screenshot-plugin/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Per constitution Test-First Development (Principle III) - ALL tests are MANDATORY

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions (Flutter Federated Plugin)

- **Dart models**: `lib/src/models/`
- **Platform interface**: `lib/screenshot_platform_interface.dart`
- **Method channel**: `lib/screenshot_method_channel.dart`
- **Public API**: `lib/screenshot.dart`
- **Native Windows**: `windows/screenshot_plugin.cpp`, `windows/screenshot_plugin.h`
- **Tests**: `test/` (Dart), `windows/test/` (C++)
- **Example**: `example/lib/main.dart`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency setup

- [ ] T001 Verify Flutter SDK version 3.3.0+ and Dart 3.7.2+ installed
- [ ] T002 [P] Add plugin_platform_interface: ^2.0.2 to pubspec.yaml dependencies
- [ ] T003 [P] Add flutter_lints: ^5.0.0 to pubspec.yaml dev_dependencies
- [ ] T004 Configure analysis_options.yaml with strict linting rules
- [ ] T005 [P] Setup Windows C++ build configuration in windows/CMakeLists.txt for gtest
- [ ] T006 Update pubspec.yaml metadata (description, version 0.1.0, homepage)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Data Models (Shared Foundation)

- [ ] T007 [P] Create lib/src/models/screenshot_mode.dart with enum (screen, region) and serialization methods
- [ ] T008 [P] Create lib/src/models/captured_data.dart with immutable class (width, height, bytes) and validation
- [ ] T009 [P] Create lib/src/models/capture_request.dart with immutable class (mode, includeCursor, displayId) for internal use
- [ ] T010 [P] Create lib/src/models/screenshot_exception.dart with error codes (cancelled, not_supported, internal_error)

### Platform Interface

- [ ] T011 Create lib/screenshot_platform_interface.dart with abstract ScreenshotPlatform class
- [ ] T012 Add capture() abstract method to ScreenshotPlatform with typed parameters
- [ ] T013 Implement ScreenshotPlatform singleton pattern with verifyToken
- [ ] T014 Export data models from platform interface package

### Method Channel Implementation

- [ ] T015 Create lib/screenshot_method_channel.dart implementing ScreenshotPlatform
- [ ] T016 Implement MethodChannelScreenshot.capture() using channel 'dev.flutter.screenshot'
- [ ] T017 Add parameter serialization (CaptureRequest.toMap()) in method channel
- [ ] T018 Add response deserialization (CapturedData.fromMap()) in method channel
- [ ] T019 Add PlatformException → ScreenshotException error mapping

### Public API

- [ ] T020 Update lib/screenshot.dart with Screenshot singleton class
- [ ] T021 Implement Screenshot.capture() method delegating to ScreenshotPlatform
- [ ] T022 Export public models (ScreenshotMode, CapturedData, ScreenshotException)

### Native Windows Scaffolding

- [ ] T023 Update windows/screenshot_plugin.h with HandleMethodCall signature
- [ ] T024 Update windows/screenshot_plugin.cpp with method channel registration
- [ ] T025 [P] Add Win32 API includes (windows.h, wingdi.h, wincodec.h) to screenshot_plugin.cpp
- [ ] T026 [P] Setup Google Test framework in windows/test/CMakeLists.txt
- [ ] T027 Create windows/test/screenshot_plugin_test.cpp with MockMethodResult helper class

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Capture Full Screen Screenshot (Priority: P1) 🎯 MVP

**Goal**: Enable full screen capture with single API call, supporting cursor inclusion and primary display targeting

**Independent Test**: Call capture(mode: screen), verify returned image matches screen dimensions and contains valid pixel data

### Tests for User Story 1 (Test-First Development - RED Phase) ⚠️

**Dart Tests**:

- [ ] T028 [P] [US1] Create test/models/screenshot_mode_test.dart with enum serialization tests
- [ ] T029 [P] [US1] Create test/models/captured_data_test.dart with validation and equality tests
- [ ] T030 [P] [US1] Create test/screenshot_platform_interface_test.dart with default instance tests
- [ ] T031 [P] [US1] Create test/screenshot_method_channel_test.dart with mock channel for screen capture
- [ ] T032 [P] [US1] Create test/screenshot_test.dart with public API delegation tests
- [ ] T033 [US1] **VERIFY ALL DART TESTS FAIL** (flutter test) - RED phase confirmed

**Native C++ Tests**:

- [ ] T034 [P] [US1] Add TEST(ScreenshotPluginTest, HandleCaptureScreenMethod) in windows/test/screenshot_plugin_test.cpp
- [ ] T035 [P] [US1] Add TEST(ScreenshotPluginTest, InvalidModeReturnsError) in windows/test/screenshot_plugin_test.cpp
- [ ] T036 [P] [US1] Add TEST(ScreenshotPluginTest, CaptureScreenReturnsValidPngData) in windows/test/screenshot_plugin_test.cpp
- [ ] T037 [US1] **VERIFY ALL NATIVE TESTS FAIL** (ctest) - RED phase confirmed
- [ ] T038 [US1] **GET APPROVAL** for test coverage before proceeding to implementation

### Implementation for User Story 1 (Clean Architecture: External → Repository → Presenter → UI)

**External Layer (Native Windows - C++)**:

- [ ] T039 [US1] Implement HandleMethodCall in screenshot_plugin.cpp to parse 'capture' method
- [ ] T040 [US1] Add parameter extraction and validation (mode, includeCursor, displayId) from EncodableMap
- [ ] T041 [P] [US1] Implement CaptureScreen() function in screenshot_plugin.cpp using GetDC/BitBlt pattern
- [ ] T042 [P] [US1] Add GetSystemMetrics calls for screen width/height retrieval
- [ ] T043 [US1] Implement CreateCompatibleDC and CreateCompatibleBitmap for memory buffering
- [ ] T044 [US1] Implement BitBlt(SRCCOPY) to copy screen pixels to memory bitmap
- [ ] T045 [US1] Add cursor rendering logic using GetCursorInfo and DrawIconEx (if includeCursor=true)
- [ ] T046 [US1] Implement SetProcessDPIAware for correct DPI handling
- [ ] T047 [P] [US1] Implement PNG encoding using Windows Imaging Component (WIC) APIs
- [ ] T048 [P] [US1] Add WIC factory creation (IWICImagingFactory) and PNG encoder setup
- [ ] T049 [US1] Convert HBITMAP to IWICBitmap and encode to memory stream
- [ ] T050 [US1] Return EncodableMap with width, height, bytes to Dart via MethodResult::Success
- [ ] T051 [US1] Add error handling with MethodResult::Error for internal_error cases
- [ ] T052 [US1] Implement proper resource cleanup (DeleteObject, DeleteDC, ReleaseDC)

**Repository Layer (Platform Abstraction - Already Complete in Foundational)**:

- [x] Platform interface defined (T011-T014)
- [x] Method channel implemented (T015-T019)

**Presenter Layer (Public API - Already Complete in Foundational)**:

- [x] Screenshot singleton created (T020-T022)

**UI Layer (Example App)**:

- [ ] T053 [P] [US1] Update example/lib/main.dart with "Capture Screen" ElevatedButton
- [ ] T054 [US1] Implement _captureScreen() method calling screenshot.capture(mode: ScreenshotMode.screen)
- [ ] T055 [US1] Add state management to store CapturedData result
- [ ] T056 [US1] Display captured image using Image.memory(capturedData.bytes)
- [ ] T057 [US1] Display dimensions text widget showing "width x height"

### Verification for User Story 1 (GREEN Phase) ✅

- [ ] T058 [US1] Run flutter test - verify all Dart tests PASS (GREEN)
- [ ] T059 [US1] Run ctest --test-dir windows/build - verify all C++ tests PASS (GREEN)
- [ ] T060 [US1] Manual test: Run example app, click "Capture Screen", verify screenshot displays
- [ ] T061 [US1] Manual test: Verify cursor appears when includeCursor=true, absent when false
- [ ] T062 [US1] Manual test: Test on high DPI display (125%, 150%, 200%), verify correct dimensions
- [ ] T063 [US1] Verify no layer boundary violations (Screenshot → Platform → Native only)
- [ ] T064 [US1] **REFACTOR** code while keeping tests green (extract helper functions, clean up)

**Checkpoint**: User Story 1 complete - Full screen capture working and independently testable ✅

---

## Phase 4: User Story 2 - Select and Capture Screen Region (Priority: P2)

**Goal**: Enable user to select rectangular region via interactive overlay, capture only selected area

**Independent Test**: Invoke region capture, drag selection rectangle, verify only selected area captured

### Tests for User Story 2 (Test-First Development - RED Phase) ⚠️

**Dart Tests**:

- [ ] T065 [P] [US2] Add test for region mode in test/screenshot_method_channel_test.dart
- [ ] T066 [P] [US2] Add test for null return (cancellation) in test/screenshot_method_channel_test.dart
- [ ] T067 [US2] **VERIFY REGION TESTS FAIL** - RED phase confirmed

**Native C++ Tests**:

- [ ] T068 [P] [US2] Add TEST(ScreenshotPluginTest, CaptureRegionCreatesOverlay) in windows/test/screenshot_plugin_test.cpp
- [ ] T069 [P] [US2] Add TEST(ScreenshotPluginTest, RegionCaptureReturnsNullOnCancel) in windows/test/screenshot_plugin_test.cpp
- [ ] T070 [P] [US2] Add TEST(ScreenshotPluginTest, RegionCaptureHandlesReverseSelection) in windows/test/screenshot_plugin_test.cpp
- [ ] T071 [US2] **VERIFY NATIVE REGION TESTS FAIL** - RED phase confirmed
- [ ] T072 [US2] **GET APPROVAL** for test coverage before proceeding

### Implementation for User Story 2 (External Layer Focus)

**External Layer (Native Windows - Overlay Window)**:

- [ ] T073 [US2] Implement CaptureRegion() function in screenshot_plugin.cpp
- [ ] T074 [P] [US2] Create layered window class with WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW
- [ ] T075 [US2] Register window class for overlay with unique class name
- [ ] T076 [US2] Create fullscreen overlay window covering primary display
- [ ] T077 [US2] Set semi-transparent background using SetLayeredWindowAttributes (50% opacity)
- [ ] T078 [P] [US2] Implement WM_LBUTTONDOWN handler to capture start point (x0, y0)
- [ ] T079 [P] [US2] Implement WM_MOUSEMOVE handler to track current point and redraw selection rectangle
- [ ] T080 [P] [US2] Implement WM_PAINT handler to render highlighted selection rectangle
- [ ] T081 [US2] Implement WM_LBUTTONUP handler to capture end point (x1, y1) and close overlay
- [ ] T082 [US2] Implement WM_KEYDOWN handler for VK_ESCAPE to cancel and return null
- [ ] T083 [US2] Implement WM_RBUTTONDOWN handler to cancel and return null
- [ ] T084 [US2] Add selection rectangle normalization (handle bottom-right to top-left drag)
- [ ] T085 [US2] Validate selected region has positive width and height (min 1x1 pixels)
- [ ] T086 [US2] Call BitBlt with region coordinates (x, y, width, height) to capture selected area
- [ ] T087 [US2] Reuse PNG encoding logic from User Story 1 for region bytes
- [ ] T088 [US2] Return null via MethodResult::Success when user cancels (ESC/right-click)
- [ ] T089 [US2] Add proper overlay window cleanup and DestroyWindow

**UI Layer (Example App)**:

- [ ] T090 [P] [US2] Add "Capture Region" ElevatedButton in example/lib/main.dart
- [ ] T091 [US2] Implement _captureRegion() method calling screenshot.capture(mode: ScreenshotMode.region)
- [ ] T092 [US2] Handle null result (cancellation) with SnackBar message "Capture cancelled"
- [ ] T093 [US2] Display region capture result using same Image.memory widget

### Verification for User Story 2 (GREEN Phase) ✅

- [ ] T094 [US2] Run flutter test - verify region mode tests PASS
- [ ] T095 [US2] Run ctest - verify native overlay tests PASS
- [ ] T096 [US2] Manual test: Click "Capture Region", verify overlay appears
- [ ] T097 [US2] Manual test: Drag selection rectangle, verify real-time visual feedback
- [ ] T098 [US2] Manual test: Release mouse, verify overlay closes and region displays
- [ ] T099 [US2] Manual test: Press ESC during selection, verify returns null (no crash)
- [ ] T100 [US2] Manual test: Right-click during selection, verify cancels gracefully
- [ ] T101 [US2] Manual test: Drag from bottom-right to top-left, verify correct region captured
- [ ] T102 [US2] Manual test: Select very small region (5x5), verify valid capture
- [ ] T103 [US2] **REFACTOR** overlay code while keeping tests green

**Checkpoint**: User Story 2 complete - Region selection working independently ✅

---

## Phase 5: User Story 3 - Handle Capture Cancellation Gracefully (Priority: P3)

**Goal**: Provide clear feedback on cancellation, distinguish from errors, enable robust error handling

**Independent Test**: Trigger cancellation scenarios, verify API returns null consistently without exceptions

### Tests for User Story 3 (Test-First Development - RED Phase) ⚠️

**Dart Tests**:

- [ ] T104 [P] [US3] Add test for ScreenshotException in test/models/screenshot_exception_test.dart
- [ ] T105 [P] [US3] Add test for PlatformException → ScreenshotException mapping in test/screenshot_method_channel_test.dart
- [ ] T106 [P] [US3] Add test for error code distinction (cancelled vs internal_error) in test/screenshot_method_channel_test.dart
- [ ] T107 [US3] **VERIFY ERROR HANDLING TESTS FAIL** - RED phase confirmed

**Native C++ Tests**:

- [ ] T108 [P] [US3] Add TEST(ScreenshotPluginTest, InternalErrorReturnsCorrectCode) in windows/test/screenshot_plugin_test.cpp
- [ ] T109 [P] [US3] Add TEST(ScreenshotPluginTest, NotSupportedErrorForInvalidPlatform) in windows/test/screenshot_plugin_test.cpp
- [ ] T110 [US3] **VERIFY ERROR TESTS FAIL** - RED phase confirmed
- [ ] T111 [US3] **GET APPROVAL** for error handling coverage

### Implementation for User Story 3 (Error Handling Refinement)

**External Layer (Error Handling)**:

- [ ] T112 [P] [US3] Add try-catch for BitBlt failures, return MethodResult::Error("internal_error", "BitBlt failed", GetLastError())
- [ ] T113 [P] [US3] Add try-catch for WIC encoding failures, return MethodResult::Error("internal_error", "PNG encoding failed")
- [ ] T114 [US3] Add memory allocation failure checks, return MethodResult::Error("internal_error", "Memory allocation failed")
- [ ] T115 [US3] Add validation for invalid mode parameter, return MethodResult::Error("invalid_argument", "Invalid mode")
- [ ] T116 [US3] Document error codes in windows/screenshot_plugin.h header comments

**Repository Layer (Error Mapping - Already in Foundational)**:

- [x] PlatformException mapping implemented (T019)

**UI Layer (Example App Error Handling)**:

- [ ] T117 [P] [US3] Add try-catch in example/lib/main.dart around screenshot.capture() calls
- [ ] T118 [US3] Display SnackBar with error message on ScreenshotException
- [ ] T119 [US3] Distinguish cancellation (null) from errors (exception) in UI feedback

### Verification for User Story 3 (GREEN Phase) ✅

- [ ] T120 [US3] Run flutter test - verify error handling tests PASS
- [ ] T121 [US3] Run ctest - verify error code tests PASS
- [ ] T122 [US3] Manual test: Trigger cancellation (ESC), verify null returned without exception
- [ ] T123 [US3] Manual test: Simulate error condition, verify ScreenshotException with correct code
- [ ] T124 [US3] Review error messages for clarity and actionability
- [ ] T125 [US3] **REFACTOR** error handling while keeping tests green

**Checkpoint**: User Story 3 complete - All user stories functional with robust error handling ✅

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final quality checks

### Documentation

- [ ] T126 [P] Update README.md with installation instructions and usage examples
- [ ] T127 [P] Update CHANGELOG.md with version 0.1.0 initial release notes
- [ ] T128 [P] Add API documentation comments (dartdoc) to all public classes and methods
- [ ] T129 [P] Create LICENSE file if not present
- [ ] T130 Add inline code comments for complex Win32 API usage

### Code Quality

- [ ] T131 Run dart format lib/ test/ example/ and commit formatting
- [ ] T132 Run flutter analyze and fix all warnings/errors
- [ ] T133 [P] Run windows build and fix any C++ compiler warnings
- [ ] T134 Review and remove any dead code or commented-out code
- [ ] T135 Verify all TODO comments are resolved or tracked in issues

### Performance & Memory

- [ ] T136 Profile full screen capture time, verify <500ms @ 1920x1080
- [ ] T137 Profile overlay responsiveness, verify <16ms mouse tracking
- [ ] T138 Measure memory usage during capture, verify <100MB
- [ ] T139 Test on high-resolution displays (4K), verify performance acceptable
- [ ] T140 Add memory leak detection in native code (check all DeleteObject/DeleteDC calls)

### Edge Case Handling

- [ ] T141 Test screen resolution change during region selection, document behavior
- [ ] T142 Test multi-monitor scenarios (primary vs secondary display)
- [ ] T143 Test DPI scaling 100%, 125%, 150%, 200%, verify correct dimensions
- [ ] T144 Test partially off-screen selection, document/fix clipping behavior
- [ ] T145 Test with DRM content (if accessible), document limitations

### Security & Validation

- [ ] T146 Review parameter validation in native code for buffer overflows
- [ ] T147 Verify no sensitive data logged in debug output
- [ ] T148 Test with very large screenshots, verify no integer overflow
- [ ] T149 Add assertions for null pointer checks in native code

### Constitution Compliance Final Check

- [ ] T150 Verify all data models are immutable (const constructors, final fields)
- [ ] T151 Verify no dynamic types in public APIs
- [ ] T152 Verify test-first workflow followed (commit history shows tests before implementation)
- [ ] T153 Verify method channel contract matches contracts/method-channel-contract.md
- [ ] T154 Verify semver compliance (version 0.1.0 correct for initial release)
- [ ] T155 Verify no layer boundary violations (use grep to check imports)
- [ ] T156 Run all quickstart.md validation steps

### Final Integration Testing

- [ ] T157 Run full flutter test suite, verify 100% pass rate
- [ ] T158 Run full ctest suite, verify 100% pass rate
- [ ] T159 Test example app end-to-end on clean Windows machine
- [ ] T160 Verify pub publish --dry-run succeeds (if planning to publish)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - Can start after T027 complete
- **User Story 2 (Phase 4)**: Depends on Foundational - Can start after T027 complete (independent of US1)
- **User Story 3 (Phase 5)**: Depends on Foundational - Can start after T027 complete (independent of US1/US2)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent - Can start after Foundational (MVP candidate)
- **User Story 2 (P2)**: Independent - Can start after Foundational (parallel with US1 if staffed)
- **User Story 3 (P3)**: Independent - Can start after Foundational (parallel with US1/US2 if staffed)

### Within Each User Story (Constitution: Test-First)

1. **RED Phase**: Write all tests, verify they FAIL
2. **Approval Gate**: Get test coverage approved
3. **GREEN Phase**: Implement minimum code to pass tests
4. **Verification**: Run tests, verify they PASS
5. **REFACTOR Phase**: Improve code while keeping tests green

### Parallel Opportunities

**Phase 1 (Setup)**: T002, T003, T005 can run in parallel

**Phase 2 (Foundational)**:
- Data models: T007, T008, T009, T010 can run in parallel
- Native scaffolding: T025, T026 can run in parallel

**User Story 1 Tests**: T028-T032 (Dart), T034-T036 (C++) can run in parallel

**User Story 1 Implementation**: 
- T041, T042 (screen capture logic) parallel with T047, T048 (PNG encoding)
- T053, T054, T055 (example UI) can run parallel with native work

**User Story 2 Tests**: T065-T066 (Dart), T068-T070 (C++) can run in parallel

**User Story 2 Implementation**:
- T074, T075, T076 (overlay setup) can run parallel
- T078, T079, T080 (mouse handlers) can run parallel
- T090, T091, T092 (example UI) can run parallel with native work

**User Story 3 Tests**: T104-T106 (Dart), T108-T109 (C++) can run in parallel

**User Story 3 Implementation**:
- T112, T113, T114, T115 (error handling) can run in parallel
- T117, T118, T119 (UI error handling) can run in parallel

**Phase 6 (Polish)**:
- Documentation: T126, T127, T128, T129 can run in parallel
- Code quality: T133, T134 can run in parallel after T131, T132

---

## Parallel Example: User Story 1

```bash
# Step 1: Launch all Dart tests in parallel
Task T028: Create test/models/screenshot_mode_test.dart
Task T029: Create test/models/captured_data_test.dart
Task T030: Create test/screenshot_platform_interface_test.dart
Task T031: Create test/screenshot_method_channel_test.dart
Task T032: Create test/screenshot_test.dart

# Step 2: Launch all C++ tests in parallel
Task T034: Add HandleCaptureScreenMethod test
Task T035: Add InvalidModeReturnsError test
Task T036: Add CaptureScreenReturnsValidPngData test

# Step 3: After tests fail and are approved, implement in parallel
Task T041: Implement CaptureScreen() function
Task T047: Implement PNG encoding with WIC
Task T053: Update example app UI
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

**Minimum Viable Product**: Full screen screenshot capture

1. Complete Phase 1: Setup (T001-T006) → ~1 hour
2. Complete Phase 2: Foundational (T007-T027) → ~4-6 hours
3. Complete Phase 3: User Story 1 (T028-T064) → ~8-12 hours
4. **STOP and VALIDATE**: Test independently, demo to stakeholders
5. **Decision Point**: Ship MVP or continue to US2/US3

**Total MVP Estimate**: 1-2 days for experienced Flutter/Windows developer

### Incremental Delivery

**Iteration 1** (MVP): Setup + Foundational + User Story 1 → Full screen capture working
- Deploy/Demo/Get feedback
- Value delivered: Basic screenshot functionality

**Iteration 2**: Add User Story 2 (T065-T103) → Region selection added
- Deploy/Demo/Get feedback
- Value delivered: User-controlled selective capture

**Iteration 3**: Add User Story 3 (T104-T125) → Robust error handling
- Deploy/Demo/Get feedback
- Value delivered: Production-ready error handling

**Iteration 4**: Polish (T126-T160) → Production release
- Final quality checks
- Documentation complete
- Ready for pub.dev publication

### Parallel Team Strategy

With 2-3 developers and Foundational phase complete:

**Developer A**: User Story 1 (T028-T064) - Full screen capture
**Developer B**: User Story 2 (T065-T103) - Region selection
**Developer C**: User Story 3 (T104-T125) - Error handling

Stories can be integrated and tested independently, then merged together.

---

## Task Summary

**Total Tasks**: 160
- **Phase 1 (Setup)**: 6 tasks
- **Phase 2 (Foundational)**: 21 tasks (BLOCKS all user stories)
- **Phase 3 (User Story 1 - P1)**: 37 tasks (MVP)
- **Phase 4 (User Story 2 - P2)**: 39 tasks
- **Phase 5 (User Story 3 - P3)**: 22 tasks
- **Phase 6 (Polish)**: 35 tasks

**Parallelizable Tasks**: 58 tasks marked [P] (36% can run in parallel)

**MVP Scope** (Recommended first delivery):
- Phase 1: Setup (6 tasks)
- Phase 2: Foundational (21 tasks)
- Phase 3: User Story 1 (37 tasks)
- **Total**: 64 tasks for working full screen screenshot feature

**Independent Test Criteria**:
- User Story 1: Call capture(screen), verify image matches screen
- User Story 2: Invoke region mode, drag selection, verify region only
- User Story 3: Trigger cancellation, verify null return without exception

---

## Notes

- All tasks follow strict checklist format: `- [ ] [ID] [P?] [Story?] Description with file path`
- Test-First Development enforced: Tests (RED) → Approval → Implementation (GREEN) → Refactor
- Each user story is independently testable and deliverable
- Constitution compliance validated throughout (immutability, type safety, layer boundaries)
- Commit after each task or logical group for clear history
- Stop at any checkpoint to validate independently before continuing
