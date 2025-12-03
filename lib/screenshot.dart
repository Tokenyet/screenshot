
import 'screenshot_platform_interface.dart';

class Screenshot {
  Future<String?> getPlatformVersion() {
    return ScreenshotPlatform.instance.getPlatformVersion();
  }
}
