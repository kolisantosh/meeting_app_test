import 'package:equatable/equatable.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object> get props => [];
}

class LoadMeetings extends MeetingEvent {}

class UpdateCurrentTime extends MeetingEvent {
  final DateTime currentTime;

  const UpdateCurrentTime(this.currentTime);

  @override
  List<Object> get props => [currentTime];
}
