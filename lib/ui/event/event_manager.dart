import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';

class EventManager extends ChangeNotifier {
  List<Event> _events = [];
  String currentScheduleId = '';
  int currentAppHwnd = 0;
  final Offset reloadCoordinates = const Offset(300, 28);
  final Offset reloadButton = const Offset(300, 50);
  final String telebotToken = '7791763155:AAHLRzFaKZFBC5T-_PqDQqy4cvMtpIVI_40';
  final String chatId = '6401692795';
  final String windowSize = '402x712';

  EventManager();

  int get eventCount {
    return _events.length;
  }

  int getEventCountBySchduleId(String scheduleId) {
    return _events.where((element) => element.id.contains(scheduleId)).length;
  }

  set currentSchedule(String selectSchedule) {
    currentScheduleId = selectSchedule;
    notifyListeners();
  }

  set currentHwnd(int hwnd) {
    currentAppHwnd = hwnd;
    notifyListeners();
  }

  List<Event> get events {
    return [..._events];
  }

  List<Event> getEventByScheduleId({String? scheduleId}) {
    scheduleId ??= currentScheduleId;
    List<Event> result = [];
    for (var element in _events) {
      if (element.id.contains(scheduleId)) {
        result.add(element);
      }
    }
    return result;
  }

  String get scheduleId {
    return currentScheduleId;
  }

  int get appHwnd {
    return currentAppHwnd;
  }

  Event? getEventById(String eventId) {
    int index = _events.indexWhere((element) => element.id == eventId);
    if (index != -1) {
      return _events[index];
    }
    return null;
  }

  void deleteEvent(String eventId) {
    int index = _events.indexWhere((element) => element.id == eventId);
    if (index != -1) {
      _events.removeAt(index);
    }
    notifyListeners();
  }

  void resetEvent() {
    _events = [];
    notifyListeners();
  }

  void resetEventByScheduleId(String scheduleId) {
    _events.removeWhere((element) => element.id.contains(scheduleId));
    notifyListeners();
  }

  void addEvent(String scheduleId,
      {String actionName = 'Default Action',
      String actionType = 'single',
      Duration timeWait = Duration.zero,
      int? clickCount}) {
    int eventCountByScheduleId = getEventCountBySchduleId(scheduleId);
    String eventId = DateTime.now().microsecondsSinceEpoch.toString();
    final newEvent = Event(
        id: '$scheduleId/event-$eventId',
        actionName: actionName,
        actionType: actionType,
        timeWait: timeWait,
        dx: (eventCountByScheduleId * 15) + 100,
        dy: (eventCountByScheduleId * 15) + 100,
        clickCount: actionType == 'multi' ? clickCount : 0);

    scheduleId = scheduleId;
    _events.add(newEvent);
    notifyListeners();
  }

  void swapEvent(int first, int second) {
    Event temp = _events[first];
    _events[first] = _events[second];
    _events[second] = temp;

    notifyListeners();
  }

  void updateEvent(
    String eventId, {
    String? actionName,
    String? actionType,
    Duration? timeWait,
    double? dx,
    double? dy,
    DateTime? lastActive, // Cập nhật để thay đổi lastActive
    int? clickCount,
  }) {
    int index = _events.indexWhere((element) => element.id == eventId);
    if (index < 0 || index >= _events.length) {
      return;
    }

    final updatedEvent = _events[index].copyWith(
        actionName: actionName,
        actionType: actionType,
        timeWait: timeWait,
        dx: dx,
        dy: dy,
        lastActive: lastActive,
        clickCount: clickCount);

    _events[index] = updatedEvent;
    notifyListeners();
  }

  void triggerEvent(String eventId) {
    int index = _events.indexWhere((element) => element.id == eventId);

    if (index < 0 || index >= _events.length) {
      return;
    }

    final event = _events[index];
    if (event.canTrigger()) {
      // Xử lý sự kiện
      print('Event triggered: ${event.actionName}');

      // Cập nhật thời gian kích hoạt lần cuối
      _events[index] = event.copyWith(lastActive: DateTime.now());
      notifyListeners();
    } else {
      print('Event cannot be triggered yet.');
    }
  }

  List<Event> getListEventReload(String scheduleId) {
    String eventId = DateTime.now().microsecondsSinceEpoch.toString();

    if (isExitsReloadEvent()) {
      return findReloadEvent();
    } else {
      Event open = Event(
          id: '$scheduleId/event-$eventId',
          actionName: 'open reload panel',
          actionType: 'single',
          clickCount: 0,
          dx: reloadCoordinates.dx,
          dy: reloadCoordinates.dy,
          timeWait: const Duration(minutes: 30));
      Event click = Event(
          id: '$scheduleId/event-$eventId',
          actionName: 'click reload button',
          actionType: 'single',
          clickCount: 0,
          dx: reloadButton.dx,
          dy: reloadButton.dy,
          timeWait: const Duration(minutes: 30));
      _events.addAll([open, click]);
      notifyListeners();
      return [open, click];
    }
  }

  bool isExitsReloadEvent() {
    return _events.any((element) => element.actionType == 'reload');
  }

  List<Event> findReloadEvent() {
    return _events.where((element) => element.actionType == 'reload').toList();
  }

  List<double> calculateRealCor(double dx, double dy) {
    // double realDx = dx + (dx * (350 / 402));
    // double realDy = dy + (dy * (692 / 712));
    double realDx = ((dx + 30) / 350) * 402;
    double realDy = ((dy + 65) / 692) * 712;
    return [realDx, realDy];
  }
}
