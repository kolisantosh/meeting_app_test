import 'dart:convert';

import 'package:http/http.dart' as http;

class MeetingApiService {
  static const String _baseUrl =
      'https://app.airis.co.in/AIRISApi/API/MeetingRoom/GetEventFomMeetingRoom';

  static const String _authHeader =
      'Basic 2670:KFThEvNX3kj8rg1Vd9AqQ6ZbHGYS5LlW';

  Future<List<dynamic>> fetchMeetings({
    required DateTime fromDate,
    required DateTime toDate,
    required String doorId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl'
      '?FromDate=${_formatDate(fromDate)}'
      '&ToDate=${_formatDate(toDate)}'
      '&DoorID=$doorId',
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': _authHeader,
        // 'Content-Type': 'application/json',
      },
    );
    print(response);

    if (response.statusCode != 200) {
      throw Exception('API failed: ${response.statusCode}');
    }

    final jsonData = json.decode(response.body);
    return jsonData['Data']['list'] as List<dynamic>;
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
