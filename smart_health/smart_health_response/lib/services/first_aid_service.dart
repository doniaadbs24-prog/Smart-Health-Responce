import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_assets.dart';
import '../models/first_aid_guide_model.dart';

class FirstAidService {
  List<FirstAidGuide>? _cached;

  Future<List<FirstAidGuide>> loadGuides() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString(AppAssets.firstAidGuides);
    final list = jsonDecode(raw) as List;
    _cached = list
        .map((e) => FirstAidGuide.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cached!;
  }
}
