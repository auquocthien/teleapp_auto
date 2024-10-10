import 'package:flutter/services.dart';

class AppControl {
  static const MethodChannel _channel =
      MethodChannel('com.example.window_control');

  Future<List<String>> getOpenWindows() async {
    try {
      final List<dynamic> windowList =
          await _channel.invokeMethod('getOpenWindows');
      return List<String>.from(windowList);
    } on PlatformException catch (e) {
      throw "Failed to get open windows: '${e.message}'.";
    }
  }
}
