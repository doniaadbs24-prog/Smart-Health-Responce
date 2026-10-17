import 'package:flutter/foundation.dart';
import '../models/first_aid_guide_model.dart';
import '../services/service_locator.dart';

class FirstAidProvider extends ChangeNotifier {
  List<FirstAidGuide> _guides = [];
  bool _isLoading = false;

  List<FirstAidGuide> get guides => _guides;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    if (_guides.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    _guides = await sl.firstAid.loadGuides();
    _isLoading = false;
    notifyListeners();
  }
}
