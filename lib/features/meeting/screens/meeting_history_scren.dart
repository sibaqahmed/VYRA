import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/meeting_service.dart';
import '../widgets/meeting_tile.dart';
import 'meeting_screen.dart';

class MeetingHistoryScreen extends StatelessWidget {
  MeetingHistoryScreen({super.key});

  final MeetingService _meetingService = MeetingService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔒 AUTH GUARD (prevents crash + flicker)
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _meetingService.getUserMeetingsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No meetings yet"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String meetingId = data['meetingId'];
              final String hostName = data['hostName'];
              final DateTime createdAt =
              (data['createdAt'] as Timestamp).toDate();

              return MeetingTile(
                meetingId: meetingId,
                hostName: hostName,
                createdAt: createdAt,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MeetingScreen(
                        meetingId: meetingId,
                        userName: user.displayName ?? "Guest",
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
