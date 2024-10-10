import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
    'Item5',
    'Item6',
    'Item7',
    'Item8',
  ];
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(border: Border.all(width: 0.5)),
        width: 65 * 6,
        child: Scaffold(
          appBar: AppBar(
            title: selectedValue != null
                ? Text(selectedValue!)
                : const Text('App'),
          ),
          drawer: buildSlideTool(),
          body: Container(
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
          buildSearchWindow(),
          ListTile(
            enabled: selectedValue != null,
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
            enabled: selectedValue != null,
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
            enabled: selectedValue != null,
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
        ],
      ),
    );
  }

  Widget buildSearchWindow() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: const Row(
          children: [
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.list,
              size: 20,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                'Select Window',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (String? value) {
          setState(() {
            selectedValue = value;
          });
          context
              .read<TeleAppManager>()
              .updateTitle(widget.app.id, selectedValue!);
        },
        buttonStyleData: const ButtonStyleData(
          height: 50,
          width: 160,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_forward_ios_outlined,
          ),
          iconSize: 14,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 250,
          width: 180,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 243, 243, 243),
          ),
          offset: const Offset(10, -10),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      ),
    );
  }
}
