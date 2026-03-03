import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/login/login_model.dart';
import '../models/meeting/meeting_model.dart';
import '../services/get_storage_data.dart';
import '../views.dart' hide GetStorageData;

enum MeetingStatus { initial, loading, success, failure }

enum WatchStatus { green, yellow, red }

class MeetingState {
  final MeetingStatus status;
  final List<MeetingModel> meetings;
  final DateTime currentTime;
  final WatchStatus watchStatus;
  final MeetingModel? currentMeeting;

  MeetingState({
    this.status = MeetingStatus.initial,
    this.meetings = const [],
    required this.currentTime,
    this.watchStatus = WatchStatus.green,
    this.currentMeeting,
  });

  MeetingState copyWith({
    MeetingStatus? status,
    List<MeetingModel>? meetings,
    DateTime? currentTime,
    WatchStatus? watchStatus,
    MeetingModel? currentMeeting,
  }) => MeetingState(
    status: status ?? this.status,
    meetings: meetings ?? this.meetings,
    currentTime: currentTime ?? this.currentTime,
    watchStatus: watchStatus ?? this.watchStatus,
    currentMeeting: currentMeeting ?? this.currentMeeting,
  );
}

final meetingProvider = StateNotifierProvider<MeetingNotifier, MeetingState>(
  (ref) => MeetingNotifier(ref),
);

class MeetingNotifier extends StateNotifier<MeetingState> {
  final Ref _ref;
  Timer? _ticker;

  MeetingNotifier(this._ref)
    : super(MeetingState(currentTime: DateTime.now())) {
    _startClock();
  }

  void _startClock() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime(DateTime.now());
    });
  }

  // logic: Updated to handle real-time socket data injections
  Future<void> loadMeetings([dynamic socketData]) async {
    state = state.copyWith(status: MeetingStatus.loading);
    try {
      dynamic data = socketData;

      var store = await GetStorageData().readObject(GetStorageData().loginData);
      var DoorID;
      if (store != null) {
        print(store);
        LoginModel userData = LoginModel.fromJson(store);
        DoorID = userData.meetingRoomId ?? "Unknown User";
        print(DoorID);
      }
      // If no socket data is passed, fetch from the API (initial load)
      // if (data == null) {
      //   final date = state.currentTime.toString().split(' ')[0];
      //   // Replace with your actual DoorID logic
      //   final query = {'FromDate': date, 'ToDate': date, 'DoorID': DoorID};
      //   data = await LoginRepository().meetingList(query);
      // }
      if (data['Data']?['DoorID'] != DoorID) return;

      // Handle the 'Data' -> 'list' structure from your API/Socket
      final List<dynamic> list = data['Data']?['list'] ?? [];
      print(list);

      final meetings = list.map((e) => MeetingModel.fromJson(e)).toList();

      state = state.copyWith(status: MeetingStatus.success, meetings: meetings);

      _updateTime(DateTime.now());
    } catch (e) {
      debugPrint(" Meeting Load Error: $e");
      state = state.copyWith(status: MeetingStatus.failure);
    }
  }

  void _updateTime(DateTime now) {
    WatchStatus status = WatchStatus.green;
    MeetingModel? current;

    for (var m in state.meetings) {
      // Logic: Is current time within meeting bounds?
      if (now.isAfter(m.eventFromDate) && now.isBefore(m.eventToDate)) {
        status = WatchStatus.red;
        current = m;
        break;
      }
      // Logic: 5-minute warning (Yellow)
      if (m.eventFromDate.difference(now).inMinutes <= 5 &&
          m.eventFromDate.isAfter(now)) {
        status = WatchStatus.yellow;
        current = m;
      }
    }

    state = state.copyWith(
      currentTime: now,
      watchStatus: status,
      currentMeeting: current,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
