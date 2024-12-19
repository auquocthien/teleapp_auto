import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/config/config.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/services/app_control.dart';
import 'package:flutter_auto_tele/services/images_control.dart';
import 'package:flutter_auto_tele/ui/schedule/add_schedule.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

class CellItem extends StatefulWidget {
  final TeleApp app;
  const CellItem(this.app, {super.key});

  @override
  State<CellItem> createState() => _CellItemState();
}

class _CellItemState extends State<CellItem> {
  AppControl appControl = AppControl();
  ImagesControl imagesControl = ImagesControl();
  String? imagePath;
  bool isEditing = false;
  String titleApp = '';
  // bool isHovered = false;
  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    loadImagePath();
    titleApp = widget.app.hwnd.toString();
  }

  Future<void> loadImagePath() async {
    String path = '$temporarySavePath/${widget.app.hwnd}.png';
    try {
      bool fileExists = await File(path).exists();
      if (!fileExists) {
        await appControl.captureScreenshot(widget.app.hwnd!);
      }
      String croppedPath =
          await imagesControl.cropImage(path, 10, isHome: true);
      await imagesControl.deleteImage(widget.app.hwnd!);
      setState(() {
        imagePath = croppedPath;
      });
    } catch (e) {
      print('loadImagePath: $e');
    }
  }

  Future<void> reCaptureScreenshot() async {
    String path = '$temporarySavePath/${widget.app.hwnd}_home.png';
    try {
      if (await File(path).exists()) {
        imageCache.evict(FileImage(File(path)));
        await File(path).delete();
      }
      await appControl.captureScreenshot(widget.app.hwnd!);
      await loadImagePath(); // Tải lại đường dẫn ảnh sau khi chụp lại
    } catch (e) {
      print('reCaptureScreenshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BoxShadow> boxShadow = widget.app.actived
        ? [
            const BoxShadow(
              color: Color.fromARGB(255, 0, 195, 255),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
            const BoxShadow(
              color: Color.fromARGB(184, 12, 161, 187),
              blurRadius: 20,
              spreadRadius: 10,
              offset: Offset(0, 5),
            )
          ]
        : [
            const BoxShadow(
              color: Color.fromARGB(255, 248, 1, 125),
              blurRadius: 15,
              spreadRadius: 5,
              offset: Offset(0, 5),
            ),
            const BoxShadow(
              color: Color.fromARGB(193, 244, 67, 54),
              blurRadius: 15,
              spreadRadius: 5,
              offset: Offset(0, 5),
            )
          ];

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: boxShadow,
          ),
          width: 65 * 6,
          child: Scaffold(
            appBar: AppBar(
              title: !isEditing
                  ? Row(
                      children: [
                        Text(
                            '$titleApp - ${widget.app.actived ? 'opened' : 'closed'}'),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isEditing = !isEditing;
                              });
                            },
                            icon: const Icon(Icons.edit))
                      ],
                    )
                  : buildRenameTextField(),
            ),
            drawer: buildSlideTool(),
            body: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: MediaQuery.of(context).size.height,
              child: Stack(children: [
                Center(
                  child: Container(
                    width: 325,
                    height: 570,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: imagePath != null
                              ? Colors.grey
                              : Colors.transparent,
                          blurRadius: 4)
                    ]),
                  ),
                ),
                Center(
                  child: imagePath != null
                      ? Image.file(
                          File(imagePath!),
                          key: UniqueKey(),
                        )
                      : const CircularProgressIndicator(),
                ),
              ]),
            ),
          ),
        ),
        buildSchedulesList(),
        Positioned(
          top: 5,
          right: 55,
          child: FloatingActionButton(
            heroTag: 'delete_app_${widget.app.hwnd}',
            mini: true,
            backgroundColor: Colors.red,
            onPressed: () async {
              context.read<TeleAppManager>().deleteTeleAppById(widget.app.id);
              context
                  .read<ScheduleManager>()
                  .deleteSchduleByAppId(widget.app.id);
              imageCache.evict(FileImage(File(imagePath!)));
              setState(() {});
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSlideTool() {
    return Drawer(
      width: 200,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildSideToolItem('Play', () {}, Icons.play_arrow),
          buildSideToolItem('Pause', () {}, Icons.pause),
          buildSideToolItem('Add schedule', () {
            context.read<ScheduleManager>().addReloadSchedule(widget.app.id);
            Navigator.of(context)
                .pushNamed(AddSchedule.routeName, arguments: widget.app.id);
          }, Icons.schedule),
          buildSideToolItem('Import/Export', () {}, Icons.import_export),
          buildSideToolItem('ReCapture', () async {
            await reCaptureScreenshot();
          }, Icons.camera),
        ],
      ),
    );
  }

  Widget buildSideToolItem(String title, VoidCallback func, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: func,
    );
  }

  Widget buildRenameTextField() {
    return SizedBox(
      width: 250,
      child: TextField(
        autofocus: true,
        onSubmitted: (value) {
          TeleAppManager teleAppManager = context.read<TeleAppManager>();
          teleAppManager.updateTitle(widget.app.id, value);
          setState(() {
            isEditing = false;
            titleApp = value;
          });
        },
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                icon: const Icon(Icons.exit_to_app))),
      ),
    );
  }

  Widget buildSchedulesList() {
    int scheduleCount = context
        .read<ScheduleManager>()
        .getScheduleByAppId(widget.app.id)
        .length;
    print(scheduleCount);
    return Positioned(
      bottom: 0,
      child: Container(
          height: 315,
          width: 65 * 6,
          color: Colors.transparent,
          child: ListView.builder(
            itemCount: scheduleCount,
            itemBuilder: (context, index) {
              return buildSchedulContainer(index);
            },
          )),
    );
  }

  Widget buildSchedulContainer(int index) {
    bool isHovered = hoveredIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Align(
        alignment: Alignment.centerLeft, // Căn sát cạnh trái
        child: MouseRegion(
          onEnter: (_) => setState(() => hoveredIndex = index),
          onExit: (_) => setState(() => hoveredIndex = null),
          child: AnimatedContainer(
            padding: const EdgeInsets.only(bottom: 10),
            duration: const Duration(milliseconds: 300),
            height: 75,
            width: isHovered ? 65 * 6 : 40, // Mở rộng về bên phải khi hover
            decoration: BoxDecoration(
              boxShadow: isHovered
                  ? [
                      const BoxShadow(
                          color: Colors.grey, spreadRadius: 2, blurRadius: 5),
                    ]
                  : [],
              border: Border.all(width: 0.5),
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(isHovered ? 10 : 20),
                bottomRight: Radius.circular(isHovered ? 10 : 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
