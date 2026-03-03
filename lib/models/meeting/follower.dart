import 'package:equatable/equatable.dart';

class Follower extends Equatable {
  final int followersID;
  final int personID;
  final String personName;
  final String personDepartment;
  final String personDesignation;
  final String personCompany;
  final String? personPhotoName;

  const Follower({
    required this.followersID,
    required this.personID,
    required this.personName,
    required this.personDepartment,
    required this.personDesignation,
    required this.personCompany,
    this.personPhotoName,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      followersID: json['FollowersID'] ?? 0,
      personID: json['PersonID'] ?? 0,
      personName: json['PersonName'] ?? '',
      personDepartment: json['PersonDepartment'] ?? '',
      personDesignation: json['PersonDesignation'] ?? '',
      personCompany: json['PersonCompany'] ?? '',
      personPhotoName: json['PersonPhotoName'],
    );
  }

  @override
  List<Object?> get props => [
    followersID,
    personID,
    personName,
    personDepartment,
    personDesignation,
    personCompany,
    personPhotoName,
  ];
}
