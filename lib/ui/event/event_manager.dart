import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';

class EventManager extends ChangeNotifier {
  List<Event> _events = [];
  String currentScheduleId = '';

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
      int? preNode,
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
        preNode: preNode,
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
    int? preNode,
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
        preNode: preNode,
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
}
