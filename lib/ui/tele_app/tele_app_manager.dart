import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';

class TeleAppManager extends ChangeNotifier {
  final List<TeleApp> _teleApps = [];

  // Trả về số lượng TeleApps
  int get teleAppCount => _teleApps.length;

  // Lấy tất cả TeleApps
  List<TeleApp> get teleApps => [..._teleApps];

  // Thêm một TeleApp mới
  void addTeleApp() {
    String teleAppId = 'app-$teleAppCount';
    TeleApp teleApp = TeleApp(id: teleAppId);
    _teleApps.add(teleApp);
    notifyListeners();
  }

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
