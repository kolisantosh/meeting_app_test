import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/login/login_model.dart';
import 'get_storage_data.dart';

class MeetingApiService extends GetStorageData {
  static const String _baseUrl =
      'https://myapp.airis.co.in/AIRISApi/API/MeetingRoom/GetEventFomMeetingRoom';
  static const String SERVICEPATH = 'https://myapp.airis.co.in/AIRISApi/API/';
  static const String _casaBaseUrl =
      'https://nodejssrv02.airis.co.in/CasaSocket/api/v1/CosecDeviceCommand/unlockDoor';

  Future<List<dynamic>> fetchMeetings({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      String tokenStr = await readString(token);
      String meetingRoomID = "";

      var data = await readObject(loginData);
      if (data != null) {
        LoginModel userData = LoginModel.fromJson(jsonDecode(data));

        meetingRoomID = userData.meetingRoomId ?? "d_622";
      }

      final uri = Uri.parse(
        '$_baseUrl'
        '?FromDate=${_formatDate(fromDate)}'
        '&ToDate=${_formatDate(toDate)}'
        '&DoorID=$meetingRoomID',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': "Basic $tokenStr"},
      );

      if (response.statusCode != 200) {
        throw Exception('API failed: ${response.statusCode}');
      }
      if (kDebugMode) {
        print("object=>${response.body}");
      }
      final jsonData = json.decode(response.body);

      return jsonData['Data']['list'] as List<dynamic>;
    } catch (e) {
      throw Exception('API failed: ${e.toString()}');
    }
  }

  Future<bool> unLockDoor(empCode) async {
    try {
      // 1. Get dynamic data from Storage
      String? tokenStr = await readString(token);
      var data = await readObject(loginData);

      if (data == null) throw Exception('User data not found');
      LoginModel userData = LoginModel.fromJson(jsonDecode(data));

      // 2. Prepare payload (Using stored MID and EmpCode if available, else defaults)
      final body = jsonEncode({
        // "MID": 669,
        "MID": userData.meetingRoomId!.replaceAll("d_", ""),
        "EmpCode": empCode,
      });

      final uri = Uri.parse(_casaBaseUrl);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Use the dynamic token from storage
          'Authorization': "Bearer $tokenStr",
        },
        body: body,
      );

      if (kDebugMode) {
        print("Unlock Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Assuming 'Status' or 'Success' is part of your API response
        return jsonData['status'] == true || jsonData['status'] == "Success";
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Unlock Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchMockMeetings() async {
    final String jsonString = await rootBundle.loadString(
      'assets/file/meetings.json',
    );

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> meetingList = jsonData['Data']['list'];

    return meetingList;
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Maps to func ExtendMeeting() and func CompleteMeeting() in Swift
  /// IntExtendStatus 325 = Complete, others = Extend
  Future<bool> extendOrCompleteMeeting({
    required int eventId,
    required int statusId,
  }) async {
    // URL Construction: MeetingRoom/ExtendEventFromTime?DLEventID=...&StatusID=...
    final String url =
        "${SERVICEPATH}MeetingRoom/ExtendEventFromTime?DLEventID=$eventId&StatusID=$statusId";
    String tokenStr = await readString(token);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $tokenStr',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Swift logic: if responseCode != "0" it is considered success
        return data['responseCode'] != "0";
      }
      return false;
    } catch (e) {
      debugPrint("Extend/Complete Error: $e");
      return false;
    }
  }

  /// Maps to func CallAddMe() in Swift
  Future<bool> addMeInMeeting({
    required int eventId,
    required int personId,
  }) async {
    final String url = "${SERVICEPATH}MeetingRoom/AddMeInMeeting";
    String tokenStr = await readString(token);
    final body = jsonEncode({
      "DLEventID": eventId,
      "PersonList": [
        {"PersonID": personId},
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $tokenStr',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final data = jsonDecode(response.body);
      return data['responseCode'] != "0";
    } catch (e) {
      return false;
    }
  }

  /// Maps to func AddCleaningRequest() in Swift
  Future<bool> addCleaningRequest({
    required int eventId,
    required String doorId,
    required String empCode,
    required int userId,
  }) async {
    final String url =
        "${SERVICEPATH}MeetingRoom/SendRequestForCleaningv2?"
        "DLEventID=$eventId&DoorID=$doorId&EmpCode=$empCode&UserID=$userId";
    String tokenStr = await readString(token);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Basic $tokenStr'},
      );
      final data = jsonDecode(response.body);
      return data['responseCode'] != "0";
    } catch (e) {
      return false;
    }
  }

  /// Maps to func AddWaterRequest() in Swift
  Future<bool> addWaterRequest({
    required int eventId,
    required String doorId,
    required String empCode,
    required int userId,
    required int qty,
  }) async {
    final String url =
        "${SERVICEPATH}MeetingRoom/SendWaterRequestv2?"
        "DLEventID=$eventId&DoorID=$doorId&EmpCode=$empCode&RequestByUserID=$userId&Qty=$qty";
    String tokenStr = await readString(token);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Basic $tokenStr'},
      );
      final data = jsonDecode(response.body);
      return data['responseCode'] != "0";
    } catch (e) {
      return false;
    }
  }
}
