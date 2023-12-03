import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_model.dart';
import 'dart:math';

class FeedbackService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference feedbackCollection;

  FeedbackService()
      : feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  Future<void> createFeedback(FeedbackModel feedback) async {
    try {
      await feedbackCollection.add(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  Future<void> updateFeedback(FeedbackModel feedback) async {
    try {
      await feedbackCollection
          .doc(feedback.feedbackId)
          .update(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }

  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await feedbackCollection.doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByIds(
      List<String>? feedbackIds) async {
    List<FeedbackModel> feedbacks = [];

    try {
      QuerySnapshot querySnapshot = await feedbackCollection
          .where('feedbackId', whereIn: feedbackIds)
          .get();

      for (var doc in querySnapshot.docs) {
        feedbacks.add(FeedbackModel.fromMap(doc));
      }
    } catch (e) {
      throw Exception('Failed to get feedbacks by IDs: $e');
    }

    return feedbacks;
  }

  Future<String> generateUniqueFeedbackId() async {
    String feedbackId = '';
    bool isUnique = false;
    final random = Random();

    while (!isUnique) {
      feedbackId = String.fromCharCodes(
        List.generate(10, (_) => random.nextInt(33) + 89),
      );

      var existingFeedback = await feedbackCollection
          .where('feedbackId', isEqualTo: feedbackId)
          .get();

      if (existingFeedback.docs.isEmpty) {
        isUnique = true;
      }
    }

    return feedbackId;
  }
}
