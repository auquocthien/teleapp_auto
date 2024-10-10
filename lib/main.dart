import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/ui/event/event_manager.dart';
import 'package:flutter_auto_tele/ui/home.dart';
import 'package:flutter_auto_tele/ui/schedule/add_schedule.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => TeleAppManager()),
          ChangeNotifierProvider(create: (ctx) => ScheduleManager()),
          ChangeNotifierProvider(create: (ctx) => EventManager()),
        ],
        child: Consumer(
          builder: (
            ctx,
            cellManager,
            child,
          ) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              home: const Home(),
              // routes: {},
              onGenerateRoute: (settings) {
                final agr = settings.arguments;
                if (settings.name == AddSchedule.routeName) {
                  return MaterialPageRoute(builder: (ctx) {
                    return AddSchedule(agr.toString());
                  });
                }
                return null;
              },
            );
          },
        ));
  }
}
