import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final int rating; // Rating ranging from 1 to 5 stars
  final String feedbackNote;

  FeedbackModel({
    required this.feedbackId, 
    required this.rating, 
    required this.feedbackNote
  });

  static FeedbackModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      feedbackId: map['feedbackId'] as String,
      rating: map['rating'] as int,
      feedbackNote: map['feedbackNote'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'rating': rating,
      'feedbackNote': feedbackNote,
    };
  }
}
