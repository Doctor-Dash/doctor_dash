import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_model.dart';
import 'dart:math';

class FeedbackService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference feedbackCollection;

  FeedbackService()
      : feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      List.generate(
          10, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  Future<String> createFeedback(int rating, String feedbackNote) async {
    String feedbackId = '';
    bool isUnique = false;

    while (!isUnique) {
      feedbackId = generateRandomId();
      try {
        final QuerySnapshot querySnapshot = await feedbackCollection
            .where('feedbackId', isEqualTo: feedbackId)
            .get();

        if (querySnapshot.docs.isEmpty) {
          isUnique = true;
        }
      } catch (e) {
        throw Exception('Failed to check uniqueness of feedbackId: $e');
      }
    }

    FeedbackModel feedback = FeedbackModel(
      feedbackId: feedbackId,
      rating: rating,
      feedbackNote: feedbackNote,
    );

    try {
      await feedbackCollection.add(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }

    return feedbackId;
  }

  Future<void> updateFeedback(
      String feedbackId, int rating, String feedbackNote) async {
    FeedbackModel feedback = FeedbackModel(
      feedbackId: feedbackId,
      rating: rating,
      feedbackNote: feedbackNote,
    );

    try {
      await feedbackCollection.doc(feedbackId).update(feedback.toMap());
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
}
