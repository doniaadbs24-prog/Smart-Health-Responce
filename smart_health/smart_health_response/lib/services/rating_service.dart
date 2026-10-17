import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/rating_feedback_model.dart';

class RatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create(RatingFeedback rating) async {
    await _db
        .collection(FirestoreCollections.ratings)
        .doc(rating.ratingId)
        .set(rating.toJson());
  }

  Future<List<RatingFeedback>> getByResponder(String responderId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.ratings)
        .where('responderId', isEqualTo: responderId)
        .orderBy('ratedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => RatingFeedback.fromJson(doc.data()))
        .toList();
  }

  Future<double> getAverageRating(String responderId) async {
    final ratings = await getByResponder(responderId);
    if (ratings.isEmpty) return 0.0;
    final total = ratings.map((r) => r.ratingScore).reduce((a, b) => a + b);
    return total / ratings.length;
  }
}
