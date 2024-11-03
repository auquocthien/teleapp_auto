import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/ui/event/event_list.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:flutter_auto_tele/ui/schedule/schedules.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

class AddSchedule extends StatefulWidget {
  static const String routeName = '/add_schedule';
  final String appId;
  const AddSchedule(this.appId, {super.key});

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  int scheduleCount = 0;

  @override
  Widget build(BuildContext context) {
    TeleApp? app = context.read<TeleAppManager>().getAppById(widget.appId);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Add Schedule ${app!.title.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 50,
                decoration: BoxDecoration(border: Border.all(width: 0.5)),
                child: buildToolBar(),
              ),
              Expanded(
                child: Schedules(widget.appId, app.hwnd!),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                width: 64 * 6,
                height: MediaQuery.of(context).size.height,
                child: const EventList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            context.read<ScheduleManager>().addSchedule(widget.appId);
            setState(() {});
          },
          icon: const Icon(Icons.add),
          color: Colors.blue,
          iconSize: 30,
          tooltip: 'Add Schedule',
        ),
        const SizedBox(height: 10),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.save),
          color: Colors.green,
          iconSize: 30,
          tooltip: 'Save Schedule',
        ),
        const SizedBox(height: 10),
        IconButton(
          onPressed: () {
            _showSearchDialog(context);
          },
          icon: const Icon(Icons.search),
          color: Colors.blueAccent,
          iconSize: 30,
          tooltip: 'Search',
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Schedule'),
          content: const TextField(
            decoration: InputDecoration(
              hintText: 'Enter search term...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
