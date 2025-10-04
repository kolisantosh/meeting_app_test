import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../config/color/app_colors.dart';
import '../../model/meeting.dart';
import '../../services/time_helper.dart';

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
      body: SingleChildScrollView(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return _buildPortraitContent(context);
            } else {
              return _buildLandscapeContent(context);
            }
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildPortraitContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(),
          const SizedBox(width: 20),
          Expanded(
            child: _buildMeetingDetails(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(),
          const SizedBox(width: 20),
          Expanded(
            child: _buildMeetingDetails(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final duration = meeting.duration;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(
            TimeHelpers.formatFullTime(meeting.eventFromDate),
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 2,
            height: 100,
            color: AppColors.red,
          ),
          Text(
            TimeHelpers.formatDuration(duration),
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
          Container(
            width: 2,
            height: 100,
            color: AppColors.red,
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TimeHelpers.formatFullTime(meeting.eventToDate),
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
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
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${meeting.meetingType} : ${meeting.eventSubject}',
                style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.red, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Event Status',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              meeting.statusDesc,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            const Text(
              'Organizer',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            _buildOrganizerCard(),
          ],
        ),
        const SizedBox(height: 32),
        _buildAttendees(context),
        const SizedBox(height: 32),
        _buildFollowers(context),
        const SizedBox(height: 80),
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
            radius: 24,
            backgroundColor: AppColors.green,
            child:
            CachedNetworkImage(
              imageUrl: meeting.createdByUserName.toString(),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.person),
            ),
            // const Icon(Icons.person, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          Text(
            meeting.createdByUserName,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
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
          const Text(
            'Attendees',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          if (meeting.participants.isEmpty)
            _buildAddButton(context, 'ADD'),
          ...meeting.participants.map((participant) => Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              // decoration: BoxDecoration(
              //   border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              //   borderRadius: BorderRadius.circular(8),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.grey,
                    child:
                    CachedNetworkImage(
                      imageUrl: participant.personPhotoName.toString().replaceFirst("http://", "https://"),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.person),
                    ),
                    // const Icon(Icons.person, color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    participant.personName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
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
          )),
          if (meeting.participants.isNotEmpty)
            _buildAddButton(context, 'ADD'),
        ],
      ),
    );
  }

  Widget _buildFollowers(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Followers',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 16),
        if (meeting.followers.isEmpty)
          _buildAddButton(context, 'ADD'),
        ...meeting.followers.map((follower) => Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.grey,
                  child:
                  CachedNetworkImage(
                    imageUrl: follower.personPhotoName.toString().replaceFirst("http://", "https://"),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.person),
                  ),
                  // const Icon(Icons.person, color: AppColors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  follower.personName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
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
        )),
        if (meeting.followers.isNotEmpty)
          _buildAddButton(context, 'ADD'),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(top: 0),
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle
          // ),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.brightRedColor
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.all(16.0),
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
            label: const Text(
              'Edit',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
