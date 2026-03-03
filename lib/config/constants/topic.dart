String http = 'http://';

class TopicAPI {
  static String serverUrl = "";

  // static String baseUrl = "https://app.airis.co.in";
  static String baseUrl = "https://myapp.airis.co.in";
  static String baseUrlAuth = '${baseUrl}/AIRISApi/API/';
  static String eventSocket = "ws://nodejssrv01.airis.co.in/DLEvent";
  static String automationSocket = "ws://casa.aether.co.in/CasaSocket";

  static String login = '${baseUrlAuth}Login/LoginAuthenticationMeetingRoom';
  static String meetingList =
      '${baseUrlAuth}MeetingRoom/GetEventFomMeetingRoom';
  static String logout = '${baseUrlAuth}logout';
}
