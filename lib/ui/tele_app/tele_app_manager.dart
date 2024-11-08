import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/services/app_control.dart';

class TeleAppManager extends ChangeNotifier {
  List<TeleApp> teleApps = [];
  final AppControl appControl;

  TeleAppManager() : appControl = AppControl();
  // Trả về số lượng TeleApps
  int get teleAppCount => teleApps.length;

  // Lấy tất cả TeleApps
  List<TeleApp> get teleAppsList => [...teleApps];

  Future<void> getTeleApp() async {
    List<TeleApp> apps = await appControl.getOpenWindows();
    Map<int, TeleApp> appMap = {for (var app in apps) app.hwnd!: app};

    if (teleApps.isEmpty) {
      teleApps.addAll(apps);
    } else {
      for (var i = 0; i < teleApps.length; i++) {
        var teleApp = teleApps[i];
        if (!appMap.containsKey(teleApp.hwnd)) {
          teleApps[i] = teleApp.copyWith(actived: false);
        }
      }

      for (var app in apps) {
        if (!teleApps.any((teleApp) => teleApp.hwnd == app.hwnd)) {
          teleApps.add(app);
        }
      }
    }
    notifyListeners();
  }

  void updateTitle(String appId, String newTitle) {
    print(teleApps);
    int index = teleApps.indexWhere((element) => element.id == appId);
    if (index != -1) {
      teleApps[index] = teleApps[index].copyWith(title: newTitle);
      print(teleApps[index].title);
      notifyListeners();
    } else {
      print('app not found');
    }
  }

  void deleteTeleAppById(String appId) {
    int appIndex = teleApps.indexWhere((element) => element.id == appId);
    if (appIndex != -1) {
      teleApps.removeAt(appIndex);
      notifyListeners();
    } else {
      print('app id not found');
    }
  }

  TeleApp? getAppById(String appId) {
    int index = teleApps.indexWhere((element) => element.id == appId);
    if (index != -1) {
      return teleApps[index];
    }
    return null;
  }
}
