import 'package:equatable/equatable.dart';

import 'door.dart';
import 'follower.dart';
import 'participant.dart';

class MeetingModel extends Equatable {
  final int dlEventID;
  final String eventSubject;
  final String meetingType;
  final String? eventDesc;

  final int eventType;
  final bool eventAllDays;
  final int eventStatusID;
  final int eventMainStatusID;

  final DateTime eventFromDate;
  final DateTime eventToDate;
  final DateTime eventEntDt;
  final DateTime? eventUpdDt;

  final int meetingTypeID;
  final String meetingTypeName;

  final bool eventIsBroadcast;
  final int onResourceBeforeMinutes;

  final int locationID;
  final int eventLocationID;
  final String eventLocation;
  final String locationName;

  final int createdByUserID;
  final String createdByUserName;
  final int createdForUserID;
  final String createdForUserName;
  final int createdForEmpId;
  final String empCode;

  final String statusDesc;
  final bool isExternalInvitee;

  final List<Participant> participants;
  final List<Follower> followers;
  final List<Door> doors;

  const MeetingModel({
    required this.dlEventID,
    required this.eventSubject,
    required this.meetingType,
    this.eventDesc,
    required this.eventType,
    required this.eventAllDays,
    required this.eventStatusID,
    required this.eventMainStatusID,
    required this.eventFromDate,
    required this.eventToDate,
    required this.eventEntDt,
    this.eventUpdDt,
    required this.meetingTypeID,
    required this.meetingTypeName,
    required this.eventIsBroadcast,
    required this.onResourceBeforeMinutes,
    required this.locationID,
    required this.eventLocationID,
    required this.eventLocation,
    required this.locationName,
    required this.createdByUserID,
    required this.createdByUserName,
    required this.createdForUserID,
    required this.createdForUserName,
    required this.createdForEmpId,
    required this.empCode,
    required this.statusDesc,
    required this.isExternalInvitee,
    required this.participants,
    required this.followers,
    required this.doors,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      dlEventID: json['DLEventID'] ?? 0,
      eventSubject: json['EventSubject'] ?? '',
      meetingType: json['MeetingType'] ?? '',
      eventDesc: json['EventDesc'],
      eventType: json['EventType'] ?? 0,
      eventAllDays: json['EventAllDays'] ?? false,
      eventStatusID: json['EventStatusID'] ?? 0,
      eventMainStatusID: json['EventMainStatusID'] ?? 0,
      eventFromDate: DateTime.parse(json['EventFromDate']),
      eventToDate: DateTime.parse(json['EventToDate']),
      eventEntDt: DateTime.parse(json['EventEntDt']),
      eventUpdDt: json['EventUpdDt'] != null
          ? DateTime.parse(json['EventUpdDt'])
          : null,
      meetingTypeID: json['MeetingTypeID'] ?? 0,
      meetingTypeName: json['MeetingTypeName'] ?? '',
      eventIsBroadcast: json['EventIsBroadcast'] ?? false,
      onResourceBeforeMinutes: json['OnResourceBeforeMinutes'] ?? 0,
      locationID: json['LocationID'] ?? 0,
      eventLocationID: json['EventLocationID'] ?? 0,
      eventLocation: json['EventLocation'] ?? '',
      locationName: json['LocationName'] ?? '',
      createdByUserID: json['CreatedByUserID'] ?? 0,
      createdByUserName: json['CreatedByUserName'] ?? '',
      createdForUserID: json['CreatedForUserID'] ?? 0,
      createdForUserName: json['CreatedForUserName'] ?? '',
      empCode: json['EmpCode'] ?? '',
      createdForEmpId: json['CreatedforEmpid'] ?? 0,
      statusDesc: json['StatusDesc'] ?? '',
      isExternalInvitee: json['IsExternalInvitee'] ?? false,
      participants:
          (json['DLEventParticipents'] as List<dynamic>?)
              ?.map((e) => Participant.fromJson(e))
              .toList() ??
          [],
      followers:
          (json['DLEventFollowersDet'] as List<dynamic>?)
              ?.map((e) => Follower.fromJson(e))
              .toList() ??
          [],
      doors:
          (json['DLEventMatrixDoorDet'] as List<dynamic>?)
              ?.map((e) => Door.fromJson(e))
              .toList() ??
          [],
    );
  }

  Duration get duration => eventToDate.difference(eventFromDate);

  @override
  List<Object?> get props => [
    dlEventID,
    eventSubject,
    meetingType,
    eventDesc,
    eventType,
    eventAllDays,
    eventStatusID,
    eventMainStatusID,
    eventFromDate,
    eventToDate,
    eventEntDt,
    eventUpdDt,
    meetingTypeID,
    meetingTypeName,
    eventIsBroadcast,
    onResourceBeforeMinutes,
    locationID,
    eventLocationID,
    eventLocation,
    locationName,
    createdByUserID,
    createdByUserName,
    createdForUserID,
    createdForUserName,
    createdForEmpId,
    empCode,
    statusDesc,
    isExternalInvitee,
    participants,
    followers,
    doors,
  ];
}
