import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';

class ScheduleEventItem extends StatefulWidget {
  final Event event;
  final int eventIndex;
  const ScheduleEventItem(this.event, this.eventIndex, {super.key});

  @override
  State<ScheduleEventItem> createState() => _ScheduleEventItemState();
}

class _ScheduleEventItemState extends State<ScheduleEventItem> {
  double firstColumnWidth = 85;
  double secondColumnWidth = 105;

  String lastActive = '';
  String nextActive = '';
  int timeWaitHour = 0;
  int timeWaitMinute = 0;
  int timeWaitSecond = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(top: 10, left: 10),
          padding: const EdgeInsets.all(10),
          height: 150,
          width: 230,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(14)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // Vị trí của bóng
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildTypeOfEvent(),
                  SizedBox(
                    width: secondColumnWidth,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [buildClickTimes(), buildTimeWait()],
              ),
              buildDisplayTimeActive(lastActive, 'Last'),
              buildDisplayTimeActive(nextActive, 'Next')
            ],
          ),
        ),
      ),
      Positioned(
          right: 9,
          top: 10,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.blueAccent),
            child: Center(
              child: Text(
                (widget.eventIndex + 1).toString(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )),
    ]);
  }

  Widget buildTypeOfEvent() {
    return Container(
        alignment: Alignment.center,
        width: firstColumnWidth,
        height: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.green),
        child: Text(
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          capitalize(widget.event.actionType),
          textAlign: TextAlign.center,
        ));
  }

  Widget buildClickTimes() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      width: firstColumnWidth,
      height: 35,
      child: Text(
        widget.event.clickCount.toString(),
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget buildTimeWait() {
    timeWaitHour = widget.event.timeWait.inHours;
    timeWaitMinute = (widget.event.timeWait.inMinutes % 60);
    timeWaitSecond = (widget.event.timeWait.inSeconds % 60);
    return SizedBox(
      width: secondColumnWidth,
      height: 35,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300]),
            width: 30,
            height: 35,
            child: Center(
              child: Text(
                timeWaitHour.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            child: Center(
              child: Text(
                ':',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300]),
            width: 30,
            height: 35,
            child: Center(
              child: Text(
                timeWaitMinute.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            child: Center(
              child: Text(
                ':',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300]),
            width: 30,
            height: 35,
            child: Center(
              child: Text(
                timeWaitSecond.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDisplayTimeActive(String timeActive, String title) {
    return SizedBox(
      width: 200,
      height: 20,
      child: Text('$title active: $timeActive',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }
}
