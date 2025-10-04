import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertest/config/image/imape_path.dart';

import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';

class WatchFacePainter extends CustomPainter {
  final List<Meeting> meetings;
  final DateTime currentTime;
  final Function(Meeting?)? onSegmentTap;

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
    _drawHourMarkers(canvas, center, radius);
    // _drawClockHand(canvas, center, radius);
    // _drawVShape(canvas,center,radius);
    // _drawFilledCaretShape(canvas,center,radius,radius);
    _drawCaretShape(canvas,center,radius,radius);



  }
  void _drawCaretShape(Canvas canvas, Offset center, double width, double height) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    // Left bottom point
    path.moveTo(center.dx - width / 2, center.dy + height / 2);

    // Top middle point
    path.lineTo(center.dx, center.dy - height / 2);

    // Right bottom point
    path.lineTo(center.dx + width / 2, center.dy + height / 2);

    canvas.drawPath(path, paint);
  }


// Loads an image from assets as ui.Image
  Future<ui.Image> loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
  void _drawLogo(Canvas canvas, Size size, ui.Image image) {
    final imageSize = 80.0;
    final centerOffset = Offset(
      (size.width - imageSize) / 2,
      (size.height - imageSize) / 2,
    );

    final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromLTWH(centerOffset.dx, centerOffset.dy, imageSize, imageSize);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  void _drawWatchSegments(Canvas canvas, Offset center, double radius) {
    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final totalMinutesInDay = 12 * 60;
    final segmentAngle = (5 / totalMinutesInDay) * 2 * pi;

    for (int i = 0; i < 144; i++) {
      final startAngle = (i * segmentAngle) - pi / 2;
      final meeting = _getMeetingForSegment(i);

      if (meeting != null) {
        final isOngoing = currentTime.isAfter(meeting.eventFromDate) &&
            currentTime.isBefore(meeting.eventToDate);
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

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle * 0.8,
        false,
        segmentPaint,
      );
    }
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

      if (currentSegmentMinutes >= meetingStartMinutes &&
          currentSegmentMinutes < meetingEndMinutes) {
        return meeting;
      }
    }

    return null;
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final x = center.dx + (radius + 30) * cos(angle);
      final y = center.dy + (radius + 30) * sin(angle);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(
          color: AppColors.grey,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }
  void _drawFilledCaretShape(Canvas canvas, Offset center, double width, double height) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    path.moveTo(center.dx - width / 2, center.dy + height / 2);
    path.lineTo(center.dx, center.dy - height / 2);
    path.lineTo(center.dx + width / 2, center.dy + height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawVShape(Canvas canvas, Offset center, double size) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    // Starting from the left upper arm of V
    path.moveTo(center.dx - size / 2, center.dy - size / 2);

    // Draw line down to the bottom point of V
    path.lineTo(center.dx, center.dy + size / 2);

    // Draw line up to the right upper arm of V
    path.lineTo(center.dx + size / 2, center.dy - size / 2);

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
    path.lineTo(
      center.dx + handLength * cos(angle),
      center.dy + handLength * sin(angle),
    );

    final handPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final double tipX = center.dx + handLength * cos(angle);
    final double tipY = center.dy + handLength * sin(angle);

    final trianglePath = Path();
    final triangleSize = 40.0;

    trianglePath.moveTo(tipX, tipY);
    trianglePath.lineTo(
      tipX - triangleSize * cos(angle + pi / 6),
      tipY - triangleSize * sin(angle + pi / 6),
    );
    trianglePath.lineTo(
      tipX - triangleSize * cos(angle - pi / 6),
      tipY - triangleSize * sin(angle - pi / 6),
    );
    trianglePath.close();

    canvas.drawPath(trianglePath, handPaint);
  }

  @override
  bool shouldRepaint(WatchFacePainter oldDelegate) {
    return oldDelegate.currentTime != currentTime ||
        oldDelegate.meetings != meetings;
  }
}
