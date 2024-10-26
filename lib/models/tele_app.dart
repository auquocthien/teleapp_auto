import 'package:flutter_auto_tele/models/schedule.dart';

class TeleApp {
  final String id;
  final String? title;
  final int? hwnd;
  final bool actived;
  final List<Schedule>? schedules;

  TeleApp(
      {required this.id,
      required this.actived,
      this.title,
      this.hwnd,
      this.schedules});

  TeleApp copyWith({
    String? id,
    String? title,
    int? hwnd,
    bool? actived,
    List<Schedule>? schedules,
  }) {
    return TeleApp(
      id: id ?? this.id,
      title: title ?? this.title,
      hwnd: hwnd ?? this.hwnd,
      actived: actived ?? this.actived,
      schedules: schedules ?? this.schedules,
    );
  }
}
