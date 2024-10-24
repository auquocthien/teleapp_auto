import 'package:flutter/services.dart';

class AppControl {
  static const MethodChannel _channel =
      MethodChannel('com.example.window_control');

  final String targetWindows = 'TelegramDesktop';

  Future<List<String>> getOpenWindows() async {
    try {
      final List<dynamic> windowList =
          await _channel.invokeMethod('getOpenWindows');

      final List<dynamic> filteredList = windowList
          .where((element) => element.toString().contains(targetWindows))
          .toList();
      return List<String>.from(filteredList);
    } on PlatformException catch (e) {
      throw "Failed to get open windows: '${e.message}'.";
    }
  }
}
