import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest/config/constants/app_colors.dart';
import 'package:fluttertest/config/constants/imape_path.dart';

import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_event.dart';
import '../../bloc/timer/timer_state.dart';
import '../../models/meeting/meeting_model.dart';
import '../../views.dart';

void showSmoothTimerPopup(BuildContext context) {
  context.read<TimerBloc>().add(
    StartPopupTimer(durationSeconds: 10, isReverse: false),
  );

  if (ModalRoute.of(context)?.isCurrent == false) return;
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    pageBuilder: (context, anim1, anim2) => const SizedBox.expand(),
    transitionBuilder: (dialogContext, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: BlocListener<TimerBloc, TimerState>(
          listener: (context, state) {
            // This handles removing the popup automatically
            if (state is TimerFinished) {
              // Navigator.of(dialogContext).pop();
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Glassmorphism Blur
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.transparent),
                ),
                Center(child: buildCircularTimer()),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showEmployeePinPopup(BuildContext context) {
  context.read<TimerBloc>().add(
    StartPopupTimer(durationSeconds: 10, isReverse: false),
  );

  if (ModalRoute.of(context)?.isCurrent == false) return;
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    pageBuilder: (context, anim1, anim2) => const SizedBox.expand(),
    transitionBuilder: (dialogContext, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: BlocListener<TimerBloc, TimerState>(
          listener: (context, state) {
            // This handles removing the popup automatically
            if (state is TimerFinished) {
              // Navigator.of(dialogContext).pop();
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.transparent),
                ),
                Center(child: buildCircularTimer()),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showSmoothTimerPopup1(
  BuildContext context,
  MeetingModel meeting,
) async {
  // 1. Prevent overlapping dialogs
  if (ModalRoute.of(context)?.isCurrent == false) return;

  // 2. Start the "Warning" timer (the 15-minute countdown)
  // context.read<TimerBloc>().add(
  //   StartPopupTimer(durationSeconds: 15 * 60, isReverse: true),
  // );
  final now = DateTime.now();

  final remainingSeconds = meeting.eventToDate.difference(now).inSeconds;

  // 2. Restart the Bloc timer with the correct remaining duration
  // This ensures the Dashboard UI is accurate when we return
  context.read<TimerBloc>().add(
    StartPopupTimer(
      durationSeconds: remainingSeconds > 0 ? remainingSeconds : 0,
      isReverse: true,
    ),
  );

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (dialogContext, anim1, anim2) {
      return FadeTransition(
        opacity: anim1,
        child: BlocListener<TimerBloc, TimerState>(
          // Listen to the timer finishing on its own
          listener: (context, state) {
            if (state is TimerFinished) {
              _handleClose(context, meeting);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Background Blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      Center(
                        child: buildCircularTimer(),
                      ), // Your existing widget
                      const Spacer(flex: 2),

                      // Button Row
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _actionBtn(
                              "5 Min",
                              () => _addExtraTime(context, 5),
                            ),
                            _actionBtn(
                              "10 Min",
                              () => _addExtraTime(context, 10),
                            ),
                            _actionBtn(
                              "15 Min",
                              () => _addExtraTime(context, 15),
                            ),
                            _actionBtn(
                              "COMPLETE NOW",
                              () => _completeMeeting(context),
                            ),
                            _actionBtn(
                              "CLOSE",
                              () => _handleClose(context, meeting),
                              isRed: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// --- HELPER LOGIC ---

void _handleClose(BuildContext context, MeetingModel meeting) {
  /*
  // 1. Calculate the REAL remaining time until the meeting officially ends
  final now = DateTime.now();
  final remainingSeconds = meeting.eventToDate.difference(now).inSeconds;

  // 2. Restart the Bloc timer with the correct remaining duration
  // This ensures the Dashboard UI is accurate when we return
  context.read<TimerBloc>().add(
    StartPopupTimer(
      durationSeconds: remainingSeconds > 0 ? remainingSeconds : 0,
      isReverse: true,
    ),
  );
*/
  // 3. Close the Dialog
  Navigator.of(context, rootNavigator: true).pop();
}

void _addExtraTime(BuildContext context, int minutes) {
  // Logic to call your API to extend meeting, then update Bloc

  int status = (minutes == 5)
      ? 322
      : (minutes == 10)
      ? 323
      : 324;
  context.read<MeetingBloc>().add(
    ExtendMeetingRequest(extensionMinutes: minutes, statusId: status),
  );
  Navigator.of(context, rootNavigator: true).pop();
}

void _completeMeeting(BuildContext context) {
  context.read<MeetingBloc>().add(
    ExtendMeetingRequest(extensionMinutes: 0, statusId: 325),
  );
  Navigator.of(context, rootNavigator: true).pop();
}

Widget _actionBtn(String title, VoidCallback onTap, {bool isRed = false}) {
  return Expanded(
    child: CommonIconButton(
      onTap: onTap,
      title: title,
      imagePath: "",
      widthFull: false,
      border: true,
      textColor: AppColors.white,
      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.symmetric(vertical: 18.h),
      color: isRed ? AppColors.black : AppColors.black,
    ),
  );
}

Widget buildCircularTimer() {
  // Inside your Popup or Dashboard Widget
  return BlocBuilder<TimerBloc, TimerState>(
    builder: (context, state) {
      if (state is TimerRunning) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 450,
                  height: 450,
                  child: CircularProgressIndicator(
                    value: state.progress,
                    color: state.progress > 0.8
                        ? Colors.red
                        : Colors.green, // Dynamic Status
                    strokeWidth: 28,
                    strokeCap: StrokeCap.round, // Rounded ends for smooth look
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brightRedColor,
                    ),
                  ),
                ),

                Text(
                  state.timeLeft,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 39,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            // Text(
            //   state.progress > 0.8 ? "Hurry Up!" : "Time Remaining",
            //   style: TextStyle(color: Colors.white),
            // ),
          ],
        );
      }
      return const SizedBox.shrink();
    },
  );
}

void showAetherExtensionListDialog(
  BuildContext context,
  image, {
  network = false,
}) {
  if (ModalRoute.of(context)?.isCurrent == false) return;
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    pageBuilder: (context, anim1, anim2) => const SizedBox.expand(),
    transitionBuilder: (dialogContext, anim1, anim2, child) {
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300 && image.toString() == ImagePath.IMG_0112) {
            Navigator.of(context, rootNavigator: true).pop();
          } else if (velocity < -300 &&
              image.toString() == ImagePath.aetherExtensionList) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;

          if (velocity > 300 && network == true) {
            // _showSwipeDialog("Swiped Down");
            Navigator.of(context, rootNavigator: true).pop();
          } else if (velocity < -300 && network == false) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        onTap: () {
          if (ModalRoute.of(context)?.isCurrent == false) return;
          Navigator.of(context, rootNavigator: true).pop();
        },
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: FadeTransition(
                opacity: anim1,
                child: network
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.fitHeight,
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.black,
                          alignment: Alignment.center,
                          child: Icon(Icons.info),
                        ),
                      )
                    : Image.asset(image, fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      );
    },
  );
}
