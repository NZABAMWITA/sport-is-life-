import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallService {
  static const String appId = "43827fc539ab4ea48b67f1e7ac884123";

  // Create a new call
  static Future<Map<String, dynamic>> createCall({
    required String calleeId,
    required String calleeName,
    required String callType, // 'video' or 'audio'
  }) async {
    final caller = FirebaseAuth.instance.currentUser;
    if (caller == null) throw Exception('User not logged in');

    final channelName =
        'call_${DateTime.now().millisecondsSinceEpoch}_${caller.uid}';

    final callData = {
      'channelName': channelName,
      'callerId': caller.uid,
      'callerName': caller.displayName ?? 'User',
      'calleeId': calleeId,
      'calleeName': calleeName,
      'callType': callType,
      'status': 'ringing', // ringing, connected, ended, missed
      'startTime': FieldValue.serverTimestamp(),
      'endTime': null,
    };

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(channelName)
        .set(callData);

    // Create invite for callee
    await FirebaseFirestore.instance
        .collection('call_invites')
        .doc(calleeId)
        .set({
      'fromId': caller.uid,
      'fromName': caller.displayName ?? 'User',
      'channelName': channelName,
      'callType': callType,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    return callData;
  }

  // Accept a call
  static Future<void> acceptCall(String channelName) async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(channelName)
        .update({
      'status': 'connected',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // Clear invite
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('call_invites')
          .doc(user.uid)
          .delete();
    }
  }

  // End a call
  static Future<void> endCall(String channelName) async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(channelName)
        .update({
      'status': 'ended',
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  // Listen for incoming calls
  static Stream<DocumentSnapshot> listenForIncomingCalls() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    return FirebaseFirestore.instance
        .collection('call_invites')
        .doc(user.uid)
        .snapshots();
  }
}
