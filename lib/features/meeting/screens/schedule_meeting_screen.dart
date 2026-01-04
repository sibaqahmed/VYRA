import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/notification_service.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  DateTime _selectedDateTime =
  DateTime.now().add(const Duration(hours: 1));

  /// 📅 PICK DATE
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  /// ⏰ PICK TIME
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  /// 📌 SCHEDULE MEETING (FINAL + CORRECT)
  Future<void> _scheduleMeeting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final meetingId =
    DateTime.now().millisecondsSinceEpoch.toString();

    // 🔔 Notification (safe, non-blocking)
    try {
      await NotificationService.scheduleReminder(
        meetingId.hashCode,
        _selectedDateTime.subtract(const Duration(minutes: 15)),
        "Meeting Reminder",
        "Your VYRA meeting starts in 15 minutes",
      );
    } catch (e) {
      debugPrint("Notification error: $e");
    }

    // ✅ SINGLE FIRESTORE WRITE — THIS IS KEY
    await FirebaseFirestore.instance
        .collection('scheduled_meetings')
        .doc(meetingId)
        .set({
      'meetingId': meetingId,
      'hostUid': user.uid,
      'hostName': user.displayName ?? "Host",
      'scheduledAt': Timestamp.fromDate(_selectedDateTime),
      'reminderAt': Timestamp.fromDate(
        _selectedDateTime.subtract(const Duration(minutes: 15)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Meeting scheduled successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Meeting"),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              color: AppColors.surface,
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Date"),
                subtitle: Text(
                  "${_selectedDateTime.day}-${_selectedDateTime.month}-${_selectedDateTime.year}",
                ),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surface,
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Time"),
                subtitle: Text(
                  TimeOfDay.fromDateTime(_selectedDateTime)
                      .format(context),
                ),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  "Host: ${user?.displayName ?? "You"}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _scheduleMeeting,
                child: const Text(
                  "Schedule Meeting",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
