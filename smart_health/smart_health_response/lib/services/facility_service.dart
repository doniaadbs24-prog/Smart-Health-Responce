import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/facility_model.dart';

class FacilityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<FacilityModel>> getAll() async {
    final snapshot = await _db
        .collection(FirestoreCollections.facilities)
        .get();
    return snapshot.docs
        .map((doc) => FacilityModel.fromJson(doc.data()))
        .toList();
  }

  Future<FacilityModel?> getById(String facilityId) async {
    final doc = await _db
        .collection(FirestoreCollections.facilities)
        .doc(facilityId)
        .get();
    if (!doc.exists) return null;
    return FacilityModel.fromJson(doc.data()!);
  }

  Future<void> create(FacilityModel facility) async {
    await _db
        .collection(FirestoreCollections.facilities)
        .doc(facility.facilityId)
        .set(facility.toJson());
  }

  Future<void> update(FacilityModel facility) async {
    await _db
        .collection(FirestoreCollections.facilities)
        .doc(facility.facilityId)
        .update(facility.toJson());
  }

  Future<void> delete(String facilityId) async {
    await _db
        .collection(FirestoreCollections.facilities)
        .doc(facilityId)
        .delete();
  }
}
