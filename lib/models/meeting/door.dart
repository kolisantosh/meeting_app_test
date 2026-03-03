import 'package:equatable/equatable.dart';

class Door extends Equatable {
  final int evtdirectDID;
  final int? dlEventID;
  final String doorID;
  final String doorName;
  final DateTime? entdt;
  final int? doorGroupID;
  final String? doorType;
  final String? entUser;
  final String? entTerm;
  final bool doorLink;
  final bool? isSharedWorkSpace;

  const Door({
    required this.evtdirectDID,
    this.dlEventID,
    required this.doorID,
    required this.doorName,
    this.entdt,
    this.doorGroupID,
    this.doorType,
    this.entUser,
    this.entTerm,
    required this.doorLink,
    this.isSharedWorkSpace,
  });

  factory Door.fromJson(Map<String, dynamic> json) {
    return Door(
      evtdirectDID: json['EvtdirectDID'] ?? 0,
      dlEventID: json['DLEventID'],
      doorID: json['DoorID'] ?? '',
      doorName: json['DoorName'] ?? '',
      entdt: json['Entdt'] != null ? DateTime.tryParse(json['Entdt']) : null,
      doorGroupID: json['DoorGroupID'],
      doorType: json['DoorType'],
      entUser: json['EntUser'],
      entTerm: json['EntTerm'],
      doorLink: json['DoorLink'] ?? false,
      isSharedWorkSpace: json['IsSharedWorkSpace'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EvtdirectDID': evtdirectDID,
      'DLEventID': dlEventID,
      'DoorID': doorID,
      'DoorName': doorName,
      'Entdt': entdt?.toIso8601String(),
      'DoorGroupID': doorGroupID,
      'DoorType': doorType,
      'EntUser': entUser,
      'EntTerm': entTerm,
      'DoorLink': doorLink,
      'IsSharedWorkSpace': isSharedWorkSpace,
    };
  }

  @override
  List<Object?> get props => [
    evtdirectDID,
    dlEventID,
    doorID,
    doorName,
    entdt,
    doorGroupID,
    doorType,
    entUser,
    entTerm,
    doorLink,
    isSharedWorkSpace,
  ];
}
