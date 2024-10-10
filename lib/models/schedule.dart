import 'package:flutter_auto_tele/models/event.dart';

class Schedule {
  final String id;
  final String scheduleName;
  final DateTime? startTime;
  final DateTime? interupTime;
  final List<Event>? events;
  final int repeatCount;
  final Duration? totalTimeWait;

  Schedule(
      {required this.id,
      required this.scheduleName,
      required this.repeatCount,
      this.totalTimeWait,
      this.events,
      this.startTime,
      this.interupTime});

  Schedule copyWith(
      {String? id,
      String? scheduleName,
      List<Event>? events,
      DateTime? startTime,
      DateTime? interupTime,
      int? repeatCount,
      Duration? totalTimeWait}) {
    return Schedule(
        id: id ?? this.id,
        scheduleName: scheduleName ?? this.scheduleName,
        events: events ?? List.from(this.events ?? []),
        startTime: startTime ?? this.startTime,
        interupTime: interupTime ?? this.interupTime,
        repeatCount: repeatCount ?? this.repeatCount,
        totalTimeWait: totalTimeWait ?? this.totalTimeWait);
  }
}
