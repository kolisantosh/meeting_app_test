import 'package:equatable/equatable.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object> get props => [];
}

class LoadMeetings extends MeetingEvent {}

class UnLockDoor extends MeetingEvent {
  final String empCode;

  const UnLockDoor({required this.empCode});
}

class ExtendMeetingRequest extends MeetingEvent {
  final int extensionMinutes;
  final int statusId; // Corresponds to IntExtendStatus (322, 323, etc.)

  const ExtendMeetingRequest({
    required this.extensionMinutes,
    required this.statusId,
  });
}

class SendCleaningRequest extends MeetingEvent {}

class SendWaterRequest extends MeetingEvent {
  final int quantity;
  const SendWaterRequest(this.quantity);
}

class CompleteMeetingNow extends MeetingEvent {}

class UpdateCurrentTime extends MeetingEvent {
  final DateTime currentTime;

  const UpdateCurrentTime(this.currentTime);

  @override
  List<Object> get props => [currentTime];
}
