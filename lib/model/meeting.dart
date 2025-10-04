import 'package:equatable/equatable.dart';
import 'participant.dart';
import 'follower.dart';
import 'door.dart';

class Meeting extends Equatable {
  final int dlEventID;
  final String eventSubject;
  final String meetingType;
  final String? eventDesc;
  final DateTime eventFromDate;
  final DateTime eventToDate;
  final String meetingTypeName;
  final String createdByUserName;
  final String createdForUserName;
  final String statusDesc;
  final String eventLocation;
  final String locationName;
  final List<Participant> participants;
  final List<Follower> followers;
  final List<Door> doors;

  const Meeting({
    required this.dlEventID,
    required this.eventSubject,
    required this.meetingType,
    this.eventDesc,
    required this.eventFromDate,
    required this.eventToDate,
    required this.meetingTypeName,
    required this.createdByUserName,
    required this.createdForUserName,
    required this.statusDesc,
    required this.eventLocation,
    required this.locationName,
    required this.participants,
    required this.followers,
    required this.doors,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      dlEventID: json['DLEventID'] ?? 0,
      eventSubject: json['EventSubject'] ?? '',
      meetingType: json['MeetingType'] ?? '',
      eventDesc: json['EventDesc'],
      eventFromDate: DateTime.parse(json['EventFromDate']),
      eventToDate: DateTime.parse(json['EventToDate']),
      meetingTypeName: json['MeetingTypeName'] ?? '',
      createdByUserName: json['CreatedByUserName'] ?? '',
      createdForUserName: json['CreatedForUserName'] ?? '',
      statusDesc: json['StatusDesc'] ?? '',
      eventLocation: json['EventLocation'] ?? '',
      locationName: json['LocationName'] ?? '',
      participants: (json['DLEventParticipents'] as List<dynamic>?)
          ?.map((p) => Participant.fromJson(p))
          .toList() ??
          [],
      followers: (json['DLEventFollowersDet'] as List<dynamic>?)
          ?.map((f) => Follower.fromJson(f))
          .toList() ??
          [],
      doors: (json['DLEventMatrixDoorDet'] as List<dynamic>?)
          ?.map((d) => Door.fromJson(d))
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
    eventFromDate,
    eventToDate,
    meetingTypeName,
    createdByUserName,
    createdForUserName,
    statusDesc,
    eventLocation,
    locationName,
    participants,
    followers,
    doors,
  ];
}
