import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_item.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

class Cells extends StatefulWidget {
  // final int cellLong;
  const Cells({super.key});

  @override
  State<Cells> createState() => _CellsState();
}

class _CellsState extends State<Cells> {
  @override
  Widget build(BuildContext context) {
    int cellLong = context.watch<TeleAppManager>().teleAppCount;
    return Container(
      width: MediaQuery.of(context).size.width,
      child: GridView.builder(
        itemCount: cellLong,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.705),
        itemBuilder: (BuildContext context, int index) {
          List<TeleApp> teleApps = context.read<TeleAppManager>().teleApps;
          return CellItem(teleApps[index]);
        },
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
