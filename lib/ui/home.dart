import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int cell = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Stack(children: [
            const Cells(),
            // buildFloatdingButton(10, 0, () {
            //   context.read<TeleAppManager>().addTeleApp();
            //   setState(() {});
            // }, Icons.add),
            buildFloatdingButton(10, 0, () async {
              await context.read<TeleAppManager>().getTeleApp();
            }, Icons.refresh)
          ]),
        ),
      ),
    );
  }

  Widget buildFloatdingButton(
      double bottom, double right, VoidCallback func, IconData icon) {
    return Positioned(
      bottom: bottom,
      right: 0,
      child: SizedBox(
        height: 45,
        width: 45,
        child: FloatingActionButton(
            heroTag: 'refesh_app',
            onPressed: func,
            child: Icon(
              icon,
              size: 35,
            )),
      ),
    );
  }
}
