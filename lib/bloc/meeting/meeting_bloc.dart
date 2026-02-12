import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fluttertest/views.dart';

import '../../model/meeting.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  Timer? _timer;
  APIFunction apiFunction = APIFunction();
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
      final String jsonString = await rootBundle.loadString(
        'assets/file/meetings.json',
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> meetingList = jsonData['Data']['list'];

      List<Meeting> meetings = meetingList
          .map((json) => Meeting.fromJson(json))
          .toList();

      final currentTime = DateTime.now();
      // Filter to current day (comment out if you want all dates)
      final today = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
      );
      meetings = meetings.where((m) {
        final mDate = DateTime(
          m.eventFromDate.year,
          m.eventFromDate.month,
          m.eventFromDate.day,
        );
        return mDate == today;
      }).toList();

      final watchStatus = _calculateWatchStatus(meetings, currentTime);
      final currentMeeting = _findCurrentOrUpcomingMeeting(
        meetings,
        currentTime,
      );

      emit(
        state.copyWith(
          status: MeetingStatus.success,
          meetings: meetings,
          currentTime: currentTime,
          watchStatus: watchStatus,
          currentMeeting: currentMeeting,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.failure,
          errorMessage: 'Failed to load meetings: $e',
        ),
      );
    }
  }

  void _onUpdateCurrentTime(
    UpdateCurrentTime event,
    Emitter<MeetingState> emit,
  ) {
    final watchStatus = _calculateWatchStatus(
      state.meetings,
      event.currentTime,
    );
    final currentMeeting = _findCurrentOrUpcomingMeeting(
      state.meetings,
      event.currentTime,
    );

    emit(
      state.copyWith(
        currentTime: event.currentTime,
        watchStatus: watchStatus,
        currentMeeting: currentMeeting,
      ),
    );
  }

  WatchStatus _calculateWatchStatus(
    List<Meeting> meetings,
    DateTime currentTime,
  ) {
    for (var meeting in meetings) {
      if (currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate)) {
        return WatchStatus.red;
      }

      final minutesUntilStart = meeting.eventFromDate
          .difference(currentTime)
          .inMinutes;
      if (minutesUntilStart >= 0 && minutesUntilStart <= 5) {
        return WatchStatus.yellow;
      }
    }

    return WatchStatus.green;
  }

  Meeting? _findCurrentOrUpcomingMeeting(
    List<Meeting> meetings,
    DateTime currentTime,
  ) {
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

//
// class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
//   Timer? _timer;
//   final MeetingApiService _apiService = MeetingApiService();
//
//   MeetingBloc() : super(MeetingState(currentTime: DateTime.now())) {
//     on<LoadMeetings>(_onLoadMeetings);
//     on<UpdateCurrentTime>(_onUpdateCurrentTime);
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       add(UpdateCurrentTime(DateTime.now()));
//     });
//   }
//
//   Future<void> _onLoadMeetings(
//     LoadMeetings event,
//     Emitter<MeetingState> emit,
//   ) async {
//     emit(state.copyWith(status: MeetingStatus.loading));
//
//     try {
//       final now = DateTime.now();
//
//       final meetingList = await _apiService.fetchMeetings(
//         fromDate: now,
//         toDate: now,
//         doorId: 'd_668',
//       );
//
//       print(meetingList);
//       List<Meeting> meetings = meetingList
//           .map((json) => Meeting.fromJson(json))
//           .toList();
//
//       final watchStatus = _calculateWatchStatus(meetings, now);
//       final currentMeeting = _findCurrentOrUpcomingMeeting(meetings, now);
//
//       emit(
//         state.copyWith(
//           status: MeetingStatus.success,
//           meetings: meetings,
//           currentTime: now,
//           watchStatus: watchStatus,
//           currentMeeting: currentMeeting,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: MeetingStatus.failure,
//           errorMessage: 'Failed to load meetings: $e',
//         ),
//       );
//     }
//   }
//
//   void _onUpdateCurrentTime(
//     UpdateCurrentTime event,
//     Emitter<MeetingState> emit,
//   ) {
//     final watchStatus = _calculateWatchStatus(
//       state.meetings,
//       event.currentTime,
//     );
//     final currentMeeting = _findCurrentOrUpcomingMeeting(
//       state.meetings,
//       event.currentTime,
//     );
//
//     emit(
//       state.copyWith(
//         currentTime: event.currentTime,
//         watchStatus: watchStatus,
//         currentMeeting: currentMeeting,
//       ),
//     );
//   }
//
//   WatchStatus _calculateWatchStatus(
//     List<Meeting> meetings,
//     DateTime currentTime,
//   ) {
//     for (var meeting in meetings) {
//       if (currentTime.isAfter(meeting.eventFromDate) &&
//           currentTime.isBefore(meeting.eventToDate)) {
//         return WatchStatus.red;
//       }
//
//       final minutesUntilStart = meeting.eventFromDate
//           .difference(currentTime)
//           .inMinutes;
//       if (minutesUntilStart >= 0 && minutesUntilStart <= 5) {
//         return WatchStatus.yellow;
//       }
//     }
//
//     return WatchStatus.green;
//   }
//
//   Meeting? _findCurrentOrUpcomingMeeting(
//     List<Meeting> meetings,
//     DateTime currentTime,
//   ) {
//     for (var meeting in meetings) {
//       if (currentTime.isAfter(meeting.eventFromDate) &&
//           currentTime.isBefore(meeting.eventToDate)) {
//         return meeting;
//       }
//     }
//
//     for (var meeting in meetings) {
//       if (meeting.eventFromDate.isAfter(currentTime)) {
//         return meeting;
//       }
//     }
//
//     return meetings.isNotEmpty ? meetings.first : null;
//   }
//
//   @override
//   Future<void> close() {
//     _timer?.cancel();
//     return super.close();
//   }
//
//   void _onUpdateCurrentTime1(
//     UpdateCurrentTime event,
//     Emitter<MeetingState> emit,
//   ) {
//     emit(
//       state.copyWith(
//         currentTime: event.currentTime,
//         watchStatus: _calculateWatchStatus(state.meetings, event.currentTime),
//         currentMeeting: _findCurrentOrUpcomingMeeting(
//           state.meetings,
//           event.currentTime,
//         ),
//       ),
//     );
//   }
//
//   WatchStatus _calculateWatchStatus1(
//     List<Meeting> meetings,
//     DateTime currentTime,
//   ) {
//     for (final meeting in meetings) {
//       if (currentTime.isAfter(meeting.eventFromDate) &&
//           currentTime.isBefore(meeting.eventToDate)) {
//         return WatchStatus.red;
//       }
//
//       final minutesUntilStart = meeting.eventFromDate
//           .difference(currentTime)
//           .inMinutes;
//
//       if (minutesUntilStart >= 0 && minutesUntilStart <= 5) {
//         return WatchStatus.yellow;
//       }
//     }
//     return WatchStatus.green;
//   }
//
//   Meeting? _findCurrentOrUpcomingMeeting1(
//     List<Meeting> meetings,
//     DateTime currentTime,
//   ) {
//     for (final meeting in meetings) {
//       if (currentTime.isAfter(meeting.eventFromDate) &&
//           currentTime.isBefore(meeting.eventToDate)) {
//         return meeting;
//       }
//     }
//
//     for (final meeting in meetings) {
//       if (meeting.eventFromDate.isAfter(currentTime)) {
//         return meeting;
//       }
//     }
//
//     return meetings.isNotEmpty ? meetings.first : null;
//   }
// }
