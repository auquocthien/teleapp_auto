import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/schedule.dart';
import 'package:flutter_auto_tele/services/app_control.dart';

import 'package:flutter_auto_tele/ui/event/event_manager.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_events.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:flutter_auto_tele/ui/shared/toast_helper.dart';
import 'package:provider/provider.dart';

import 'package:toastification/toastification.dart';
import 'dart:io';

class ScheduleItem extends StatefulWidget {
  final Schedule schedule;
  final int hwnd;
  const ScheduleItem(this.schedule, this.hwnd, {super.key});

  @override
  State<ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<ScheduleItem> {
  late String scheduleName = '';
  int scheduleRepeatCount = 0;
  bool isEditTitile = false;

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _titleSchedule = TextEditingController();

  AppControl appControl = AppControl();

  void calculateTotalTimeWait() {
    bool isChangeTotalTimeWait = scheduleRepeatCount != 0;

    if (widget.schedule.totalTimeWait != null) {
      setState(() {
        _hourController.text = isChangeTotalTimeWait
            ? '00'
            : widget.schedule.totalTimeWait!.inHours.toString();
        _minuteController.text = isChangeTotalTimeWait
            ? '00'
            : (widget.schedule.totalTimeWait!.inMinutes % 60).toString();
        _secondController.text = isChangeTotalTimeWait
            ? '00'
            : (widget.schedule.totalTimeWait!.inSeconds % 60).toString();
      });
    }
  }

  @override
  void initState() {
    _titleSchedule.text = widget.schedule.scheduleName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    calculateTotalTimeWait();
    String currentScheduleId = context.watch<EventManager>().scheduleId;
    bool isSelected = (currentScheduleId == widget.schedule.id);
    Color borderColor = !isSelected ? Colors.grey : Colors.black;
    List<BoxShadow> boxShadow = isSelected
        ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ]
        : [];
    return GestureDetector(
      onTap: () {
        context.read<EventManager>().currentSchedule = widget.schedule.id;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 250,
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: borderColor),
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 252, 252, 252),
            boxShadow: boxShadow),
        child: Column(
          children: [
            Container(
              height: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: !isEditTitile
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            widget.schedule.scheduleName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isEditTitile = !isEditTitile;
                              });
                            },
                            icon: const Icon(Icons.edit))
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: buildTitleSchedule(),
                    ),
            ),
            Expanded(child: ScheduleEvents(widget.schedule.id)),
            Container(
              height: 45,
              width: 250,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(width: 0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      'Time until next run',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  buildTotalTimeWait(),
                ],
              ),
            ),
            Container(
              height: 49 * 2,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: buildFooterBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTitleSchedule() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextField(
        controller: _titleSchedule,
        autofocus: true,
        onSubmitted: (value) {
          setState(() {
            context
                .read<ScheduleManager>()
                .updateSchedule(widget.schedule.id, schedulName: value);
            isEditTitile = !isEditTitile;
            _titleSchedule.text = value;
          });
        },
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
            suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isEditTitile = !isEditTitile;
            });
          },
          icon: const Icon(Icons.exit_to_app),
        )),
      ),
    );
  }

  Widget buildFooterBar() {
    ScheduleManager scheduleManager = context.read<ScheduleManager>();
    EventManager eventManager = context.read<EventManager>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildButtonFooter('Save', () {}, Colors.green),
            buildButtonFooter('Add', () {
              if (widget.schedule.scheduleName != 'Reload schedule') {
                eventManager.addEvent(
                  widget.schedule.id,
                );
                eventManager.currentSchedule = widget.schedule.id;
                showCustomToast(context, 'add event sucsess',
                    type: ToastificationType.info);
                setState(() {});
              }
            }, const Color.fromARGB(255, 255, 233, 38)),
            buildButtonFooter('Del', () {
              scheduleManager.deleteSchedule(widget.schedule.id);
              eventManager.resetEventByScheduleId(widget.schedule.id);
              setState(() {});
            }, Colors.red),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildRepeatCount(),
            buildButtonFooter('Run', () async {
              String result = await appControl.captureScreenshot(widget.hwnd);
              // throw Exception('this is test');
            }, Colors.blue),
            buildButtonFooter('Reset', () {
              context.read<EventManager>().resetEvent();
              context
                  .read<ScheduleManager>()
                  .resetEventOfSchedule(widget.schedule.id);
              setState(() {
                scheduleRepeatCount = 0;
              });
            }, Colors.redAccent),
          ],
        )
      ],
    );
  }

  Widget buildTotalTimeWait() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        timeWaitItem(_hourController),
        const Center(
          child: Text(
            ':',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        timeWaitItem(_minuteController),
        const Center(
          child: Text(
            ':',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        timeWaitItem(_secondController),
      ],
    );
  }

  Widget timeWaitItem(TextEditingController controller) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        enabled: scheduleRepeatCount != 0,
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.only(bottom: 10)),
        onChanged: (value) {
          if (value.isNotEmpty) {
            int? input = int.tryParse(value);
            if (input != null) {
              if (controller == _hourController) {
                if (input < 0 || input > 23) {
                  controller.text = '00';
                }
              } else if (controller == _minuteController ||
                  controller == _secondController) {
                if (input < 0 || input > 59) {
                  controller.text = '00';
                }
              }
            }
          }
        },
      ),
    );
  }

  Widget buildButtonFooter(String label, VoidCallback func, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: func,
        child: Container(
          height: 35,
          width: 65,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ], color: color, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRepeatCount() {
    return Container(
      height: 35,
      width: 65,
      padding: const EdgeInsets.only(left: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.7),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: scheduleRepeatCount,
          items: List.generate(
            11,
            (index) => DropdownMenuItem<int>(
              value: index,
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              scheduleRepeatCount = value!;
            });
          },
        ),
      ),
    );
  }
}
