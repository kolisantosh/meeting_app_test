import 'package:cached_network_image/cached_network_image.dart';

import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';
import '../../services/time_helper.dart';
import '../../views.dart';

class DetailScreen extends StatelessWidget {
  final Meeting meeting;

  const DetailScreen({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meeting Summary',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _buildPortraitContent(context);
          } else {
            return _buildLandscapeContent(context);
          }
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildPortraitContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(),
          SizedBox(width: 20.w),
          Expanded(child: _buildMeetingDetails(context)),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTimeline(),
          SizedBox(width: 20.w),
          Expanded(child: _buildMeetingDetails(context)),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final duration = meeting.duration;

    return SizedBox(
      // width: 80,
      // height: ScreenUtil().screenHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text(
                TimeHelpers.formatFullTime(meeting.eventFromDate),
                style: TextStyle(color: AppColors.grey, fontSize: 14.sp),
              ),
              Spacer(),
              Text(
                TimeHelpers.formatDuration(duration),
                style: TextStyle(color: AppColors.grey, fontSize: 12.sp),
              ),
              Spacer(),

              Text(
                TimeHelpers.formatFullTime(meeting.eventToDate),
                style: TextStyle(color: AppColors.grey, fontSize: 14.sp),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: AppColors.brightRedColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2.w,
                height: ScreenUtil().screenHeight - 325,
                color: AppColors.brightRedColor,
              ),

              Container(width: 2, height: 100, color: AppColors.brightRedColor),
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColors.brightRedColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TimeHelpers.formatDate(meeting.eventFromDate),
          style: TextStyle(color: AppColors.grey, fontSize: 14.sp),
        ),

        // SizedBox(height: 8.h),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${meeting.meetingType} : ${meeting.eventSubject}',
                style: TextStyle(
                  color: AppColors.brightRedColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: AppColors.brightRedColor,
                size: 20.w,
              ),
              onPressed: () {},
            ),
          ],
        ),

        // SizedBox(height: 16.h),
        Spacer(),
        Row(
          children: [
            Text(
              'Event Status',
              style: TextStyle(color: AppColors.grey, fontSize: 14.sp),
            ),
            SizedBox(width: 20.w),
            Text(
              meeting.statusDesc,
              style: TextStyle(color: AppColors.white, fontSize: 14.sp),
            ),
          ],
        ),

        // SizedBox(height: 32.h),
        Spacer(),
        Row(
          children: [
            Text(
              'Organizer',
              style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
            ),
            SizedBox(width: 16.w),
            _buildOrganizerCard(),
          ],
        ),

        Spacer(),
        // SizedBox(height: 32.h),
        _buildAttendees(context),
        // SizedBox(height: 32.h),
        Spacer(),
        _buildFollowers(context),
        // SizedBox(height: 80.h),
        Spacer(),
      ],
    );
  }

  Widget _buildOrganizerCard() {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        // border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        // borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.brightGreenColor,
            child: CachedNetworkImage(
              imageUrl: meeting.createdByUserName.toString(),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.person),
            ),
            // const Icon(Icons.person, color: AppColors.white),
          ),
          SizedBox(height: 12.h),
          Text(
            meeting.createdByUserName,
            style: TextStyle(color: AppColors.white, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendees(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Attendees',
            style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
          ),
          SizedBox(width: 16.w),
          if (meeting.participants.isEmpty) _buildAddButton(context, 'ADD'),
          ...meeting.participants.map(
            (participant) => Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                padding: EdgeInsets.all(12.w),
                // decoration: BoxDecoration(
                //   border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                //   borderRadius: BorderRadius.circular(8),
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.grey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: CachedNetworkImage(
                          imageUrl: participant.personPhotoName
                              .toString()
                              .replaceFirst("http://", "https://"),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person),
                        ),
                      ),
                      // const Icon(Icons.person, color: AppColors.white),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      participant.personName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         participant.personName,
                    //         style: const TextStyle(
                    //           color: AppColors.white,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       Text(
                    //         participant.personDesignation,
                    //         style: const TextStyle(
                    //           color: AppColors.grey,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          if (meeting.participants.isNotEmpty) _buildAddButton(context, 'ADD'),
        ],
      ),
    );
  }

  Widget _buildFollowers(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Followers',
            style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
          ),
          SizedBox(width: 16.w),
          if (meeting.followers.isEmpty) _buildAddButton(context, 'ADD'),
          ...meeting.followers.map(
            (follower) => Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                padding: EdgeInsets.all(12.w),
                // decoration: BoxDecoration(border: Border.all(color: AppColors.grey.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.r),
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.grey,
                        child: CachedNetworkImage(
                          imageUrl: follower.personPhotoName
                              .toString()
                              .replaceFirst("http://", "https://"),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person),
                        ),
                        // const Icon(Icons.person, color: AppColors.white),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      follower.personName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         follower.personName,
                    //         style: const TextStyle(
                    //           color: AppColors.white,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       Text(
                    //         follower.personDesignation,
                    //         style: const TextStyle(
                    //           color: AppColors.grey,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          if (meeting.followers.isNotEmpty) _buildAddButton(context, 'ADD'),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          margin: EdgeInsets.only(top: 0.h),
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle
          // ),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brightRedColor,
              side: BorderSide(color: AppColors.brightRedColor, width: 2.w),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.add, color: Colors.red, size: 24.w)],
            ),
          ),
        ),
        SizedBox(height: 8.h),

        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.brightRedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: AppColors.black,
      padding: EdgeInsets.all(16.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline, color: AppColors.grey),
            label: const Text(
              'Complete Event',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: AppColors.grey),
            label: const Text('Edit', style: TextStyle(color: AppColors.grey)),
          ),
        ],
      ),
    );
  }
}
