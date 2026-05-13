class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String type;
  final String subject;
  final String feedback;
  final int rating;
  final int attachments;
  final DateTime timestamp;
  bool isRead;
  bool isReplied;
  String? reply;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.subject,
    required this.feedback,
    required this.rating,
    required this.attachments,
    required this.timestamp,
    this.isRead = false,
    this.isReplied = false,
    this.reply,
  });

  factory FeedbackModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FeedbackModel(
      id: docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userEmail: data['userEmail'] ?? '',
      type: data['type'] ?? 'General',
      subject: data['subject'] ?? '',
      feedback: data['feedback'] ?? '',
      rating: data['rating'] ?? 0,
      attachments: data['attachments'] ?? 0,
      timestamp: (data['timestamp'] as dynamic).toDate(),
      isRead: data['isRead'] ?? false,
      isReplied: data['isReplied'] ?? false,
      reply: data['reply'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRead': isRead,
      'isReplied': isReplied,
      'reply': reply,
    };
  }
}
