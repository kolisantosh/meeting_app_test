import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/constants/topic.dart';
import 'meeting_provider.dart';

// class SocketNotifier extends StateNotifier<IO.Socket?> {
//   final Ref ref;
//
//   SocketNotifier(this.ref) : super(null);
//
//   void connect(String token) {
//     // Clean previous socket
//     state?.disconnect();
//     state?.dispose();
//     state = null;
//
//     final socket = IO.io('ws://nodejssrv01.airis.co.in/DLEvent', {
//       'transports': ['websocket'],
//       'path': '/DLEvent/socket.io',
//       'autoConnect': false,
//       'reconnection': true,
//       'reconnectionAttempts': double.infinity,
//       'reconnectionDelay': 1000,
//       'reconnectionDelayMax': 5000,
//       'timeout': 20000,
//       'query': {'token': token}, // better than query
//     });
//
//     socket.onConnect((_) {
//       debugPrint(' Socket Connected: ${socket.id}');
//     });
//
//     socket.onDisconnect((_) {
//       debugPrint(' Socket Disconnected');
//     });
//
//     socket.onConnectError((error) {
//       debugPrint(' Connection Error: $error');
//     });
//
//     socket.onError((error) {
//       debugPrint(' Socket Error: $error');
//     });
//
//     socket.on('GetEventFromMeetingRoom', (data) {
//       debugPrint('Socket GetEventFromMeetingRoom Data: $data');
//       // if (data['Data']?['DoorID'] == "d_668") {
//       ref.read(meetingProvider.notifier).loadMeetings(data);
//       // }
//     });
//
//     socket.on('GetEventDetails', (data) {
//       debugPrint('Socket GetEventDetails Data: $data');
//       // if (data['Data']?['DoorID'] == "d_668") {
//       ref.read(meetingProvider.notifier).loadMeetings(data);
//       // }
//     });
//     socket.on('pong', (data) {
//       print("pong====>$data");
//     });
//
//     socket.connect();
//
//     state = socket;
//   }
//
//   void emitCommand(String event, dynamic data) {
//     if (state?.connected == true) {
//       try {
//         print("event =${event}");
//         // state!.send(data);
//         state?.emit(event, data);
//         print("emit submitted");
//         print(event);
//         print(data);
//       } catch (e) {
//         print(e.toString());
//       }
//     } else {
//       debugPrint("Socket not connected");
//     }
//   }
//
//   @override
//   void dispose() {
//     state?.disconnect();
//     state?.dispose();
//     super.dispose();
//   }
// }
//
// final socketProvider = StateNotifierProvider<SocketNotifier, IO.Socket?>(
//   (ref) => SocketNotifier(ref),
// );

final socketManagerProvider =
    StateNotifierProvider<SocketManager, Map<String, IO.Socket>>(
      (ref) => SocketManager(ref),
    );

class SocketManager extends StateNotifier<Map<String, IO.Socket>> {
  final Ref ref;
  SocketManager(this.ref) : super({});

  /// SINGLE METHOD TO INITIALIZE ALL SOCKETS
  void initializeSockets(String token) {
    _createEventSocket(token);
    _createAutomationSocket(token);
  }

  void _createEventSocket(String token) {
    final socket = IO.io(TopicAPI.eventSocket, {
      'transports': ['websocket'],
      'path': '/DLEvent/socket.io',
      'query': {'token': token},
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': double.infinity,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
    });

    socket.onConnect((_) {
      debugPrint("Event Socket Connected");
    });

    socket.onDisconnect((_) {
      debugPrint("Event Socket Disconnected");
    });

    socket.on('GetEventFromMeetingRoom', (data) {
      debugPrint("Event Data: $data");
      ref.read(meetingProvider.notifier).loadMeetings(data);
    });

    socket.on('GetEventDetailsByIdV2', (data) {
      debugPrint("Event Data: $data");
      ref.read(meetingProvider.notifier).loadMeetings(data);
    });

    socket.connect();

    state = {...state, "event": socket};
  }

  void _createAutomationSocket(String token) {
    final socket = IO.io(TopicAPI.automationSocket, {
      'transports': ['websocket'],
      'path': '/CasaSocket/socket.io',
      'query': {'token': token},
      'autoConnect': false,
      'reconnection': true,
    });

    socket.onConnect((_) {
      debugPrint("Automation Socket Connected");
    });

    socket.onDisconnect((_) {
      debugPrint("Automation Socket Disconnected");
    });

    socket.on('LightStatusUpdate', (data) {
      debugPrint("Automation Data: $data");
    });

    socket.connect();

    state = {...state, "automation": socket};
  }

  /// COMMON EMIT METHOD
  void emit(String socketKey, String event, dynamic data) {
    final socket = state[socketKey];

    if (socket?.connected == true) {
      socket?.emit(event, data);
    } else {
      debugPrint("Socket $socketKey not connected");
    }
  }

  /// Dispose All
  @override
  void dispose() {
    for (var socket in state.values) {
      socket.disconnect();
      socket.dispose();
    }
    super.dispose();
  }
}
