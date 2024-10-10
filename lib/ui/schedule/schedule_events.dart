import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_event_item.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:provider/provider.dart';

class ScheduleEvents extends StatefulWidget {
  final String scheduleId;
  const ScheduleEvents(this.scheduleId, {super.key});

  @override
  State<ScheduleEvents> createState() => _ScheduleEventsState();
}

class _ScheduleEventsState extends State<ScheduleEvents> {
  @override
  Widget build(BuildContext context) {
    ScheduleManager scheduleManager = context.watch<ScheduleManager>();
    List<Event> events =
        scheduleManager.getAllEventOfSchedule(widget.scheduleId);
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: events.length,
        itemBuilder: (context, index) {
          return events.isEmpty
              ? Container()
              : ScheduleEventItem(events[index], index);
        });
  }
}
