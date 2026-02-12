import 'dart:math';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertest/config/image/imape_path.dart';
import 'package:fluttertest/config/routes/routes_name.dart';

import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_event.dart';
import '../../bloc/timer/timer_state.dart';
import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';
import '../../services/time_helper.dart';
import '../../views.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/watch_face_painter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey _watchKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<MeetingBloc>().add(LoadMeetings());
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: BlocBuilder<MeetingBloc, MeetingState>(
        builder: (context, state) {
          final themeColor = AppColors.getThemeColor(state.watchStatus);

          return Scaffold(
            backgroundColor: AppColors.black,
            body: SafeArea(
              top: false,
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    return _buildPortraitLayout(context, state, themeColor);
                  } else {
                    return _buildLandscapeLayout(context, state, themeColor);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
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
            children: [
              Expanded(
                flex: 1,
                child: _buildLeftPanel(context, state, themeColor),
              ),
              Expanded(
                flex: 2,
                child: _buildWatchFace(context, state, themeColor),
              ),
            ],
          ),
        ),
        _buildBottomIcons(themeColor),
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
          child: Padding(
            padding: EdgeInsets.all(18.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildLeftPanel(context, state, themeColor),
                ),
                Expanded(
                  flex: 2,
                  child: _buildWatchFace(context, state, themeColor),
                ),
              ],
            ),
          ),
        ),
        _buildBottomIcons(themeColor),
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
    final meeting = state.currentMeeting;
    final doorName = meeting?.doors.isNotEmpty == true
        ? meeting!.doors.first.doorName
        : 'Fire';

    return Padding(
      padding: EdgeInsets.only(left: 50.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            doorName,
            style: TextStyle(
              color: themeColor,
              fontSize: 68.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          // SizedBox(height: 8.h),
          Text(
            TimeHelpers.formatDate(state.currentTime),
            style: TextStyle(color: themeColor, fontSize: 28.sp),
          ),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: themeColor,
                fontSize: 104.sp,
                height: 1.0.h,
              ),
              children: [
                TextSpan(
                  text: TimeHelpers.formatFullTime(state.currentTime).substring(
                    0,
                    TimeHelpers.formatFullTime(state.currentTime).length - 4,
                  ), // hours
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: TimeHelpers.formatFullTime(state.currentTime).substring(
                    TimeHelpers.formatFullTime(state.currentTime).length - 4,
                    TimeHelpers.formatFullTime(state.currentTime).length - 2,
                  ), // hours
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: TimeHelpers.formatFullTime(state.currentTime).substring(
                    TimeHelpers.formatFullTime(state.currentTime).length - 2,
                  ), // rest (minutes, seconds)
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          if (meeting != null) ...[
            Text(
              '${meeting.meetingType} : ${meeting.eventSubject}',
              style: TextStyle(
                color: themeColor,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        TimeHelpers.formatTimeWithPeriod(meeting.eventFromDate),
                        style: TextStyle(color: themeColor, fontSize: 26.sp),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End',
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 26.sp,
                        ),
                      ),
                      Text(
                        TimeHelpers.formatTimeWithPeriod(meeting.eventToDate),
                        style: TextStyle(color: themeColor, fontSize: 20.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // SizedBox(height: 24.h),
          ],
          Spacer(),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.calendar_month, size: 30.w),
                // icon: Image.asset(ImagePath.calender, height: 16),
                label: Text('Schedule', style: TextStyle(fontSize: 20.sp)),
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
                label: Text('Book', style: TextStyle(fontSize: 20.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: AppColors.black,
                  padding: EdgeInsets.symmetric(
                    vertical: 22.h,
                    horizontal: 22.w,
                  ),
                ),
              ),
            ],
          ),

          Spacer(),
        ],
      ),
    );
  }

  Widget _buildWatchFace(
    BuildContext context,
    MeetingState state,
    Color themeColor,
  ) {
    return GestureDetector(
      onTapUp: (details) {
        _handleWatchTap(details, state);
      },
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: CustomPaint(
            key: _watchKey, // ✅ IMPORTANT
            painter: WatchFacePainter(
              meetings: state.meetings,
              currentTime: state.currentTime,
              onSegmentTap: (meeting) {
                print("meeting.....");
                print(meeting.toString());
              },
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150.w,
                  width: 150.w,
                  child: SvgPicture.asset(
                    ImagePath.icLogo,
                    colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
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

    const double ringThickness = 24;

    if (distance < radius - ringThickness || distance > radius) {
      debugPrint("❌ Tap outside watch ring");
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
      debugPrint("✅ Tapped meeting: ${meeting.eventSubject}");
      Navigator.pushNamed(context, RoutesName.details, arguments: meeting);
    } else {
      debugPrint("ℹ️ No meeting at this time");
    }
  }

  Meeting? _getMeetingForSegment(
    int segmentIndex,
    List<Meeting> meetings,
    DateTime now,
  ) {
    // Each segment = 5 minutes on a 12-hour clock
    final tappedMinutes12h = segmentIndex * 5; // 0–719

    for (final meeting in meetings) {
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
    }
    return null;
  }

  Widget _buildBottomIcons(Color themeColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 20.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SvgPicture.asset(
            ImagePath.info,
            colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
            height: 40.w,
          ),
          // Icon(Icons.cleaning_services, color: themeColor, size: 40.w),
          SvgPicture.asset(
            ImagePath.spray,
            colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
            // fit: BoxFit.scaleDown,
            height: 40.w,
          ),
          SvgPicture.asset(
            ImagePath.cupCleaning,
            colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
            // fit: BoxFit.scaleDown,
            height: 40.w,
          ),
          SvgPicture.asset(
            ImagePath.water,
            colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
            height: 35.w,
          ),
          Image.asset(
            ImagePath.ic_add_me_white,
            color: themeColor,
            height: 35.w,
          ),
          SvgPicture.asset(
            ImagePath.cafe,
            colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),
            // fit: BoxFit.scaleDown,
            height: 40.w,
          ),
          GestureDetector(
            onTap: () {
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

  void showSmoothTimerPopup(BuildContext context) {
    context.read<TimerBloc>().add(StartPopupTimer());

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      pageBuilder: (context, anim1, anim2) => const SizedBox.expand(),
      transitionBuilder: (dialogContext, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: BlocListener<TimerBloc, TimerState>(
            listener: (context, state) {
              // This handles removing the popup automatically
              if (state is TimerFinished) {
                Navigator.of(dialogContext).pop();
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
}
