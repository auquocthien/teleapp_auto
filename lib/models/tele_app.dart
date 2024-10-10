import 'package:flutter_auto_tele/models/schedule.dart';

class TeleApp {
  final String id;
  final String? title;
  final List<Schedule>? schedules;

  TeleApp({required this.id, this.title, this.schedules});

  TeleApp copyWith({
    String? id,
    String? title,
    List<Schedule>? schedules,
  }) {
    return TeleApp(
      id: id ?? this.id,
      title: title ?? this.title, // Giữ nguyên title nếu không có giá trị mới
      schedules: schedules ??
          this.schedules, // Giữ nguyên schedules nếu không có giá trị mới
    );
  }
}
