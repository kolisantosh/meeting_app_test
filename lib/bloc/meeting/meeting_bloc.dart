import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/meeting.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  Timer? _timer;

  MeetingBloc() : super(MeetingState(currentTime: DateTime.now())) {
    on<LoadMeetings>(_onLoadMeetings);
    on<UpdateCurrentTime>(_onUpdateCurrentTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateCurrentTime(DateTime.now()));
    });
  }

  Future<void> _onLoadMeetings(
      LoadMeetings event,
      Emitter<MeetingState> emit,
      ) async {
    emit(state.copyWith(status: MeetingStatus.loading));

    try {
      final String jsonString = await rootBundle.loadString('file/meetings.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> meetingList = jsonData['Data']['list'];

      final meetings = meetingList
          .map((json) => Meeting.fromJson(json))
          .toList();

      final currentTime = DateTime.now();
      final watchStatus = _calculateWatchStatus(meetings, currentTime);
      final currentMeeting = _findCurrentOrUpcomingMeeting(meetings, currentTime);

      emit(state.copyWith(
        status: MeetingStatus.success,
        meetings: meetings,
        currentTime: currentTime,
        watchStatus: watchStatus,
        currentMeeting: currentMeeting,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MeetingStatus.failure,
        errorMessage: 'Failed to load meetings: $e',
      ));
    }
  }

  void _onUpdateCurrentTime(
      UpdateCurrentTime event,
      Emitter<MeetingState> emit,
      ) {
    final watchStatus = _calculateWatchStatus(state.meetings, event.currentTime);
    final currentMeeting = _findCurrentOrUpcomingMeeting(state.meetings, event.currentTime);

    emit(state.copyWith(
      currentTime: event.currentTime,
      watchStatus: watchStatus,
      currentMeeting: currentMeeting,
    ));
  }

  WatchStatus _calculateWatchStatus(List<Meeting> meetings, DateTime currentTime) {
    for (var meeting in meetings) {
      if (currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate)) {
        return WatchStatus.red;
      }

      final minutesUntilStart = meeting.eventFromDate.difference(currentTime).inMinutes;
      if (minutesUntilStart >= 0 && minutesUntilStart <= 5) {
        return WatchStatus.yellow;
      }
    }

    return WatchStatus.green;
  }

  Meeting? _findCurrentOrUpcomingMeeting(List<Meeting> meetings, DateTime currentTime) {
    for (var meeting in meetings) {
      if (currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate)) {
        return meeting;
      }
    }

    for (var meeting in meetings) {
      if (meeting.eventFromDate.isAfter(currentTime)) {
        return meeting;
      }
    }

    return meetings.isNotEmpty ? meetings.first : null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
