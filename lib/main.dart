
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest/config/color/app_colors.dart';
import 'package:fluttertest/config/routes/routes.dart';
import 'package:fluttertest/config/routes/routes_name.dart';
import 'bloc/meeting/meeting_bloc.dart';
import 'bloc/meeting/meeting_event.dart';
import 'views.dart';
import 'package:project_common_module/project_common_module.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Initializer.initAppColors(primaryColor: AppColors.red);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  
  runApp(BlocProvider(create: (context) => MeetingBloc()..add(LoadMeetings()),
  child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1080, 1001),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.dashboard,
        onGenerateRoute: Routes.generateRoutes,
        // home: Scaffold(body: Text( 'Flutter Demo Home Page')),
      ),
    );
  }
}
