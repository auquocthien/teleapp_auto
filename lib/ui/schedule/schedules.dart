import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/schedule.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_item.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:provider/provider.dart';

class Schedules extends StatefulWidget {
  final String appId;
  const Schedules(this.appId, {super.key});

  @override
  State<Schedules> createState() => SchedulesState();
}

class SchedulesState extends State<Schedules> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleManager>(
        builder: (context, scheduleManager, child) {
      List<Schedule> schedules =
          context.read<ScheduleManager>().getScheduleByAppId(widget.appId);
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: schedules.length,
          itemBuilder: (BuildContext context, int index) {
            return ScheduleItem(
              schedules[index],
            );
          });
    });
  }
}
