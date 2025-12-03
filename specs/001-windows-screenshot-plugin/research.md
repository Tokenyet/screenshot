# Research: Windows Screenshot Plugin

**Feature**: Windows Screenshot Plugin  
**Date**: December 3, 2025  
**Status**: Complete

## Research Items

### 1. Native C++ Testing Framework for Flutter Windows Plugins

**Question**: What testing framework should be used for C++ Windows plugin native code?

**Decision**: Use **Google Test (gtest)** with Flutter's existing Windows plugin test infrastructure

**Rationale**:
- Flutter's Windows plugin template already includes gtest in `windows/test/` directory
- Google Test is industry standard for C++ unit testing
- CMake integration is straightforward and well-documented
- Supports mock objects, test fixtures, and assertions needed for Win32 API testing
- Compatible with Flutter's existing test runner and CI/CD pipelines

**Alternatives Considered**:
1. **Catch2**: Modern C++ testing framework, but requires additional setup and not Flutter default
2. **Boost.Test**: More heavyweight, adds unnecessary dependencies
3. **Microsoft Unit Testing Framework**: Windows-specific, but less portable and not Flutter standard

**Implementation Notes**:
- Test files location: `windows/test/screenshot_plugin_test.cpp` (already exists in template)
- CMake configuration: Add to `windows/test/CMakeLists.txt`
- Run tests via: `flutter test` (includes Windows native tests) or directly via CMake build
- Mock Win32 APIs using gtest's `MOCK_METHOD` or manual mock implementations

**References**:
- Flutter Windows plugin test example: `screenshot/windows/test/screenshot_plugin_test.cpp`
- Google Test documentation: https://google.github.io/googletest/

---

### 2. Win32 API Best Practices for Screenshot Capture

**Question**: What are the recommended Win32 API patterns for reliable screenshot capture with cursor support and DPI awareness?

**Decision**: Use **BitBlt with GetDC/CreateCompatibleDC** pattern for screen capture, **DrawIconEx** for cursor overlay, **SetProcessDPIAware** for DPI handling

**Rationale**:
- **BitBlt** (Bit Block Transfer) is the standard Win32 method for copying screen pixels
  - Fast, hardware-accelerated when available
  - Works with compatible DCs (device contexts)
  - Supports partial screen regions
  
- **GetDC(NULL)** gets the desktop device context (entire screen)
  - Combined with CreateCompatibleDC and CreateCompatibleBitmap for memory buffering
  - SelectObject to move bitmap data into memory DC
  
- **Cursor capture** via GetCursorInfo + DrawIconEx:
  - GetCursorInfo retrieves current cursor position and visibility
  - DrawIconEx renders cursor onto captured bitmap at correct position
  
- **DPI Awareness** via SetProcessDPIAware or manifest:
  - Ensures coordinates and dimensions match actual pixels
  - Critical for high-DPI displays (125%, 150%, 200% scaling)
  - Alternative: GetDpiForMonitor for per-monitor DPI

**Alternatives Considered**:
1. **Windows.Graphics.Capture API** (WinRT): Modern, but requires Windows 10 1903+, more complex setup
2. **GDI+ Bitmap::FromHBITMAP**: Higher-level, but adds GDI+ dependency and encoding complexity
3. **DirectX/DXGI Desktop Duplication**: Most efficient for continuous capture, overkill for single screenshots

**Implementation Pattern**:
```cpp
// Pseudo-code for screen capture
HDC hdcScreen = GetDC(NULL);
HDC hdcMemory = CreateCompatibleDC(hdcScreen);
HBITMAP hBitmap = CreateCompatibleBitmap(hdcScreen, width, height);
SelectObject(hdcMemory, hBitmap);
BitBlt(hdcMemory, 0, 0, width, height, hdcScreen, x, y, SRCCOPY);

// Optional: Draw cursor
CURSORINFO cursorInfo = {sizeof(CURSORINFO)};
if (includeCursor && GetCursorInfo(&cursorInfo)) {
    DrawIconEx(hdcMemory, cursorX, cursorY, cursorInfo.hCursor, 0, 0, 0, NULL, DI_NORMAL);
}

// Convert to PNG bytes (use libpng or WIC)
// ... encoding logic ...

// Cleanup
DeleteObject(hBitmap);
DeleteDC(hdcMemory);
ReleaseDC(NULL, hdcScreen);
```

**References**:
- MSDN BitBlt: https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-bitblt
- MSDN GetCursorInfo: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorinfo
- DPI Awareness: https://learn.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows

---

### 3. Image Encoding: PNG vs Raw Bytes

**Question**: Should we encode screenshots as PNG or return raw pixel data (BGRA)?

**Decision**: **PNG encoding** via Windows Imaging Component (WIC) for initial implementation

**Rationale**:
- **PNG advantages**:
  - Lossless compression reduces data transfer size (typically 3-5x smaller than raw)
  - Standard format, easily saved to disk or transmitted
  - Built-in Windows support via WIC (no external dependencies)
  
- **WIC (Windows Imaging Component)** is preferred over libpng:
  - Already available on all Windows systems
  - No external library dependencies to manage
  - Native COM API, well-documented
  - Supports multiple formats if needed in future

- **Raw bytes** option deferred:
  - Can be added as parameter option in future (breaking: NO, additive: YES)
  - Useful for real-time processing or custom encoding
  - Larger data transfer, but no encoding overhead

**Alternatives Considered**:
1. **libpng**: Cross-platform, but adds build complexity and external dependency
2. **stb_image_write**: Single-header library, good for portability, but WIC is already available
3. **Raw BGRA only**: Simplest implementation, but poor performance for large screenshots

**Implementation Notes**:
- Use WIC's IWICImagingFactory to create PNG encoder
- Convert HBITMAP → IWICBitmap → IWICStream (memory) → PNG bytes
- Return Uint8List to Dart side
- Future: Add `imageFormat` parameter to support raw/jpeg/bmp (MINOR version bump)

**References**:
- WIC Programming Guide: https://learn.microsoft.com/en-us/windows/win32/wic/-wic-programming-guide
- WIC Encoding Example: https://learn.microsoft.com/en-us/windows/win32/wic/-wic-sample-d2d-viewer

---

### 4. Region Selection Overlay Implementation

**Question**: How to implement the semi-transparent fullscreen overlay for region selection on Windows?

**Decision**: **Native Win32 layered window** with WS_EX_LAYERED and UpdateLayeredWindow

**Rationale**:
- **Layered windows** (WS_EX_LAYERED style) support:
  - Per-pixel alpha transparency
  - Hardware-accelerated compositing
  - Topmost Z-order (WS_EX_TOPMOST) for overlay effect
  - Fast redraw for real-time selection rectangle
  
- **UpdateLayeredWindow** allows:
  - Direct bitmap rendering with alpha channel
  - No WM_PAINT overhead (faster for frequent updates)
  - Full control over transparency levels
  
- **Input handling**:
  - WM_LBUTTONDOWN: Start selection (capture mouse)
  - WM_MOUSEMOVE: Update selection rectangle
  - WM_LBUTTONUP: Complete selection
  - WM_KEYDOWN (VK_ESCAPE): Cancel selection
  - WM_RBUTTONDOWN: Cancel selection

**Alternatives Considered**:
1. **Flutter overlay widget**: Can't display over non-Flutter windows, defeats purpose
2. **WS_EX_TRANSPARENT + SetLayeredWindowAttributes**: Simpler but less control over rendering
3. **DirectComposition/Direct2D**: Modern, but overkill for simple rectangle selection

**Implementation Pattern**:
```cpp
// Create layered window
HWND hwndOverlay = CreateWindowEx(
    WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW,
    className, NULL,
    WS_POPUP,
    0, 0, screenWidth, screenHeight,
    NULL, NULL, hInstance, NULL
);

// Set transparency
SetLayeredWindowAttributes(hwndOverlay, 0, 128, LWA_ALPHA); // 50% opacity

// Message loop handles mouse events
// On selection complete: capture region via BitBlt(x, y, width, height)
// On cancel: destroy window, return null to Dart
```

**References**:
- Layered Windows: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-features#layered-windows
- UpdateLayeredWindow: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-updatelayeredwindow

---

### 5. Method Channel Threading and Asynchronous Handling

**Question**: How to handle long-running region selection (user interaction) without blocking Flutter UI thread?

**Decision**: **Async method channel invocation** with native event loop integration

**Rationale**:
- **Flutter MethodChannel** supports asynchronous responses:
  - Native side can delay sending result until user completes/cancels selection
  - Dart side awaits Future, UI remains responsive
  
- **Windows message pump** runs on native thread:
  - Region selection overlay uses modal message loop
  - Blocks native thread but NOT Dart/Flutter UI thread
  - Result sent back when DestroyWindow called (selection complete)
  
- **No separate threading needed**:
  - Windows message loop is already event-driven
  - MethodChannel handles async bridge automatically
  - Simpler than creating worker threads + synchronization

**Implementation Notes**:
- Native handler for `capture` method:
  1. Receive MethodCall from Dart
  2. If mode == "region": Create overlay, enter message loop (blocks native thread)
  3. Message loop exits when user completes/cancels
  4. Send result or error back through MethodChannel
  5. Dart Future completes
  
- Dart side remains responsive during selection (can cancel via timeout if needed)

**Alternatives Considered**:
1. **Separate worker thread**: Complex synchronization, unnecessary for Windows message loops
2. **Polling**: Inefficient, poor UX
3. **Callback-based API**: More complex for plugin users, Future is idiomatic Dart

**References**:
- Flutter Platform Channels: https://docs.flutter.dev/platform-integration/platform-channels
- MethodChannel Async: https://api.flutter.dev/flutter/services/MethodChannel-class.html

---

## Summary

All technical unknowns resolved. Implementation can proceed with:

1. **Testing**: Google Test (gtest) for C++ native tests
2. **Screen Capture**: BitBlt + GetDC/CreateCompatibleDC pattern
3. **Cursor Rendering**: GetCursorInfo + DrawIconEx
4. **DPI Handling**: SetProcessDPIAware for coordinate accuracy
5. **Image Encoding**: Windows Imaging Component (WIC) for PNG output
6. **Region Overlay**: WS_EX_LAYERED native window with UpdateLayeredWindow
7. **Async Handling**: MethodChannel async with modal message loop, no threading complexity

**Risk Assessment**: Low
- All technologies are proven, well-documented Windows APIs
- Flutter plugin patterns are standard and well-supported
- No external dependencies beyond Windows SDK and Flutter framework

**Next Steps**: Proceed to Phase 1 (Design) - data models, contracts, quickstart
