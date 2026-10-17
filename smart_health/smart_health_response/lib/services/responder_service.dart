import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/configuration/geo_point_extensions.dart';
import '../models/responder_model.dart';
import '../utils/distance_calculator.dart';

class ResponderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ResponderModel>> getAll() async {
    final snapshot = await _db
        .collection(FirestoreCollections.responders)
        .get();
    return snapshot.docs
        .map((doc) => ResponderModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<ResponderModel>> getApproved() async {
    final snapshot = await _db
        .collection(FirestoreCollections.responders)
        .where('isApproved', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ResponderModel.fromJson(doc.data()))
        .toList();
  }

  Future<ResponderModel?> getById(String responderId) async {
    final doc = await _db
        .collection(FirestoreCollections.responders)
        .doc(responderId)
        .get();
    if (!doc.exists) return null;
    return ResponderModel.fromJson(doc.data()!);
  }

  Stream<ResponderModel?> watchById(String responderId) {
    return _db
        .collection(FirestoreCollections.responders)
        .doc(responderId)
        .snapshots()
        .map((doc) => doc.exists ? ResponderModel.fromJson(doc.data()!) : null);
  }

  Future<void> recomputeStats(String responderId) async {
    final ratingsSnap = await _db
        .collection(FirestoreCollections.ratings)
        .where('responderId', isEqualTo: responderId)
        .get();
    double avg = 0.0;
    if (ratingsSnap.docs.isNotEmpty) {
      final total = ratingsSnap.docs.fold<int>(
        0,
        (acc, d) => acc + ((d.data()['ratingScore'] as num?)?.toInt() ?? 0),
      );
      avg = total / ratingsSnap.docs.length;
    }
    final closedSnap = await _db
        .collection(FirestoreCollections.cases)
        .where('responderId', isEqualTo: responderId)
        .where('caseStatus', isEqualTo: 'closed')
        .get();
    await _db
        .collection(FirestoreCollections.responders)
        .doc(responderId)
        .update({
          'averageRating': avg,
          'totalCasesResponded': closedSnap.docs.length,
        });
  }

  Future<void> create(ResponderModel responder) async {
    await _db
        .collection(FirestoreCollections.responders)
        .doc(responder.responderId)
        .set(responder.toJson());
  }

  Future<void> update(ResponderModel responder) async {
    await _db
        .collection(FirestoreCollections.responders)
        .doc(responder.responderId)
        .update(responder.toJson());
  }

  Future<void> delete(String responderId) async {
    await _db
        .collection(FirestoreCollections.responders)
        .doc(responderId)
        .delete();
  }

  Future<void> updateLocation(String responderId, GeoPoint location) async {
    await _db
        .collection(FirestoreCollections.responders)
        .doc(responderId)
        .update({'currentLocation': location});
  }

  Future<void> updateAvailability(String responderId, bool isAvailable) async {
    await _db
        .collection(FirestoreCollections.responders)
        .doc(responderId)
        .update({'isAvailable': isAvailable});
  }

  Future<List<ResponderModel>> findNearbyAvailable(
    GeoPoint incidentLocation,
    double radiusKm,
  ) async {
    final snapshot = await _db
        .collection(FirestoreCollections.responders)
        .where('isApproved', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .get();

    final incidentLatLng = incidentLocation.toLatLng();
    final results = <MapEntry<ResponderModel, double>>[];

    for (final doc in snapshot.docs) {
      final responder = ResponderModel.fromJson(doc.data());
      if (responder.currentLocation == null) continue;
      final distance = DistanceCalculator.haversineKm(
        incidentLatLng,
        responder.currentLocation!.toLatLng(),
      );
      if (distance <= radiusKm) {
        results.add(MapEntry(responder, distance));
      }
    }

    results.sort((a, b) => a.value.compareTo(b.value));
    return results.map((e) => e.key).toList();
  }
}
