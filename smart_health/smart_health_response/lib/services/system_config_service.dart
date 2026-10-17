import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/system_config_model.dart';

class SystemConfigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<SystemConfig?> getByKey(String key) async {
    final snapshot = await _db
        .collection(FirestoreCollections.systemConfig)
        .where('configKey', isEqualTo: key)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return SystemConfig.fromJson(snapshot.docs.first.data());
  }

  Future<List<SystemConfig>> getAll() async {
    final snapshot = await _db
        .collection(FirestoreCollections.systemConfig)
        .get();
    return snapshot.docs
        .map((doc) => SystemConfig.fromJson(doc.data()))
        .toList();
  }

  Future<void> update(SystemConfig config) async {
    await _db
        .collection(FirestoreCollections.systemConfig)
        .doc(config.configId)
        .update(config.toJson());
  }
}
