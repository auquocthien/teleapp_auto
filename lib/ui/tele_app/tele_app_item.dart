import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/config/config.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/services/app_control.dart';
import 'package:flutter_auto_tele/services/images_control.dart';
import 'package:flutter_auto_tele/ui/schedule/add_schedule.dart';
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

  @override
  void initState() {
    super.initState();
    loadImagePath();
  }

  Future<void> loadImagePath() async {
    String path = '$temporarySavePath/${widget.app.hwnd}.png';
    try {
      bool fileExists = await File(path).exists();
      if (!fileExists) {
        await appControl.captureScreenshot(widget.app.hwnd!);
      }
      String croppedPath = await imagesControl.cropImage(path, 10);
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
              title: Text(
                  '${widget.app.hwnd} - ${widget.app.actived ? 'opened' : 'closed'}'),
            ),
            drawer: buildSlideTool(),
            body: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: imagePath != null
                    ? Image.file(
                        File(imagePath!),
                        key: UniqueKey(),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 55,
          child: FloatingActionButton(
            heroTag: 'delete_app_${widget.app.hwnd}',
            mini: true,
            backgroundColor: Colors.red,
            onPressed: () {
              context.read<TeleAppManager>().deleteTeleAppById(widget.app.id);
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
}
