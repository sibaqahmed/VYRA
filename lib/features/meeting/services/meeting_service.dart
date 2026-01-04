import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔢 Generate meeting ID
  String _generateMeetingId() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    final rand = Random();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // 🎥 CREATE MEETING
  Future<String> createMeeting({
    required String hostUid,
    required String hostName,
  }) async {
    final meetingId = _generateMeetingId();

    await _firestore.collection('meetings').doc(meetingId).set({
      'meetingId': meetingId,
      'hostUid': hostUid,
      'hostName': hostName,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'ended': false,
      'hostJoined': true,
    });

    return meetingId;
  }

  // 💾 SAVE MEETING (JOIN / SHARE)
  Future<void> saveMeeting({
    required String meetingId,
    required String hostUid,
    required String hostName,
  }) async {
    await _firestore.collection("meetings").doc(meetingId).set({
      "meetingId": meetingId,
      "hostUid": hostUid,
      "hostName": hostName,
      "createdAt": FieldValue.serverTimestamp(),
      "active": true,
      "ended": false,
    });
  }

  // 🛑 END MEETING
  Future<void> endMeeting(String meetingId) async {
    await _firestore.collection('meetings').doc(meetingId).update({
      'active': false,
      'ended': true,
      'endedAt': FieldValue.serverTimestamp(), // 🔥 CRITICAL
    });
  }


  // 🔍 CHECK IF MEETING EXISTS
  Future<bool> checkMeetingExists(String meetingId) async {
    final doc =
    await _firestore.collection('meetings').doc(meetingId).get();
    return doc.exists;
  }

  // 🔓 CHECK IF MEETING IS JOINABLE
  Future<bool> canJoinMeeting(String meetingId) async {
    final doc =
    await _firestore.collection('meetings').doc(meetingId).get();
    if (!doc.exists) return false;
    return doc['active'] == true;
  }

  // 🔴 ACTIVE MEETINGS
  Stream<QuerySnapshot> activeMeetingsStream(String uid) {
    return _firestore
        .collection('meetings')
        .where('hostUid', isEqualTo: uid)
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> scheduledMeetingsStream(String uid) {
    return _firestore
        .collection('scheduled_meetings')
        .orderBy('scheduledAt')
        .snapshots();
  }

  Stream<QuerySnapshot> recentMeetingsStream(String uid) {
    return _firestore
        .collection('meetings')
        .where('hostUid', isEqualTo: uid)
        .where('ended', isEqualTo: true)
        .snapshots();
  }




  // ❌ CANCEL SCHEDULED MEETING
  Future<void> cancelScheduledMeeting(String meetingId) async {
    await _firestore
        .collection('scheduled_meetings')
        .doc(meetingId)
        .delete();
  }

  Stream<QuerySnapshot> getUserMeetingsStream(String uid) {
    return _firestore
        .collection('meetings')
        .where('hostUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  // ✏️ RESCHEDULE MEETING
  Future<void> rescheduleMeeting(
      String meetingId,
      DateTime newTime,
      ) async {
    await _firestore
        .collection('scheduled_meetings')
        .doc(meetingId)
        .update({
      'scheduledAt': Timestamp.fromDate(newTime),
      'reminderAt':
      Timestamp.fromDate(newTime.subtract(const Duration(minutes: 15))),
    });
  }
}
