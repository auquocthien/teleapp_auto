import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/ui/event/event_manager.dart';
import 'package:flutter_auto_tele/ui/home.dart';
import 'package:flutter_auto_tele/ui/schedule/add_schedule.dart';
import 'package:flutter_auto_tele/ui/schedule/schedule_manager.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://82a0f4ee1b1bda98cd9077f637b3c900@o4508211841662976.ingest.de.sentry.io/4508211844284496';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
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
