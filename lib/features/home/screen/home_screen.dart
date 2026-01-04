import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:vyra/features/meeting/screens/meeting_screen.dart';
import 'package:vyra/features/meeting/screens/schedule_meeting_screen.dart';
import 'package:vyra/features/meeting/services/meeting_service.dart';
import 'package:vyra/features/profile/screens/profile_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/home_action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    /// 🔒 HARD AUTH GUARD
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final MeetingService meetingService = MeetingService();

    void shareMeeting(String meetingId) {
      Share.share(
        "Join my VYRA meeting 🚀\n\nMeeting Code: $meetingId",
      );
    }

    /// 🎥 CREATE NEW MEETING — FIXED
    Future<void> createNewMeeting() async {
      final meetingId = await meetingService.createMeeting(
        hostUid: user.uid,
        hostName: user.displayName ?? "Host",
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingScreen(
            meetingId: meetingId,
            userName: user.displayName ?? "Host",
            isAudioMuted: false,
            isVideoMuted: false,
          ),
        ),
      );
    }

    /// ➕ JOIN MEETING
    void showJoinMeetingDialog() {
      final controller = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Join Meeting"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter Meeting ID",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = controller.text.trim();
                if (id.isEmpty) return;

                Navigator.pop(context);

                await meetingService.saveMeeting(
                  meetingId: id,
                  hostUid: user.uid,
                  hostName: user.displayName ?? "Guest",
                );

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeetingScreen(
                      meetingId: id,
                      userName: user.displayName ?? "Guest",
                      isAudioMuted: false,
                      isVideoMuted: false,
                    ),
                  ),
                );
              },
              child: const Text("Join"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return AppColors.primaryGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            );
          },
          child: const Text(
            'VYRA',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// 🔘 ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HomeActionButton(
                  icon: Icons.videocam,
                  label: 'New Meeting',
                  onPressed: createNewMeeting,
                ),
                HomeActionButton(
                  icon: Icons.add_box_rounded,
                  label: 'Join Meeting',
                  onPressed: showJoinMeetingDialog,
                ),
                HomeActionButton(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScheduleMeetingScreen(),
                      ),
                    );
                  },
                ),
                HomeActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onPressed: () async {
                    final meetingId =
                    await meetingService.createMeeting(
                      hostUid: user.uid,
                      hostName: user.displayName ?? "Host",
                    );

                    shareMeeting(meetingId);

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetingScreen(
                          meetingId: meetingId,
                          userName: user.displayName ?? "Host",
                          isAudioMuted: false,
                          isVideoMuted: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 60),

            const Text(
              'Create or join meetings instantly',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            /// 💡 TIPS
            Row(
              children: const [
                Icon(Icons.lightbulb_outline,
                    color: AppColors.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  "Professional Tips",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            tipItem("Only hosts can end meetings"),
            tipItem("Share meeting code to invite participants"),
            tipItem("Ended meetings appear in your history"),
          ],
        ),
      ),
    );
  }

  Widget tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
