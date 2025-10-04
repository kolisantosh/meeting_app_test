import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest/config/image/imape_path.dart';
import 'package:fluttertest/config/routes/routes.dart';
import 'package:fluttertest/config/routes/routes_name.dart';

import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';
import '../../services/time_helper.dart';
import '../../views.dart';
import '../widgets/watch_face_painter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child:  BlocBuilder<MeetingBloc, MeetingState>(
        builder: (context, state) {
          final themeColor = AppColors.getThemeColor(state.watchStatus);

          return Scaffold(
            backgroundColor: AppColors.black,
            body: SafeArea(
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
      )


    );
  }



  Widget _buildPortraitLayout(BuildContext context, MeetingState state, Color themeColor) {
    return Column(
      children: [
        Container(
          height: 4,
          color: themeColor,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildLeftPanel(context, state, themeColor),
              ),
              Expanded(
                flex: 3,
                child: _buildWatchFace(context, state),
              ),
            ],
          ),
        ),
        _buildBottomIcons(themeColor),
        Container(
          height: 4,
          color: themeColor,
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, MeetingState state, Color themeColor) {
    return Column(
      children: [
        Container(
          height: 4,
          color: themeColor,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildLeftPanel(context, state, themeColor),
              ),
              Expanded(
                child: _buildWatchFace(context, state),
              ),
            ],
          ),
        ),
        _buildBottomIcons(themeColor),
        Container(
          height: 4,
          color: themeColor,
        ),
      ],
    );
  }

  Widget _buildLeftPanel(BuildContext context, MeetingState state, Color themeColor) {
    final meeting = state.currentMeeting;
    final doorName = meeting?.doors.isNotEmpty == true
        ? meeting!.doors.first.doorName
        : 'Fire';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              doorName,
              style: TextStyle(
                color: themeColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TimeHelpers.formatDate(state.currentTime),
              style: TextStyle(
                color: themeColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: themeColor,
                  fontSize: 64,
                  height: 1.0,
                ),
                children: [
                  TextSpan(
                    text: TimeHelpers.formatFullTime(state.currentTime).substring(0, 4), // hours
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: TimeHelpers.formatFullTime(state.currentTime).substring(4), // rest (minutes, seconds)
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            if (meeting != null) ...[
              Text(
                '${meeting.meetingType} : ${meeting.eventSubject}',
                style: TextStyle(
                  color: themeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          TimeHelpers.formatTimeWithPeriod(meeting.eventFromDate),
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 16,
                          ),
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
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          TimeHelpers.formatTimeWithPeriod(meeting.eventToDate),
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_today, size: 16),
                      // icon: Image.asset(ImagePath.calender, height: 16),
                      label: const Text('Schedule'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeColor,
                        side: BorderSide(color: themeColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWatchFace(BuildContext context, MeetingState state) {
    return GestureDetector(
      onTapUp: (details) {
        _handleWatchTap(context, details, state);
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomPaint(
              painter: WatchFacePainter(
                meetings: state.meetings,
                currentTime: state.currentTime,
              ),
              child: Container(
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleWatchTap(BuildContext context, TapUpDetails details, MeetingState state) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    print("meeting======>${state.meetings[0]}");
    Navigator.pushNamed(context, RoutesName.details,arguments: state.meetings[0]);

    if (distance < radius - 40 || distance > radius + 40) {
      return;
    }

    var angle = atan2(dy, dx);
    if (angle < 0) angle += 2 * pi;
    angle = (angle + pi / 2) % (2 * pi);

    final segmentIndex = ((angle / (2 * pi)) * 144).floor();
    final meeting = _getMeetingForSegment(segmentIndex, state.meetings, state.currentTime);


    if (meeting != null) {
      Navigator.pushNamed(context, RoutesName.details,arguments: meeting);
    }else{
      print("meeting======>$meeting");
      print("meeting======>$details");
    }
  }

  Meeting? _getMeetingForSegment(int segmentIndex, List<Meeting> meetings, DateTime currentTime) {
    final segmentMinutes = segmentIndex * 5;
    final segmentHour = (segmentMinutes ~/ 60) % 12;
    final segmentMinute = segmentMinutes % 60;

    for (var meeting in meetings) {
      final meetingHour = meeting.eventFromDate.hour % 12;
      final meetingMinute = meeting.eventFromDate.minute;
      final meetingEndHour = meeting.eventToDate.hour % 12;
      final meetingEndMinute = meeting.eventToDate.minute;

      final meetingStartMinutes = meetingHour * 60 + meetingMinute;
      final meetingEndMinutes = meetingEndHour * 60 + meetingEndMinute;
      final currentSegmentMinutes = segmentMinutes;

      if (currentSegmentMinutes >= meetingStartMinutes &&
          currentSegmentMinutes < meetingEndMinutes) {
        return meeting;
      }

    }

    return null;
  }

  Widget _buildBottomIcons(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(ImagePath.ic_info_white, color: themeColor, height: 32),
          Icon(Icons.cleaning_services, color: themeColor, size: 32),
          Image.asset(ImagePath.ic_CupCleaning, color: themeColor, height: 32),
          Image.asset(ImagePath.water_glass_gray, color: themeColor, height: 32),
          Image.asset(ImagePath.ic_add_me_white, color: themeColor, height: 32),
          Image.asset(ImagePath.food_delivery, color: themeColor, height: 32),
          Image.asset(ImagePath.open_lock, color: themeColor, height: 32),
        ],
      ),
    );
  }
}
