class AuthException implements Exception {
  final String message;
  final String? code;
  AuthException(this.message, {this.code});
  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);
  @override
  String toString() => 'PermissionDeniedException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
  @override
  String toString() => 'CacheException: $message';
}
