import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/meeting_service.dart';

class ScheduledMeetingsScreen extends StatelessWidget {
  ScheduledMeetingsScreen({super.key});

  final MeetingService _service = MeetingService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    /// 🔒 AUTH GUARD — prevents flicker
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Scheduled Meetings"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.scheduledMeetingsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final DateTime time =
              (data['scheduledAt'] as Timestamp).toDate();

              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.schedule,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    data['meetingId'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    "${time.day}-${time.month}-${time.year} • "
                        "${TimeOfDay.fromDateTime(time).format(context)}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'cancel') {
                        await _service.cancelScheduledMeeting(doc.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'cancel',
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 💤 EMPTY STATE
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No scheduled meetings",
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
