import 'package:flutter/material.dart';

class MeetingTile extends StatelessWidget {
  final String meetingId;
  final String hostName;
  final DateTime? createdAt;
  final VoidCallback onTap;

  const MeetingTile({
    super.key,
    required this.meetingId,
    required this.hostName,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14)
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.video_call, color: Colors.white),
        ),
        title: Text(
          "Meeting $meetingId",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Host: $hostName",
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              createdAt == null
                  ? "Created just now"
                  : "Created on ${createdAt!.toLocal().toString().split('.')[0]}",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
