import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/services/app_control.dart';

class TeleAppManager with ChangeNotifier {
  List<TeleApp> _teleApps = [];
  final AppControl appControl;

  TeleAppManager() : appControl = AppControl();
  // Trả về số lượng TeleApps
  int get teleAppCount => _teleApps.length;

  // Lấy tất cả TeleApps
  List<TeleApp> get teleApps => [..._teleApps];

  Future<void> getTeleApp() async {
    List<TeleApp> apps = await appControl.getOpenWindows();
    if (_teleApps.isEmpty) {
      _teleApps = apps;
    } else {
      for (var i = 0; i < _teleApps.length; i++) {
        var teleApp = _teleApps[i];
        if (!apps.any((app) => app.hwnd == teleApp.hwnd)) {
          _teleApps[i] = teleApp.copyWith(actived: false);
        }
      }

      for (var app in apps) {
        if (!_teleApps.any((teleApp) => app.hwnd == teleApp.hwnd)) {
          _teleApps.add(app);
        }
      }
    }
    notifyListeners();
  }

  Future<void> refeshApp() async {}

  // void addTeleApp() {
  //   String teleAppId = 'app-$teleAppCount';
  //   TeleApp teleApp = TeleApp(id: teleAppId);
  //   _teleApps.add(teleApp);
  //   notifyListeners();
  // }

  void updateTitle(String appId, String newTitle) {
    int index = _teleApps.indexWhere((element) => element.id == appId);
    if (index != -1) {
      _teleApps[index] = _teleApps[index].copyWith(title: newTitle);
      notifyListeners();
    } else {
      print('app not found');
    }
  }

  void deleteTeleAppById(String appId) {
    int appIndex = _teleApps.indexWhere((element) => element.id == appId);
    if (appIndex != -1) {
      _teleApps.removeAt(appIndex);
      notifyListeners();
    } else {
      print('app id not found');
    }
  }

  TeleApp? getAppById(String appId) {
    int index = _teleApps.indexWhere((element) => element.id == appId);
    if (index != -1) {
      return _teleApps[index];
    }
    return null;
  }
}
