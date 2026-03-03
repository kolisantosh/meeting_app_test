class LoginModel {
  final String? message;

  final String? userPin;

  final String? userName;

  final bool? userIsActive;

  final bool? userIsDeleted;

  final String? apiAccToken;

  final String? userEmail;

  final int? userId;

  final String? userProfileImage;

  final int? currentLocationId;

  final String? meetingRoomId;

  final int? cleaningLocationId;

  final int? cntLocId;

  LoginModel({
    this.message,

    this.userPin,

    this.userName,

    this.userIsActive,

    this.userIsDeleted,

    this.apiAccToken,

    this.userEmail,

    this.userId,

    this.userProfileImage,

    this.currentLocationId,

    this.meetingRoomId,

    this.cleaningLocationId,

    this.cntLocId,
  });

  // Factory method to create an instance from JSON

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'] as String?,

      userPin: json['UserPin'] as String?,

      userName: json['UserName'] as String?,

      userIsActive: json['UserIsActive'] as bool?,

      userIsDeleted: json['userIsDeleted'] as bool?,

      apiAccToken: json['ApiAccToken'] as String?,

      userEmail: json['userEmail'] as String?,

      userId: json['userid'] as int?,

      userProfileImage: json['UserProfileImage'] as String?,

      currentLocationId: json['currentlocationid'] as int?,

      meetingRoomId: json['MeetingRoomID'] as String?,

      cleaningLocationId: json['CleaningLocationID'] as int?,

      cntLocId: json['CntLocID'] as int?,
    );
  }

  // Method to convert the model back to JSON

  Map<String, dynamic> toJson() {
    return {
      'message': message,

      'UserPin': userPin,

      'UserName': userName,

      'UserIsActive': userIsActive,

      'userIsDeleted': userIsDeleted,

      'ApiAccToken': apiAccToken,

      'userEmail': userEmail,

      'userid': userId,

      'UserProfileImage': userProfileImage,

      'currentlocationid': currentLocationId,

      'MeetingRoomID': meetingRoomId,

      'CleaningLocationID': cleaningLocationId,

      'CntLocID': cntLocId,
    };
  }
}
