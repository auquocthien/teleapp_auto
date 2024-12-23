import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';
import 'package:flutter_auto_tele/models/schedule.dart';
import 'package:flutter_auto_tele/ui/event/event_manager.dart';

class ScheduleManager extends ChangeNotifier {
  final List<Schedule> _schedule = [];
  final EventManager eventManager = EventManager();

  ScheduleManager();

  int get scheduleCount {
    return _schedule.length;
  }

  int getEventCountOfScheduleId(String scheduleId) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);
    if (_schedule[index].events == null) {
      return 0;
    }
    return _schedule[index].events!.length;
  }

  List<Schedule> get schedules {
    return [..._schedule];
  }

  List<Event> getAllEventOfSchedule(String scheduleId) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);
    if (_schedule[index].events == null) {
      return [];
    }
    return [...?_schedule[index].events];
  }

  void addSchedule(String appId, {String? scheduleName}) {
    int scheduleIndex = scheduleCount > 0 ? scheduleCount : 0;
    Schedule schedule = Schedule(
        id: '$appId/schdeule-$scheduleIndex',
        scheduleName: scheduleName ?? '$appId/schdeule_$scheduleIndex',
        repeatCount: 0,
        isActive: false);
    _schedule.add(schedule);
    notifyListeners();
  }

  void deleteSchduleByAppId(String appId) {
    _schedule.removeWhere((element) => element.id.contains(appId));
    notifyListeners();
  }

  void addEventToSchedule(String scheduleId, Event event) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);

    if (index != -1) {
      List<Event> events = _schedule[index].events != null
          ? List.from(_schedule[index].events!)
          : [];
      int exitsEventIndex = events
          .indexWhere((element) => element.actionName == event.actionName);

      if (exitsEventIndex == -1) {
        events.add(event);
      } else {
        events[exitsEventIndex] = events[exitsEventIndex].copyWith(
            actionName: event.actionName,
            actionType: event.actionType,
            timeWait: event.timeWait,
            dx: event.dx,
            dy: event.dy,
            lastActive: event.lastActive,
            clickCount: event.clickCount);
      }
      _schedule[index] = _schedule[index].copyWith(events: events);
      notifyListeners();
    }
  }

  void deleteSchedule(String scheduleId) {
    int index = _schedule.indexWhere((schedule) => schedule.id == scheduleId);
    if (index != -1) {
      _schedule.removeAt(index);
      notifyListeners();
    }
  }

  void deleteEventOfSchedule(String scheduleId, String eventId) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);
    if (index != -1) {
      List<Event> events = _schedule[index].events != null
          ? List.from(_schedule[index].events!)
          : [];
      int eventIndex = events.indexWhere((element) => element.id == eventId);

      if (eventIndex != -1) {
        events.removeAt(eventIndex);
        _schedule[index] = _schedule[index].copyWith(events: events);
        notifyListeners();
      }
    }
  }

  List<Schedule> getScheduleByAppId(String appId) {
    List<Schedule> result = [];
    for (var element in _schedule) {
      if (element.id.contains(appId)) {
        result.add(element);
      }
    }

    return result;
  }

  void resetEventOfSchedule(String scheduleId) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);
    if (index != 1) {
      _schedule[index] = _schedule[index].copyWith(events: []);
      notifyListeners();
    }
  }

  void calculateTotalTimeWait(String scheduleId) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);
    if (index != -1) {
      Duration totalTimeWait = Duration.zero;
      for (var element in _schedule[index].events!) {
        totalTimeWait = totalTimeWait + element.timeWait;
      }
      _schedule[index] =
          _schedule[index].copyWith(totalTimeWait: totalTimeWait);
      notifyListeners();
    }
  }

  void sortEventOfScheduleByDate(String scheduleId) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);
    if (index != -1) {
      List<Event> events = _schedule[index].events != null
          ? List.from(_schedule[index].events!)
          : [];

      events
          .sort((a, b) => a.id.split('-').last.compareTo(b.id.split('-').last));
      _schedule[index] = _schedule[index].copyWith(events: events);
      notifyListeners();
    }
  }

  int getScheduleCountOfApp(String appId) {
    return _schedule.where((element) => element.id == appId).length;
  }

  void updateSchedule(String scheduleId,
      {String? schedulName,
      DateTime? startTime,
      DateTime? interupTime,
      List<Event>? events,
      int? repeatCount,
      bool? isActive}) {
    int index = _schedule.indexWhere((element) => element.id == scheduleId);

    if (index != -1) {
      _schedule[index] = _schedule[index].copyWith(
          scheduleName: schedulName,
          startTime: startTime,
          interupTime: interupTime,
          events: events,
          repeatCount: repeatCount,
          isActive: isActive);
      notifyListeners();
      // print(schedules[index]);
    } else {
      print('error when update schedule name');
    }
  }
}
