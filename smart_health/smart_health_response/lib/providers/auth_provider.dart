import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = sl.auth;
  StreamSubscription<UserModel?>? _authSub;

  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _user;
  bool get isAuthenticated => _user != null;
  UserRole? get role => _user?.userType;

  AuthProvider() {
    _authSub = _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _auth.signIn(email, password);
      _error = null;
      await sl.audit.log(
        userId: _user!.userId,
        action: AuditActionType.login,
        resourceType: 'auth',
        resourceId: _user!.userId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String phone,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      _user = await _auth.signUp(
        email: email,
        phone: phone,
        fullName: fullName,
        password: password,
        role: role,
      );
      _error = null;
      await sl.audit.log(
        userId: _user!.userId,
        action: AuditActionType.dataModification,
        resourceType: 'user',
        resourceId: _user!.userId,
        details: 'signup as ${role.name}',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    final uid = _user?.userId;
    await _auth.signOut();
    _user = null;
    notifyListeners();
    if (uid != null) {
      await sl.audit.log(
        userId: uid,
        action: AuditActionType.logout,
        resourceType: 'auth',
        resourceId: uid,
      );
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordReset(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String code) async {
    _setLoading(true);
    try {
      return await _auth.verifyOtp(code);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> emergencyAccess() async {
    _setLoading(true);
    try {
      _user = await _auth.emergencyAccess();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
