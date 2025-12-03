# Data Models: Windows Screenshot Plugin

**Feature**: Windows Screenshot Plugin  
**Date**: December 3, 2025  
**Layer**: Platform Interface (shared across implementations)

## Overview

This document defines all data models used in the screenshot plugin, following the constitution's Type Safety principle. All models are immutable, strongly-typed, with explicit validation.

---

## 1. ScreenshotMode (Enum)

**Purpose**: Defines the capture behavior type

**Values**:
- `screen`: Capture the entire primary display
- `region`: User-selected rectangular area via interactive overlay

**Dart Definition**:
```dart
enum ScreenshotMode {
  /// Drag the cursor around an object to form a rectangle.
  region,

  /// Capture the entire (primary) screen.
  screen,
}
```

**Serialization**:
```dart
// To string for method channel
String toValue() => name; // "region" or "screen"

// From string
static ScreenshotMode fromValue(String value) {
  return ScreenshotMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => throw ArgumentError('Invalid ScreenshotMode: $value'),
  );
}
```

**Validation**: 
- Must be one of the defined enum values
- Enforced at compile-time by Dart enum

**Layer**: Platform Interface

---

## 2. CapturedData (Value Object)

**Purpose**: Represents the result of a successful screenshot capture operation

**Fields**:
- `width` (int): Image width in pixels, must be > 0
- `height` (int): Image height in pixels, must be > 0
- `bytes` (Uint8List): PNG-encoded image data, must not be empty

**Dart Definition**:
```dart
import 'dart:typed_data';

class CapturedData {
  const CapturedData({
    required this.width,
    required this.height,
    required this.bytes,
  }) : assert(width > 0, 'Width must be positive'),
       assert(height > 0, 'Height must be positive'),
       assert(bytes.length > 0, 'Image bytes must not be empty');

  /// Image width in pixels
  final int width;

  /// Image height in pixels
  final int height;

  /// PNG-encoded image data
  final Uint8List bytes;

  /// Serialize to Map for method channel communication
  Map<String, Object> toMap() {
    return <String, Object>{
      'width': width,
      'height': height,
      'bytes': bytes,
    };
  }

  /// Deserialize from Map received from method channel
  static CapturedData fromMap(Map<Object?, Object?> map) {
    final width = map['width'] as int;
    final height = map['height'] as int;
    final bytes = map['bytes'] as Uint8List;

    return CapturedData(
      width: width,
      height: height,
      bytes: bytes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CapturedData) return false;
    
    return width == other.width &&
           height == other.height &&
           _bytesEqual(bytes, other.bytes);
  }

  @override
  int get hashCode => Object.hash(width, height, Object.hashAll(bytes));

  @override
  String toString() => 'CapturedData(width: $width, height: $height, bytes: ${bytes.length} bytes)';

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
```

**Validation Rules**:
- `width > 0`: Cannot have zero or negative width
- `height > 0`: Cannot have zero or negative height
- `bytes.length > 0`: Must contain image data
- `bytes` must be valid PNG format (validated by native code before creation)

**Relationships**: 
- Returned by `ScreenshotPlatform.capture()`
- None (standalone value object)

**Layer**: Platform Interface

---

## 3. CaptureRequest (Internal Model)

**Purpose**: Internal representation of capture parameters passed from Dart to native code

**Fields**:
- `mode` (ScreenshotMode): Capture behavior type
- `includeCursor` (bool): Whether to render cursor in captured image
- `displayId` (int?): Target display identifier, null = primary display

**Dart Definition**:
```dart
class CaptureRequest {
  const CaptureRequest({
    required this.mode,
    this.includeCursor = false,
    this.displayId,
  }) : assert(displayId == null || displayId >= 0, 'DisplayId must be null or non-negative');

  final ScreenshotMode mode;
  final bool includeCursor;
  final int? displayId;

  /// Serialize to Map for method channel communication
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'mode': mode.toValue(),
      'includeCursor': includeCursor,
      'displayId': displayId,
    };
  }

  /// Deserialize from Map (for testing)
  static CaptureRequest fromMap(Map<Object?, Object?> map) {
    return CaptureRequest(
      mode: ScreenshotMode.fromValue(map['mode'] as String),
      includeCursor: map['includeCursor'] as bool? ?? false,
      displayId: map['displayId'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CaptureRequest) return false;
    
    return mode == other.mode &&
           includeCursor == other.includeCursor &&
           displayId == other.displayId;
  }

  @override
  int get hashCode => Object.hash(mode, includeCursor, displayId);

  @override
  String toString() => 'CaptureRequest(mode: $mode, includeCursor: $includeCursor, displayId: $displayId)';
}
```

**Validation Rules**:
- `mode`: Must be valid ScreenshotMode enum value
- `includeCursor`: No validation (boolean)
- `displayId`: Must be null or >= 0 (display indices are non-negative)

**Relationships**:
- Used internally by `Screenshot.capture()` to pass parameters to platform
- Not exposed in public API

**Layer**: Platform Interface (internal use)

---

## 4. ScreenshotException (Exception Model)

**Purpose**: Represents errors during screenshot capture operations

**Fields**:
- `code` (String): Error code ("cancelled", "not_supported", "internal_error")
- `message` (String?): Human-readable error description
- `details` (dynamic): Additional error context (e.g., Win32 error code)

**Dart Definition**:
```dart
class ScreenshotException implements Exception {
  const ScreenshotException({
    required this.code,
    this.message,
    this.details,
  });

  final String code;
  final String? message;
  final dynamic details;

  @override
  String toString() {
    final buffer = StringBuffer('ScreenshotException($code');
    if (message != null) buffer.write(': $message');
    if (details != null) buffer.write(' [details: $details]');
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScreenshotException) return false;
    
    return code == other.code &&
           message == other.message &&
           details == other.details;
  }

  @override
  int get hashCode => Object.hash(code, message, details);
}
```

**Error Codes**:
- `"cancelled"`: User cancelled region selection (ESC or right-click)
- `"not_supported"`: Platform does not support screenshot (e.g., non-Windows platform using Windows implementation)
- `"internal_error"`: Native API failure (e.g., BitBlt failed, memory allocation error, PNG encoding failed)

**Usage**:
- Thrown by platform implementation when capture fails
- Dart code can catch and handle specific error codes
- Note: User cancellation may return `null` instead of throwing (design decision)

**Layer**: Platform Interface

---

## Model Relationships

```
[Screenshot API]
      ↓
   capture(mode, includeCursor, displayId)
      ↓
[CaptureRequest] ────→ [MethodChannel] ────→ [Native Code]
      ↓                                           ↓
      ↓                                    [Win32 APIs]
      ↓                                           ↓
[ScreenshotPlatform] ←── [MethodChannel] ←── [PNG bytes]
      ↓
[CapturedData] or null or [ScreenshotException]
      ↓
[User Code]
```

---

## Validation Summary

| Model | Immutable | Strongly-Typed | Validation | Serialization |
|-------|-----------|----------------|------------|---------------|
| ScreenshotMode | ✅ | ✅ (enum) | Compile-time | toValue/fromValue |
| CapturedData | ✅ | ✅ | width>0, height>0, bytes non-empty | toMap/fromMap |
| CaptureRequest | ✅ | ✅ | displayId>=0 or null | toMap/fromMap |
| ScreenshotException | ✅ | ✅ | None (error object) | toString |

All models follow constitution requirements:
- ✅ Immutable (`const` constructors, `final` fields)
- ✅ Strongly-typed (no `dynamic` in public fields)
- ✅ Explicit validation (assert statements in constructors)
- ✅ Value semantics (`==`, `hashCode`, `toString` overrides)
- ✅ Serialization methods for method channel communication

---

## File Organization

**Recommended structure**:
```
lib/
└── src/
    └── models/
        ├── screenshot_mode.dart         # ScreenshotMode enum
        ├── captured_data.dart           # CapturedData class
        ├── capture_request.dart         # CaptureRequest class (internal)
        └── screenshot_exception.dart    # ScreenshotException class
```

**Public API exports** (in `lib/screenshot.dart` or `lib/screenshot_platform_interface.dart`):
```dart
export 'src/models/screenshot_mode.dart';
export 'src/models/captured_data.dart';
export 'src/models/screenshot_exception.dart';
// Note: CaptureRequest is internal, not exported
```
