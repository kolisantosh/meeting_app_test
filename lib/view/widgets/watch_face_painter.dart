import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';

class WatchFacePainter extends CustomPainter {
  final List<Meeting> meetings;
  final DateTime currentTime;
  final Function(Meeting?)? onSegmentTap;
  final Map<Path, Meeting> _segmentPaths = {}; // For hit detection
  WatchFacePainter({required this.meetings, required this.currentTime, this.onSegmentTap});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    _drawWatchSegments(canvas, center, radius);
    _drawHourMarkers(canvas, center, radius);
    // _drawClockHand(canvas, center, radius);
    // _drawVShape(canvas, center, radius);
    _drawFilledCaretShape(canvas, center, radius / 2, radius / 2);
    _drawFilledCaretShape1(canvas, center, radius / 2, radius / 2);
    // _drawCaretShape(canvas, center, radius / 2, radius / 2);
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
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.square;

    // Thin black line (15-min marks)
    final separatorPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Thick black line (hour marks)
    final hourSeparatorPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    // Define path for the arc segment
    final path = Path();
    const totalMinutesInDay = 12 * 60;
    final segmentAngle = (5 / totalMinutesInDay) * 2 * pi;

    // 🟢 Draw 5-min segments
    for (int i = 0; i < 144; i++) {
      final startAngle = (i * segmentAngle) - pi / 2;
      final meeting = _getMeetingForSegment(i);

      // 🎨 Segment color
      if (meeting != null) {
        final isOngoing = currentTime.isAfter(meeting.eventFromDate) && currentTime.isBefore(meeting.eventToDate);
        final minutesUntilStart = meeting.eventFromDate.difference(currentTime).inMinutes;
        final isUpcoming = minutesUntilStart >= 0 && minutesUntilStart <= 5;

        if (isOngoing) {
          segmentPaint.color = AppColors.red;
        } else if (isUpcoming) {
          segmentPaint.color = AppColors.yellow;
        } else {
          segmentPaint.color = AppColors.darkRed;
        }
      } else {
        segmentPaint.color = AppColors.green;
      }

      // Draw colored segment arc
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, segmentAngle * 0.8, false, segmentPaint);

      // 🕒 Draw black separator lines
      if (i % 3 == 0 || i == 0) {
        // Every 15 min (3 segments) or explicitly the 12 o’clock position
        final angle = startAngle;
        final isHourMark = (i % 12 == 0);

        final innerOffset = isHourMark ? 15.0 : 8.0;
        final outerOffset = isHourMark ? 20.0 : 8.0;

        final start = Offset(center.dx + (radius - innerOffset) * cos(angle), center.dy + (radius - innerOffset) * sin(angle));
        final end = Offset(center.dx + (radius + outerOffset) * cos(angle), center.dy + (radius + outerOffset) * sin(angle));

        if (meeting != null) {
          _segmentPaths[path] = meeting;
        }
        // Bold for hour marks (including 12 o’clock)
        canvas.drawLine(start, end, isHourMark ? hourSeparatorPaint : separatorPaint);
      }
    }

    // 🕐 Draw hour numbers (1 to 12)
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int hour = 1; hour <= 12; hour++) {
      final angle = (hour / 12) * 2 * pi - pi / 2;
      final textRadius = radius + 30;

      final offset = Offset(center.dx + textRadius * cos(angle), center.dy + textRadius * sin(angle));

      textPainter.text = TextSpan(
        text: hour.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      );
      textPainter.layout();

      final textOffset = offset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }

    // 🕛 Ensure 12 o’clock line is visible (draw explicitly on top)
    final topAngle = -pi / 2;
    final topStart = Offset(center.dx + (radius - 15) * cos(topAngle), center.dy + (radius - 15) * sin(topAngle));
    final topEnd = Offset(center.dx + (radius + 20) * cos(topAngle), center.dy + (radius + 20) * sin(topAngle));

    canvas.drawLine(topStart, topEnd, hourSeparatorPaint);
  }

  Meeting? _getMeetingForSegment(int segmentIndex) {
    final segmentMinutes = segmentIndex * 5;
    final segmentHour = (segmentMinutes ~/ 60) % 12;
    final segmentMinute = segmentMinutes % 60;

    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final segmentTime = today.add(Duration(hours: segmentHour, minutes: segmentMinute));
    final segmentEndTime = segmentTime.add(const Duration(minutes: 5));

    for (var meeting in meetings) {
      final meetingHour = meeting.eventFromDate.hour % 12;
      final meetingMinute = meeting.eventFromDate.minute;
      final meetingEndHour = meeting.eventToDate.hour % 12;
      final meetingEndMinute = meeting.eventToDate.minute;

      final meetingStartMinutes = meetingHour * 60 + meetingMinute;
      final meetingEndMinutes = meetingEndHour * 60 + meetingEndMinute;
      final currentSegmentMinutes = segmentMinutes;

      if (currentSegmentMinutes >= meetingStartMinutes && currentSegmentMinutes < meetingEndMinutes) {
        return meeting;
      }
    }

    return null;
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final x = center.dx + (radius + 30) * cos(angle);
      final y = center.dy + (radius + 30) * sin(angle);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: AppColors.grey, fontSize: 20, fontWeight: FontWeight.normal),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawFilledCaretShape(Canvas canvas, Offset center, double width, double height) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    path.moveTo(center.dx - width / 2, center.dy + height / 2);
    path.lineTo(center.dx, center.dy - height / 2);
    path.lineTo(center.dx + width / 2, center.dy + height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFilledCaretShape1(Canvas canvas, Offset center, double width, double height) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    // 🔽 Shift the shape down by 20 pixels (top padding)
    final double paddingTop = 20;
    final double shiftedY = center.dy + paddingTop;

    path.moveTo(center.dx - width / 2, shiftedY + height / 2); // bottom-left
    path.lineTo(center.dx, shiftedY - height / 3); // top
    path.lineTo(center.dx + width / 2, shiftedY + height / 2); // bottom-right
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawCaretShape(Canvas canvas, Offset center, double width, double height) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;
    // Left bottom point
    path.moveTo(center.dx - width / 2, center.dy + height / 2);

    // Top middle point
    path.lineTo(center.dx, center.dy - height / 3);

    // Right bottom point
    path.lineTo(center.dx + width / 2, center.dy + height / 2);

    canvas.drawPath(path, paint);
  }

  void _drawClockHand(Canvas canvas, Offset center, double radius) {
    final hour = currentTime.hour % 12;
    final minute = currentTime.minute;
    final totalMinutes = hour * 60 + minute;
    final angle = (totalMinutes / 720) * 2 * pi - pi / 2;

    final path = Path();
    final handLength = radius * 0.6;

    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx + handLength * cos(angle), center.dy + handLength * sin(angle));

    final handPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final double tipX = center.dx + handLength * cos(angle);
    final double tipY = center.dy + handLength * sin(angle);

    final trianglePath = Path();
    final triangleSize = 40.0;

    trianglePath.moveTo(tipX, tipY);
    trianglePath.lineTo(tipX - triangleSize * cos(angle + pi / 6), tipY - triangleSize * sin(angle + pi / 6));
    trianglePath.lineTo(tipX - triangleSize * cos(angle - pi / 6), tipY - triangleSize * sin(angle - pi / 6));
    trianglePath.close();

    canvas.drawPath(trianglePath, handPaint);
  }

  @override
  bool shouldRepaint(WatchFacePainter oldDelegate) {
    return oldDelegate.currentTime != currentTime || oldDelegate.meetings != meetings;
  }
}
