
class FeedbackModel {
  final String feedbackId;
  final int rating; // Rating ranging from 1 to 5 stars
  final String feedbackNote;

  FeedbackModel({required this.feedbackId, required this.rating, required this.feedbackNote});

  // Deserialize the map to a FeedbackModel object
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedbackId'],
      rating: map['rating'],
      feedbackNote: map['feedbackNote'],
    );
  }

  // Serialize the FeedbackModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'rating': rating,
      'feedbackNote': feedbackNote,
    };
  }

  @override
  String toString() {
    return 'FeedbackModel(feedbackId: $feedbackId, rating: $rating, feedbackNote: $feedbackNote)';
  }
}