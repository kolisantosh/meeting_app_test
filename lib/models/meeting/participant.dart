import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  final int participantLogID; // Corrected spelling
  final int personID;
  final String? isAttending;
  final String? personPhotoName;
  final int showAs;
  final bool isCoHost;
  final int dlEventID;
  final bool isEmployee;
  final String personName;
  final String personDepartment;
  final String personDesignation;
  final String personCompany;
  final bool meetingRoomAddMe;
  final bool isPersonActive;
  final String empCode;
  final DateTime? actualCheckInTime;
  final DateTime? actualCheckOutTime;
  final List<ParticipantPunchDetail> participantPunchDetail;

  const Participant({
    required this.participantLogID,
    required this.personID,
    this.isAttending,
    this.personPhotoName,
    required this.showAs,
    required this.isCoHost,
    required this.dlEventID,
    required this.isEmployee,
    required this.personName,
    required this.personDepartment,
    required this.personDesignation,
    required this.personCompany,
    required this.meetingRoomAddMe,
    required this.isPersonActive,
    required this.empCode,
    this.actualCheckInTime,
    this.actualCheckOutTime,
    required this.participantPunchDetail,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantLogID: json['ParticipentLogID'] ?? 0,
      personID: json['PersonID'] ?? 0,
      isAttending: json['IsAttending'],
      personPhotoName: json['PersonPhotoName'],
      showAs: json['ShowAs'] ?? 0,
      isCoHost: json['IsCoHost'] ?? false,
      dlEventID: json['DLEventID'] ?? 0,
      isEmployee: json['IsEmployee'] ?? false,
      personName: json['PersonName'] ?? '',
      personDepartment: json['PersonDepartment'] ?? '',
      personDesignation: json['PersonDesignation'] ?? '',
      personCompany: json['PersonCompany'] ?? '',
      meetingRoomAddMe: json['MeetingRoomAddMe'] ?? false,
      isPersonActive: json['IsPersonActive'] ?? false,
      empCode: json['EmpCode'] ?? '',
      actualCheckInTime: json['ActualCheckInTime'] != null
          ? DateTime.tryParse(json['ActualCheckInTime'])
          : null,
      actualCheckOutTime: json['ActualCheckOutTime'] != null
          ? DateTime.tryParse(json['ActualCheckOutTime'])
          : null,
      participantPunchDetail: json['ParticipentPunchDetail'] != null
          ? (json['ParticipentPunchDetail'] as List)
                .map((i) => ParticipantPunchDetail.fromJson(i))
                .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [
    participantLogID,
    personID,
    isAttending,
    personPhotoName,
    showAs,
    isCoHost,
    dlEventID,
    isEmployee,
    personName,
    personDepartment,
    personDesignation,
    personCompany,
    meetingRoomAddMe,
    isPersonActive,
    empCode,
    actualCheckInTime,
    actualCheckOutTime,
    participantPunchDetail,
  ];
}

class ParticipantPunchDetail extends Equatable {
  final String personName;
  final String doorName;
  final int personID;
  final String cardNo;
  final DateTime? datetimes;

  const ParticipantPunchDetail({
    required this.personName,
    required this.doorName,
    required this.personID,
    required this.cardNo,
    this.datetimes,
  });

  factory ParticipantPunchDetail.fromJson(Map<String, dynamic> json) {
    return ParticipantPunchDetail(
      personName: json['PersonName'] ?? '',
      doorName: json['DoorName'] ?? '',
      personID: json['PersonID'] ?? 0,
      cardNo: json['CardNo'] ?? '',
      datetimes: json['Datetimes'] != null
          ? DateTime.tryParse(json['Datetimes'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    personName,
    doorName,
    personID,
    cardNo,
    datetimes,
  ];
}
