import 'package:cloud_firestore/cloud_firestore.dart';

class JoinMeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> canJoinMeeting(String meetingId) async {
    final doc =
    await _firestore.collection('meetings').doc(meetingId).get();

    if (!doc.exists) return false;

    // meeting must be active
    return doc['hostJoined'] == true;
  }
}
