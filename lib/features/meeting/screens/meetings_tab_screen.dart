import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/meeting_service.dart';
import '../widgets/meeting_tile.dart';
import 'meeting_screen.dart';

class MeetingsTabScreen extends StatelessWidget {
  MeetingsTabScreen({super.key});

  final MeetingService _service = MeetingService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔒 AUTH GUARD (CRITICAL)
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meetings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          /// 🔹 SCHEDULED
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Scheduled",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildStream(
            stream: _service.scheduledMeetingsStream(user.uid),
            context: context,
          ),

          /// 🔹 RECENT
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Recent",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildStream(
            stream: _service.recentMeetingsStream(user.uid),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildStream({
    required Stream<QuerySnapshot> stream,
    required BuildContext context,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(Icons.video_call_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text("No meetings yet",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final DateTime createdAt =
            (data['scheduledAt'] ?? data['createdAt'] as Timestamp)
                .toDate();

            return MeetingTile(
              meetingId: data['meetingId'],
              hostName: data['hostName'] ?? "Unknown",
              createdAt: createdAt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeetingScreen(
                      meetingId: data['meetingId'],
                      userName: "You",
                      isAudioMuted: false,
                      isVideoMuted: false,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
