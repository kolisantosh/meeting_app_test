import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../services/get_storage_data.dart';

// Simple state class for login
class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LoginState({this.isLoading = false, this.error, this.isSuccess = false});
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginState());

  Future<void> login(String email, String password) async {
    state = LoginState(isLoading: true);
    try {
      final uri =
          Uri.parse(
            'https://myapp.airis.co.in/AIRISApi/API/Login/LoginAuthenticationMeetingRoom',
          ).replace(
            queryParameters: {'pUserEmailID': email, 'pUserPassword': password},
          );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        GetStorageData getStorageData = GetStorageData();
        final Map<String, dynamic> jsonData = json.decode(response.body);

        getStorageData.saveObject(
          getStorageData.loginData,
          jsonEncode(jsonData),
        );
        getStorageData.saveString(
          getStorageData.token,
          jsonData['ApiAccToken'],
        );
        state = LoginState(isSuccess: true);
      } else {
        state = LoginState(error: "Login failed: ${response.statusCode}");
      }
    } catch (e) {
      state = LoginState(error: e.toString());
    }
  }

  Future<void> logout(String email, String password) async {
    state = LoginState(isLoading: true);
    try {
      final uri =
          Uri.parse(
            'https://myapp.airis.co.in/AIRISApi/API/Login/LoginAuthenticationMeetingRoom',
          ).replace(
            queryParameters: {'pUserEmailID': email, 'pUserPassword': password},
          );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        // Handle storage saving here if needed
        if (kDebugMode) {
          print("object=>${response.body}");
        }
        GetStorageData getStorageData = GetStorageData();
        final Map<String, dynamic> jsonData = json.decode(response.body);
        await getStorageData.saveString(getStorageData.isLogin, "true");

        await getStorageData.saveObject(
          getStorageData.loginData,
          response.body,
        );
        await getStorageData.saveString(
          getStorageData.token,
          jsonData['ApiAccToken'],
        );
        state = LoginState(isSuccess: true);
      } else {
        state = LoginState(error: "Login failed: ${response.statusCode}");
      }
    } catch (e) {
      state = LoginState(error: e.toString());
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
