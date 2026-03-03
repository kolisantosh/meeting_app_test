import 'package:fluttertest/config/routes/routes_name.dart';
import 'package:fluttertest/views.dart' hide GetStorageData;

import '../../config/constants/app_colors.dart';
import '../../config/constants/strings.dart';
import '../../services/get_storage_data.dart';

Future<void> showDeviceSelectionDialog(BuildContext context) async {
  GetStorageData getStorageData = GetStorageData();
  navigationToDashboard(str) async {
    deviceType = str;

    await getStorageData.saveString(getStorageData.deviceType, str);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, RoutesName.dashboard);
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    pageBuilder: (context, anim1, anim2) => const SizedBox.expand(),
    transitionBuilder: (dialogContext, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AlertDialog(
              content: Container(
                width: 100,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Confirm",
                      style: TextStyle(
                        color: AppColors.textDisableColor,
                        fontSize: 16.h,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 10.h),
                    Text(
                      "Please Select an Option",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    SizedBox(height: 15.h),
                    CommonIconButton(
                      onTap: () {
                        navigationToDashboard("INNER");
                      },
                      color: Colors.white.withValues(alpha: 0.05),
                      textColor: AppColors.white,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      borderRadius: BorderRadius.circular(50.r),
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      title: "INNER",
                      imagePath: "",
                    ),
                    CommonIconButton(
                      onTap: () {
                        navigationToDashboard("OUTER");
                      },
                      color: Colors.white.withValues(alpha: 0.05),
                      textColor: AppColors.white,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      borderRadius: BorderRadius.circular(50.r),
                      margin: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 10.h,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      title: "OUTER",
                      imagePath: "",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showNoMeetingDialog(BuildContext context) async {
  navigationToDashboard(str) async {
    Navigator.pop(context);
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    pageBuilder: (context, anim1, anim2) => const SizedBox.expand(),
    transitionBuilder: (dialogContext, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AlertDialog(
              content: Container(
                width: 20,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No Meetings",
                      style: TextStyle(
                        color: AppColors.textDisableColor,
                        fontSize: 16.h,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Text(
                      "There are no meetings to place order",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    SizedBox(height: 15.h),

                    CommonIconButton(
                      onTap: () {
                        navigationToDashboard("OK");
                      },
                      color: Colors.white.withValues(alpha: 0.05),
                      textColor: AppColors.white,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      borderRadius: BorderRadius.circular(50.r),
                      margin: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 10.h,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      title: "Okay",
                      imagePath: "",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
