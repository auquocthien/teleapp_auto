import 'package:flutter/services.dart';

class MouseControl {
  static const MethodChannel _channel =
      MethodChannel('com.example.window_control');

  Future<void> performClick(int x, int y, int hwnd) async {
    try {
      // print('$x $y $hwnd');
      String result = await _channel.invokeMethod('performClick', {
        'x': x,
        'y': y,
        'hwnd': hwnd, // Gửi HWND từ Flutter
      });
      print(result);
    } on PlatformException catch (e) {
      print("Error performing click: ${e.message}");
    }
  }
}
