import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  final int participentLogID;
  final int personID;
  final String? isAttending;
  final String? personPhotoName;
  final bool isCoHost;
  final String personName;
  final String personDepartment;
  final String personDesignation;
  final String personCompany;
  final String empCode;

  const Participant({
    required this.participentLogID,
    required this.personID,
    this.isAttending,
    this.personPhotoName,
    required this.isCoHost,
    required this.personName,
    required this.personDepartment,
    required this.personDesignation,
    required this.personCompany,
    required this.empCode,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participentLogID: json['ParticipentLogID'] ?? 0,
      personID: json['PersonID'] ?? 0,
      isAttending: json['IsAttending'],
      personPhotoName: json['PersonPhotoName'],
      isCoHost: json['IsCoHost'] ?? false,
      personName: json['PersonName'] ?? '',
      personDepartment: json['PersonDepartment'] ?? '',
      personDesignation: json['PersonDesignation'] ?? '',
      personCompany: json['PersonCompany'] ?? '',
      empCode: json['EmpCode'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    participentLogID,
    personID,
    isAttending,
    personPhotoName,
    isCoHost,
    personName,
    personDepartment,
    personDesignation,
    personCompany,
    empCode,
  ];
}
