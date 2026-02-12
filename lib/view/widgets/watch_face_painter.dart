import 'dart:math';

import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';
import '../../views.dart';

class WatchFacePainter extends CustomPainter {
  final List<Meeting> meetings;
  final DateTime currentTime;
  final Function(Meeting?)? onSegmentTap;
  final Map<Path, Meeting> _segmentPaths = {}; // For hit detection
  WatchFacePainter({
    required this.meetings,
    required this.currentTime,
    this.onSegmentTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    _drawWatchSegments(canvas, center, radius);
    // _drawHourMarkers(canvas, center, radius);
    // _drawFilledCaretShape(canvas, center, radius / 2, radius / 2);
    // _drawFilledCaretShape1(canvas, center, radius / 2, radius / 2);
  }

  Meeting? hitTestCheck(Offset position) {
    for (final entry in _segmentPaths.entries) {
      final path = entry.key;
      if (path.contains(position)) {
        return entry.value;
      }
    }
    return null;
  }

  void _drawWatchSegments(Canvas canvas, Offset center, double radius) {
    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25.w;

    final separatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.w;

    final hourSeparatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.w;

    const totalSegments = 144;
    final segmentAngle = (2 * pi) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      final startAngle = (i * segmentAngle) - pi / 2;
      final meeting = _getMeetingForSegment(i);
      final path = Path();

      if (meeting != null) {
        final isOngoing =
            currentTime.isAfter(meeting.eventFromDate) &&
            currentTime.isBefore(meeting.eventToDate);
        final minutesUntilStart = meeting.eventFromDate
            .difference(currentTime)
            .inMinutes;
        final isUpcoming = minutesUntilStart >= 0 && minutesUntilStart <= 5;

        if (isOngoing) {
          segmentPaint.color = AppColors.brightRedColor;
        } else if (isUpcoming) {
          segmentPaint.color = AppColors.brightYellowColor;
        } else {
          segmentPaint.color = AppColors.brightRedColor;
        }
      } else {
        segmentPaint.color = AppColors.brightGreenColor.withOpacity(.3);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle * 0.8,
        false,
        segmentPaint,
      );

      if (i % 3 == 0 || i == 0) {
        final angle = startAngle;
        final isHourMark = (i % 12 == 0);

        final innerOffset = isHourMark ? 15.0 : 8.0;
        final outerOffset = isHourMark ? 20.0 : 8.0;

        final start = Offset(
          center.dx + (radius - innerOffset) * cos(angle),
          center.dy + (radius - innerOffset) * sin(angle),
        );
        final end = Offset(
          center.dx + (radius + outerOffset) * cos(angle),
          center.dy + (radius + outerOffset) * sin(angle),
        );

        if (meeting != null) {
          _segmentPaths[path] = meeting;
        }

        canvas.drawLine(
          start,
          end,
          isHourMark ? hourSeparatorPaint : separatorPaint,
        );
      }
    }

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int hour = 1; hour <= 12; hour++) {
      final angle = (hour / 12) * 2 * pi - pi / 2;
      final textRadius = radius + 30;

      final offset = Offset(
        center.dx + textRadius * cos(angle),
        center.dy + textRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: hour.toString(),
        style: const TextStyle(
          color: AppColors.grey,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  Meeting? _getMeetingForSegment(int i) {
    final segmentMinutes = i * 5;

    for (final meeting in meetings) {
      final startHour = meeting.eventFromDate.hour % 12;
      final endHour = meeting.eventToDate.hour % 12;
      final startMinutes = startHour * 60 + meeting.eventFromDate.minute;
      final endMinutes = endHour * 60 + meeting.eventToDate.minute;

      bool matches = false;
      if (endMinutes >= startMinutes) {
        matches = segmentMinutes >= startMinutes && segmentMinutes < endMinutes;
      } else {
        // Spans across noon on clock
        matches = segmentMinutes >= startMinutes || segmentMinutes < endMinutes;
      }

      if (matches) {
        return meeting;
      }
    }

    return null;
  }

  Color _getCaretColor() {
    for (final meeting in meetings) {
      final isOngoing =
          currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate);

      if (isOngoing) {
        return AppColors.brightRedColor; // 🔴 ongoing
      }
    }

    for (final meeting in meetings) {
      final minutesUntilStart = meeting.eventFromDate
          .difference(currentTime)
          .inMinutes;

      if (minutesUntilStart >= 0 && minutesUntilStart <= 5) {
        return AppColors.brightYellowColor; // 🟡 upcoming
      }
    }

    return AppColors.brightGreenColor; // 🟢 free
  }

  void _drawFilledCaretShape(
    Canvas canvas,
    Offset center,
    double width,
    double height,
  ) {
    final path = Path();
    final paint = Paint()
      ..color = _getCaretColor()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.w;
    path.moveTo(center.dx - width / 2, center.dy + height / 2);
    path.lineTo(center.dx, center.dy - height / 2);
    path.lineTo(center.dx + width / 2, center.dy + height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFilledCaretShape1(
    Canvas canvas,
    Offset center,
    double width,
    double height,
  ) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final double paddingTop = 20;
    final double shiftedY = center.dy + paddingTop;

    path.moveTo(center.dx - width / 2, shiftedY + height / 2); // bottom-left
    path.lineTo(center.dx, shiftedY - height / 3); // top
    path.lineTo(center.dx + width / 2, shiftedY + height / 2); // bottom-right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WatchFacePainter oldDelegate) {
    return oldDelegate.currentTime != currentTime ||
        oldDelegate.meetings != meetings;
  }
}
