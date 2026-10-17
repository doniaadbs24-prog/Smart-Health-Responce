import 'package:uuid/uuid.dart';

class Helpers {
  Helpers._();

  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  static String shortId(String id, {int length = 6}) =>
      id.length <= length ? id : id.substring(0, length).toUpperCase();
}
