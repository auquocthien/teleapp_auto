class Event {
  final String id;
  final String actionName;
  final String actionType;
  final Duration timeWait;
  final double dx;
  final double dy;
  final DateTime? lastActive;
  final int? clickCount;

  Event(
      {required this.id,
      required this.actionName,
      required this.actionType,
      required this.timeWait,
      required this.dx,
      required this.dy,
      this.lastActive,
      this.clickCount});

  Event copyWith(
      {String? id,
      String? actionName,
      String? actionType,
      Duration? timeWait,
      double? dx,
      double? dy,
      DateTime? lastActive,
      int? clickCount}) {
    return Event(
        id: id ?? this.id,
        actionName: actionName ?? this.actionName,
        actionType: actionType ?? this.actionType,
        timeWait: timeWait ?? this.timeWait,
        dx: dx ?? this.dx,
        dy: dy ?? this.dy,
        lastActive: lastActive ?? this.lastActive,
        clickCount: clickCount ?? this.clickCount);
  }

  DateTime? getNextTriggerTime() {
    if (lastActive == null) return null;
    return lastActive!.add(timeWait);
  }

  bool canTrigger() {
    if (lastActive == null) return true;
    DateTime nextTriggerTime = getNextTriggerTime()!;
    return DateTime.now().isAfter(nextTriggerTime);
  }

  @override
  String toString() {
    return 'Event(id: $id, actionName: $actionName, actionType: $actionType, timeWait: $timeWait, dx: $dx, dy: $dy)';
  }
}
