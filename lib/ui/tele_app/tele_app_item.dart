import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
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
  @override
  Widget build(BuildContext context) {
    List<BoxShadow> boxShadow = widget.app.actived
        ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 10,
              offset: Offset(0, 10),
            )
          ]
        : [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
              offset: Offset(0, 5),
            )
          ];
    return Stack(children: [
      Container(
        decoration: BoxDecoration(boxShadow: boxShadow),
        width: 65 * 6,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                '${widget.app.hwnd} - ${widget.app.actived ? 'opened' : 'closed'}'),
          ),
          drawer: buildSlideTool(),
          body: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
      Positioned(
          top: 5,
          right: 55,
          child: FloatingActionButton(
            heroTag: 'delete_app',
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
          ))
    ]);
  }

  Widget buildSlideTool() {
    return Drawer(
      width: 200,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(
              Icons.play_arrow,
            ),
            title: const Text(
              'Play',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.pause,
            ),
            title: const Text(
              'Pause',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text(
              'Add schedule',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AddSchedule.routeName, arguments: widget.app.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text(
              'Import/Export',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
