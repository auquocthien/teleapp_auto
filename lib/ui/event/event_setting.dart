import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';
import 'package:flutter_auto_tele/ui/event/event_manager.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:provider/provider.dart';

class EventSetting extends StatefulWidget {
  final Event event;
  final VoidCallback changeShowEventSetting;
  const EventSetting(this.event, this.changeShowEventSetting, {super.key});

  @override
  State<EventSetting> createState() => _EventSettingState();
}

class _EventSettingState extends State<EventSetting> {
  List<String> startedNode = [];

  bool multiClick = false;
  bool singleClick = true;
  final TextEditingController _controller = TextEditingController();

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  void initEventSetting() {
    Event event = widget.event;
    multiClick = event.actionType == 'multi';
    singleClick = event.actionType == 'single';
    _controller.text =
        event.clickCount!.toInt() > 1 ? event.clickCount.toString() : '0';
    _hourController.text = event.timeWait.inHours.toString();
    _minuteController.text = (event.timeWait.inMinutes % 60).toString();
    _secondController.text = (event.timeWait.inSeconds % 60).toString();
  }

  void updateEvent() {
    EventManager eventManager = context.read<EventManager>();
    ScheduleManager scheduleManager = context.read<ScheduleManager>();

    Duration timeWait = Duration(
        hours: int.parse(_hourController.text),
        minutes: int.parse(_minuteController.text),
        seconds: int.parse(_secondController.text));

    String actionType = multiClick ? 'multi' : 'single';
    int clickCount = int.parse(_controller.text);

    eventManager.updateEvent(
      widget.event.id,
      timeWait: timeWait,
      actionType: actionType,
      clickCount: clickCount,
      actionName: widget.event.id,
    );
    Event? event = eventManager.getEventById(widget.event.id);
    String scheduleId = eventManager.currentScheduleId;
    scheduleManager.addEventToSchedule(scheduleId, event!);
    scheduleManager.calculateTotalTimeWait(scheduleId);
    scheduleManager.sortEventOfScheduleByDate(scheduleId);
  }

  @override
  void initState() {
    super.initState();
    initEventSetting();
  }

  double clickTimesWidth = 95;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Vị trí của bóng
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 55,
            child: buildTypeOfEvent(),
          ),
          SizedBox(
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                multiClick
                    ? buildClickTimes()
                    : SizedBox(
                        width: clickTimesWidth,
                      ),
                buildTimeWaitSelect()
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildEventSettingButton(
                  () {
                    updateEvent();
                    widget.changeShowEventSetting();
                    setState(() {});
                  },
                  Colors.blueAccent,
                  Icons.check,
                ),
                buildEventSettingButton(
                  () {
                    print('Event execution started');
                  },
                  Colors.greenAccent,
                  Icons.play_arrow_rounded,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildEventSettingButton(
      VoidCallback ontapFunc, Color btnColor, IconData btnIcon) {
    return GestureDetector(
      onTap: ontapFunc,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 100,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              color: btnColor,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          child: Icon(
            btnIcon,
            size: 30,
            weight: 500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildTypeOfEvent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 95,
          child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (multiClick) {
                    return Colors.green;
                  }
                  return null;
                }),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              onPressed: () {
                setState(() {
                  multiClick = !multiClick;
                  singleClick = !singleClick;
                });
              },
              child: Text(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: multiClick ? Colors.white : Colors.black),
                'Multi',
                textAlign: TextAlign.center,
              )),
        ),
        SizedBox(
          width: 105,
          child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (singleClick) {
                    return Colors.green;
                  }
                  return null;
                }),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              onPressed: () {
                setState(() {
                  singleClick = !singleClick;
                  multiClick = !multiClick;
                });
              },
              child: Text(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: singleClick ? Colors.white : Colors.black),
                'Sigle',
                textAlign: TextAlign.center,
              )),
        )
      ],
    );
  }

  Widget buildClickTimes() {
    return Container(
      alignment: Alignment.center,
      width: clickTimesWidth,
      height: 40,
      child: Column(children: [
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.only(bottom: 10)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 2),
              height: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    child: InkWell(
                      child: const Icon(
                        Icons.arrow_drop_up,
                        size: 18.0,
                      ),
                      onTap: () {
                        int currentValue = int.parse(_controller.text);
                        setState(() {
                          currentValue++;
                          _controller.text =
                              (currentValue).toString(); // incrementing value
                        });
                      },
                    ),
                  ),
                  Container(
                    child: InkWell(
                      child: const Icon(
                        Icons.arrow_drop_down,
                        size: 18.0,
                      ),
                      onTap: () {
                        int currentValue = int.parse(_controller.text);
                        setState(() {
                          print("Setting state");
                          currentValue--;
                          _controller.text =
                              (currentValue > 0 ? currentValue : 0)
                                  .toString(); // decrementing value
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget buildTimeWaitSelect() {
    return Container(
      width: 105,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimeInputField(_hourController), // Ô nhập giờ
          const Center(
            child: Text(
              ':',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          buildTimeInputField(_minuteController),
          const Center(
            child: Text(
              ':',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ), // Ô nhập phút
          buildTimeInputField(_secondController), // Ô nhập phút
        ],
      ),
    );
  }

  Widget buildTimeInputField(TextEditingController controller) {
    return Container(
      width: 30,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    // Giới hạn giờ từ 0 đến 23
                    controller.text = '00';
                  }
                } else if (controller == _minuteController ||
                    controller == _secondController) {
                  if (input < 0 || input > 59) {
                    // Giới hạn phút từ 0 đến 59
                    controller.text = '00';
                  }
                }
              }
            }
          },
        ),
      ),
    );
  }
}
