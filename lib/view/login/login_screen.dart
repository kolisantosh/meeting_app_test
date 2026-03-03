import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertest/config/constants/app_colors.dart';
import 'package:fluttertest/config/constants/imape_path.dart';

import '../../providers/login_provider.dart';
import '../../views.dart';
import '../widgets/device_select_dialog.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController(
    text: "almighty@aether.co.in",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "1234",
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    // Get screen dimensions for tablet responsiveness
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600.w;

    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.isSuccess) {
        showDeviceSelectionDialog(context);
        // Navigator.pushReplacementNamed(context, RoutesName.dashboard);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return CommonContainer(
      title: "",
      backIcon: false,
      suffix: false,
      shadow: false,
      appBarColor: Colors.transparent,
      scroll: true, // Enabled scroll for tablet keyboards
      child: Center(
        child: Container(
          // Constrain width for tablets so fields don't stretch too far
          width: isTablet ? 500.w : double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
          margin: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05), // Subtle glass effect
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Buttons fill width
            children: [
              // Logo or Icon Placeholder
              SvgPicture.asset(
                ImagePath.icLogo,
                height: 80.h,
                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              ),
              SizedBox(height: 24.h),
              Text(
                "Welcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text(
                "Please login to your meeting account",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 40.h),

              // Username Field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_open),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Login Button / Loading
              if (loginState.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    ref
                        .read(loginProvider.notifier)
                        .login(
                          usernameController.text,
                          passwordController.text,
                        );
                  },
                  child: Text('Login', style: TextStyle(fontSize: 18.sp)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
