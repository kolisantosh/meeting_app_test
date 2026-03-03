import 'dart:math';

import '../../config/constants/app_colors.dart';
import '../../models/meeting/meeting_model.dart';
import '../../views.dart';

/*abstract class BaseClockPainter extends CustomPainter {
  final List<MeetingModel> meetings;
  final DateTime currentTime;
  final Map<Path, MeetingModel> segmentPaths = {};

  BaseClockPainter({required this.meetings, required this.currentTime});
  //
  // MeetingModel? hitTest(Offset position, Size size) {
  //   for (var entry in segmentPaths.entries) {
  //     if (entry.key.contains(position)) return entry.value;
  //   }
  //   return null;
  // }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  // Shared helper for meeting segments
  MeetingModel? getMeetingForSegment(int segmentIndex) {
    final segmentMinutes = segmentIndex * 5;
    for (final meeting in meetings) {
      final start =
          (meeting.eventFromDate.hour % 12) * 60 + meeting.eventFromDate.minute;
      final end =
          (meeting.eventToDate.hour % 12) * 60 + meeting.eventToDate.minute;
      if (end >= start) {
        if (segmentMinutes >= start && segmentMinutes < end) return meeting;
      } else {
        if (segmentMinutes >= start || segmentMinutes < end) return meeting;
      }
    }
    return null;
  }
}

// --- TYPE 1: ACTIVITY RING ---
class ActivityPainter extends BaseClockPainter {
  ActivityPainter({required super.meetings, required super.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final pulse = (sin(currentTime.millisecondsSinceEpoch / 300) + 1) / 2;

    segmentPaths.clear();

    // Background
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25,
    );

    for (int i = 0; i < 144; i++) {
      final meeting = getMeetingForSegment(i);
      final startAngle = (i * (2 * pi / 144)) - pi / 2;
      final sweepAngle = (2 * pi / 144) - 0.01;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25
        ..strokeCap = StrokeCap.round
        ..color = meeting != null ? Colors.red : Colors.greenAccent;

      if (meeting != null) {
        final isOngoing =
            currentTime.isAfter(meeting.eventFromDate) &&
            currentTime.isBefore(meeting.eventToDate);
        if (isOngoing) {
          paint.strokeWidth = 25 + (5 * pulse);
          paint.imageFilter = ImageFilter.blur(
            sigmaX: 2 * pulse,
            sigmaY: 2 * pulse,
          );
        }
        segmentPaths[Path()..addArc(rect.inflate(10), startAngle, sweepAngle)] =
            meeting;
      }
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }
}

// --- TYPE 2: RADAR TECH ---
class RadarPainter extends BaseClockPainter {
  RadarPainter({required super.meetings, required super.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Radar Background
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.stroke,
    );

    // 2. Meeting Slices (Correct Shader usage)
    for (var meeting in meetings) {
      final start =
          (meeting.eventFromDate.hour % 12 +
                  meeting.eventFromDate.minute / 60) *
              30 *
              pi /
              180 -
          pi / 2;
      final end =
          (meeting.eventToDate.hour % 12 + meeting.eventToDate.minute / 60) *
              30 *
              pi /
              180 -
          pi / 2;

      final slicePaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.green.withOpacity(0.4), Colors.transparent],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, start, end - start, true, slicePaint);
    }

    // 3. Scanning Sweep (Correct Shader usage)
    final sweepAngle =
        (currentTime.second + currentTime.millisecond / 1000) * 6 * pi / 180 -
        pi / 2;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [Colors.transparent, Colors.green.withOpacity(0.6)],
        stops: const [0.9, 1.0],
        transform: GradientRotation(sweepAngle),
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sweepPaint);
  }
}

class SolarOrbitPainter extends BaseClockPainter {
  SolarOrbitPainter({required super.meetings, required super.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2 - 20;

    // 1. Draw "Orbit" rings for visual depth
    final orbitPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double r = 0.4; r <= 1.0; r += 0.2) {
      canvas.drawCircle(center, maxRadius * r, orbitPaint);
    }

    // 2. Draw Meetings as Floating Orbs
    for (var meeting in meetings) {
      final startAngle =
          (meeting.eventFromDate.hour % 12 +
                  meeting.eventFromDate.minute / 60) *
              30 *
              pi /
              180 -
          pi / 2;
      final endAngle =
          (meeting.eventToDate.hour % 12 + meeting.eventToDate.minute / 60) *
              30 *
              pi /
              180 -
          pi / 2;

      final middleAngle = (startAngle + endAngle) / 2;
      final orbRadius = maxRadius * 0.8;
      final orbPos = Offset(
        center.dx + orbRadius * cos(middleAngle),
        center.dy + orbRadius * sin(middleAngle),
      );

      final isOngoing =
          currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate);

      // Meeting Glow
      final orbPaint = Paint()
        ..color = isOngoing
            ? Colors.orangeAccent
            : Colors.blueAccent.withOpacity(0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isOngoing ? 8 : 2);

      canvas.drawCircle(orbPos, isOngoing ? 12 : 6, orbPaint);

      // Store hit path
      // segmentPaths[Path()..addCircle(orbPos, 20)] = meeting;
    }

    // 3. The "Gravity" Second Hand
    final sAngle =
        (currentTime.second + currentTime.millisecond / 1000) * 6 * pi / 180 -
        pi / 2;
    final wavePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..strokeWidth = 2;

    canvas.drawLine(
      center,
      center + Offset(cos(sAngle) * maxRadius, sin(sAngle) * maxRadius),
      wavePaint,
    );
  }
}

class MatrixHelixPainter extends BaseClockPainter {
  MatrixHelixPainter({required super.meetings, required super.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final height = size.height - 40;
    final width = 60.0;
    final rect = Rect.fromCenter(center: center, width: width, height: height);

    // 1. Draw the "Stream" Container
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(30)),
      Paint()..color = Colors.black.withOpacity(0.8),
    );

    // 2. Map 12 hours to the vertical height
    final double pixelPerMinute = height / (12 * 60);
    final double currentMinuteOffsetY =
        (currentTime.hour % 12 * 60 + currentTime.minute) * pixelPerMinute;

    // 3. Draw Meetings as Data Blocks
    for (var meeting in meetings) {
      final startY =
          (meeting.eventFromDate.hour % 12 * 60 +
              meeting.eventFromDate.minute) *
          pixelPerMinute;
      final endY =
          (meeting.eventToDate.hour % 12 * 60 + meeting.eventToDate.minute) *
          pixelPerMinute;

      final blockRect = Rect.fromLTRB(
        center.dx - width / 2 + 5,
        rect.top + startY,
        center.dx + width / 2 - 5,
        rect.top + endY,
      );

      final isOngoing =
          currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate);

      canvas.drawRRect(
        RRect.fromRectAndRadius(blockRect, const Radius.circular(8)),
        Paint()
          ..color = isOngoing
              ? Colors.cyanAccent
              : Colors.cyan.withOpacity(0.3),
      );

      segmentPaths[Path()..addRect(blockRect)] = meeting;
    }

    // 4. Current Time Indicator (Floating Line)
    final indicatorY = rect.top + currentMinuteOffsetY;
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    canvas.drawLine(
      Offset(center.dx - width / 2 - 10, indicatorY),
      Offset(center.dx + width / 2 + 10, indicatorY),
      indicatorPaint,
    );
  }
}

class MinimalistPainter1 extends CustomPainter {
  final List<MeetingModel> meetings;
  final DateTime currentTime;

  MinimalistPainter1({required this.meetings, required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // 1. Draw Hour Ticks
    for (var i = 0; i < 60; i++) {
      final angle = i * 6 * pi / 180;
      final isHour = i % 5 == 0;
      final tickLength = isHour ? 15.0 : 8.0;

      canvas.drawLine(
        Offset(
          center.dx + (radius - tickLength) * cos(angle),
          center.dy + (radius - tickLength) * sin(angle),
        ),
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        Paint()
          ..color = isHour ? Colors.black : Colors.grey
          ..strokeWidth = isHour ? 2 : 1,
      );
    }

    // 2. Meeting Dots (Instead of arcs)
    for (var meeting in meetings) {
      final startAngle =
          (meeting.eventFromDate.hour % 12 +
                  meeting.eventFromDate.minute / 60) *
              30 *
              pi /
              180 -
          pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + (radius - 30) * cos(startAngle),
          center.dy + (radius - 30) * sin(startAngle),
        ),
        4,
        Paint()..color = AppColors.solidRedColor,
      );
    }

    // 3. Elegant Hands
    _drawHand(
      canvas,
      center,
      (currentTime.hour % 12 + currentTime.minute / 60) * 30,
      radius * 0.5,
      4,
    ); // Hour
    _drawHand(
      canvas,
      center,
      currentTime.minute * 6,
      radius * 0.8,
      2,
    ); // Minute

    _drawSweepNeedle(canvas, center, radius);
  }

  void _drawSweepNeedle(Canvas canvas, Offset center, double radius) {
    // Smooth second hand calculation
    final fractionalSeconds =
        currentTime.second + (currentTime.millisecond / 1000.0);
    final angle = (fractionalSeconds / 60) * 2 * pi - pi / 2;

    final needlePaint = Paint()
      ..color = AppColors.brightRedColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final startOffset = Offset(
      center.dx + (-15 * cos(angle)),
      center.dy + (-15 * sin(angle)),
    );
    final endOffset = Offset(
      center.dx + ((radius + 10) * cos(angle)),
      center.dy + ((radius + 10) * sin(angle)),
    );

    canvas.drawLine(startOffset, endOffset, needlePaint);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angleDeg,
    double length,
    double width,
  ) {
    final angle = (angleDeg - 90) * pi / 180;
    canvas.drawLine(
      center,
      Offset(center.dx + length * cos(angle), center.dy + length * sin(angle)),
      Paint()
        ..color = Colors.black
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ModernWatchFacePainter extends CustomPainter {
  final List<MeetingModel> meetings;
  final DateTime currentTime;
  final Map<Path, MeetingModel> _segmentPaths = {};

  ModernWatchFacePainter({required this.meetings, required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 45;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Calculate pulse (0.0 to 1.0) using a Sine wave for a "breathing" effect
    // Period is roughly 2 seconds
    final pulseValue = (sin(currentTime.millisecondsSinceEpoch / 300) + 1) / 2;

    _drawBackgroundTrack(canvas, center, radius);
    _drawSegments(canvas, center, radius, rect, pulseValue);
    _drawHourMarkers(canvas, center, radius);
    _drawHourNumbers(canvas, center, radius);
    _drawSweepNeedle(canvas, center, radius);
    _drawCenterHub(canvas, center);
  }

  void _drawBackgroundTrack(Canvas canvas, Offset center, double radius) {
    final trackPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    canvas.drawCircle(center, radius, trackPaint);
  }

  void _drawSegments(
    Canvas canvas,
    Offset center,
    double radius,
    Rect rect,
    double pulse,
  ) {
    _segmentPaths.clear();
    const totalSegments = 144;
    const segmentAngle = (2 * pi) / totalSegments;
    const gap = 0.015;

    for (int i = 0; i < totalSegments; i++) {
      final startAngle = (i * segmentAngle) - pi / 2 + (gap / 2);
      final sweepAngle = segmentAngle - gap;
      final meeting = _getMeetingForSegment(i);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;

      if (meeting != null) {
        final isOngoing =
            currentTime.isAfter(meeting.eventFromDate) &&
            currentTime.isBefore(meeting.eventToDate);

        if (isOngoing) {
          // PULSE LOGIC: Vary thickness and blur intensity
          paint.color = AppColors.brightRedColor;
          paint.strokeWidth = 24 + (6 * pulse); // Grows from 24 to 30
          paint.imageFilter = ImageFilter.blur(
            sigmaX: 1 + (3 * pulse),
            sigmaY: 1 + (3 * pulse),
          );
        } else {
          paint.color = AppColors.solidRedColor;
        }

        final path = Path()..addArc(rect, startAngle, sweepAngle);
        _segmentPaths[path] = meeting;
        canvas.drawPath(path, paint);
      } else {
        paint.color = AppColors.brightGreenColor;
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      }
    }
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final markerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 1.5.w;

    for (int i = 0; i < 12; i++) {
      final angle = (i * (2 * pi / 12)) - pi / 2;
      final innerPos = Offset(
        center.dx + (radius - 25.h) * cos(angle),
        center.dy + (radius - 25.h) * sin(angle),
      );
      final outerPos = Offset(
        center.dx + (radius - 15.h) * cos(angle),
        center.dy + (radius - 15.h) * sin(angle),
      );
      canvas.drawLine(innerPos, outerPos, markerPaint);
    }
  }

  void _drawHourNumbers(Canvas canvas, Offset center, double radius) {
    for (int hour = 1; hour <= 12; hour++) {
      final angle = (hour / 12) * 2 * pi - pi / 2;
      final textRadius = radius + 35.h;

      final tp = TextPainter(
        text: TextSpan(
          text: hour.toString(),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 18.h,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        center.dx + textRadius * cos(angle) - (tp.width / 2),
        center.dy + textRadius * sin(angle) - (tp.height / 2),
      );
      tp.paint(canvas, offset);
    }
  }

  MeetingModel? hitTestCheck(Offset position) {
    for (final entry in _segmentPaths.entries) {
      if (entry.key.contains(position)) return entry.value;
    }
    return null;
  }

  MeetingModel? _getMeetingForSegment(int segmentIndex) {
    final segmentMinutes = segmentIndex * 5;
    for (final meeting in meetings) {
      if (meeting.statusDesc == "Completed" ||
          meeting.statusDesc == "Cancelled" ||
          // meeting.doors.length > 0 ||
          currentTime.isAfter(meeting.eventToDate)) {
        continue;
      }

      final startMinutes =
          (meeting.eventFromDate.hour % 12) * 60 + meeting.eventFromDate.minute;
      final endMinutes =
          (meeting.eventToDate.hour % 12) * 60 + meeting.eventToDate.minute;

      if (endMinutes >= startMinutes) {
        if (segmentMinutes >= startMinutes && segmentMinutes < endMinutes)
          return meeting;
      } else {
        if (segmentMinutes >= startMinutes || segmentMinutes < endMinutes)
          return meeting;
      }
    }
    return null;
  }

  void _drawSweepNeedle(Canvas canvas, Offset center, double radius) {
    // Smooth second hand calculation
    final fractionalSeconds =
        currentTime.second + (currentTime.millisecond / 1000.0);
    final angle = (fractionalSeconds / 60) * 2 * pi - pi / 2;

    final needlePaint = Paint()
      ..color = AppColors.brightRedColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final startOffset = Offset(
      center.dx + (-15 * cos(angle)),
      center.dy + (-15 * sin(angle)),
    );
    final endOffset = Offset(
      center.dx + ((radius + 10) * cos(angle)),
      center.dy + ((radius + 10) * sin(angle)),
    );

    canvas.drawLine(startOffset, endOffset, needlePaint);
  }

  void _drawCenterHub(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 6, Paint()..color = Colors.black);
    canvas.drawCircle(
      center,
      2,
      Paint()..color = Colors.white.withOpacity(0.5),
    );
  }

  @override
  bool shouldRepaint(covariant ModernWatchFacePainter oldDelegate) => true;
}*/

class WatchFacePainter extends CustomPainter {
  final List<MeetingModel> meetings;
  final DateTime currentTime;

  /// Used for tap detection
  final Map<Path, MeetingModel> _segmentPaths = {};

  WatchFacePainter({required this.meetings, required this.currentTime});

  /// =========================
  /// MAIN PAINT METHOD
  /// =========================
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 30;

    _drawWatchSegments(canvas, center, radius);
    _drawHourNumbers(canvas, center, radius);
  }

  /// =========================
  /// DRAW SEGMENTS
  /// =========================
  void _drawWatchSegments(Canvas canvas, Offset center, double radius) {
    _segmentPaths.clear();

    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.h
      ..strokeCap = StrokeCap.butt;

    final separatorPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.w;

    final hourSeparatorPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.w;

    const totalSegments = 144; // 12 hours × 60 / 5
    final segmentAngle = (2 * pi) / totalSegments;
    bool isOngoing = false;
    bool isUpcoming = false;

    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < totalSegments; i++) {
      final startAngle = (i * segmentAngle) - pi / 2;
      final meeting = _getMeetingForSegment(i);

      final hasActiveOrUpcoming = isAnyMeetingActiveOrUpcoming();

      /// COLOR LOGIC
      if (meeting != null) {
        isOngoing =
            currentTime.isAfter(meeting.eventFromDate) &&
            currentTime.isBefore(meeting.eventToDate);
        final minutesUntilStart = meeting.eventFromDate
            .difference(currentTime)
            .inMinutes;

        isUpcoming = minutesUntilStart >= 0 && minutesUntilStart < 5;

        if (isOngoing) {
          segmentPaint.color = AppColors.brightRedColor;
        } else if (isUpcoming) {
          segmentPaint.color = AppColors.brightYellowColor;
        } else if (currentTime.isAfter(meeting.eventToDate)) {
          segmentPaint.color = hasActiveOrUpcoming
              ? AppColors.solidGreenColor
              : AppColors.brightGreenColor;
        } else {
          segmentPaint.color = AppColors.solidRedColor;
        }
      } else {
        segmentPaint.color = hasActiveOrUpcoming
            ? AppColors.solidGreenColor
            : AppColors.brightGreenColor;
      }

      /// CREATE ARC PATH (IMPORTANT FOR TAP DETECTION)
      final path = Path()..addArc(rect, startAngle, segmentAngle);

      canvas.drawPath(path, segmentPaint);

      if (i % 3 == 0 || i == 0) {
        final angle = startAngle;
        final isHourMark = (i % 12 == 0);

        final innerOffset = isHourMark ? 15.0 : 8.0;
        final outerOffset = isHourMark ? 20.0 : 18.0;

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

      /// Store path for hit test
      if (meeting != null) {
        _segmentPaths[path] = meeting;
      }
    }
  }

  /// =========================
  /// DRAW HOUR NUMBERS
  /// =========================
  void _drawHourNumbers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int hour = 1; hour <= 12; hour++) {
      final angle = (hour / 12) * 2 * pi - pi / 2;
      final textRadius = radius + 38;

      final offset = Offset(
        center.dx + textRadius * cos(angle),
        center.dy + textRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: hour.toString(),
        style: TextStyle(
          color: AppColors.grey.withValues(alpha: 0.95),
          fontSize: 22,
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

  bool isAnyMeetingActiveOrUpcoming() {
    for (final meeting in meetings) {
      if (meeting.statusDesc == "Completed" ||
          meeting.statusDesc == "Cancelled" ||
          // meeting.doors.length > 0 ||
          currentTime.isAfter(meeting.eventToDate)) {
        continue;
      }

      final isOngoing =
          currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate);

      final minutesUntilStart = meeting.eventFromDate
          .difference(currentTime)
          .inMinutes;

      final isUpcoming = minutesUntilStart >= 0 && minutesUntilStart < 5;

      if (isOngoing || isUpcoming) {
        return true;
      }
    }

    return false;
  }

  /// =========================
  /// FIND MEETING FOR SEGMENT
  /// =========================
  MeetingModel? _getMeetingForSegment(int segmentIndex) {
    final segmentMinutes = segmentIndex * 5;

    for (final meeting in meetings) {
      if (meeting.statusDesc == "Completed" ||
          meeting.statusDesc == "Cancelled" ||
          // meeting.doors.length > 0 ||
          currentTime.isAfter(meeting.eventToDate)) {
        continue;
      }

      // if (!currentTime.isAfter(meeting.eventToDate)) {
      final startHour = meeting.eventFromDate.hour % 12;
      final endHour = meeting.eventToDate.hour % 12;
      final startMinutes = startHour * 60 + meeting.eventFromDate.minute;

      final endMinutes = endHour * 60 + meeting.eventToDate.minute;

      bool matches;
      if (endMinutes >= startMinutes) {
        matches = segmentMinutes >= startMinutes && segmentMinutes < endMinutes;
      } else {
        /// Handles crossing 12 (11:30 → 12:30)
        matches = segmentMinutes >= startMinutes || segmentMinutes < endMinutes;
      }

      if (matches) return meeting;
      // }
    }

    return null;
  }

  /// =========================
  /// TAP DETECTION
  /// =========================
  MeetingModel? hitTestCheck(Offset position) {
    for (final entry in _segmentPaths.entries) {
      if (entry.key.contains(position)) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant WatchFacePainter oldDelegate) {
    return oldDelegate.currentTime != currentTime ||
        oldDelegate.meetings != meetings;
  }
}
