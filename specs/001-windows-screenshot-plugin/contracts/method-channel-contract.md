# Platform Method Channel Contract

**Feature**: Windows Screenshot Plugin  
**Date**: December 3, 2025  
**Version**: 0.1.0  
**Channel Name**: `dev.flutter.screenshot`

## Overview

This contract defines the communication protocol between Dart code and native Windows C++ implementation via Flutter's MethodChannel. All parameters and return values are strictly typed and validated.

---

## Method: `capture`

**Purpose**: Capture a screenshot of the screen or a user-selected region

**Channel**: `dev.flutter.screenshot`  
**Method Name**: `"capture"`  
**Async**: Yes (awaitable Future in Dart)

### Request Parameters

**Type**: `Map<String, Object?>`

| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `mode` | String | Yes | - | Must be `"screen"` or `"region"` | Capture mode: full screen or region selection |
| `includeCursor` | bool | No | `false` | - | Whether to render cursor in captured image |
| `displayId` | int? | No | `null` | Must be `null` or `>= 0` | Target display identifier, `null` = primary display |

**Example Request**:
```dart
// Full screen capture without cursor
{
  "mode": "screen",
  "includeCursor": false,
  "displayId": null
}

// Region selection with cursor
{
  "mode": "region",
  "includeCursor": true,
  "displayId": null
}

// Full screen on second monitor
{
  "mode": "screen",
  "includeCursor": false,
  "displayId": 1
}
```

### Response (Success)

**Type**: `Map<String, Object>` or `null`

**Success Response** (screenshot captured):

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `width` | int | Yes | Must be `> 0` | Image width in pixels |
| `height` | int | Yes | Must be `> 0` | Image height in pixels |
| `bytes` | Uint8List | Yes | Must not be empty | PNG-encoded image data |

**Null Response** (user cancelled):
- Returns `null` when user cancels region selection (ESC or right-click)
- This is NOT an error, but a valid outcome

**Example Success Response**:
```dart
{
  "width": 1920,
  "height": 1080,
  "bytes": Uint8List([0x89, 0x50, 0x4E, 0x47, ...]) // PNG magic bytes + data
}
```

### Response (Error)

**Type**: `PlatformException`

| Error Code | Message | Details | When Thrown |
|------------|---------|---------|-------------|
| `cancelled` | "Screenshot capture cancelled by user" | null | User pressed ESC or right-click during region selection (alternative to null return) |
| `not_supported` | "Screenshot capture not supported on this platform" | Platform name (string) | Non-Windows platform attempts to use Windows implementation |
| `internal_error` | Varies (e.g., "BitBlt failed") | Win32 error code (int) or error message | Win32 API call failed, memory allocation error, PNG encoding error |
| `invalid_argument` | Varies (e.g., "Invalid mode") | Invalid parameter value | Request validation failed (e.g., mode not "screen" or "region") |

**Example Error Response** (Dart catch):
```dart
try {
  final result = await methodChannel.invokeMethod('capture', {...});
} on PlatformException catch (e) {
  if (e.code == 'cancelled') {
    // User cancelled
  } else if (e.code == 'internal_error') {
    // Native error, check e.message and e.details
  }
}
```

---

## Native Implementation Requirements

### Windows C++ Handler

**Function Signature**:
```cpp
void ScreenshotPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result
);
```

**Implementation Checklist**:

1. **Validate method name**:
   - Check `method_call.method_name() == "capture"`
   - Return `result->NotImplemented()` if unknown method

2. **Extract and validate arguments**:
   - Get `mode` (string): Validate is "screen" or "region"
   - Get `includeCursor` (bool, default false)
   - Get `displayId` (int or null)
   - Return `result->Error("invalid_argument", ...)` if validation fails

3. **Execute capture** (based on mode):
   - **Screen mode**: 
     - Call `CaptureScreen(displayId, includeCursor)`
     - Return PNG bytes or error
   - **Region mode**:
     - Call `CaptureRegion(includeCursor)` (creates overlay, waits for user)
     - Returns PNG bytes, null (cancelled), or error

4. **Return result**:
   - **Success**: `result->Success(EncodableMap{{"width", w}, {"height", h}, {"bytes", pngBytes}})`
   - **Cancelled**: `result->Success(nullptr)` or `result->Error("cancelled", ...)`
   - **Error**: `result->Error(code, message, details)`

**Threading Notes**:
- Method handler runs on Flutter platform thread
- Region selection overlay runs modal message loop (blocks platform thread)
- Async response sent when message loop exits (user completes/cancels)
- No separate threading needed (Windows message loop handles async)

---

## Version Compatibility

| Version | Changes | Breaking? |
|---------|---------|-----------|
| 0.1.0 | Initial `capture` method | N/A (initial) |
| Future: 0.2.0 | Add `imageFormat` parameter (`"png"`, `"raw"`, `"jpeg"`) | NO (additive, default = `"png"`) |
| Future: 1.0.0 | Change return type structure | YES (MAJOR bump required) |

**Semver Rules** (per constitution):
- **PATCH**: Bug fixes, no API changes
- **MINOR**: Add optional parameters, new methods (backward compatible)
- **MAJOR**: Change existing parameter types, remove parameters, change return structure

---

## Testing Contract

### Unit Tests (Dart)

**Test file**: `test/screenshot_method_channel_test.dart`

```dart
test('capture sends correct arguments to method channel', () async {
  final mockChannel = MockMethodChannel();
  
  // Setup mock
  when(mockChannel.invokeMethod('capture', {
    'mode': 'screen',
    'includeCursor': true,
    'displayId': null,
  })).thenAnswer((_) async => {
    'width': 1920,
    'height': 1080,
    'bytes': Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]),
  });
  
  final platform = MethodChannelScreenshot(mockChannel);
  final result = await platform.capture(
    mode: ScreenshotMode.screen,
    includeCursor: true,
  );
  
  expect(result, isNotNull);
  expect(result!.width, 1920);
  expect(result.height, 1080);
});

test('capture returns null when user cancels', () async {
  final mockChannel = MockMethodChannel();
  
  when(mockChannel.invokeMethod('capture', any))
      .thenAnswer((_) async => null);
  
  final platform = MethodChannelScreenshot(mockChannel);
  final result = await platform.capture(mode: ScreenshotMode.region);
  
  expect(result, isNull);
});

test('capture throws ScreenshotException on error', () async {
  final mockChannel = MockMethodChannel();
  
  when(mockChannel.invokeMethod('capture', any))
      .thenThrow(PlatformException(code: 'internal_error', message: 'BitBlt failed'));
  
  final platform = MethodChannelScreenshot(mockChannel);
  
  expect(
    () => platform.capture(mode: ScreenshotMode.screen),
    throwsA(isA<ScreenshotException>()),
  );
});
```

### Integration Tests (Native C++)

**Test file**: `windows/test/screenshot_plugin_test.cpp`

```cpp
TEST(ScreenshotPluginTest, CaptureScreenReturnsValidPngData) {
  ScreenshotPlugin plugin;
  auto result = std::make_unique<MockMethodResult>();
  
  flutter::EncodableMap args = {
    {"mode", "screen"},
    {"includeCursor", false},
    {"displayId", nullptr}
  };
  
  plugin.HandleMethodCall(
    flutter::MethodCall("capture", std::make_unique<flutter::EncodableValue>(args)),
    std::move(result)
  );
  
  // Verify result->Success called with valid map
  EXPECT_TRUE(result->success_called);
  EXPECT_TRUE(result->success_value.IsMap());
  // ... validate width, height, bytes
}

TEST(ScreenshotPluginTest, InvalidModeReturnsError) {
  ScreenshotPlugin plugin;
  auto result = std::make_unique<MockMethodResult>();
  
  flutter::EncodableMap args = {{"mode", "invalid"}};
  
  plugin.HandleMethodCall(
    flutter::MethodCall("capture", std::make_unique<flutter::EncodableValue>(args)),
    std::move(result)
  );
  
  EXPECT_TRUE(result->error_called);
  EXPECT_EQ(result->error_code, "invalid_argument");
}
```

---

## Contract Compliance Checklist

- [x] Method name documented: `"capture"`
- [x] Channel name specified: `"dev.flutter.screenshot"`
- [x] All parameters typed and validated
- [x] Return type structure defined
- [x] Error codes enumerated
- [x] Null handling specified (user cancellation)
- [x] Example requests/responses provided
- [x] Version compatibility documented
- [x] Test cases defined for contract validation
- [x] Threading model described
- [x] Semver rules applied per constitution

**Reviewed**: 2025-12-03  
**Status**: Ready for implementation
