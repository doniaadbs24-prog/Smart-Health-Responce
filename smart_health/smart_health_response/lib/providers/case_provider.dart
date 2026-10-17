import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';
import '../models/emergency_case_model.dart';
import '../services/service_locator.dart';

class CaseProvider extends ChangeNotifier {
  EmergencyCase? _current;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<EmergencyCase?>? _caseSub;

  EmergencyCase? get current => _current;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void watchCase(String caseId) {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _caseSub?.cancel();
    _caseSub = sl.cases.watchCase(caseId).listen(
      (c) {
        _current = c;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateStatus(CaseStatus status) async {
    if (_current == null) return;
    await sl.cases.updateStatus(_current!.caseId, status);
  }

  void clear() {
    _caseSub?.cancel();
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _caseSub?.cancel();
    super.dispose();
  }
}
