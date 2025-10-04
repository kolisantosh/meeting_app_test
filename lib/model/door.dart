import 'package:equatable/equatable.dart';

class Door extends Equatable {
  final int evtdirectDID;
  final String doorID;
  final String doorName;

  const Door({
    required this.evtdirectDID,
    required this.doorID,
    required this.doorName,
  });

  factory Door.fromJson(Map<String, dynamic> json) {
    return Door(
      evtdirectDID: json['EvtdirectDID'] ?? 0,
      doorID: json['DoorID'] ?? '',
      doorName: json['DoorName'] ?? '',
    );
  }

  @override
  List<Object?> get props => [evtdirectDID, doorID, doorName];
}
