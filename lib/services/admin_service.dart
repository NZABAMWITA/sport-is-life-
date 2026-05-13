import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc['role'] == 'admin' || userDoc['role'] == 'coach';
  }

  // Get all feedback
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedbackModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get unread feedback
  Stream<List<FeedbackModel>> getUnreadFeedback() {
    return _firestore
        .collection('feedback')
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedbackModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get feedback by type
  Stream<List<FeedbackModel>> getFeedbackByType(String type) {
    return _firestore
        .collection('feedback')
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedbackModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Mark as read
  Future<void> markAsRead(String feedbackId) async {
    await _firestore.collection('feedback').doc(feedbackId).update({
      'isRead': true,
    });
  }

  // Mark as replied
  Future<void> markAsReplied(String feedbackId, String reply) async {
    await _firestore.collection('feedback').doc(feedbackId).update({
      'isReplied': true,
      'reply': reply,
      'repliedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    await _firestore.collection('feedback').doc(feedbackId).delete();
  }
}
