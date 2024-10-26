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
  late Future<void> getTeleApps;

  @override
  void initState() {
    // TODO: implement initState
    getTeleApps = context.read<TeleAppManager>().getTeleApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTeleApps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<TeleApp> apps = context.watch<TeleAppManager>().teleApps;
            return GridView.builder(
              itemCount: apps.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.705),
              itemBuilder: (BuildContext context, int index) {
                return CellItem(apps[index]);
              },
              scrollDirection: Axis.vertical,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
