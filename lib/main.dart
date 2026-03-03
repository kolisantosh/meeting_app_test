import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertest/config/constants/app_colors.dart';
import 'package:fluttertest/config/routes/routes.dart';
import 'package:fluttertest/config/routes/routes_name.dart';
import 'package:project_common_module/project_common_module.dart';

import 'bloc/meeting/meeting_bloc.dart';
import 'bloc/timer/timer_bloc.dart';
import 'config/utils/theme_utils.dart';
import 'views.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Initializer.initAppColors(primaryColor: AppColors.brightRedColor);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MeetingBloc()),
        BlocProvider(
          create: (context) => TimerBloc(),
        ), // Initialized but not started
      ],
      child: ProviderScope(child: const MyApp()),
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
        title: 'Meeting room',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        // Setting theme mode to dark
        theme: lightTheme,
        // Setting light theme
        darkTheme: darkTheme,
        // theme: ThemeUtils.theme,
        initialRoute: RoutesName.splash,
        onGenerateRoute: Routes.generateRoutes,
        // home: Scaffold(body: Text( 'Flutter Demo Home Page')),
      ),
    );
  }
}
