import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_model.dart';
import 'dart:math';

class FeedbackService {
  final User? user = FirebaseAuth.instance.currentUser;
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
        print('Failed to check uniqueness of feedbackId: $e');
        return '';
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
      print('Failed to add feedback: $e');
      return '';
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
      print('Failed to update feedback: $e');
    }
  }

  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await feedbackCollection.doc(feedbackId).delete();
    } catch (e) {
      print('Failed to delete feedback: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByIds(
      List<String> feedbackIds) async {
    List<FeedbackModel> feedbacks = [];

    for (String feedbackId in feedbackIds) {
      try {
        DocumentSnapshot doc = await feedbackCollection.doc(feedbackId).get();
        feedbacks.add(FeedbackModel.fromMap(doc));
      } catch (e) {
        print('Failed to get feedback: $e');
      }
    }

    return feedbacks;
  }
}
