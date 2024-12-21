import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/config/config.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/services/app_control.dart';
import 'package:flutter_auto_tele/services/images_control.dart';
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
  TeleApp? app;
  List<String> imagePathList = [];
  int index = 0;

  ImagesControl imagesControl = ImagesControl();
  AppControl appControl = AppControl();

  Future<void> getImageListPath() async {
    imagePathList = await imagesControl.getImageListByHwnd(app!.hwnd!);
    if (imagePathList.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getImageListPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getImageListPath();
    app = context.read<TeleAppManager>().getAppById(widget.appId);
    String imagePath = '$temporarySavePath/${app!.hwnd}_home.png';

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
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    decoration: BoxDecoration(border: Border.all(width: 0.5)),
                    child: buildToolBar(),
                  ),
                  Expanded(
                    child: Schedules(widget.appId, app!.hwnd!),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5),
                      image: DecorationImage(
                          image: imagePathList.isNotEmpty
                              ? FileImage(File(imagePathList[index]))
                              : FileImage(
                                  File(imagePath),
                                ),
                          fit: BoxFit.contain,
                          alignment: Alignment.center),
                    ),
                    width: 350,
                    height: 692,
                    child: const EventList(),
                  ),
                ],
              ),
              Positioned(
                right: 360,
                child: SizedBox(
                  height: 185,
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildIconContainer(
                        icon: Icons.camera_alt_rounded,
                        color: Colors.blue,
                        onPressed: () async {
                          await appControl.captureScreenshot(app!.hwnd!);

                          String newPath = await imagesControl.renameImage(
                              imagePathList.isEmpty ? 1 : imagePathList.length,
                              app!.hwnd!);
                          newPath = await imagesControl.cropImage(newPath, 10,
                              isHome: false);

                          await imagesControl.deleteImage(app!.hwnd!);
                          await getImageListPath();
                        },
                      ),
                      buildIconContainer(
                        icon: Icons.arrow_upward,
                        color: Colors.green,
                        onPressed: () async {
                          await getImageListPath();
                          setState(() {
                            if (index > 0) {
                              index = index - 1;
                            }
                          });
                        },
                      ),
                      buildIconContainer(
                        icon: Icons.arrow_downward,
                        color: Colors.green,
                        onPressed: () async {
                          await getImageListPath();
                          setState(() {
                            if (index + 1 < imagePathList.length) {
                              index = index + 1;
                            }
                          });
                        },
                      ),
                      buildIconContainer(
                          icon: Icons.delete,
                          color: Colors.red,
                          onPressed: () async {
                            await imagesControl.deleteImage(
                              imagePathList[index],
                            );
                            imageCache
                                .evict(FileImage(File(imagePathList[index])));
                            await getImageListPath();
                            setState(() {
                              index = 0;
                            });
                          })
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIconContainer({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền
        shape: BoxShape.circle, // Hình dạng tròn
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Màu shadow
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2), // Độ dịch chuyển của shadow
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color), // Đặt icon và màu icon
        onPressed: onPressed,
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
