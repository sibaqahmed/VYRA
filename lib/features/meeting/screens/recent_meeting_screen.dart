import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'meeting_screen.dart';
import '../services/meeting_service.dart';
import '../widgets/meeting_tile.dart';

class RecentMeetingScreen extends StatelessWidget {
  RecentMeetingScreen({super.key});

  final MeetingService _meetingService = MeetingService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔒 AUTH GUARD — prevents flicker
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Meetings"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _meetingService.recentMeetingsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No meetings yet"));
          }

          /// ✅ FILTER + SORT LOCALLY (FIXES BUG)
          final meetings = snapshot.data!.docs
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['endedAt'] != null;
          })
              .toList()
            ..sort((a, b) {
              final ta =
              (a['endedAt'] as Timestamp).toDate();
              final tb =
              (b['endedAt'] as Timestamp).toDate();
              return tb.compareTo(ta);
            });

          if (meetings.isEmpty) {
            return const Center(child: Text("No meetings yet"));
          }

          return ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final data =
              meetings[index].data() as Map<String, dynamic>;

              return MeetingTile(
                meetingId: data['meetingId'],
                hostName: data['hostName'],
                createdAt:
                (data['endedAt'] as Timestamp).toDate(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MeetingScreen(
                        meetingId: data['meetingId'],
                        userName: user.displayName ?? "User",
                        isAudioMuted: false,
                        isVideoMuted: false,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
