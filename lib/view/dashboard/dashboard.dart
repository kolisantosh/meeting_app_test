import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertest/config/constants/imape_path.dart';
import 'package:fluttertest/config/routes/routes_name.dart';
import 'package:fluttertest/view/login/login_screen.dart';

import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../config/constants/app_colors.dart';
import '../../config/constants/strings.dart';
import '../../models/login/login_model.dart';
import '../../models/meeting/meeting_model.dart';
import '../../services/get_storage_data.dart';
import '../../services/time_helper.dart';
import '../../views.dart' hide GetStorageData;
import '../widgets/circular_timer_widget.dart';
import '../widgets/device_select_dialog.dart';
import '../widgets/watch_face_painter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey _watchKey = GlobalKey();
  final GetStorageData getStorageData = GetStorageData();
  String doorUsername = "No Meeting";
  bool _isDialogShowing = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _played15Min = false;
  bool _played2Min = false;
  bool _played30Sec = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    context.read<MeetingBloc>().add(LoadMeetings());
  }

  getData() async {
    var data = await getStorageData.readObject(getStorageData.loginData);

    if (data != null) {
      LoginModel userData = LoginModel.fromJson(jsonDecode(data));
      setState(() {
        doorUsername = userData.userName ?? "Unknown User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity > 300) {
          showAetherExtensionListDialog(context, ImagePath.aetherExtensionList);
        } else if (velocity < -300) {
          showAetherExtensionListDialog(context, ImagePath.IMG_0112);
        }
      },

      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity > 300) {
          // _showSwipeDialog("Swiped Down");
        } else if (velocity < -300) {
          showAetherExtensionListDialog(
            context,
            "http://myapp.airis.co.in/src/app/ClientResources/Airis/QR/8203.png",
            network: true,
          );
        }
      },
      child: BaseScreen(
        color: AppColors.black,
        resizeToAvoidBottomInset: false,
        bottom: false,
        child: BlocConsumer<MeetingBloc, MeetingState>(
          // Listen only triggers ONCE when the state changes
          listener: (context, state) {
            if (state.showHostSelection) {
              showSnackBarTop(context, "Success", error: false);
            } else if (state.status == MeetingStatus.failure &&
                state.errorMessage != null) {
              if (!_isDialogShowing) {
                _isDialogShowing = true;
                showSnackBarTop(context, state.errorMessage!, error: true);
              }
            }

            // Check meeting logic here if it triggers an external notification/sound

            _checkMeetingEndingSoon(state, state.currentTime);
          },
          builder: (context, state) {
            final themeColor = AppColors.getThemeColor(state.watchStatus);

            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return _buildPortraitLayout(context, state, themeColor);
                } else {
                  return _buildLandscapeLayout(context, state, themeColor);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _playSound(String fileName) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource("sound/$fileName"));
  }

  Future<void> _checkMeetingEndingSoon(state, DateTime currentTime) async {
    final meeting = _getCurrentMeetingExit(state.meetings, state.currentTime);

    if (meeting == null) return;
    final difference = meeting!.eventToDate.difference(currentTime);
    // print(difference);
    // print(difference.inMinutes);
    // print(difference.inSeconds);

    // Reset if new meeting
    // if (_currentMeetingEnd != meeting.eventToDate) {
    //   _currentMeetingEnd = meeting.eventToDate;
    //   _resetSoundFlags();
    // }

    // 15 minutes warning
    if (difference.inMinutes < 15 && !_played15Min) {
      _played15Min = true;
      await _playSound("MeetingExpiry.mp3");
    } else if (difference.inMinutes == 1 && !_played2Min) {
      _played2Min = true;
      await _playSound("timer_countdown.mp3");
    } else if (difference.inMinutes == 0 &&
        difference.inSeconds == 30 &&
        !_played30Sec) {
      _played30Sec = true;
      await _playSound("30sec.mp3");
    }

    final isEndingSoon = difference.inMinutes < 15 && difference.inMinutes > 0;
    if (isEndingSoon) {
      if (!_isDialogShowing) {
        _isDialogShowing = true;

        Future.microtask(() async {
          if (deviceType == "INNER") {
            await showSmoothTimerPopup1(context, meeting);
            // _isDialogShowing = false;
          }
        });
      }
    }
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    MeetingState state,
    Color themeColor,
  ) {
    return Column(
      children: [
        Container(height: 4.h, color: themeColor),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 0,
                child: _buildLeftPanel(context, state, themeColor),
              ),
              _buildWatchFace(context, state, themeColor),
            ],
          ),
        ),
        _buildBottomIcons(themeColor, state),
        Container(height: 4, color: themeColor),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    MeetingState state,
    Color themeColor,
  ) {
    return Column(
      children: [
        Container(
          width: 300.w,
          height: 8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: themeColor,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 0,
                child: _buildLeftPanel(context, state, themeColor),
              ),
              Expanded(
                flex: 2,
                child: _buildWatchFace(context, state, themeColor),
              ),
            ],
          ),
        ),
        _buildBottomIcons(themeColor, state),
        SizedBox(height: 24.h),
        Container(
          width: 300.w,
          height: 8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: themeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(
    BuildContext context,
    MeetingState state,
    Color themeColor,
  ) {
    final meeting = _getCurrentMeetingExit(state.meetings, state.currentTime);
    // final meeting = state.currentMeeting;

    final doorName =
        // meeting?.doors.isNotEmpty == true
        //     ? meeting!.doors.first.doorName
        //     :
        doorUsername;

    // Extract the time parts once for efficiency
    final fullTime = TimeHelpers.formatFullTime(
      state.currentTime,
    ); // e.g., "12:10PM"
    final timeParts = fullTime.split(':'); // ["12", "10PM"]
    final hour = timeParts[0];
    final minute = timeParts[1].substring(0, 2);
    final period = timeParts[1].substring(2);

    return SizedBox(
      width: 450.w,
      child: Padding(
        padding: EdgeInsets.only(left: 50.w, top: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            GestureDetector(
              onDoubleTap: () {
                context.read<MeetingBloc>().add(LoadMeetings());
              },
              child: Text(
                doorName,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 58.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.01,
                ),
              ),
            ),
            // SizedBox(height: 8.h),
            Text(
              TimeHelpers.formatDate(state.currentTime),
              style: TextStyle(
                color: themeColor,
                fontSize: 29.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.01,
              ),
            ),
            SizedBox(height: 6.h),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: themeColor,
                  fontSize: 104.h,
                  height:
                      1.1, // Added a tiny bit of breathing room to prevent clipping
                ),
                children: [
                  // Hours (Bold)
                  TextSpan(
                    text: hour,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -10.h,
                      ), // NEGATIVE moves it UP, POSITIVE moves it DOWN
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 104.h,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  // Minutes (Light)
                  TextSpan(
                    text: minute,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),

                  // AM/PM (Small/Normal)
                  TextSpan(
                    text: period,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 22.h,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            if (meeting != null) ...[
              GestureDetector(
                onTap: () {
                  debugPrint("Tapped meeting: ${meeting.eventSubject}");
                  Navigator.pushNamed(
                    context,
                    RoutesName.details,
                    arguments: meeting,
                  );
                },
                child: Text(
                  '${meeting.meetingTypeName.toUpperCase()} : ${meeting.eventSubject}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 28.h,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
              ),

              // SizedBox(height: 24.h),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 23.h,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        TimeHelpers.formatTimeWithPeriod(meeting.eventFromDate),
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 21.h,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 23.h,
                          ),
                        ),
                        Text(
                          TimeHelpers.formatTimeWithPeriod(meeting.eventToDate),
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 21.h,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(),
                ],
              ),

              // SizedBox(height: 24.h),
            ] else ...[
              Spacer(),
              Spacer(),
            ],
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.calendar_month, size: 30.w),
                  // icon: Image.asset(ImagePath.calender, height: 16),
                  label: Text('Schedule', style: TextStyle(fontSize: 23.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor, width: 2.w),
                    padding: EdgeInsets.symmetric(
                      vertical: 22.h,
                      horizontal: 22.w,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.calendar_month, size: 30.w),
                  label: Text('Book', style: TextStyle(fontSize: 23.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: AppColors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: 22.h,
                      horizontal: 22.w,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                //     (deviceType == "INNER" && meeting != null)
                //         ? CommonIconButton(
                //             onTap: () {},
                //             title: "",
                //             widthFull: false,
                //             padding: EdgeInsets.symmetric(
                //               horizontal: 23.w,
                //               vertical: 20,
                //             ),
                //             border: false,
                //             margin: EdgeInsets.zero,
                //             // width: 100,
                //             // color: Colors.transparent,
                //             imagePath: ImagePath.mic,
                //             color: themeColor,
                //             textColor: AppColors.white,
                //           )
                //         :
                SizedBox(),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchFace(
    BuildContext context,
    MeetingState state,
    Color themeColor,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapUp: (details) {
        _handleWatchTap(details, state);
      },
      // child: AspectRatio(
      //   aspectRatio: 1.06,
      child: Padding(
        padding: EdgeInsets.only(bottom: 30.0.h, top: 90.h),
        child: CustomPaint(
          key: _watchKey,
          painter: WatchFacePainter(
            meetings: state.meetings,
            currentTime: state.currentTime,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onDoubleTap: () {
                  logoutTap();
                },

                child: SizedBox(
                  height: 140.h,
                  // width: 150.w,
                  child: SvgPicture.asset(
                    ImagePath.icLogo,
                    colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ),
      ),
    );
  }

  void _handleWatchTap(TapUpDetails details, MeetingState state) {
    final RenderBox box =
        _watchKey.currentContext!.findRenderObject() as RenderBox;

    final localPosition = box.globalToLocal(details.globalPosition);
    final size = box.size;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    const double ringThickness = 30;

    if (distance < radius - ringThickness || distance > radius) {
      debugPrint("Tap outside watch ring");
      return;
    }

    // 12 o’clock = 0 rad
    double angle = atan2(dy, dx);
    angle = (angle + pi / 2) % (2 * pi);
    if (angle < 0) angle += 2 * pi;

    const totalSegments = 144; // 12h × 5min
    final segmentAngle = (2 * pi) / totalSegments;
    final segmentIndex = angle ~/ segmentAngle;

    final meeting = _getMeetingForSegment(
      segmentIndex.toInt(),
      state.meetings,
      state.currentTime,
    );

    if (meeting != null) {
      debugPrint("Tapped meeting: ${meeting.eventSubject}");
      Navigator.pushNamed(context, RoutesName.details, arguments: meeting);
    } else {
      debugPrint("No meeting at this time");
    }
  }

  bool _is15MinutesLeft(MeetingModel meeting, DateTime currentTime) {
    final difference = meeting.eventToDate.difference(currentTime).inMinutes;

    if (difference < 15 && difference > 0) {
      return true;
    }
    return false;
  }

  MeetingModel? _getCurrentMeetingExit(
    List<MeetingModel> meetings,
    DateTime currentTime,
  ) {
    for (final meeting in meetings) {
      if (meeting.statusDesc == "Completed" ||
          meeting.statusDesc == "Cancelled" ||
          // meeting.doors.length > 0 ||
          currentTime.isAfter(meeting.eventToDate)) {
        continue;
      }
      final start = meeting.eventFromDate;
      final end = meeting.eventToDate;
      final minutesUntilStart = meeting.eventFromDate
          .difference(currentTime)
          .inMinutes;

      var isUpcoming = minutesUntilStart >= 0 && minutesUntilStart < 5;
      if ((!currentTime.isBefore(start) && !currentTime.isAfter(end)) ||
          isUpcoming) {
        return meeting;
      }
    }
    return null;
  }

  MeetingModel? _getMeetingForSegment(
    int segmentIndex,
    List<MeetingModel> meetings,
    DateTime now,
  ) {
    // Each segment = 5 minutes on a 12-hour clock
    final tappedMinutes12h = segmentIndex * 5; // 0–719

    for (final meeting in meetings) {
      // if (meeting.statusDesc != "Completed") {
      if (meeting.statusDesc == "Completed" ||
          meeting.statusDesc == "Cancelled" ||
          // meeting.doors.length > 0 ||
          now.isAfter(meeting.eventToDate)) {
        continue;
      }
      int start =
          meeting.eventFromDate.hour * 60 + meeting.eventFromDate.minute;
      int end = meeting.eventToDate.hour * 60 + meeting.eventToDate.minute;

      // Convert meeting time to 12-hour space
      start %= 720;
      end %= 720;

      // Handle meetings crossing 12:00 (rare but safe)
      if (end < start) {
        // Example: 11:30 → 12:30
        if (tappedMinutes12h >= start || tappedMinutes12h < end) {
          return meeting;
        }
      } else {
        if (tappedMinutes12h >= start && tappedMinutes12h < end) {
          return meeting;
        }
      }
      // }
    }
    return null;
  }

  Widget _buildBottomIcons(Color themeColor, state) {
    final meeting = _getCurrentMeetingExit(state.meetings, state.currentTime);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 20.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              if (deviceType == "OUTER") {
                _showSecurityDialog(context);
              } else {
                showAetherExtensionListDialog(context, ImagePath.IMG_0112);
              }
            },
            child: SvgPicture.asset(
              ImagePath.info,
              colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              height: 40.w,
            ),
          ),
          // Icon(Icons.cleaning_services, color: themeColor, size: 40.w),
          GestureDetector(
            onTap: () {
              showNoMeetingDialog(context);
            },
            child: SvgPicture.asset(
              ImagePath.spray,
              colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              // fit: BoxFit.scaleDown,
              height: 40.w,
            ),
          ),
          GestureDetector(
            onTap: () {
              showNoMeetingDialog(context);
            },
            child: SvgPicture.asset(
              ImagePath.cupCleaning,
              colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              // fit: BoxFit.scaleDown,
              height: 40.w,
            ),
          ),
          GestureDetector(
            onTap: () {
              showNoMeetingDialog(context);
            },
            child: SvgPicture.asset(
              ImagePath.water,
              colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              height: 35.w,
            ),
          ),
          if (deviceType != "OUTER" && meeting != null)
            Image.asset(
              ImagePath.ic_add_me_white,
              color: themeColor,
              height: 35.w,
            ),
          if (deviceType == "OUTER" && meeting != null)
            GestureDetector(
              onTap: () {
                showNoMeetingDialog(context);
              },
              child: SvgPicture.asset(
                ImagePath.bell,
                colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
                // fit: BoxFit.scaleDown,
                height: 40.w,
              ),
            ),
          if (deviceType != "OUTER" &&
              state.currentMeeting != null &&
              _is15MinutesLeft(
                state.currentMeeting!,
                state.currentTime,
              )) //15 min left to finish meeting show button
            GestureDetector(
              onTap: () {
                print("clicked button");
                showSmoothTimerPopup1(context, meeting!);
              },
              child: SvgPicture.asset(
                ImagePath.times,
                colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
                // fit: BoxFit.scaleDown,
                height: 40.w,
              ),
            ),
          if (deviceType != "OUTER")
            GestureDetector(
              onTap: () {
                showNoMeetingDialog(context);
              },
              child: SvgPicture.asset(
                ImagePath.cafe,
                colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
                // fit: BoxFit.scaleDown,
                height: 40.w,
              ),
            ),
          GestureDetector(
            onTap: () {
              if (meeting == null) {
                showNoMeetingDialog(context);
              }
            },
            child: SvgPicture.asset(
              ImagePath.sos,
              colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
              // fit: BoxFit.scaleDown,
              height: 40.w,
            ),
          ),
          if (deviceType != "OUTER" || meeting == null)
            GestureDetector(
              onTap: () {
                if (meeting == null) {
                  showEmployeePinPopup(context);
                }
                context.read<MeetingBloc>().add(
                  UnLockDoor(empCode: meeting!.empCode),
                );
                showSmoothTimerPopup(context);
              },
              child: SvgPicture.asset(
                ImagePath.lock,
                colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
                // fit: BoxFit.scaleDown,
                height: 40.w,
              ),
            ),
        ],
      ),
    );
  }

  void logoutTap() {
    TextEditingController codeController = TextEditingController();

    if (ModalRoute.of(context)?.isCurrent == false) return;
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
                // clipBehavior: Clip.antiAliasWithSaveLayer,
                // backgroundColor: Colors.black.withValues(alpha: 0.4),
                // shadowColor: AppColors.white.withValues(alpha: 0.4),
                content: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: AppColors.textDisableColor,
                          fontSize: 16.h,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 10.h),
                      const Text(
                        "Do you want to logout?",
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: codeController,
                        style: TextStyle(color: AppColors.textDisableColor),
                        decoration: InputDecoration(
                          hintText: "Enter a code here",
                          hintStyle: TextStyle(color: AppColors.textColor),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.textColor),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.r),
                            borderSide: BorderSide(
                              color: AppColors.textColor,
                              width: 1.0.w,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 20.w,
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),

                      CommonIconButton(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();

                          // Navigator.of(context).pop(); // close dialog

                          if (codeController.text == "2202") {
                            getStorageData.clear();
                            showSnackBar("Success!\n\nLogout successful");
                            loadDashboardView();
                          } else {
                            showSnackBar("Alert!\n\nIncorrect Code");
                          }
                        },
                        color: Colors.white.withValues(alpha: 0.05),
                        textColor: AppColors.white,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        borderRadius: BorderRadius.circular(50.r),
                        margin: EdgeInsets.symmetric(
                          // horizontal: 8.w,
                          vertical: 10.h,
                        ),
                        widthFull: false,
                        width: 250,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        title: "OK",
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

  void _showSecurityDialog(context) {
    TextEditingController codeController = TextEditingController();

    if (ModalRoute.of(context)?.isCurrent == false) return;
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
                content: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Confirmation",
                        style: TextStyle(
                          color: AppColors.textDisableColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Please enter security code",
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: codeController,
                        style: TextStyle(color: AppColors.textDisableColor),
                        decoration: InputDecoration(
                          hintText: "Enter a code here",
                          hintStyle: TextStyle(color: AppColors.textColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.textColor),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.r),
                            borderSide: BorderSide(
                              color: AppColors.textColor,
                              width: 1.0.w,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 20.w,
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),

                      CommonIconButton(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          // Navigator.of(context).pop();

                          if (codeController.text == "3040") {
                            showSnackBar("Success!");
                            showAetherExtensionListDialog(
                              context,
                              ImagePath.IMG_0112,
                            );
                          } else {
                            showSnackBar("Alert!\n\nIncorrect Code");
                          }
                        },
                        color: Colors.white.withValues(alpha: 0.05),
                        textColor: AppColors.white,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        borderRadius: BorderRadius.circular(50.r),
                        margin: EdgeInsets.symmetric(
                          // horizontal: 8.w,
                          vertical: 10.h,
                        ),
                        widthFull: false,
                        width: 250,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        title: "OK",
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

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void loadDashboardView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}
