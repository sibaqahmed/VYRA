import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:share_plus/share_plus.dart';

import 'package:vyra/core/services/jwt_service.dart';
import 'package:vyra/features/meeting/services/meeting_service.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String userName;
  final bool isAudioMuted;
  final bool isVideoMuted;


  const MeetingScreen({
    super.key,
    required this.meetingId,
    required this.userName,
    required this.isAudioMuted,
    required this.isVideoMuted,
  });

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final JitsiMeet _jitsiMeet = JitsiMeet();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MeetingService _meetingService=MeetingService();

  bool _isHost = false;
  late bool _audioMuted;
  late bool _videoMuted;

  static const String _jaasAppId =
      "vpaas-magic-cookie-2fbbf37f24184f5eb71ad71a6b5a3ac3";

  @override
  void initState() {
    super.initState();
    _audioMuted = widget.isAudioMuted;
    _videoMuted = widget.isVideoMuted;
    _checkHostAndJoin();
  }

  Future<void> _checkHostAndJoin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meetingId)
        .get();

    final isHost = doc.exists && doc['hostUid'] == user.uid;

    if (!mounted) return;
    setState(() => _isHost = isHost);

    await _joinMeeting(isHost);
  }

  /// ✅ CORRECT JAAS JOIN (THIS FIXES EVERYTHING)
  Future<void> _joinMeeting(bool isHost) async {
    final jwt = await JwtService.fetchJwt(
      room: widget.meetingId,
      name: widget.userName,
      moderator: isHost,
    );

    final options = JitsiMeetConferenceOptions(
      serverURL: "https://8x8.vc",
      room: "vpaas-magic-cookie-2fbbf37f24184f5eb71ad71a6b5a3ac3/${widget.meetingId}",
      token: jwt,
      userInfo: JitsiMeetUserInfo(
        displayName: widget.userName,
      ),
      configOverrides: {
        "startWithAudioMuted": _audioMuted,
        "startWithVideoMuted": _videoMuted,
      },
    );


    _jitsiMeet.join(options);
  }

  void _toggleAudio() {
    setState(() => _audioMuted = !_audioMuted);
    _jitsiMeet.setAudioMuted(_audioMuted);
  }

  void _toggleVideo() {
    setState(() => _videoMuted = !_videoMuted);
    _jitsiMeet.setVideoMuted(_videoMuted);
  }

  Future<void> _leaveMeeting() async {
    try {
      await _meetingService.endMeeting(widget.meetingId);
    } catch (e) {
      debugPrint("End meeting failed: $e");
    }

    _jitsiMeet.hangUp();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _jitsiMeet.hangUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("VYRA Meeting", style: TextStyle(fontSize: 16)),
            Text(
              "ID: ${widget.meetingId}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: widget.meetingId),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Meeting ID copied")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                "Join my VYRA meeting 🚀\nMeeting ID: ${widget.meetingId}",
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const Center(
            child: Text(
              "Meeting in progress...",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(
                  icon: _audioMuted ? Icons.mic_off : Icons.mic,
                  color: _audioMuted ? Colors.red : Colors.white,
                  onTap: _toggleAudio,
                ),
                _controlButton(
                  icon: _videoMuted
                      ? Icons.videocam_off
                      : Icons.videocam,
                  color: _videoMuted ? Colors.red : Colors.white,
                  onTap: _toggleVideo,
                ),
                _controlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: _leaveMeeting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade900,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
