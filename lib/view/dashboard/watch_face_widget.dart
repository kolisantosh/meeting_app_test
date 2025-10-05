import '../../model/meeting.dart';
import '../../views.dart';
import '../widgets/watch_face_painter.dart';

class WatchFaceWidget extends StatefulWidget {
  final List<Meeting> meetings;
  final DateTime currentTime;
  final Function(Meeting?)? onSegmentTap;

  const WatchFaceWidget({Key? key, required this.meetings, required this.currentTime, this.onSegmentTap}) : super(key: key);

  @override
  State<WatchFaceWidget> createState() => _WatchFaceWidgetState();
}

class _WatchFaceWidgetState extends State<WatchFaceWidget> {
  late WatchFacePainter _painter;

  @override
  void initState() {
    super.initState();
    _painter = WatchFacePainter(meetings: widget.meetings, currentTime: widget.currentTime, onSegmentTap: widget.onSegmentTap);
  }

  @override
  void didUpdateWidget(covariant WatchFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _painter = WatchFacePainter(meetings: widget.meetings, currentTime: widget.currentTime, onSegmentTap: widget.onSegmentTap);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final tappedMeeting = _painter.hitTestCheck(details.localPosition);
        widget.onSegmentTap?.call(tappedMeeting);
      },
      child: CustomPaint(painter: _painter, size: Size.infinite),
    );
  }
}
