import 'package:flutter/services.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

class AppControl {
  static const MethodChannel _channel =
      MethodChannel('com.example.window_control');

  final String targetWindows = 'TelegramDesktop';

  Future<List<TeleApp>> getOpenWindows() async {
    try {
      final List<dynamic> windowList =
          await _channel.invokeMethod('getOpenWindows');

      final List<dynamic> filteredList = windowList
          .where((element) => element.toString().contains(targetWindows))
          .toList();
      List<TeleApp> apps = [];
      for (var e in filteredList.asMap().entries) {
        String title = e.value.toString().split(' - ')[0];
        int hwnd = int.parse(e.value.toString().split(' - ').last);
        TeleApp app = TeleApp(
            id: 'app-${e.key}', title: title, hwnd: hwnd, actived: true);

        apps.add(app);
      }
      return apps;
    } on PlatformException catch (e) {
      throw "Failed to get open windows: '${e.message}'.";
    }
  }

  Future<String> captureScreenshot(int hwnd) async {
    try {
      String result = await _channel.invokeMethod('captureScreenshot', hwnd);
      return result;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      // Trả về một giá trị mặc định hoặc giá trị báo lỗi
      return 'Error: Failed to capture screenshot';
    }
  }
}
