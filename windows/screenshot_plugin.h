#ifndef FLUTTER_PLUGIN_SCREENSHOT_PLUGIN_H_
#define FLUTTER_PLUGIN_SCREENSHOT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace screenshot {

class ScreenshotPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ScreenshotPlugin();

  virtual ~ScreenshotPlugin();

  // Disallow copy and assign.
  ScreenshotPlugin(const ScreenshotPlugin&) = delete;
  ScreenshotPlugin& operator=(const ScreenshotPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace screenshot

#endif  // FLUTTER_PLUGIN_SCREENSHOT_PLUGIN_H_
