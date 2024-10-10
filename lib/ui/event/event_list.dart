import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/event.dart';
import 'package:flutter_auto_tele/ui/event/event_line_painter.dart';
import 'package:flutter_auto_tele/ui/event/event_manager.dart';
import 'package:flutter_auto_tele/ui/event/event_setting.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:provider/provider.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  bool showEventSetting = false;

  Offset eventSettingOffset = const Offset(100, 100);
  List<Event> events = [];
  List<Offset> positions = [];

  Event? selectedEvent;

  @override
  void initState() {
    showEventSetting = false;
    super.initState();
  }

  void _getWidgetOffset(int index) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    double sHeight = renderBox.size.height;
    double sWidth = renderBox.size.width;
    double extraDx = 60;
    double extraDy = 5;

    // Kích thước của eventSetting
    double eventSettingWidth = 250;
    double eventSettingHeight = 155;

    // Khoảng cách từ các cạnh
    double padding = 5.0;

    // Tính toán vị trí tối đa mà eventSetting có thể nằm trong Stack
    double maxDx = sWidth - eventSettingWidth - padding;
    double maxDy = sHeight - eventSettingHeight - padding;

    // Điều chỉnh extraDx và extraDy nếu cần thiết
    if ((sWidth - positions[index].dx) < 330) {
      extraDx = 0;
      extraDy = 65;
    }

    // Tính toán vị trí mới cho eventSetting
    double newDx = positions[index].dx + extraDx;
    double newDy = positions[index].dy + extraDy;

    // Nếu vị trí của nút tròn quá gần cạnh dưới, di chuyển eventSetting lên trên
    if (positions[index].dy + extraDy + eventSettingHeight > sHeight) {
      newDy = positions[index].dy - eventSettingHeight;
    }

    // Đảm bảo rằng eventSetting không tràn ra ngoài và giữ khoảng cách padding
    newDx = newDx.clamp(padding, maxDx);
    newDy = newDy.clamp(padding, maxDy);

    setState(() {
      eventSettingOffset = Offset(newDx, newDy);
    });

    // print('Widget Offset: $eventSettingOffset');
    // print('Widget Offset: $positions[index]');
  }

  void changeShowEventSetting() {
    setState(() {
      print('hidden');
      showEventSetting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventManager>(
      builder: (context, eventManager, child) {
        List<Event> events = eventManager.getEventByScheduleId();
        positions = events
            .map((e) => Offset(e.dx, e.dy))
            .toList(); // Cập nhật positions theo events
        // startedNode = positions.asMap().keys.map((e) => e.toString()).toList();
        Offset center = const Offset(25, 25);
        return Stack(
          children: [
            if (positions.length > 1)
              CustomPaint(
                painter: EventLinePainter(
                  points: positions
                      .map((e) => e + center)
                      .toList(), // Truyền tất cả các điểm cho CustomPainter
                ),
              ),
            ...positions.asMap().entries.map((entry) {
              int index = entry.key;
              Offset position = Offset(entry.value.dx, entry.value.dy);

              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Draggable(
                    feedback: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.5),
                          shape: BoxShape.circle),
                    ),
                    onDragStarted: () {
                      setState(() {
                        showEventSetting = false;
                      });
                    },
                    onDragEnd: (dragDetails) {
                      setState(() {
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        Offset localOffset =
                            renderBox.globalToLocal(dragDetails.offset);
                        positions[index] = localOffset;
                        eventManager.updateEvent(events[index].id,
                            dx: localOffset.dx, dy: localOffset.dy);
                      });
                    },
                    child: buildEventItem(events[index], index)),
              );
            }),
            showEventSetting
                ? Positioned(
                    top: eventSettingOffset.dy,
                    left: eventSettingOffset.dx,
                    child: EventSetting(selectedEvent!, changeShowEventSetting))
                : Container(),
          ],
        );
      },
    );
  }

  Widget buildEventItem(Event event, int index) {
    ScheduleManager scheduleManager = context.read<ScheduleManager>();
    EventManager eventManager = context.read<EventManager>();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _getWidgetOffset(index);
              setState(() {
                showEventSetting = !showEventSetting;
                selectedEvent = event;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10, right: 10),
              alignment: Alignment.center,
              width: 50, // Kích thước tổng cho ba vòng tròn lồng nhau
              height: 50, // Kích thước tổng cho ba vòng tròn lồng nhau
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.7),
                          width: 2, // Độ dày của vòng tròn trung bình
                        ),
                        color: Colors.white),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent, // Vòng tròn nhỏ nhất có màu nền
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (index + 1).toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 7,
            right: 7,
            child: TextButton(
              onPressed: () {
                String currentScheduleId = eventManager.currentScheduleId;
                bool shouldDeleteEventFromSchedule = scheduleManager
                        .getEventCountOfScheduleId(currentScheduleId) ==
                    eventManager.getEventCountBySchduleId(currentScheduleId);
                setState(() {
                  showEventSetting = false;
                  eventManager.deleteEvent(event.id);
                  if (shouldDeleteEventFromSchedule) {
                    scheduleManager.deleteEventOfSchedule(
                        currentScheduleId, event.id);
                  }
                  scheduleManager.calculateTotalTimeWait(currentScheduleId);
                });
              },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(20, 20)),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return Colors.red;
                  },
                ),
                overlayColor: MaterialStateProperty.all(
                    Colors.redAccent.withOpacity(0.2)),
                shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
                  (Set<MaterialState> states) {
                    return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50));
                  },
                ),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
