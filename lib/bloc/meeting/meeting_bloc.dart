import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../models/login/login_model.dart';
import '../../models/meeting/meeting_model.dart';
import '../../services/meeting _api_service.dart';
import '../../views.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  Timer? _timer;
  final MeetingApiService _apiService = MeetingApiService();
  final GetStorageData getStorageData = GetStorageData();

  MeetingBloc() : super(MeetingState(currentTime: DateTime.now())) {
    on<LoadMeetings>(_onLoadMeetings);
    on<UnLockDoor>(_onUnLockDoor);
    on<UpdateCurrentTime>(_onUpdateCurrentTime);
    on<ExtendMeetingRequest>(_onExtendMeetingRequest);
    on<CompleteMeetingNow>(_onCompleteMeetingNow);
    on<SendCleaningRequest>(_onSendCleaningRequest);
    on<SendWaterRequest>(_onSendWaterRequest);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(UpdateCurrentTime(DateTime.now()));
    });
  }

  Future<void> _onLoadMeetings(
    LoadMeetings event,
    Emitter<MeetingState> emit,
  ) async {
    emit(state.copyWith(status: MeetingStatus.loading));

    try {
      final now = DateTime.now();

      final meetingList = await _apiService.fetchMeetings(
        fromDate: now,
        toDate: now,
      );
      // final meetingList = await _apiService.fetchMockMeetings();

      List<MeetingModel> meetings = meetingList
          .map((json) => MeetingModel.fromJson(json))
          .toList();

      final watchStatus = _calculateWatchStatus(meetings, now);
      final currentMeeting = _findCurrentOrUpcomingMeeting(meetings, now);

      emit(
        state.copyWith(
          status: MeetingStatus.success,
          meetings: meetings,
          currentTime: now,
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

  Future<void> _onUnLockDoor(
    UnLockDoor event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      final unLockDoorSuccess = await _apiService.unLockDoor(event.empCode);
      // if (unLockDoorSuccess == true) {
      if (kDebugMode) {
        print(unLockDoorSuccess);
      }
      // }
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
    List<MeetingModel> meetings,
    DateTime currentTime,
  ) {
    for (var meeting in meetings) {
      if (meeting.statusDesc == "Completed" ||
          meeting.statusDesc == "Cancelled" ||
          // meeting.doors.length > 0 ||
          currentTime.isAfter(meeting.eventToDate)) {
        continue;
      }
      if (currentTime.isAfter(meeting.eventFromDate) &&
          currentTime.isBefore(meeting.eventToDate)) {
        return WatchStatus.red;
      }

      final minutesUntilStart = meeting.eventFromDate
          .difference(currentTime)
          .inMinutes;
      if (minutesUntilStart >= 0 && minutesUntilStart < 5) {
        return WatchStatus.yellow;
      }
    }

    return WatchStatus.green;
  }

  MeetingModel? _findCurrentOrUpcomingMeeting(
    List<MeetingModel> meetings,
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

  Future<void> _onExtendMeeting(
    ExtendMeetingRequest event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      // 1. Call API to extend the current meeting
      final success = await _apiService.extendOrCompleteMeeting(
        // minutes: event.minutes,
        eventId: state.currentMeeting?.dlEventID ?? 0,
        statusId: 324,
      );

      if (success) {
        // 2. Refresh the meeting list to show the new 'End Time'
        add(LoadMeetings());
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.failure,
          errorMessage: 'Failed to extend meeting: $e',
        ),
      );
    }
  }

  Future<void> _onExtendMeetingRequest(
    ExtendMeetingRequest event,
    Emitter<MeetingState> emit,
  ) async {
    final currentMeeting = state.currentMeeting;
    if (currentMeeting == null) return;

    print(event.extensionMinutes);

    // 1. Calculate the proposed new end time
    // Swift logic: DateToDate + extensionMinutes
    DateTime currentEndTime = currentMeeting.eventToDate;
    DateTime proposedEndTime = currentEndTime.add(
      Duration(minutes: event.extensionMinutes),
    );

    // 2. Check for conflicts with the NEXT meeting
    bool isConflicting = false;
    MeetingModel? nextMeeting;

    if (state.meetings.length > 1) {
      // k == 1 logic from your Swift code (checking the second item in the list)
      nextMeeting = state.meetings[1];
      DateTime nextMeetingStart = nextMeeting.eventFromDate;

      // If our proposed end time pushes into the next meeting's start time
      if (proposedEndTime.isAfter(nextMeetingStart)) {
        isConflicting = true;
      }
    }

    if (isConflicting) {
      // Trigger an alert state (handled in the UI via BlocListener)
      emit(
        state.copyWith(
          errorMessage:
              "Conflicting with ${nextMeeting?.eventSubject} owned by ${nextMeeting?.createdByUserName}",
          status: MeetingStatus.failure,
        ),
      );
    } else {
      // 3. Prepare for Pin Entry (Show Host Selection View)
      // Update state to show the host selection overlay and set the extension context
      // add(LoadMeetings());
      emit(
        state.copyWith(
          selectionType: "extendMeeting",
          showHostSelection: true,
          pendingExtensionMinutes: event.extensionMinutes,
          intExtendStatus: event.statusId,
        ),
      );
    }
  }

  Future<void> _onCompleteMeetingNow(
    CompleteMeetingNow event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      // 1. Call API to end the meeting early
      final success = await _apiService.extendOrCompleteMeeting(
        eventId: state.currentMeeting?.dlEventID ?? 0,
        statusId: 325,
      );

      if (success) {
        // 2. Refresh list (it will now show the room as green/free)
        add(LoadMeetings());
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.failure,
          errorMessage: 'Failed to complete meeting: $e',
        ),
      );
    }
  }

  Future<void> _onSendCleaningRequest(
    SendCleaningRequest event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      var data = await getStorageData.readObject(getStorageData.loginData);

      if (data == null) throw Exception('User data not found');
      LoginModel userData = LoginModel.fromJson(jsonDecode(data));
      // 1. Call API to end the meeting early
      /*  final success = await _apiService.addCleaningRequest(
        eventId: state.currentMeeting?.dlEventID ?? 0,
          doorId:userData.meetingRoomId!,
        empCode:state.currentMeeting?.,
        userId:0,
      );

      if (success) {
        // 2. Refresh list (it will now show the room as green/free)
        add(LoadMeetings());
      }*/
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.failure,
          errorMessage: 'Failed to complete meeting: $e',
        ),
      );
    }
  }

  Future<void> _onSendWaterRequest(
    SendWaterRequest event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      var data = await getStorageData.readObject(getStorageData.loginData);

      if (data == null) throw Exception('User data not found');
      LoginModel userData = LoginModel.fromJson(jsonDecode(data));
      // 1. Call API to end the meeting early
      /*      final success = await _apiService.addWaterRequest(
        eventId: state.currentMeeting?.dlEventID ?? 0,
        doorId:userData.meetingRoomId!,
        empCode:state.currentMeeting?.,
        userId:0,
        qty:event.quantity,
      );

      if (success) {
        // 2. Refresh list (it will now show the room as green/free)
        add(LoadMeetings());
      }*/
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.failure,
          errorMessage: 'Failed to complete meeting: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
