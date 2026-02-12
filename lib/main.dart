import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest/config/color/app_colors.dart';
import 'package:fluttertest/config/routes/routes.dart';
import 'package:fluttertest/config/routes/routes_name.dart';
import 'package:project_common_module/project_common_module.dart';

import 'bloc/meeting/meeting_bloc.dart';
import 'bloc/meeting/meeting_event.dart';
import 'bloc/timer/timer_bloc.dart';
import 'views.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Initializer.initAppColors(primaryColor: AppColors.brightRedColor);
  SystemChrome.setPreferredOrientations([
    // DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MeetingBloc()..add(LoadMeetings())),
        BlocProvider(
          create: (context) => TimerBloc(),
        ), // Initialized but not started
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1194, 834),
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        // theme: ThemeUtils.theme,
        initialRoute: RoutesName.dashboard,
        onGenerateRoute: Routes.generateRoutes,
        // home: Scaffold(body: Text( 'Flutter Demo Home Page')),
      ),
    );
  }
}
