import 'package:fluttertest/config/color/app_colors.dart';
import 'package:fluttertest/config/routes/routes.dart';
import 'package:fluttertest/config/routes/routes_name.dart';
import 'package:fluttertest/views.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 2),(){
      Navigator.pushReplacementNamed(context, RoutesName.dashboard);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      title: "",
      backIcon: false,
      suffix: false,
      color: AppColors.black,
        scroll:false,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          Text("Splash Screen",style: TextStyle(color: AppColors.white),)
                ],
              ),
        ));
  }
}

