import 'package:equatable/equatable.dart';

import '../../models/meeting/meeting_model.dart';

enum MeetingStatus { initial, loading, success, failure }

enum WatchStatus { green, yellow, red }

class MeetingState extends Equatable {
  final MeetingStatus status;
  final List<MeetingModel> meetings;
  final DateTime currentTime;
  final WatchStatus watchStatus;
  final MeetingModel? currentMeeting;
  final String? errorMessage;

  // New fields for Extend/Action Logic
  final String selectionType; // e.g., "extendMeeting", "addWater"
  final bool showHostSelection;
  final int intExtendStatus; // 322, 323, 324 etc.
  final int pendingExtensionMinutes;

  const MeetingState({
    this.status = MeetingStatus.initial,
    this.meetings = const [],
    required this.currentTime,
    this.watchStatus = WatchStatus.green,
    this.currentMeeting,
    this.errorMessage,
    this.selectionType = "",
    this.showHostSelection = false,
    this.intExtendStatus = 0,
    this.pendingExtensionMinutes = 0,
  });

  MeetingState copyWith({
    MeetingStatus? status,
    List<MeetingModel>? meetings,
    DateTime? currentTime,
    WatchStatus? watchStatus,
    MeetingModel? currentMeeting,
    String? errorMessage,
    String? selectionType,
    bool? showHostSelection,
    int? intExtendStatus,
    int? pendingExtensionMinutes,
  }) {
    return MeetingState(
      status: status ?? this.status,
      meetings: meetings ?? this.meetings,
      currentTime: currentTime ?? this.currentTime,
      watchStatus: watchStatus ?? this.watchStatus,
      currentMeeting: currentMeeting ?? this.currentMeeting,
      errorMessage: errorMessage ?? this.errorMessage,
      selectionType: selectionType ?? this.selectionType,
      showHostSelection: showHostSelection ?? this.showHostSelection,
      intExtendStatus: intExtendStatus ?? this.intExtendStatus,
      pendingExtensionMinutes:
          pendingExtensionMinutes ?? this.pendingExtensionMinutes,
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
    selectionType,
    showHostSelection,
    intExtendStatus,
    pendingExtensionMinutes,
  ];
}
