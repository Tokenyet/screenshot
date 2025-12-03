# Quickstart Guide: Windows Screenshot Plugin

**Feature**: Windows Screenshot Plugin  
**Date**: December 3, 2025  
**Target Audience**: Developers implementing the feature

## Overview

This guide provides step-by-step instructions for implementing the Windows Screenshot Plugin. Follow the phases in order, adhering to the Test-First Development principle from the constitution.

---

## Prerequisites

**Development Environment**:
- Flutter 3.3.0+ (Dart 3.7.2+)
- Windows 10+ (development machine)
- Visual Studio 2019+ with C++ desktop development workload
- Git for version control

**Knowledge Requirements**:
- Dart language and Flutter plugin development
- C++ and Win32 API basics
- MethodChannel communication pattern
- Google Test (gtest) for C++ testing

**Branch**: `001-windows-screenshot-plugin` (already created)

---

## Phase 0: Setup & Research ✅ (Complete)

**Status**: ✅ Complete

**Outputs**:
- ✅ `specs/001-windows-screenshot-plugin/spec.md` - Feature specification
- ✅ `specs/001-windows-screenshot-plugin/plan.md` - Implementation plan
- ✅ `specs/001-windows-screenshot-plugin/research.md` - Technical research
- ✅ `specs/001-windows-screenshot-plugin/data-model.md` - Data model definitions
- ✅ `specs/001-windows-screenshot-plugin/contracts/` - Platform contracts
- ✅ `specs/001-windows-screenshot-plugin/quickstart.md` - This file

**Constitution Check**: ✅ Passed (see plan.md)

---

## Phase 1: Write Tests (Test-First Development)

**Principle**: Tests MUST be written BEFORE implementation and MUST fail initially.

### 1.1 Create Data Model Tests

**File**: `test/models/screenshot_mode_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/src/models/screenshot_mode.dart';

void main() {
  group('ScreenshotMode', () {
    test('toValue returns correct string', () {
      expect(ScreenshotMode.screen.toValue(), 'screen');
      expect(ScreenshotMode.region.toValue(), 'region');
    });

    test('fromValue creates correct enum', () {
      expect(ScreenshotMode.fromValue('screen'), ScreenshotMode.screen);
      expect(ScreenshotMode.fromValue('region'), ScreenshotMode.region);
    });

    test('fromValue throws on invalid value', () {
      expect(
        () => ScreenshotMode.fromValue('invalid'),
        throwsArgumentError,
      );
    });
  });
}
```

**File**: `test/models/captured_data_test.dart`

```dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/src/models/captured_data.dart';

void main() {
  group('CapturedData', () {
    test('constructor validates width > 0', () {
      expect(
        () => CapturedData(width: 0, height: 100, bytes: Uint8List(10)),
        throwsAssertionError,
      );
    });

    test('constructor validates height > 0', () {
      expect(
        () => CapturedData(width: 100, height: 0, bytes: Uint8List(10)),
        throwsAssertionError,
      );
    });

    test('constructor validates bytes not empty', () {
      expect(
        () => CapturedData(width: 100, height: 100, bytes: Uint8List(0)),
        throwsAssertionError,
      );
    });

    test('toMap serializes correctly', () {
      final data = CapturedData(
        width: 1920,
        height: 1080,
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      final map = data.toMap();
      expect(map['width'], 1920);
      expect(map['height'], 1080);
      expect(map['bytes'], isA<Uint8List>());
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'width': 1920,
        'height': 1080,
        'bytes': Uint8List.fromList([1, 2, 3]),
      };

      final data = CapturedData.fromMap(map);
      expect(data.width, 1920);
      expect(data.height, 1080);
      expect(data.bytes.length, 3);
    });

    test('equality works correctly', () {
      final data1 = CapturedData(
        width: 100,
        height: 100,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final data2 = CapturedData(
        width: 100,
        height: 100,
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
    });
  });
}
```

**Run Tests** (should FAIL - models don't exist yet):
```bash
flutter test test/models/
```

### 1.2 Create Platform Interface Tests

**File**: `test/screenshot_platform_interface_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot_platform_interface.dart';
import 'package:screenshot/src/models/screenshot_mode.dart';

class TestScreenshotPlatform extends ScreenshotPlatform {
  @override
  Future<CapturedData?> capture({
    required ScreenshotMode mode,
    bool includeCursor = false,
    int? displayId,
  }) async {
    return null; // Test implementation
  }
}

void main() {
  group('ScreenshotPlatform', () {
    test('default instance throws UnimplementedError', () {
      final platform = ScreenshotPlatform.instance;
      expect(
        () => platform.capture(mode: ScreenshotMode.screen),
        throwsUnimplementedError,
      );
    });

    test('can set custom instance', () {
      final testPlatform = TestScreenshotPlatform();
      ScreenshotPlatform.instance = testPlatform;
      expect(ScreenshotPlatform.instance, same(testPlatform));
    });
  });
}
```

### 1.3 Create Method Channel Tests

**File**: `test/screenshot_method_channel_test.dart`

```dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot_method_channel.dart';
import 'package:screenshot/src/models/screenshot_mode.dart';
import 'package:screenshot/src/models/captured_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelScreenshot', () {
    const channel = MethodChannel('dev.flutter.screenshot');
    final platform = MethodChannelScreenshot();
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        log.add(call);
        
        if (call.method == 'capture') {
          final args = call.arguments as Map;
          if (args['mode'] == 'screen') {
            return {
              'width': 1920,
              'height': 1080,
              'bytes': Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]),
            };
          } else if (args['mode'] == 'region') {
            return null; // Simulated cancellation
          }
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('capture screen sends correct arguments', () async {
      await platform.capture(
        mode: ScreenshotMode.screen,
        includeCursor: true,
        displayId: null,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'capture');
      expect(log.first.arguments['mode'], 'screen');
      expect(log.first.arguments['includeCursor'], true);
    });

    test('capture screen returns CapturedData', () async {
      final result = await platform.capture(mode: ScreenshotMode.screen);

      expect(result, isNotNull);
      expect(result!.width, 1920);
      expect(result.height, 1080);
      expect(result.bytes.length, 4);
    });

    test('capture region returns null on cancellation', () async {
      final result = await platform.capture(mode: ScreenshotMode.region);

      expect(result, isNull);
    });
  });
}
```

**Run Tests** (should FAIL):
```bash
flutter test test/screenshot_method_channel_test.dart
```

### 1.4 Create Public API Tests

**File**: `test/screenshot_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screenshot/screenshot_platform_interface.dart';
import 'package:screenshot/src/models/screenshot_mode.dart';
import 'package:screenshot/src/models/captured_data.dart';
import 'dart:typed_data';

class MockScreenshotPlatform extends ScreenshotPlatform {
  CapturedData? mockResult;
  ScreenshotMode? lastMode;
  bool? lastIncludeCursor;

  @override
  Future<CapturedData?> capture({
    required ScreenshotMode mode,
    bool includeCursor = false,
    int? displayId,
  }) async {
    lastMode = mode;
    lastIncludeCursor = includeCursor;
    return mockResult;
  }
}

void main() {
  group('Screenshot', () {
    late MockScreenshotPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockScreenshotPlatform();
      ScreenshotPlatform.instance = mockPlatform;
    });

    test('is singleton', () {
      final instance1 = Screenshot();
      final instance2 = Screenshot();
      expect(instance1, same(instance2));
    });

    test('capture delegates to platform', () async {
      mockPlatform.mockResult = CapturedData(
        width: 1920,
        height: 1080,
        bytes: Uint8List(100),
      );

      final screenshot = Screenshot();
      final result = await screenshot.capture(
        mode: ScreenshotMode.screen,
        includeCursor: true,
      );

      expect(mockPlatform.lastMode, ScreenshotMode.screen);
      expect(mockPlatform.lastIncludeCursor, true);
      expect(result, isNotNull);
    });
  });
}
```

**Run All Tests** (should all FAIL - implementation doesn't exist):
```bash
flutter test
```

✅ **Phase 1 Gate**: All tests written and failing (RED phase)

---

## Phase 2: Implement Data Models (GREEN phase)

**Goal**: Make data model tests pass

### 2.1 Implement ScreenshotMode

**File**: `lib/src/models/screenshot_mode.dart`

```dart
enum ScreenshotMode {
  region,
  screen;

  String toValue() => name;

  static ScreenshotMode fromValue(String value) {
    return ScreenshotMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => throw ArgumentError('Invalid ScreenshotMode: $value'),
    );
  }
}
```

### 2.2 Implement CapturedData

**File**: `lib/src/models/captured_data.dart`

(See full implementation in data-model.md)

### 2.3 Implement CaptureRequest

**File**: `lib/src/models/capture_request.dart`

(See full implementation in data-model.md)

### 2.4 Implement ScreenshotException

**File**: `lib/src/models/screenshot_exception.dart`

(See full implementation in data-model.md)

**Run Tests**:
```bash
flutter test test/models/
```

✅ **Checkpoint**: All model tests should PASS (GREEN)

---

## Phase 3: Implement Platform Interface (GREEN phase)

### 3.1 Update Platform Interface

**File**: `lib/screenshot_platform_interface.dart`

```dart
import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'src/models/screenshot_mode.dart';
import 'src/models/captured_data.dart';
import 'screenshot_method_channel.dart';

abstract class ScreenshotPlatform extends PlatformInterface {
  ScreenshotPlatform() : super(token: _token);

  static final Object _token = Object();
  static ScreenshotPlatform _instance = MethodChannelScreenshot();

  static ScreenshotPlatform get instance => _instance;

  static set instance(ScreenshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<CapturedData?> capture({
    required ScreenshotMode mode,
    bool includeCursor = false,
    int? displayId,
  }) {
    throw UnimplementedError('capture() has not been implemented.');
  }
}
```

### 3.2 Implement Method Channel

**File**: `lib/screenshot_method_channel.dart`

```dart
import 'package:flutter/services.dart';
import 'screenshot_platform_interface.dart';
import 'src/models/screenshot_mode.dart';
import 'src/models/captured_data.dart';
import 'src/models/capture_request.dart';
import 'src/models/screenshot_exception.dart';

class MethodChannelScreenshot extends ScreenshotPlatform {
  final MethodChannel _channel = const MethodChannel('dev.flutter.screenshot');

  @override
  Future<CapturedData?> capture({
    required ScreenshotMode mode,
    bool includeCursor = false,
    int? displayId,
  }) async {
    final request = CaptureRequest(
      mode: mode,
      includeCursor: includeCursor,
      displayId: displayId,
    );

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'capture',
        request.toMap(),
      );

      if (result == null) {
        return null; // User cancelled
      }

      return CapturedData.fromMap(result);
    } on PlatformException catch (e) {
      throw ScreenshotException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }
}
```

**Run Tests**:
```bash
flutter test test/screenshot_method_channel_test.dart
flutter test test/screenshot_platform_interface_test.dart
```

✅ **Checkpoint**: Platform interface tests should PASS

---

## Phase 4: Implement Public API (GREEN phase)

**File**: `lib/screenshot.dart`

```dart
import 'screenshot_platform_interface.dart';
import 'src/models/screenshot_mode.dart';
import 'src/models/captured_data.dart';

// Export public types
export 'src/models/screenshot_mode.dart';
export 'src/models/captured_data.dart';
export 'src/models/screenshot_exception.dart';

class Screenshot {
  Screenshot._internal();

  static final Screenshot _instance = Screenshot._internal();

  factory Screenshot() => _instance;

  Future<CapturedData?> capture({
    ScreenshotMode mode = ScreenshotMode.region,
    bool includeCursor = false,
    int? displayId,
  }) {
    return ScreenshotPlatform.instance.capture(
      mode: mode,
      includeCursor: includeCursor,
      displayId: displayId,
    );
  }
}
```

**Run Tests**:
```bash
flutter test
```

✅ **Checkpoint**: All Dart tests should PASS (GREEN)

---

## Phase 5: Implement Native Windows Code

### 5.1 Write Native C++ Tests First

**File**: `windows/test/screenshot_plugin_test.cpp`

```cpp
#include <gtest/gtest.h>
#include "screenshot_plugin.h"

// Mock MethodResult for testing
class MockMethodResult : public flutter::MethodResult<flutter::EncodableValue> {
 public:
  bool success_called = false;
  bool error_called = false;
  std::string error_code;

  void SuccessInternal(const flutter::EncodableValue* result) override {
    success_called = true;
  }

  void ErrorInternal(const std::string& error_code,
                     const std::string& error_message,
                     const flutter::EncodableValue* error_details) override {
    error_called = true;
    this->error_code = error_code;
  }

  void NotImplementedInternal() override {}
};

TEST(ScreenshotPluginTest, HandleCaptureScreenMethod) {
  ScreenshotPlugin plugin;
  auto result = std::make_unique<MockMethodResult>();

  flutter::EncodableMap args;
  args[flutter::EncodableValue("mode")] = flutter::EncodableValue("screen");
  args[flutter::EncodableValue("includeCursor")] = flutter::EncodableValue(false);

  plugin.HandleMethodCall(
      flutter::MethodCall("capture",
                          std::make_unique<flutter::EncodableValue>(args)),
      std::move(result));

  EXPECT_TRUE(result->success_called);
}

TEST(ScreenshotPluginTest, InvalidModeReturnsError) {
  ScreenshotPlugin plugin;
  auto result = std::make_unique<MockMethodResult>();

  flutter::EncodableMap args;
  args[flutter::EncodableValue("mode")] = flutter::EncodableValue("invalid");

  plugin.HandleMethodCall(
      flutter::MethodCall("capture",
                          std::make_unique<flutter::EncodableValue>(args)),
      std::move(result));

  EXPECT_TRUE(result->error_called);
  EXPECT_EQ(result->error_code, "invalid_argument");
}
```

**Build and Run Native Tests** (should FAIL):
```bash
cd windows
cmake -B build
cmake --build build
ctest --test-dir build
```

### 5.2 Implement Native Screenshot Logic

**File**: `windows/screenshot_plugin.cpp`

Implement according to research.md patterns:
- BitBlt for screen capture
- WS_EX_LAYERED window for region overlay
- WIC for PNG encoding
- Proper error handling

(Implementation details in separate task tickets - see /speckit.tasks)

**Run Native Tests**:
```bash
cd windows && ctest --test-dir build
```

✅ **Checkpoint**: Native tests should PASS

---

## Phase 6: Integration Testing

### 6.1 Manual Testing with Example App

**File**: `example/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CapturedData? _capturedData;

  Future<void> _captureScreen() async {
    final screenshot = Screenshot();
    final data = await screenshot.capture(mode: ScreenshotMode.screen);
    setState(() => _capturedData = data);
  }

  Future<void> _captureRegion() async {
    final screenshot = Screenshot();
    final data = await screenshot.capture(mode: ScreenshotMode.region);
    setState(() => _capturedData = data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Screenshot Plugin Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _captureScreen,
                child: const Text('Capture Screen'),
              ),
              ElevatedButton(
                onPressed: _captureRegion,
                child: const Text('Capture Region'),
              ),
              if (_capturedData != null) ...[
                const SizedBox(height: 20),
                Text('${_capturedData!.width} x ${_capturedData!.height}'),
                Image.memory(_capturedData!.bytes, height: 300),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

**Run Example**:
```bash
cd example
flutter run -d windows
```

**Manual Test Cases**:
1. Click "Capture Screen" → verify full screen captured
2. Click "Capture Region" → verify overlay appears, select area, verify region captured
3. Click "Capture Region" → press ESC → verify returns to app (no image)
4. Test with cursor inclusion enabled/disabled

---

## Success Criteria Validation

Verify all success criteria from spec.md:

- [ ] **SC-001**: Full screen capture completes <500ms @ 1920x1080
- [ ] **SC-002**: Overlay responds to mouse <16ms (60 FPS smooth)
- [ ] **SC-003**: Captures work correctly on DPI 100-200%
- [ ] **SC-004**: Example app demonstrates both modes
- [ ] **SC-005**: Memory usage <100MB per capture
- [ ] **SC-006**: Overlay displays <100ms after API call
- [ ] **SC-007**: 95% region selections succeed (10x10+ pixels)
- [ ] **SC-008**: Cancellation detected <50ms

---

## Deployment Checklist

- [ ] All unit tests pass (`flutter test`)
- [ ] All native tests pass (`ctest`)
- [ ] Manual testing complete
- [ ] Example app demonstrates features
- [ ] README.md updated with usage examples
- [ ] CHANGELOG.md updated
- [ ] Version bumped in pubspec.yaml
- [ ] Constitution compliance verified (see plan.md)
- [ ] Code reviewed
- [ ] Ready for merge to main

---

## Next Steps

After this quickstart phase completes:

1. Run `/speckit.tasks` to generate detailed task breakdown
2. Implement tasks following TDD workflow
3. Use `update-agent-context.ps1` to keep Copilot informed
4. Submit PR when all tests pass and success criteria met

**Estimated Timeline**: 3-5 days for experienced Flutter/Windows developer

**Support**: See research.md for detailed technical guidance on Win32 APIs, PNG encoding, etc.
