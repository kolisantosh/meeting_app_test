import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// <<< To store data in phone storage --------- >>>
class GetStorageData {
  String loginData = "LoginData";
  String isLogin = "isLogin";
  String token = "token";
  String deviceType = "deviceType";
  String subscribedTopic = "subscribed_topics";
  // String refreshToken = "refreshToken";
  // String fcmToken = "fcmToken";

  /// <<< To read object data --------- >>>
  readObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(key);
    if (data == null) {
      return null;
    }
    var decode = json.decode(data);
    if (decode != null) {
      return decode;
    } else {
      return json.decode("");
    }
  }

  /// <<< To save object data --------- >>>
  saveObject(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
  }

  /// <<< To read String data --------- >>>
  Future<String> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  /// <<< To read String data --------- >>>
  Future<bool> readBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// <<< To save string data --------- >>>
  saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<List<String>> getSubscribedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('subscribedTopic') ?? [];
  }

  void fetchTopics() async {
    List<String> topics = await getSubscribedTopics();
    print("Subscribed Topics: $topics");
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      // await FirebaseMessaging.instance.subscribeToTopic(topic);

      final prefs = await SharedPreferences.getInstance();
      List<String> subscribedTopics =
          prefs.getStringList(subscribedTopic) ?? [];

      // Avoid duplicates before adding
      if (!subscribedTopics.contains(topic)) {
        subscribedTopics.add(topic);
        await prefs.setStringList(subscribedTopic, subscribedTopics);
      }

      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromAllTopics() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> subscribedTopics = prefs.getStringList(subscribedTopic) ?? [];

    for (String topic in subscribedTopics) {
      // FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    }

    // Clear stored topics
    prefs.remove(subscribedTopic);
  }

  /// <<< To save string data --------- >>>
  saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    print("value===>$value");
    await prefs.setBool(key, value);
  }

  /// <<< To read String data --------- >>>
  Future<List> readStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  /// <<< To save string data --------- >>>
  saveList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  /// <<< To read int data --------- >>>
  readInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getInt(key);
  }

  /// <<< To save int data --------- >>>
  saveInt(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// <<< To remove data --------- >>>
  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// <<< To remove data --------- >>>
  clear() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    prefs.remove(loginData);
    prefs.remove(isLogin);
    prefs.remove(token);
    // prefs.remove(subscribedTopic);
  }

  /// <<< To Store Key data --------- >>>
  Future<bool> containKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
