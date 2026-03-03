import 'package:fluttertest/config/constants/imape_path.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/strings.dart';
import '../../config/routes/routes_name.dart';
import '../../services/get_storage_data.dart';
import '../../views.dart' hide GetStorageData;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GetStorageData getStorageData = GetStorageData();
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 1), () {
      getData();
    });

    super.initState();
  }

  getData() async {
    var data = await getStorageData.readObject(getStorageData.loginData);
    deviceType = await getStorageData.readString(getStorageData.deviceType);

    if (data != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.dashboard,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      title: "",
      backIcon: false,
      suffix: false,
      shadow: false,
      appBarColor: Colors.transparent,
      color: AppColors.black,
      scroll: false,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text("Splash Screen", style: TextStyle(color: AppColors.black)),
          Image.asset(
            ImagePath.aetherLogo,
            height: 300.w,
            // colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
