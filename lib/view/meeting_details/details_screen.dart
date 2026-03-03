import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertest/config/constants/imape_path.dart';

import '../../config/constants/app_colors.dart';
import '../../models/meeting/meeting_model.dart';
import '../../services/time_helper.dart';
import '../../views.dart';

class DetailScreen extends StatelessWidget {
  final MeetingModel meeting;

  const DetailScreen({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meeting Summary',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LEFT SIDE: TIMELINE
                _buildTimeline(constraints.maxHeight),

                SizedBox(width: 40.w),

                // 2. RIGHT SIDE: CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      SizedBox(height: 20.h),

                      // This expanded section distributes the 3 rows evenly
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSplitRow(
                              'Event Status',
                              Text(
                                meeting.statusDesc,
                                style: TextStyle(
                                  color: AppColors.textDisableColor,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),

                            _buildSplitRow(
                              'Organizer',
                              Row(
                                children: [
                                  _buildPersonCard(
                                    name: meeting.createdForUserName,
                                    imageUrl: null,
                                    borderColor: AppColors.solidGreenColor,
                                    showRemove: false,
                                    subTitle: "",
                                  ),
                                  ...meeting.participants
                                      .where(
                                        (p) =>
                                            p.isCoHost &&
                                            (p.isPersonActive ||
                                                p.meetingRoomAddMe),
                                      )
                                      .map(
                                        (p) => _buildPersonCard(
                                          name: p.personName,
                                          imageUrl: p.personPhotoName,
                                          borderColor: p.isAttending == "Y"
                                              ? AppColors.solidGreenColor
                                              : p.isAttending == "N"
                                              ? AppColors.brightRedColor
                                              : AppColors.grey,
                                          subTitle: "[Co-Host]",
                                          statusIconPath: p.isAttending == "Y"
                                              ? p.participantPunchDetail !=
                                                            null &&
                                                        p
                                                                .participantPunchDetail
                                                                .first
                                                                .datetimes !=
                                                            null
                                                    ? ImagePath.checkBoxFill
                                                    : ImagePath.checkBox
                                              : ImagePath.questionLine,
                                          statusColor: p.isAttending == "Y"
                                              ? AppColors.brightGreenColor
                                              : p.isAttending == "N"
                                              ? AppColors.brightRedColor
                                              : AppColors.grey,
                                        ),
                                      ),
                                ],
                              ),
                            ),

                            _buildSplitRow(
                              'Attendees',
                              Row(
                                children: [
                                  ...meeting.participants
                                      .where(
                                        (p) =>
                                            !p.isCoHost &&
                                            (p.isPersonActive ||
                                                p.meetingRoomAddMe),
                                      )
                                      .map(
                                        (p) => _buildPersonCard(
                                          name: p.personName,
                                          imageUrl: p.personPhotoName,
                                          borderColor: p.isAttending == "Y"
                                              ? AppColors.solidGreenColor
                                              : p.isAttending == "N"
                                              ? AppColors.brightRedColor
                                              : AppColors.grey,
                                          statusIconPath: p.isAttending == "Y"
                                              ? p
                                                            .participantPunchDetail
                                                            .first
                                                            .datetimes !=
                                                        null
                                                    ? ImagePath.checkBoxFill
                                                    : ImagePath.checkBox
                                              : p.isAttending == "N"
                                              ? ImagePath.completeEvent
                                              : ImagePath.questionLine,
                                          statusColor: p.isAttending == "Y"
                                              ? AppColors.brightGreenColor
                                              : p.isAttending == "N"
                                              ? AppColors.brightRedColor
                                              : AppColors.grey,
                                        ),
                                      ),
                                  _buildAddButton('ADD'),
                                ],
                              ),
                            ),

                            _buildSplitRow(
                              'Followers',
                              Row(
                                children: [
                                  ...meeting.followers.map(
                                    (f) => _buildPersonCard(
                                      name: f.personName,
                                      imageUrl: f.personPhotoName,
                                      borderColor: AppColors.grey,
                                    ),
                                  ),
                                  _buildAddButton('ADD'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildBottomBar(context),
    );
  }

  // --- COMPONENT: THE SPLIT ROW ---
  Widget _buildSplitRow(String label, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // FIXED WIDTH LABEL SIDE
        SizedBox(
          width: 150.w,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        // SCROLLABLE DATA SIDE
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TimeHelpers.formatDate(meeting.eventFromDate),
          style: TextStyle(color: AppColors.grey, fontSize: 18.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${meeting.meetingTypeName.toUpperCase()} : ${meeting.eventSubject}',
                style: TextStyle(
                  color: AppColors.brightRedColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.edit, color: AppColors.brightRedColor, size: 24.w),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(double maxHeight) {
    return SizedBox(
      height: maxHeight - 40.h,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeText(
                TimeHelpers.formatTimeWithPeriod(
                  meeting.eventFromDate,
                ).toUpperCase(),
              ),
              _timeText(TimeHelpers.formatDuration(meeting.duration)),
              _timeText(
                TimeHelpers.formatTimeWithPeriod(
                  meeting.eventToDate,
                ).toUpperCase(),
              ),
            ],
          ),
          SizedBox(width: 20.w),
          Column(
            children: [
              _dot(),
              Expanded(
                child: Container(width: 2.w, color: AppColors.brightRedColor),
              ),
              _dot(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeText(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 16.sp,
    ),
  );
  Widget _dot() => Container(
    width: 14.w,
    height: 14.w,
    decoration: const BoxDecoration(
      color: AppColors.brightRedColor,
      shape: BoxShape.circle,
    ),
  );

  Widget _buildPersonCard({
    required String name,
    required String? imageUrl,
    required Color borderColor,
    String? subTitle,
    String? statusIconPath,
    Color? statusColor,
    bool showRemove = true,
  }) {
    return Container(
      width: 130.w,
      padding: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 5.w),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        imageUrl:
                            imageUrl?.replaceFirst("http://", "https://") ?? "",
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.black,
                          alignment: Alignment.center,
                          child: Text(
                            getInitials(name),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (statusIconPath != null)
                    Positioned(
                      right: 12.w,
                      bottom: 0,
                      child: Container(
                        height: 26.w,
                        width: 26.w,
                        decoration: BoxDecoration(
                          color: Colors.black, // Your circular background color
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          statusIconPath,
                          // colorFilter: ColorFilter.mode(
                          //   statusColor ?? AppColors.grey, // Your icon color
                          //   BlendMode.srcIn,
                          // ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textDisableColor,
                  fontSize: 12.h,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (subTitle != null)
                Text(
                  subTitle,
                  style: TextStyle(
                    color: AppColors.textDisableColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
          if (showRemove)
            Positioned(
              right: 10.h,
              top: 0,
              child: Container(
                height: 23,
                width: 23,
                decoration: BoxDecoration(
                  // color: Colors.white, // Your circular background color
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {},
                  child: SvgPicture.asset(
                    ImagePath.removeCircle,
                    // colorFilter: ColorFilter.mode(
                    //   AppColors.red, // Your icon color
                    //   BlendMode.srcIn,
                    // ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label) {
    return Column(
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brightRedColor, width: 2.w),
          ),
          child: Icon(Icons.add, color: AppColors.brightRedColor, size: 25.w),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.brightRedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _bottomAction(Icons.check_circle_outline, 'Complete Event'),
        SizedBox(width: 20.w),
        _bottomAction(Icons.edit, 'Edit'),
      ],
    );
  }

  Widget _bottomAction(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: AppColors.grey, size: 20.sp),
      label: Text(
        label,
        style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
      ),
    );
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "??";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) return (parts.first[0] + parts.last[0]).toUpperCase();
    return parts.first[0].toUpperCase();
  }
}
