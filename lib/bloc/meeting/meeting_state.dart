import 'package:equatable/equatable.dart';

import '../../model/meeting.dart';

enum MeetingStatus { initial, loading, success, failure }

enum WatchStatus { green, yellow, red }

class MeetingState extends Equatable {
  final MeetingStatus status;
  final List<Meeting> meetings;
  final DateTime currentTime;
  final WatchStatus watchStatus;
  final Meeting? currentMeeting;
  final String? errorMessage;

  const MeetingState({
    this.status = MeetingStatus.initial,
    this.meetings = const [],
    required this.currentTime,
    this.watchStatus = WatchStatus.green,
    this.currentMeeting,
    this.errorMessage,
  });

  MeetingState copyWith({
    MeetingStatus? status,
    List<Meeting>? meetings,
    DateTime? currentTime,
    WatchStatus? watchStatus,
    Meeting? currentMeeting,
    String? errorMessage,
  }) {
    return MeetingState(
      status: status ?? this.status,
      meetings: meetings ?? this.meetings,
      currentTime: currentTime ?? this.currentTime,
      watchStatus: watchStatus ?? this.watchStatus,
      currentMeeting: currentMeeting ?? this.currentMeeting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    meetings,
    currentTime,
    watchStatus,
    currentMeeting,
    errorMessage,
  ];
}
