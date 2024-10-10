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
            Positioned(
              bottom: 10,
              right: 5,
              child: FloatingActionButton(
                heroTag: 'add_app',
                child: const Icon(
                  Icons.add,
                  size: 40,
                ),
                onPressed: () {
                  context.read<TeleAppManager>().addTeleApp();
                  setState(() {});
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
