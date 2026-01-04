import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vyra/features/meeting/services/join_meeting_services.dart';
import 'package:vyra/features/meeting/services/meeting_service.dart';
import 'meeting_screen.dart';

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({super.key});

  @override
  State<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final TextEditingController _controller = TextEditingController();
  final JoinMeetingService _service = JoinMeetingService();
  bool _loading = false;

  Future<void> _join() async {
    final meetingId = _controller.text.trim().toUpperCase();
    if (meetingId.isEmpty) return;

    if(!mounted)return;
    setState(() => _loading = true);

    final canJoin=await _service.canJoinMeeting(meetingId);

    if(!mounted)return;
    setState(() => _loading = false);

    if (!canJoin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Host has not joined the meeting yet")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
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
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Meeting")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Meeting Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _loading?null: _join,
              child: const Text("Join"),
            ),
          ],
        ),
      ),
    );
  }
}
